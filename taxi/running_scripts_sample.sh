#!/bin/sh

echo "Start running sample_run.sh"
echo "Step 1/8: Filtering out outliers"
echo "ruby ./filter_traindata.rb"
ruby ./filter_traindata.rb
echo "Done"

echo "Step 2/8: Assigning clusters to the trajectory corrdinates"
echo "ruby ./assign_cluster.rb train"
ruby ./assign_cluster.rb train
echo "Done"
echo "ruby ./assign_cluster.rb test"
ruby ./assign_cluster.rb test
echo "Done"

echo "Step 3/8: Assigning grid location IDs to the trajectory corrdinates"
echo "ruby ./assign_grid.rb train"
ruby ./assign_grid.rb train
echo "Done"
echo "ruby ./assign_grid.rb test"
ruby ./assign_grid.rb test
echo "Done"

echo "Step 4/8: Formatting categorical features"
echo "ruby ./discretized_feat_generator.rb"
ruby ./discretized_feat_generator.rb
echo "Done"

echo "Step 5/8: Running random forest classifier"
echo "python ./runrf.py"
python ./runrf.py
echo "Done"

echo "Step 6/8: Running deep neural net classifier"
echo "python ./rundnn.py"
python ./rundnn.py
echo "Done"

echo "Step 7/8: Running lazy path finder algorithm"
echo "ruby ./run_lazy_path_finder.rb"
ruby ./run_lazy_path_finder.rb
echo "Done"

echo "Step 8/8: Postprocessing prediction results"
echo "ruby ./supervised_classification_postprocessor.rb rf_25p_prediction_result.dat rf_25p_final_output.csv"
ruby ./supervised_classification_postprocessor.rb rf_25p_prediction_result.dat rf_25p_final_output.csv
echo "Done"
echo "./supervised_classification_postprocessor.rb dnn_05p_prediction_result.dat dnn_05p_final_output.csv"
ruby ./supervised_classification_postprocessor.rb dnn_05p_prediction_result.dat dnn_05p_final_output.csv
echo "Done"
echo "./lazy_path_finder_postprocessor.rb matched_geo_endpoints_less_than50.csv lazy_final_output.csv"
ruby ./lazy_path_finder_postprocessor.rb matched_geo_endpoints_less_than50.csv lazy_final_output.csv
echo "Done"
echo "ruby ./get_weighted_average_corrdinates.rb dnn_05p_final_output.csv lazy_final_output.csv 1 9 dnn05p_lazylessthan50_1_9_combined.csv"
ruby ./get_weighted_average_corrdinates.rb dnn_05p_final_output.csv lazy_final_output.csv 1 9 dnn05p_lazylessthan50_1_9_combined.csv
echo "Done"
echo "Finished running sample_run.sh"
