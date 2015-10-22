#!/usr/local/bin/ruby

require './calc_grid.rb'

def calc_long_lat_mean(end_locs)

  long_sum = 0.0
  lat_sum = 0.0

  end_locs.each do |geo_idx|
    longlat = from_grid_to_longlat(geo_idx.to_i)
    long_sum += longlat[:long]
    lat_sum += longlat[:lat]
  end

  return {:long => long_sum/end_locs.size, :lat => lat_sum/end_locs.size}

end

tid_set = []
open("sampleSubmission.csv").each do |line|
  tid = line.split(",")[0]
  tid_set.push(tid) if tid =~ /T\d/
end


output_file = open(ARGV[1],'w')

output_file.puts %Q{"TRIP_ID","LATITUDE","LONGITUDE"}

input_file = ARGV[0]
open(input_file) do |line|

  #skip header
  line.gets

  tid_idx = 0
  #get result for each test trip
  line.read.split("\n").each do |grids|
    average_long_lat = calc_long_lat_mean(grids.split(","))

    output_file.print tid_set[tid_idx] + ","

    unless average_long_lat[:long].to_s == "NaN"
      output_file.puts average_long_lat[:lat].to_s + "," + average_long_lat[:long].to_s
    else
      ### When no end matching point was found in the training set, just print out the center of the city geo location
      ### in the sampleSubmission.csv at this moment  (Note: this is a rare case)
      output_file.puts "41.146504,-8.611317"
    end
    tid_idx += 1

  end

end

output_file.close
