/* Generate scripts to change the owner of SQL Server Agent Jobs */
DECLARE @NewOwner VARCHAR(256) = '<New_Job_Owner>'

SELECT	J.name AS [JobName],
		SUSER_SNAME(J.owner_sid) AS [JobOwner],
		'EXEC msdb.dbo.sp_update_job @job_name=N'''+J.name+''', @owner_login_name=N'''+@NewOwner+''';' AS [ScriptToChangeOwner]
FROM msdb.dbo.sysjobs J (NOLOCK)
WHERE SUSER_SNAME(J.owner_sid) IN ('<Previous_Job_Owner>')
GO