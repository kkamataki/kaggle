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

def generate_feat(n_week):

  df = pd.read_csv("data/train_clinetid_modified_week"+str(n_week)+".csv", header=None)
  n_row = df.shape[0]

  data = np.zeros((n_row,56))
  data[:,0] = df.ix[:,0]
  data[:,1] = df.ix[:,6]
  data[:,2] = df.ix[:,7]
  data[:,3] = df.ix[:,8]
  data[:,4] = df.ix[:,9]

  labels = np.zeros(n_row)
  labels = df.ix[:,10]

  for i in range(2,7):
    print(i)
    data_tmp = pickle.load(open('data/embedded_train_test_all_feat'+str(i)+
      '_week'+str(n_week)+'.p', 'rb'))
    data_tmp = data_tmp.reshape(n_row,10)

    start = (i-2)*10 + 5
    end = (i-1)*10 + 5
    data[:,start:end] = data_tmp

  data[:,55] = df.ix[:,10]
  data = pd.DataFrame(data)

  #print("generated data:" + str(data))
  print("data shape:"+str(data.shape))
  return data



data = generate_feat(3)
partial_data = data.sample(frac=0.01)

#print(partial_data)
#print(partial_data.shape)

training_data = partial_data.ix[:,0:54]
training_label = np.array(partial_data.ix[:,55])

def run_rf(**args):
  print("building random forest model:")
  rf_model = RandomForestRegressor()
  rf_model.fit(args['training_data'], args['training_label'])
  output = rf_model.predict(args['test_data'])
  pickle.dump(rf_model, open('rf_testmodel.p', 'wb'))
  output =  list(map(lambda e: round(e), output))
  print(output)
  pickle.dump(output, open('rf_output.p', 'wb'))
  return output

def run_xgb(**args):
  print("building xgb model:")
  xgb_model = XGBRegressor()
  xgb_model.fit(args['training_data'], args['training_label'])
  output = xgb_model.predict(args['test_data'])
  pickle.dump(xgb_model, open('xgb_testmodel.p', 'wb'))

  output = list(map(lambda e:round(e), output))
  print(output)
  pickle.dump(output, open('xgb_output.p', 'wb'))
  return output

def run_mlp(**args):

  print("building mlp model:")
  print(args['training_data'].shape[0])
  print(args['training_data'].shape[1])
  model = Sequential()
  model.add(Dense(output_dim=512, input_dim=args['training_data'].shape[1], activation='relu'))
  #model.add(Dense(output_dim=64, input_dim=128, activation='relu'))
  #model.add(Dense(output_dim=32, input_dim=64, activation='relu'))
  model.add(Dense(1))
  model.add(Activation('linear'))
  model.compile(loss='mse', optimizer='rmsprop')

  model.fit(args['training_data'], args['training_label'], nb_epoch=50, batch_size=512)

  #pickle.dump(model, open('mlp_testmodel.p', 'w'), protocol=4)
  json_string = model.to_json()
  open('mlp_model_architecture.json', 'w').write(json_string)
  model.save_weights('mlp_model_weights.h5', overwrite=True)

  #output = model.evaluate(args['test_data'], args['test_label'], batch_size=512)
  output = model.predict(args['test_data'], verbose=1, batch_size=512)
  output_int = list(map(lambda e:int(e), np.round(output)))
  pickle.dump(output_int, open('mlp_output.p', 'wb'), protocol=4)

  return output_int


#run_rf(training_data=training_data, training_label=training_label,
#    test_data=training_data, test_label=training_label)

#run_xgb(training_data=training_data, training_label=training_label,
#      test_data=training_data, test_label=training_label)

run_mlp(training_data=np.array(training_data), training_label=training_label,
      test_data=np.array(training_data), test_label=training_label)
