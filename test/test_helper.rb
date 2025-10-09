# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "finest/builder"
require "minitest/autorun"
require "json"
require "securerandom"
require "faker" # optional but recommended for realistic data

# Track total runtime (nanoseconds precision)
start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)

Minitest.after_run do
  end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
  duration_ns = end_time - start_time
  puts "\n⏱️  Total test suite runtime:"
  puts "   • #{duration_ns} ns"
  puts "   • #{(duration_ns / 1_000_000.0).round(3)} ms"
  puts "   • #{(duration_ns / 1_000_000_000.0).round(6)} s"
end

##
# Utility method: Generate random JSON-like nested hashes and arrays.
# Useful for testing APIs, serialization, or complex nested parsing.
#
# @param depth [Integer] how deep the nested structures can go
# @return [Hash] a randomly generated hash structure
#
def random_json(depth = 2)
  return [true, false, nil, rand(100), rand.to_s].sample if depth <= 0

  hash = {}
  rand(2..5).times do
    key = Faker::Lorem.unique.word.to_sym rescue SecureRandom.hex(2).to_sym
    value = case rand(5)
    when 0 then Faker::Number.number(digits: 3).to_s rescue rand(1000).to_s
    when 1 then Faker::Internet.email rescue SecureRandom.hex(4)
    when 2 then [random_json(depth - 1)]
    when 3 then SecureRandom.hex(4)
    else random_json(depth - 1)
    end
    hash[key] = value
  end
  hash
end



