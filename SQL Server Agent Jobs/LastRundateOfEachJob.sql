USE [msdb]
GO
SELECT J.[name] AS JobName,
MAX(msdb.dbo.agent_datetime(run_date, run_time)) AS [RunDateTime],
CASE JH.run_status WHEN 0 THEN 'Failed'
WHEN 1 THEN 'Success'
WHEN 2 THEN 'Retry'
WHEN 3 THEN 'Canceled'
WHEN 4 THEN 'In progress'
END AS [Status]
FROM msdb.dbo.sysjobs J (NOLOCK)
LEFT JOIN msdb.dbo.sysjobhistory JH (NOLOCK)
ON JH.job_id = J.job_id AND JH.step_id = 0
WHERE J.name LIKE ('%<job_name>%')
GROUP BY J.[name], JH.run_status
ORDER BY J.[name]