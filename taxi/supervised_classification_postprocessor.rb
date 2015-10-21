#!/usr/local/bin/ruby

raise "./supervised_classification_postprocessor.rb input_filename output_filename" if ARGV.size != 2

#read cluster data
cluster_longlat = []

open("50clusters.dat").each do |l|
  dat = l.chomp.split(" ").map{|x| x.to_f}
  cluster_longlat.push({:long => dat[0], :lat => dat[1]})
end

tid_set = []
open("sampleSubmission.csv").each do |x|
  tid = x.split(",")[0]
  tid_set.push(tid) if tid =~ /T\d/
end


f = open(ARGV[1],'w')
f.puts %Q{"TRIP_ID","LATITUDE","LONGITUDE"}

tid_idx = 0
#process clustering result
open(ARGV[0]).each do |x|

  idx = x.chomp.to_i
  f.print tid_set[tid_idx] + ","
  f.puts cluster_longlat[idx][:lat].to_s + "," + cluster_longlat[idx][:long].to_s
  tid_idx += 1
end

f.close
