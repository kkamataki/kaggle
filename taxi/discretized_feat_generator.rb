#!/usr/local/bin/ruby

require './feat_id_mapper.rb'

converted_feat_ids = feat_id_mapper("filtered_train.csv","test.csv")

input_pair = {:train=>"cluster_converted_train_supervised.csv",
              :test=>"cluster_converted_test_supervised.csv"}

output_pair = {:train=>"discretized_train_supervised.csv",
               :test=>"discretized_test_supervised.csv"}

input_pair.each_pair do |k,v|

  output_file = open(output_pair[k], 'w')
  open(v) do |line|
    output_file.puts line.gets
    line.read.split("\n").each do |entry|

      features = entry.chomp.split(",")

      tmp_array = [
        features[0].gsub!("\"","").to_i,
        converted_feat_ids[:CALL_TYPE][features[1]],
        converted_feat_ids[:ORIGIN_CALL][features[2]],
        converted_feat_ids[:ORIGIN_STAND][features[3]],
        converted_feat_ids[:TAXI_ID][features[4]],
        features[5].gsub!("\"","").to_i,
        converted_feat_ids[:DAY_TYPE][features[6]],
        converted_feat_ids[:MISSING_DATA][features[7]],
        features[8].gsub!("\"","").to_i
      ]

      if k == :train
        tmp_array.push(features[9].gsub!("\"","").to_i)
      end

      output_file.puts tmp_array.join(",")
    end
  end

  output_file.close
end
