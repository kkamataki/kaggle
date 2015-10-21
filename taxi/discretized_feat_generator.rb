#!/usr/local/bin/ruby

require './feat_id_mapper.rb'

converted_feat_ids = feat_id_mapper("filtered_train.csv","test.csv")

input_pair = {:train=>"cluster_converted_train_supervised.csv",
              :test=>"cluster_converted_test_supervised.csv"}

output_pair = {:train=>"discretized_train_supervised.csv",
               :test=>"discretized_test_supervised.csv"}

input_pair.each_pair do |k,v|

  f = open(output_pair[k], 'w')
  open(v) do |l|
    f.puts l.gets
    l.read.split("\n").each do |rest|

      dat = rest.chomp.split(",")

      tmp_array = [
      dat[0].gsub!("\"","").to_i,
      converted_feat_ids[:CALL_TYPE][dat[1]],
      converted_feat_ids[:ORIGIN_CALL][dat[2]],
      converted_feat_ids[:ORIGIN_STAND][dat[3]],
      converted_feat_ids[:TAXI_ID][dat[4]],
      dat[5].gsub!("\"","").to_i,
      converted_feat_ids[:DAY_TYPE][dat[6]],
      converted_feat_ids[:MISSING_DATA][dat[7]],
      dat[8].gsub!("\"","").to_i
      ]

      if k == :train
        tmp_array.push(dat[9].gsub!("\"","").to_i)
      end

      f.puts tmp_array.join(",")
    end
  end

  f.close
end
