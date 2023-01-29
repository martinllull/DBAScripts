SELECT step_id, step_name, subsystem, command, database_name,
CASE on_success_action
WHEN 1 THEN 'Quit with success'
WHEN 2 THEN 'Quit with error'
WHEN 3 THEN 'Go to the next step'
WHEN 4 THEN 'Go to the step '+CAST(on_success_step_id AS VARCHAR(3))
END AS on_success_action, 
CASE on_fail_action
WHEN 1 THEN 'Quit with success'
WHEN 2 THEN 'Quit with error'
WHEN 3 THEN 'Go to the next step'
WHEN 4 THEN 'Go to the step '+CAST(on_fail_step_id AS VARCHAR(3))
END AS on_fail_action
FROM msdb.dbo.sysjobsteps
WHERE job_id = '<job_id>';
GO

SELECT *
FROM msdb.dbo.sysjobschedules
WHERE job_id = '<job_id>';
GO

SELECT *
FROM msdb.dbo.sysschedules
WHERE schedule_id = id;
GO

SELECT *
FROM msdb.dbo.sysjobhistory
WHERE job_id = '<job_id>'
AND step_id = 0
ORDER BY run_date DESC, run_time DESC;
GO
