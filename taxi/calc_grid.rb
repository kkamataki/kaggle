#!/usr/local/bin/ruby

def calc_grid(long, lat)

#-8.8 <= longitude <= -7.3 && 40.5 <= latitude <= 42
raise "Longitude or Latitude out of range " if (long < -8.8 || long > -7.3 || lat < 40.5 || lat > 42)

#each return 0 <-> 1999
  long_idx = ((long+8.8)*1333).floor
  lat_idx =  ((lat-40.5)*1333).floor
  return long_idx + 2000 * lat_idx
end

def from_grid_to_longlat(idx)
  long_idx = idx % 2000
  lat_idx = idx / 2000

  long = -8.8 + 0.00075 * long_idx
  lat = 40.5 + 0.00075 * lat_idx
  return {:long => long, :lat => lat}
end
