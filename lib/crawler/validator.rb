module Crawler
  # used for manual validation results of crawlers with python results
  # I know it's shitty, but it's tests :)
  class Validator
    def initialize(batch_id)
      @batch_id = batch_id
    end

    def check
      storage = Crawler::RedisStorage.new(@batch_id)
      legacy_results = JSON.parse(storage.legacy_results)
      legacy_results.shift
      old = {}
      legacy_results.each do |r|
        old[r.shift] = r
      end

      new_r = {}
      storage.all.each do |job_id, results|
        results.each do |r|
          rr = Crawler::SMF.new(r.symbolize_keys).format.to_a
          new_r[rr.shift] = rr
        end
      end
      full_fail = false
      new_r.each do |k, v|
        puts "checking #{k}"
        unless old[k]
          full_fail = true
          puts "no match for #{k} in old results"
          next
        end
        old[k].each_with_index do |val, index|
          next if index == 7 #description
          if index == 8 || index == 9
            if val.to_f != v[index].to_f
              puts "mismatch index #{index}"
              puts "old: '#{val}'"
              puts "new: '#{v[index]}'"
            end
          elsif (15..19).include?(index)
            if !v[index].empty? && val != v[index]
              puts "mismatch index #{index}"
              puts "old: '#{val}'"
              puts "new: '#{v[index]}'"
            end
          elsif val != v[index]
            puts "mismatch index #{index}, old: '#{val}', new: '#{v[index]}'"
            ap v
            ap old[k]
          end
        end
      end

      old.each do |k, v|
        puts "reverse checking #{k}"
        next if v[1].empty?
        unless new_r[k]
          full_fail = true
          puts "no match for #{k} in new results"
          next
        end
      end

      if full_fail
        old.values.each_with_index do |val, index|
          ap "new:"
          ap new_r.values[index]
          ap "old:"
          ap val
        end
      end
    end
  end
end
