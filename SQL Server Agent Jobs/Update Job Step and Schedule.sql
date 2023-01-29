USE [msdb]
GO
EXEC msdb.dbo.sp_update_jobstep @job_name=N'<JobName>', @step_id=1 , 
		@command=N'<Command>'
GO

DECLARE @ScheduleID INT
SELECT @ScheduleID = schedule_id
FROM msdb.dbo.sysjobschedules JS
INNER JOIN msdb.dbo.sysjobs J ON JS.job_id = J.job_id
WHERE J.name = '<JobName>';

--EXEC msdb.dbo.sp_attach_schedule @job_name=N'<JobName>',@schedule_id=@ScheduleID;
EXEC msdb.dbo.sp_update_schedule @schedule_id=@ScheduleID, @new_name=N'<ScheduleName>'
EXEC msdb.dbo.sp_update_schedule @schedule_id=@ScheduleID, 
		@freq_subday_type=8, 
		@freq_subday_interval=1
GO
