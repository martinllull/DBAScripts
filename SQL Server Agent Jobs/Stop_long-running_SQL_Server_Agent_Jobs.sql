DECLARE @Duration_secs INT;
DECLARE @JobName SYSNAME;

DECLARE @LongRunningJobs TABLE(
      DurationSecs  INT     NOT NULL
    , JobName       SYSNAME NOT NULL
    , TSQLStatement NVARCHAR(300) NOT NULL
);

INSERT INTO @LongRunningJobs(DurationSecs, JobName, TSQLStatement)
SELECT DATEDIFF(ss, ja.start_execution_date, GETDATE()) AS Duration_secs
     , jobs.name AS JobName
     , 'EXEC msdb.dbo.sp_stop_job N''' + jobs.name + '''' AS TSQLStatement
FROM   msdb.dbo.sysjobs jobs
       LEFT JOIN msdb.dbo.sysjobactivity ja ON ja.job_id = jobs.job_id
            AND ja.start_execution_date IS NOT NULL
WHERE  stop_execution_date IS NULL;

SELECT * FROM @LongRunningJobs;
GO