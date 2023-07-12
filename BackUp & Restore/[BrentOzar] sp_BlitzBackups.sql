/*
sp_BlitzBackups (https://www.brentozar.com/archive/2017/05/announcing-sp_blitzbackups-check-wreck/)

If one of your SQL Servers went down at some point over the last week:
	- What’s the most data you could have lost?
	- What’s the longest you would have been down for?

It looks at the local server’s backup history stored in the msdb database and returns 3 result sets.
	The first result set says, for each database that was backed up in the last week:
		- RPOWorstCaseMinutes – what’s the most amount of data you could have lost in the last week?
		- RTOWorstCaseMinutes – what’s the longest amount of time you’d have spent restoring? By default, this is only the length of time that your backups took – and in real life, sometimes your restores take longer than your backups (especially if you don’t have Instant File Initialization turned on)
	The second and third result sets give you deeper analysis about issues with your backups,
	plus sizes over time going back -1 month, -2 months, -3 months, and more.

Parameters
	- Want to analyze more or less time? Use the @HoursBack parameter, which defaults to 168 hours (1 week).
	- Want a more precise RTO? If you’ve done restore performance tuning, and you know how fast your full, diff, and log backups restore, use the @RestoreSpeedFullMBps (and diff and log). When you pass in these numbers, then we calculate RTO based on the file size / your throughput.
*/

/* One week */
sp_BlitzBackups
GO

/* One day */
sp_BlitzBackups @HoursBack = 24
GO

/* N number of days */
DECLARE @Days INT = 7
DECLARE @Hours INT

SELECT @Hours = @Days * 24

EXEC sp_BlitzBackups @HoursBack = @Hours
GO
