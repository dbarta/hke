require_relative '../app/jobs/hke/future_message_daily_scheduler_job'

# Use this file with the 'whenever' gem or Sidekiq-Cron for scheduling
# Example for Sidekiq-Cron:
# Sidekiq::Cron::Job.create(
#   name: 'Future Message Daily Scheduler - every day at midnight',
#   class: 'Hke::FutureMessageDailySchedulerJob',
#   cron: '0 0 * * *'
# )

# If using the 'whenever' gem:
# every 1.day, at: '12:00 am' do
#   runner "Hke::FutureMessageDailySchedulerJob.perform_async"
# end
