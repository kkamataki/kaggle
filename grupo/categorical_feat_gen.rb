#!/usr/bin/env ruby

(3..9).each do |w|
  (2..5).each do |v|
    cmd = "cat data/train_clinetid_modified_week#{w}.csv | cut -d ',' -f#{v} | sort | uniq > data/week#{w}_feat#{v}_uniq.txt"
    p `#{cmd}`
    cmd = "cat data/train_clinetid_modified_week#{w}.csv | cut -d ',' -f#{v} > data/week#{w}_feat#{v}_full.txt"
    p `#{cmd}`

    id_idx = {}
    open("data/week#{w}_feat#{v}_uniq.txt").each_with_index do |x, y|
      id_idx[x.chomp] = y.to_s
    end

    f = open("data/converted_week#{w}_feat#{v}.txt", "w")
    open("data/week#{w}_feat#{v}_full.txt").each do |x|
      f.puts id_idx[x.chomp]
    end
    f.close
  end
end
