USE [ReportServer]
GO

SELECT sj.[name] AS [JobName]
	,c.[Name] AS [ReportName]
	,C.Path AS ReportPath
	,Su.Description AS SubscriptionName
	,su.LastStatus
	,su.LastRunTime
	,rs.SUBSCRIPTIONID
	,sj.JOB_ID
	,c.ComponentID
	,CASE 
		WHEN su.DataSettings IS NULL
			AND EventType = 'TimedSubscription'
			THEN 'Standard'
		WHEN su.DataSettings IS NOT NULL
			AND EventType = 'TimedSubscription'
			THEN 'Data Driven'
		END SubscriptionType
FROM msdb..sysjobs AS sj
LEFT JOIN ReportServer..ReportSchedule AS rs ON sj.[name] = CAST(rs.ScheduleID AS NVARCHAR(128))
LEFT JOIN ReportServer..Subscriptions AS su ON rs.SubscriptionID = su.SubscriptionID
LEFT JOIN ReportServer..[Catalog] c ON su.Report_OID = c.ItemID
WHERE --c.[Name] = 'DAILYETLEXECUTIONREPORT'
su.LastStatus LIKE ('%Failure writing%')
ORDER BY --[ReportName]
su.LastRunTime DESC;
GO