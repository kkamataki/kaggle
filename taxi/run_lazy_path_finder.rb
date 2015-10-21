#!/usr/local/bin/ruby

def construct_training_path_set(filename)
  training_path_set = {}
  open(filename) do |l|
    #skip header
    l.gets
    #iterate through the entire training set and get samples starting from same the grid
    l.read.split("\n").each do |rest|
      grids = rest.split(",")
      start_grid_id = grids[0]
      training_path_set.key?(start_grid_id)? training_path_set[start_grid_id].push(grids): training_path_set[start_grid_id] = [grids]
    end
  end
  training_path_set
end

def find_best_geo(partial_trajectory, training_path_set)

  start_id = partial_trajectory[0]
  training_candidates = Marshal.load(Marshal.dump(training_path_set[start_id]))
  training_candidates = [] if training_candidates == nil

  partial_trajectory.each_with_index do |val, idx|
    break if training_candidates.size < 50
    training_candidates.delete_if{|x| x[idx] != val}
  end

  result_geo_points = []
  training_candidates.each do |x|
    result_geo_points.push(x[-1])
  end

  return result_geo_points
end

f = open('matched_geo_endpoints_less_than50.csv','w')
f.puts "End_locs_in_training_data"

training_path_set = construct_training_path_set("grid_converted_train_lazy.csv")

open("grid_converted_test_lazy.csv") do |l|
  #skip header
  l.gets
  l.read.split("\n").each do |rest|
    tmp_result = find_best_geo(rest.split(","),training_path_set)
    f.puts tmp_result.join(",")
  end
end

f.close
