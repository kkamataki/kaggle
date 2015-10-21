#This code used following URL as a usage reference
#https://github.com/matsuken92/Qiita_Contents/blob/master/chainer-MNIST/chainer-MNIST_forPubs.ipynb

import numpy as np
import pandas as pd
import pickle
from sklearn.datasets import fetch_mldata
from sklearn.preprocessing import OneHotEncoder
from chainer import cuda, Variable, FunctionSet, optimizers
import chainer.functions  as F
import sys

#fix random seed
np.random.seed(2015)

base_training_data = pd.read_csv('discretized_train_supervised.csv')
base_test_data  = pd.read_csv('discretized_test_supervised.csv')

base_training_data = base_training_data.sample(frac=0.05)
training_sampled_size = len(base_training_data)
test_size = len(base_test_data)

#feature preprocessing

enc = OneHotEncoder(categorical_features=[0,1,2,3,5,6,7], sparse=True)

training_data = pd.DataFrame({ "CALL_TYPE": base_training_data.CALL_TYPE,
                               "ORIGIN_CALL": base_training_data.ORIGIN_CALL,
                               "ORIGIN_STAND": base_training_data.ORIGIN_STAND,
                               "TAXI_ID": base_training_data.TAXI_ID,
                               "TIMESTAMP": base_training_data.TIMESTAMP,
                               "DAY_TYPE": base_training_data.DAY_TYPE,
                               "MISSING_DATA": base_training_data.MISSING_DATA,
                               "START_LOC": base_training_data.START_LOC
})

test_data = pd.DataFrame({ "CALL_TYPE": base_test_data.CALL_TYPE,
                           "ORIGIN_CALL": base_test_data.ORIGIN_CALL,
                           "ORIGIN_STAND": base_test_data.ORIGIN_STAND,
                           "TAXI_ID": base_test_data.TAXI_ID,
                           "TIMESTAMP": base_test_data.TIMESTAMP,
                           "DAY_TYPE": base_test_data.DAY_TYPE,
                           "MISSING_DATA": base_test_data.MISSING_DATA,
                           "START_LOC": base_test_data.START_LOC
})

encoded_data = enc.fit_transform(pd.concat([training_data, test_data]))

training_data = encoded_data.tocsr()[0:training_sampled_size,:].tocoo()
test_data = encoded_data.tocsr()[training_sampled_size:encoded_data.shape[0],:].tocoo()

training_label = np.array(base_training_data.END_LOC)

# training size
N = training_sampled_size

# num features
n_feat = training_data.shape[1]

###basic parameters
batchsize = 100
n_epoch   = 20
n_units   = 100

model = FunctionSet(l1=F.Linear(n_feat, n_units),
                    l2=F.Linear(n_units, n_units),
                    l3=F.Linear(n_units, 50))

def forward(x_data, y_data, train=True):
    x, t = Variable(x_data), Variable(y_data)
    h1 = F.dropout(F.relu(model.l1(x)),  train=train)
    h2 = F.dropout(F.relu(model.l2(h1)), train=train)
    y  = model.l3(h2)
    return F.softmax_cross_entropy(y, t), F.accuracy(y, t)

def make_prediction(x_data, train=False):
    x = Variable(x_data)
    h1 = F.dropout(F.relu(model.l1(x)),  train=train)
    h2 = F.dropout(F.relu(model.l2(h1)), train=train)
    y  = model.l3(h2)
    return y.data.argmax(axis=1)

optimizer = optimizers.Adam()
optimizer.setup(model.collect_parameters())

train_loss = []
train_acc  = []

l1_W = []
l2_W = []
l3_W = []

for epoch in xrange(1, n_epoch+1):
    print 'epoch', epoch

    # training
    perm = np.random.permutation(N)
    sum_accuracy = 0
    sum_loss = 0
    for i in xrange(0, N, batchsize):

        x_batch = training_data.todense()[perm[i:i+batchsize]]
        y_batch = training_label[perm[i:i+batchsize]]
        x_batch = np.array(x_batch)

        optimizer.zero_grads()
        loss, acc = forward(x_batch, y_batch)
        loss.backward()
        optimizer.update()
        sum_loss     += float(cuda.to_cpu(loss.data)) * batchsize
        sum_accuracy += float(cuda.to_cpu(acc.data)) * batchsize

    print 'train mean loss={}, accuracy={}'.format(sum_loss / N, sum_accuracy / N)

    train_loss.append(sum_loss / N)
    train_acc.append(sum_accuracy / N)

    # prediction
    prediction_result = make_prediction(np.array(test_data.todense()), train=False)

    # keep over-writing latest prediction result
    f = open('dnn_05p_prediction_result.dat','w')
    for result in prediction_result:
      f.write(str(result)+"\n")
    f.close

    print prediction_result

    l1_W.append(model.l1.W)
    l2_W.append(model.l2.W)
    l3_W.append(model.l3.W)

