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

week10_feat_mat = np.zeros((3538385,4))
week11_feat_mat = np.zeros((3460866,4))

addition_times = 0
for i in range(3,10): #training
  addition_times += 1.0
  for j in range(10,12): #test
    for k in range(0,4): #feat_id (0..3)
      input_feat_filename = "_".join(['mlp_output', str(i), str(j), str(k), '.p'])
      print(input_feat_filename)
      f = pickle.load(open(input_feat_filename,'rb'))
      if (j == 10):
        f=np.array(f).reshape((3538385,))
        week10_feat_mat[:,k] += f
      elif (j == 11):
        f=np.array(f).reshape((3460866,))
        week11_feat_mat[:,k] += f

#take average
week10_feat_mat /= addition_times
week11_feat_mat /= addition_times

week10_feat_mat[:,0] = np.around(week10_feat_mat[:,0])
week11_feat_mat[:,0] = np.around(week11_feat_mat[:,0])
week10_feat_mat[:,2] = np.around(week10_feat_mat[:,2])
week11_feat_mat[:,2] = np.around(week11_feat_mat[:,2])

#np.set_printoptions(threshold=np.nan)
#print(np.mean(week10_feat_mat[:,2]))
#print(np.mean(week11_feat_mat[:,2]))

pickle.dump(week10_feat_mat, open('data/test_week10_additional_4_feats.p', 'wb'), protocol=4)
pickle.dump(week11_feat_mat, open('data/test_week11_additional_4_feats.p', 'wb'), protocol=4)
