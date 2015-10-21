#!/usr/local/bin/ruby

last_loc_cnt = {}

total_last_loc_cnt = 0.0
open("cluster_converted_train_supervised.csv").each do |x|
  last_loc = x.chomp.split(",")[-1]
  last_loc_cnt.key?(last_loc)? last_loc_cnt[last_loc] += 1: last_loc_cnt[last_loc] = 1
  total_last_loc_cnt += 1
end

sorted_last_loc_cnt = last_loc_cnt.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }

#read cluster info
$cluster_h = {}

#construct cluster
id = 0
cluster_h = {}
open("50clusters.dat").each do |x|
  dat = x.chomp.split(" ")
  cluster_h[id] = {:long => dat[0].to_f, :lat => dat[1].to_f}
  id += 1
end

#Print top N cluster info
tmp_loc_sum = 0
N = ARGV[0].to_i
sorted_last_loc_cnt[0..(N-1)].each do |x|
  idx = x[0].gsub("\"","").to_i
  puts cluster_h[idx][:lat].to_s + "," + cluster_h[idx][:long].to_s
  tmp_loc_sum += x[1]
end

puts "Top #{N} end points count for " + ((tmp_loc_sum/total_last_loc_cnt.to_f)*100.0).floor.to_s + " % of the entire data"
