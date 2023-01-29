USE [msdb]
GO
SELECT J.name, JS.step_name, JS.command
FROM dbo.sysjobsteps JS (NOLOCK)
INNER JOIN dbo.sysjobs J (NOLOCK) ON J.job_id = JS.job_id
WHERE command LIKE ('%<Some_String>%')
ORDER BY J.name ASC
GO