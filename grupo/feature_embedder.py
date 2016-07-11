#!/usr/bin/env python

'''
Sample code to convert 5th feature set of the 1st week training data
converting 269683 categorical features into 16 dimensional vector for
11165208 instances
'''

import numpy as np
import pickle
from keras.layers.embeddings import Embedding
from keras.models import Sequential

def embed_features(**args):
  print(args['input_file'])
  print(args['output_file'])
  input_array = np.zeros((81179715, 1))
  with open(args['input_file']) as f:
    for i, line in enumerate(f):
      input_array[i]=int(line)

  vocab_size = max(input_array)[0] + 1
  model = Sequential()
  model.add(Embedding(vocab_size, 10, input_length=1))
  model.compile('rmsprop', 'mse')
  output_array = model.predict(input_array)
  assert output_array.shape == (81179715, 1, 10)

  #with open(args['output_file'], mode='wb') as f:
  #pickle.dump(output_array, f, protocol=4)

  weeks_items = [11165207,11009593,10615397, 10191837,10382849,10406868,10408713,3538385,3460866]
  tmp_week_idx = 3
  tmp_sum = 0

  for i in weeks_items:
    print (str(tmp_sum) + ":" + str(tmp_sum + i))
    pickle.dump(output_array[tmp_sum:(tmp_sum+i)], open(args['output_file']+'_week'+
      str(tmp_week_idx)+'.p', 'wb'), protocol=4)
    tmp_sum += i
    tmp_week_idx += 1





#for w in range(3,10):
for v in range(2,7):
  v = str(v)
  embed_features(input_file="data/train_test_clientid_modified_all_feat"+v+".csv",
    output_file="data/embedded_train_test_all_feat"+v)

