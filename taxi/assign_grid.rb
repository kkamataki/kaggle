#!/usr/local/bin/ruby

require "./calc_grid.rb"

#Should be "train" or "test"
type = ARGV[0]

lazy_header = ""
input_file = ""

case type
  when 'train'
    lazy_header = %Q{PATH"}
    input_file = "filtered_train.csv"
  when 'test'
    lazy_header = %Q{"PATH"}
    input_file = "test.csv"
  else
    raise "Usage:./assign_grid.rb [train|test]"
end

f = open("grid_converted_#{type}_lazy.csv",'w')

open(input_file) do |l|

  f.puts lazy_header

  #skip header
  l.gets
  l.read.split("\n").each do |rest|

    #geoloc feat
    geo_dat = rest.chomp.split("\"")[-1].gsub(/^\[\[|\]\]$/,"").split("],[")

    #remove consecutive same grid ids to make the trajectory shape clear
    grid_tmp_a = []
    prev_grid = nil
    geo_dat.each do |x|
      y = x.split(",")
      grid = calc_grid(y[0].to_f,y[1].to_f)

      if grid != prev_grid
        grid_tmp_a.push(grid)
      end

      prev_grid = grid
    end

    f.puts grid_tmp_a.join(",")

  end

end

f.close
