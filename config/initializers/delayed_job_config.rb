
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.default_priority = 10
Delayed::Worker.max_run_time = 5.hours 
Delayed::Worker.delay_jobs = !Rails.env.test? # in test, do jobs immediately
