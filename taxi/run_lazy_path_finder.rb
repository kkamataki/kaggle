#!/usr/local/bin/ruby

def construct_training_path_set(filename)
  training_path_set = {}
  open(filename) do |line|
    #skip header
    line.gets
    #iterate through the entire training set and get samples starting from same the grid
    line.read.split("\n").each do |entry|
      grids = entry.split(",")
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
    training_candidates.delete_if{|trajectory| trajectory[idx] != val}
  end

  result_geo_points = []
  training_candidates.each do |end_points|
    result_geo_points.push(end_points[-1])
  end

  return result_geo_points
end

output_file = open('matched_geo_endpoints_less_than50.csv','w')
output_file.puts "End_locs_in_training_data"

training_path_set = construct_training_path_set("grid_converted_train_lazy.csv")

open("grid_converted_test_lazy.csv") do |line|
  #skip header
  line.gets
  line.read.split("\n").each do |entry|
    tmp_result = find_best_geo(entry.split(","),training_path_set)
    output_file.puts tmp_result.join(",")
  end
end

output_file.close
