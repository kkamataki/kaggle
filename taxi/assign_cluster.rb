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

output_file = open("cluster_converted_#{type}_supervised.csv",'w')
cluster_centroids = construct_cluster()

open(input_file) do |line|

  output_file.puts supervised_header

  #skip header
  line.gets

  line.read.split("\n").each do |entry|
    non_geo_feat = entry.chomp.split(",")[0..7]

    #geoloc feat
    geo_feat = entry.chomp.split("\"")[-1].gsub(/^\[\[|\]\]$/,"").split("],[")

    cluster_tmp_a = []

    #process only start point and end point cluster of each trip
    [geo_feat[0], geo_feat[-1]].each do |coordinate|
      c = coordinate.split(",")
      cluster = find_cluster(c[0].to_f, c[1].to_f, cluster_centroids)
      cluster_tmp_a.push(cluster)
    end

    if type == "train"
      output_file.puts non_geo_feat.join(",") + ",\"" + cluster_tmp_a[0].to_s + "\",\"" + cluster_tmp_a[-1].to_s + "\""
    elsif type == "test"
      output_file.puts non_geo_feat.join(",") + ",\"" + cluster_tmp_a[0].to_s + "\""
    end

  end
end

output_file.close
