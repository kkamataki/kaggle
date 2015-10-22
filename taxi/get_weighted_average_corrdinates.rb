#!/usr/local/bin/ruby

input_file_supervised = ARGV[0]
input_file_lazy = ARGV[1]
weight_for_first = ARGV[2].to_f
weight_for_second = ARGV[3].to_f
output_file_name = ARGV[4]

raise "./get_weighted_average_corrdinates.rb input_filename1 input_filename2 weight1 weight2 output_filename" if ARGV.size != 5

weight_sum = weight_for_first + weight_for_second
weighted_result = {}

[input_file_supervised, input_file_lazy].each do |file|
  open(file) do |line|
    #skip header
    line.gets
    line.read.split("\n").each do |entry|
      item = entry.split(",")
      ###item[0] = trip_id, item[1] = latitude, item[2] = longitude
      weighted_result.key?(item[0])? weighted_result[item[0]].push([item[1].to_f,item[2].to_f]): weighted_result[item[0]] = [[item[1].to_f ,item[2].to_f]]
    end
  end
end

output_file = open(output_file_name, 'w')
output_file.puts %Q{"TRIP_ID","LATITUDE","LONGITUDE"}

weighted_result.each_pair do |k,v|
  weighted_corrdinates =
  ((v[0][0] *weight_for_first + v[1][0] * weight_for_second) / weight_sum).to_s +
  "," + ((v[0][1] *weight_for_first + v[1][1] * weight_for_second) / weight_sum).to_s
  output_file.puts k + "," + weighted_corrdinates
end
