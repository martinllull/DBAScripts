/* Generate disable */
SELECT 'EXEC msdb.dbo.sp_update_job @job_name = '''+name+''', @enabled = 0'
FROM msdb.dbo.sysjobs;

/* Generate enable */
SELECT 'exec msdb.dbo.sp_update_job @job_name = '''+name+''', @enabled = 1'
FROM msdb.dbo.sysjobs;
