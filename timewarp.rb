require 'concurrent'
require 'benchmark'

class Timewarp
  def initialize(pool_size: 10)
    @pool = Concurrent::FixedThreadPool.new(pool_size)
  end

  def run(work, tasks)
    time = Benchmark.measure do
      tasks.times { work.call }
    end
    time.real
  end

  def thread(work, tasks)
    time = Benchmark.measure do
      tasks.times.map { Thread.new { work.call } }.each(&:join)
    end
    time.real
  end

  def thread_pool(work, tasks)
    latch = Concurrent::CountDownLatch.new(tasks)
    time = Benchmark.measure do
      tasks.times do
        @pool.post do
          work.call
          latch.count_down
        end
      end
      latch.wait
    end
    time.real
  end

  def process(work, tasks)
    tasks_per_process = tasks / 2
    time = Benchmark.measure do
      2.times.map do
        Process.fork do
          pool = Concurrent::FixedThreadPool.new(10)
          latch = Concurrent::CountDownLatch.new(tasks_per_process)
          tasks_per_process.times do
            pool.post do
              work.call
              latch.count_down
            end
          end
          latch.wait
          pool.shutdown
          pool.wait_for_termination
        end
      end.each do |pid|
        Process.wait(pid)
      end
    end
    time.real
  end

  def shutdown
    @pool.shutdown
    @pool.wait_for_termination
  end
end

small_work = -> { sleep(0.1); 100000.times { "work".reverse } }
large_work = -> { sleep(1); 1000000.times { "work".reverse } }
small_tasks = 50
large_tasks = 200

tw = Timewarp.new

puts "Running #{small_tasks} small tasks..."
puts "Run: #{tw.run(small_work, small_tasks)} seconds"
puts "Thread: #{tw.thread(small_work, small_tasks)} seconds"
puts "Thread Pool: #{tw.thread_pool(small_work, small_tasks)} seconds"
puts "Process: #{tw.process(small_work, small_tasks)} seconds"

puts "Running #{large_tasks} large tasks..."
puts "Run: #{tw.run(large_work, large_tasks)} seconds"
puts "Thread: #{tw.thread(large_work, large_tasks)} seconds"
puts "Thread Pool: #{tw.thread_pool(large_work, large_tasks)} seconds"
puts "Process: #{tw.process(large_work, large_tasks)} seconds"

tw.shutdown
