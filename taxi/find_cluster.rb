#!/usr/local/bin/ruby

def construct_cluster

  id = 0
  cluster_h = {}
  open("50clusters.dat").each do |centroid|
    c = centroid.chomp.split(" ")
    cluster_h[{:long => c[0].to_f, :lat => c[1].to_f}] = id
    id += 1
  end
  cluster_h

end

def find_cluster(long, lat, centroids)

  cluster = 0
  min_dist = Float::INFINITY
  centroids.each_pair do |k, v|
    tmp_dist = (k[:long] - long) ** 2 + (k[:lat] - lat) ** 2

    if tmp_dist < min_dist
      min_dist = tmp_dist
      cluster = v
    end
  end
  cluster

end
