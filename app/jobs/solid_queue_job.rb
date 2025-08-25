class SolidQueueJob < ApplicationJob
  queue_as :default

  def perform
    puts "BEGIN JOB" * 10
    sleep(20)
    puts "END JOB" * 10
  end
end
