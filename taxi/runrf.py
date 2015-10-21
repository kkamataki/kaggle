import pandas as pd
import numpy as np
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import OneHotEncoder

#fix random seed
np.random.seed(2015)

base_training_data = pd.read_csv('discretized_train_supervised.csv')
base_test_data  = pd.read_csv('discretized_test_supervised.csv')

base_training_data = base_training_data.sample(frac=0.25)
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

training_label = base_training_data.END_LOC


########Build models
###Random Forest
rf_model = RandomForestClassifier()
rf_model.fit(training_data, training_label)

output = rf_model.predict(test_data)

f = open('rf_25p_prediction_result.dat','w')
for result in output:
  f.write(str(result)+"\n")
f.close
