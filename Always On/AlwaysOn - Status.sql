SELECT	replica_server_name as servername,
		db_name(database_id) as database_name,
		is_local,
		cs.is_failover_ready,
		synchronization_health_desc,
		database_state_desc,
		last_sent_time,
		last_received_time,
		last_hardened_time,
		last_redone_time,
		log_send_queue_size,
		log_send_rate,
		redo_queue_size,
		redo_rate,
		end_of_log_lsn,
		last_commit_time,
		last_commit_lsn,
		low_water_mark_for_ghosts,
		is_suspended,
		suspend_reason_desc,
		rep_state.recovery_lsn,
		rep_state.truncation_lsn,
		last_sent_lsn,
		last_received_lsn,
		last_hardened_lsn,
		last_redone_lsn
FROM	sys.dm_hadr_database_replica_states rep_state (NOLOCK)
INNER JOIN sys.availability_replicas ar (NOLOCK) ON rep_state.replica_id = ar.replica_id AND rep_state.group_id = ar.group_id
INNER JOIN sys.dm_hadr_database_replica_cluster_states as cs (NOLOCK) ON cs.replica_id = ar.replica_id AND cs.group_database_id = rep_state.group_database_id;
GO

SELECT	db_name(database_id) as database_name,
		last_sent_time,
		last_received_time,
		last_hardened_time,
		last_redone_time,
		last_commit_time,
		log_send_queue_size,
		redo_queue_size,
		redo_rate,
		(redo_queue_size/(redo_rate+1))/60 AS MinutesPending,
		secondary_lag_seconds
FROM	sys.dm_hadr_database_replica_states rep_state
INNER JOIN sys.availability_replicas ar ON rep_state.replica_id = ar.replica_id AND rep_state.group_id = ar.group_id
INNER JOIN sys.dm_hadr_database_replica_cluster_states as cs ON cs.replica_id = ar.replica_id AND cs.group_database_id = rep_state.group_database_id;
GO

/* Always On control */
SELECT	db_name(database_id) as database_name,
		DATEDIFF(MINUTE, last_commit_time, last_received_time) AS DifferenceInMinutes,
		last_received_time,		
		last_commit_time
FROM	sys.dm_hadr_database_replica_states rep_state
WHERE	DATEDIFF(MINUTE, last_commit_time, last_received_time) > 60;
GO

/*
last_sent_time
This time indicates the last time that the PRIMARY sent a Log Block to the available secondaries. This is the start of the data synchronisation process.

last_received_time
This indicates the last time that the secondary received a log block.

last_hardened_time
This indicates the last time that the secondary cached the recieved log block data to disk.

last_redone_time
This is the time that the last LSN was redone on the target database.

last_commit_time
This is the time of the last commit record was redone and reported back to the primary.


Summary
Of the above, there are various entry-points of the data into the secondary systems:
	- The data first enters the server into memory at last_received_time
	- The data first enters the server on disk at last_hardened_time
	- The data first enters the database data files at last_redone_time
	- The data first becomes committed and available for reading by queries (outside of strange NOLOCK situations) at last_commit_time
*/

/* This query must be executed on PRIMARY */
;WITH 
	AG_Stats AS 
			(
			SELECT AR.replica_server_name,
				   HARS.role_desc, 
				   Db_name(DRS.database_id) [DBName], 
				   DRS.last_commit_time
			FROM   sys.dm_hadr_database_replica_states DRS 
			INNER JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id 
			INNER JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id 
				AND AR.replica_id = HARS.replica_id 
			),
	Pri_CommitTime AS 
			(
			SELECT	replica_server_name
					, DBName
					, last_commit_time
			FROM	AG_Stats
			WHERE	role_desc = 'PRIMARY'
			),
	Sec_CommitTime AS 
			(
			SELECT	replica_server_name
					, DBName
					, last_commit_time
			FROM	AG_Stats
			WHERE	role_desc = 'SECONDARY'
			)
SELECT p.replica_server_name [primary_replica]
	, p.[DBName] AS [DatabaseName]
	, s.replica_server_name [secondary_replica]
	, DATEDIFF(ss,s.last_commit_time,p.last_commit_time) AS [Sync_Lag_Secs]
FROM Pri_CommitTime p
LEFT JOIN Sec_CommitTime s ON [s].[DBName] = [p].[DBName]

/* This query must be executed on PRIMARY */
;WITH UpTime AS
			(
			SELECT DATEDIFF(SECOND,create_date,GETDATE()) [upTime_secs]
			FROM sys.databases
			WHERE name = 'tempdb'
			),
	AG_Stats AS 
			(
			SELECT AR.replica_server_name,
				   HARS.role_desc, 
				   Db_name(DRS.database_id) [DBName], 
				   CAST(DRS.log_send_queue_size AS DECIMAL(19,2)) log_send_queue_size_KB, 
				   (CAST(perf.cntr_value AS DECIMAL(19,2)) / CAST(UpTime.upTime_secs AS DECIMAL(19,2))) / CAST(1024 AS DECIMAL(19,2)) [log_KB_flushed_per_sec]
			FROM   sys.dm_hadr_database_replica_states DRS 
			INNER JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id 
			INNER JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id 
				AND AR.replica_id = HARS.replica_id 
			--I am calculating this as an average over the entire time that the instance has been online.
			--To capture a smaller, more recent window, you will need to:
			--1. Store the counter value.
			--2. Wait N seconds.
			--3. Recheck counter value.
			--4. Divide the difference between the two checks by N.
			INNER JOIN sys.dm_os_performance_counters perf ON perf.instance_name = Db_name(DRS.database_id)
				AND perf.counter_name like 'Log Bytes Flushed/sec%'
			CROSS APPLY UpTime
			),
	Pri_CommitTime AS 
			(
			SELECT	replica_server_name
					, DBName
					, [log_KB_flushed_per_sec]
			FROM	AG_Stats
			WHERE	role_desc = 'PRIMARY'
			),
	Sec_CommitTime AS 
			(
			SELECT	replica_server_name
					, DBName
					--Send queue will be NULL if secondary is not online and synchronizing
					, log_send_queue_size_KB
			FROM	AG_Stats
			WHERE	role_desc = 'SECONDARY'
			)
SELECT p.replica_server_name [primary_replica]
	, p.[DBName] AS [DatabaseName]
	, s.replica_server_name [secondary_replica]
	, CAST(s.log_send_queue_size_KB / p.[log_KB_flushed_per_sec] AS BIGINT) [Sync_Lag_Secs]
FROM Pri_CommitTime p
LEFT JOIN Sec_CommitTime s ON [s].[DBName] = [p].[DBName]
GO
