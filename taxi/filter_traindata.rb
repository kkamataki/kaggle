#!/usr/local/bin/ruby

f = open("long_lat_1p.csv",'w')
f1 = open("long_1p.csv",'w')
f2 = open("lat_1p.csv",'w')
f3 = open("long_lat_filtered_1p.csv",'w')
f4 = open("filtered_train.csv",'w')

f.puts  "Longitude Latitude"
f1.puts "Longitude"
f2.puts "Latitude"
f3.puts "Longitude Latitude"

open("train.csv") do |l|

  #Process header
  f4.puts l.gets

  #Extract trajectory sequence
  l.read.split("\n").each do |rest|
    dat = rest.chomp.split("\"")[-1].gsub(/^\[\[|\]\]$/,"").split("],[")
    flag = true
    #Split each trajectory as y[0]=longitude and y[1]=latitude
    dat.each do |x|
      y = x.split(",")
      if (y[0].to_f < -8.8 || y[0].to_f > -7.3 || y[1].to_f < 40.5 || y[1].to_f > 42)
        flag = false
      end

      #Sample 1% of data
      if(rand < 0.01)
        f.puts (y[0].to_f.round(4).to_s + " " + y[1].to_f.round(4).to_s)
        f1.puts y[0].to_f.round(4)
        f2.puts y[1].to_f.round(4)
        #If the location is within the area to look into
        if (y[0].to_f > -8.8 && y[0].to_f < -7.3 && y[1].to_f > 40.5 && y[1].to_f < 42)
          f3.puts (y[0].to_f.round(4).to_s + " " + y[1].to_f.round(4).to_s)
        end
      end

    end

    if flag == true
      f4.puts rest
    end
  end
end

f.close
f1.close
f2.close
f3.close
f4.close
