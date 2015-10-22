#!/usr/local/bin/ruby

raise "./supervised_classification_postprocessor.rb input_filename output_filename" if ARGV.size != 2

#read cluster data
cluster_longlat = []

open("50clusters.dat").each do |line|
  centroid = line.chomp.split(" ").map{|x| x.to_f}
  cluster_longlat.push({:long => centroid[0], :lat => centroid[1]})
end

tid_set = []
open("sampleSubmission.csv").each do |line|
  tid = line.split(",")[0]
  tid_set.push(tid) if tid =~ /T\d/
end


output_file = open(ARGV[1],'w')
output_file.puts %Q{"TRIP_ID","LATITUDE","LONGITUDE"}

tid_idx = 0
#process clustering result
input_file = ARGV[0]
open(input_file).each do |line|

  cluster_id = line.chomp.to_i
  output_file.print tid_set[tid_idx] + ","
  output_file.puts cluster_longlat[cluster_id][:lat].to_s + "," + cluster_longlat[cluster_id][:long].to_s
  tid_idx += 1
end

output_file.close
