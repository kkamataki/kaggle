#!/usr/local/bin/ruby

file_long_lat = open("long_lat_1p.csv",'w')
file_long = open("long_1p.csv",'w')
file_lat = open("lat_1p.csv",'w')
file_long_lat_filtered = open("long_lat_filtered_1p.csv",'w')
file_filtered_train = open("filtered_train.csv",'w')

file_long_lat.puts  "Longitude Latitude"
file_long.puts "Longitude"
file_lat.puts "Latitude"
file_long_lat_filtered.puts "Longitude Latitude"

open("train.csv") do |line|

  #Process header
  file_filtered_train.puts line.gets

  #Extract trajector sequence
  line.read.split("\n").each do |entry|
    coordinates = entry.chomp.split("\"")[-1].gsub(/^\[\[|\]\]$/,"").split("],[")
    flag = true
    #Split each trajector as c[0]=longitude and c[1]=latitude
    coordinates.each do |coordinate|
      c = coordinate.split(",")
      if (c[0].to_f< -8.8 || c[0].to_f > -7.3 || c[1].to_f < 40.5 || c[1].to_f > 42)
        flag = false
      end

      #Sample 1% of coordinatesa
      if(rand < 0.01)
        file_long_lat.puts (c[0].to_f.round(4).to_s + " " + c[1].to_f.round(4).to_s)
        file_long.puts c[0].to_f.round(4)
        file_lat.puts c[1].to_f.round(4)
        #If the location is within the area to look into
        if (c[0].to_f > -8.8 && c[0].to_f < -7.3 && c[1].to_f > 40.5 && c[1].to_f < 42)
          file_long_lat_filtered.puts (c[0].to_f.round(4).to_s + " " + c[1].to_f.round(4).to_s)
        end
      end

    end

    if flag == true
      file_filtered_train.puts entry
    end
  end
end

file_long_lat.close
file_long.close
file_lat.close
file_long_lat_filtered.close
file_filtered_train.close
