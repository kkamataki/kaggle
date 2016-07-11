#!/usr/bin/env python

import pickle
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier
from sklearn.ensemble import RandomForestRegressor, ExtraTreesRegressor

from xgboost.sklearn import XGBClassifier
from xgboost.sklearn import XGBRegressor

from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from keras.layers.core import Activation, Dense
from keras.layers.normalization import BatchNormalization
from keras.layers.advanced_activations import PReLU

### Features to estimate
#Venta_uni_hoy — Sales unit this week (integer)
#Venta_hoy — Sales this week (unit: pesos)
#Dev_uni_proxima — Returns unit next week (integer)
#Dev_proxima — Returns next week (unit: pesos)

def generate_label(n_week, feat_id):

  filename = ""
  if n_week < 10:
    filename = "data/train_clinetid_modified_week"+str(n_week)+".csv"
  else:
    filename = "data/test_clinetid_modified_week"+str(n_week)+".csv"
  df = pd.read_csv(filename, header=None)

  n_row = df.shape[0]
  labels = np.zeros((n_row,1))
  labels = df.ix[:,6 + feat_id]
  return labels

def generate_feat(n_week):

  filename = ""
  if n_week < 10:
    filename = "data/train_clinetid_modified_week"+str(n_week)+".csv"
  else:
    filename = "data/test_clinetid_modified_week"+str(n_week)+".csv"
  df = pd.read_csv(filename, header=None)
  n_row = df.shape[0]
  data = np.zeros((n_row,50))
  for i in range(2,7):
    data_tmp = pickle.load(open('data/embedded_train_test_all_feat'+str(i)+
      '_week'+str(n_week)+'.p', 'rb'))
    data_tmp = data_tmp.reshape(n_row,10)

    start = (i-2)*10
    end = (i-1)*10
    data[:,start:end] = data_tmp

  data = pd.DataFrame(data)
  print("data shape:"+str(data.shape))
  return data

def combine_feat_label(data,labels):
  data = pd.DataFrame(data)
  labels = pd.DataFrame(labels)
  result = pd.concat([data, labels], axis=1, ignore_index=True)
  return pd.DataFrame(result)

def run_mlp(**args):

  print("building mlp model:")
  print(args['training_data'].shape[0])
  print(args['training_data'].shape[1])
  model = Sequential()
  model.add(Dense(output_dim=512, input_dim=args['training_data'].shape[1], activation='relu'))
  model.add(Dense(1))
  model.add(Activation('linear'))
  model.compile(loss='mse', optimizer='rmsprop')

  model.fit(args['training_data'], args['training_label'], nb_epoch=20, batch_size=512)

  json_string = model.to_json()
  open('mlp_model_architecture.json', 'w').write(json_string)
  model.save_weights(args['output_weight_filename'], overwrite=True)

  output = model.predict(args['test_data'], verbose=1, batch_size=512)

  if (args['output_type']=='int'):
    output_int = list(map(lambda e:int(e), np.round(output)))
    pickle.dump(output_int, open(args['output_feat_filename'], 'wb'), protocol=4)
    return output_int
  else:
    pickle.dump(output, open(args['output_feat_filename'], 'wb'), protocol=4)
    return output

for i in range(3,10): #training
  for j in range(10,12): #test
    for k in range(0,4): #feat_id (0..3)
      print('i:' + str(i) + ' j:' + str(j) + ' k:' + str(k))
      data = generate_feat(i)
      labels = generate_label(i, k)
      data = combine_feat_label(data,labels)
      partial_data = data.sample(frac=0.1)
      training_data = partial_data.loc[:,0:partial_data.shape[1]-2]
      training_label = partial_data.loc[:,partial_data.shape[1]-1]
      test_data = generate_feat(j)

      output_type = 'float'
      if(k == 0 or k == 2):
        output_type = 'int'

      output_weight_filename = "_".join(['mlp_model_weights', str(i), str(j), str(k), '.h5'])
      output_feat_filename = "_".join(['mlp_output', str(i), str(j), str(k), '.p'])

      run_mlp(training_data=np.array(training_data), training_label=training_label,
            test_data=np.array(test_data), output_type=output_type,
            output_weight_filename=output_weight_filename,
            output_feat_filename=output_feat_filename)



