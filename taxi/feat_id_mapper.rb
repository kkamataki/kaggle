#!/usr/local/bin/ruby

##want to convert "CALL_TYPE", "ORIGIN_CALL", "ORIGIN_STAND", "TAXI_ID", "DAY_TYPE", "MISSING_DATA" into discrete feat
#dat[1] => CALL_TYPE
#dat[2] => ORIGIN_CALL
#dat[3] => ORIGIN_STAND
#dat[4] => TAXI_ID
#dat[6] => DAY_TYPE
#dat[7] => MISSING_DATA

def original_feat_set_constructor(filename, original_feat_set)
  open(filename) do |l|
    l.gets
    l.read.split("\n").each do |rest|
      dat = rest.chomp.split(",")
      original_feat_set[:CALL_TYPE].push(dat[1])
      original_feat_set[:ORIGIN_CALL].push(dat[2])
      original_feat_set[:ORIGIN_STAND].push(dat[3])
      original_feat_set[:TAXI_ID].push(dat[4])
      original_feat_set[:DAY_TYPE].push(dat[6])
      original_feat_set[:MISSING_DATA].push(dat[7])
    end
  end
end


def feat_id_mapper(training_data_file, test_data_file)
  original_feat_set = {
    :CALL_TYPE => [],
    :ORIGIN_CALL => [],
    :ORIGIN_STAND => [],
    :TAXI_ID => [],
    :DAY_TYPE => [],
    :MISSING_DATA => []
  }

  original_feat_set_constructor(training_data_file, original_feat_set)
  original_feat_set_constructor(test_data_file, original_feat_set)

  original_feat_set.each_value do |v|
    v.sort!.uniq!
  end

  converted_feat_ids = {
    :CALL_TYPE => {},
    :ORIGIN_CALL => {},
    :ORIGIN_STAND => {},
    :TAXI_ID => {},
    :DAY_TYPE => {},
    :MISSING_DATA => {}
  }

  original_feat_set.each_pair do |k, v|
    v.each_with_index do |val, idx|
      converted_feat_ids[k][val] = idx
    end
  end
  converted_feat_ids
end

