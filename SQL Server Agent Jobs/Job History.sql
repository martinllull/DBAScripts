SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
USE [msdb]
GO

SELECT 
	j.name AS [JobName],
	s.step_id AS [Step],
	s.step_name AS [StepName],
	msdb.dbo.agent_datetime(run_date, run_time) AS [RunDateTime],
	((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) AS [RunDurationMinutes],
	CASE h.run_status 
	WHEN 0 THEN 'Failed'
	WHEN 1 THEN 'Succeeded'
	WHEN 2 THEN 'Retry'
	WHEN 3 THEN 'Canceled'
	WHEN 4 THEN 'In Progress'
	END
	AS [Status],
	h.message AS [Message]
FROM msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobsteps s 
 ON j.job_id = s.job_id
INNER JOIN msdb.dbo.sysjobhistory h 
 ON s.job_id = h.job_id 
 AND s.step_id = h.step_id 
 AND h.step_id <> 0
WHERE j.enabled = 1   --Only Enabled Jobs
--AND j.name IN ('job_name') --Uncomment to search for a single job
--AND msdb.dbo.agent_datetime(run_date, run_time) 
--BETWEEN '2022-06-23 00:00:00.000' and '2022-06-24 00:00:00.000'  --Uncomment for date range queries
ORDER BY JobName, RunDateTime DESC