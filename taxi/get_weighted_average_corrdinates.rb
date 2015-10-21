#!/usr/local/bin/ruby

f1 = ARGV[0]
f2 = ARGV[1]
weight_for_first = ARGV[2].to_f
weight_for_second = ARGV[3].to_f
output_file = ARGV[4]

raise "./get_weighted_average_corrdinates.rb input_filename1 input_filename2 weight1 weight2 output_filename" if ARGV.size != 5

weight_sum = weight_for_first + weight_for_second
result = {}

[f1, f2].each do |f|
  open(f) do |l|
    l.gets
    l.read.split("\n").each do |rest|
      dat = rest.split(",")
      result.key?(dat[0])? result[dat[0]].push([dat[1].to_f,dat[2].to_f]): result[dat[0]] = [[dat[1].to_f ,dat[2].to_f]]
    end
  end
end

f = open(output_file, 'w')
f.puts %Q{"TRIP_ID","LATITUDE","LONGITUDE"}

result.each_pair do |k,v|

  weighted_corrdinates =
  ((v[0][0] *weight_for_first + v[1][0] * weight_for_second) / weight_sum).to_s +
  "," + ((v[0][1] *weight_for_first + v[1][1] * weight_for_second) / weight_sum).to_s
  f.puts k + "," + weighted_corrdinates
end
