#!/usr/local/bin/ruby

require "./calc_grid.rb"

#Should be "train" or "test"
type = ARGV[0]

lazy_header = ""
input_file = ""

case type
  when 'train'
    lazy_header = %Q{"PATH"}
    input_file = "filtered_train.csv"
  when 'test'
    lazy_header = %Q{"PATH"}
    input_file = "test.csv"
  else
    raise "Usage:./assign_grid.rb [train|test]"
end

output_file = open("grid_converted_#{type}_lazy.csv",'w')

open(input_file) do |line|

  output_file.puts lazy_header

  #skip header
  line.gets
  line.read.split("\n").each do |entry|

    #geoloc feat
    geo_feat = entry.chomp.split("\"")[-1].gsub(/^\[\[|\]\]$/,"").split("],[")

    #remove consecutive same grid ids to make the trajectory shape clear
    grid_tmp_a = []
    prev_grid = nil
    geo_feat.each do |coordinate|
      c = coordinate.split(",")
      grid = calc_grid(c[0].to_f,c[1].to_f)

      if grid != prev_grid
        grid_tmp_a.push(grid)
      end

      prev_grid = grid
    end

    output_file.puts grid_tmp_a.join(",")

  end

end

output_file.close
