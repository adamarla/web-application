
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10.minutes
Delayed::Worker.delay_jobs = !Rails.env.test? # in test, do jobs immediately
