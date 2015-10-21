#!/usr/local/bin/ruby

require "./find_cluster.rb"

#Should be "train" or "test"
type = ARGV[0]

supervised_header = ""
input_file = ""

case type
  when 'train'
    supervised_header = %Q{"TRIP_ID","CALL_TYPE","ORIGIN_CALL","ORIGIN_STAND","TAXI_ID","TIMESTAMP","DAY_TYPE","MISSING_DATA","START_LOC","END_LOC"}
    input_file = "filtered_train.csv"
  when 'test'
    supervised_header = %Q{"TRIP_ID","CALL_TYPE","ORIGIN_CALL","ORIGIN_STAND","TAXI_ID","TIMESTAMP","DAY_TYPE","MISSING_DATA","START_LOC"}
    input_file = "test.csv"
  else
    raise "Usage:./assign_cluster.rb [train|test]"
end

f = open("cluster_converted_#{type}_supervised.csv",'w')
cluster_centroids = construct_cluster()

open(input_file) do |l|

  f.puts supervised_header

  #skip header
  l.gets

  l.read.split("\n").each do |rest|
    dat = rest.chomp.split(",")[0..7]

    #geoloc feat
    geo_dat = rest.chomp.split("\"")[-1].gsub(/^\[\[|\]\]$/,"").split("],[")

    cluster_tmp_a = []

    #process only start point and end point cluster of each trip
    [geo_dat[0], geo_dat[-1]].each do |x|
      y = x.split(",")
      cluster = find_cluster(y[0].to_f, y[1].to_f, cluster_centroids)
      cluster_tmp_a.push(cluster)
    end

    if type == "train"
      f.puts dat.join(",") + ",\"" + cluster_tmp_a[0].to_s + "\",\"" + cluster_tmp_a[-1].to_s + "\""
    elsif type == "test"
      f.puts dat.join(",") + ",\"" + cluster_tmp_a[0].to_s + "\""
    end

  end
end

f.close
