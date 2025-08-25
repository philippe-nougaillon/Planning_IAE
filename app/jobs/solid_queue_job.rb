class SolidQueueJob < ApplicationJob
  queue_as :default

  def perform
    puts "C" * 100
    sleep(20)
    puts "D" * 100
  end
end
