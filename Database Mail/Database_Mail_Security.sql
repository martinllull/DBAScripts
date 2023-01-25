--Lists information (except passwords) about Database Mail accounts.
EXEC msdb.dbo.sysmail_help_account_sp;
GO

--Lists information about one or more mail profiles.
EXEC msdb.dbo.sysmail_help_profile_sp;
GO

--Lists information about associations between Database Mail profiles and database principals.
EXEC msdb.dbo.sysmail_help_principalprofile_sp @profile_name = '<profile_name>';
GO

