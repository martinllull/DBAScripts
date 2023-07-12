SELECT r.session_id AS [SPID],
       r.command AS [Command],
	   DB_NAME(r.database_id) AS [DatabaseName],
       CONVERT(NUMERIC(10, 2), r.percent_complete) AS [PercentComplete],
       CONVERT(NUMERIC(10,2), r.total_elapsed_time / 1000.0 / 60.0) AS [ElapsedTime],
       CONVERT(VARCHAR(20), DATEADD(ms, r.estimated_completion_time, GETDATE()), 20) AS [EstimatedCompletionTime],
       CONVERT(NUMERIC(10, 2), r.estimated_completion_time/1000.0/60.0) AS [MinutesPending],
       CONVERT(NUMERIC(10,2), r.estimated_completion_time/1000.0/60.0/60.0) AS [HoursPending]
FROM  sys.dm_exec_requests r
WHERE r.command IN (
         'RESTORE VERIFYON', 'RESTORE DATABASE',
         'BACKUP DATABASE','RESTORE LOG','BACKUP LOG', 
         'RESTORE HEADERON', 'DbccFilesCompact')
GO