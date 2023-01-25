/* Stop Database Mail */
EXECUTE msdb.dbo.sysmail_stop_sp;
GO

/* Status of Database Mail */
EXECUTE msdb.dbo.sysmail_help_status_sp;
GO

/* Start Database Mail */
EXECUTE msdb.dbo.sysmail_start_sp;
GO