/* Generate script to delete SQL Server Agent Jobs with "SomeString" in the name */
SELECT 'EXEC msdb.dbo.sp_delete_job @job_name=N''' + J.name + ''', @delete_unused_schedule=1' AS DeleteCommand
FROM msdb.dbo.sysjobs J (NOLOCK)
WHERE J.name LIKE ('%SomeString%')
ORDER BY J.name;

/* Generate script to delete SQL Server Agent Jobs owned by "SomeUser" */
SELECT 'EXEC msdb.dbo.sp_delete_job @job_name=N''' + J.name + ''', @delete_unused_schedule=1' AS DeleteCommand
FROM msdb.dbo.sysjobs J (NOLOCK)
WHERE J.owner_sid = SUSER_SID('SomeUser')
ORDER BY J.name;

/* Another option: using the parameter @job_id */
SELECT 'EXEC msdb.dbo.sp_delete_job @job_id=N''' + CONVERT(VARCHAR(MAX), J.job_id) + ''', @delete_unused_schedule=1' AS DeleteCommand
FROM msdb.dbo.sysjobs J (NOLOCK)
WHERE J.name LIKE ('%SomeString%')
ORDER BY J.name;

SELECT 'EXEC msdb.dbo.sp_delete_job @job_id=N''' + CONVERT(VARCHAR(MAX), J.job_id) + ''', @delete_unused_schedule=1' AS DeleteCommand
FROM msdb.dbo.sysjobs J (NOLOCK)
WHERE J.owner_sid = SUSER_SID('SomeUser')
ORDER BY J.name;