--Documentation: http://whoisactive.com/docs/

--Get help about the parameters and output columns
EXEC sp_WhoIsActive @help = 1;
GO

--Execution with default parámeters
EXEC sp_WhoIsActive
/*
--Filters (include and exclude) - session, program, database, login, and host
@filter = ''
, @filter_type = 'session'
, @not_filter = ''
, @not_filter_type = 'session'
--Show information about the session that executes sp_WhoIsActive
, @show_own_spid = 0
--Show information about system SPIDs
, @show_system_spids = 0
--Control how to show sleeping connections
	--> 0: don't show sleeping connections
	--> 1: show only sleeping SPIDs that have an open transaction
	--> 2: show all sleeping connections
, @show_sleeping_spids = 1
--1: get the Stored Procedure or Batch, when it is available // 0: get only the statement running within a batch or stored procedure
, @get_full_inner_text = 0
--0: don't show execution plan // 1: show the plan by "request's statement offset" // 2: show the complete plan from plan_handle
, @get_plans = 0
--Get the outer command or stored procedure, if available
, @get_outer_command = 0
--Get information about the transaction
, @get_transaction_info = 0
--Get information about active tasks:
	--> 0: nothing
	--> 1: light mode
	--> 2: extract all metrics related to tasks
, @get_task_info = 1
--Get locks asociated with the request, in XML format
, @get_locks = 0
--Get the average execution time of previous executions
, @get_avg_time = 0
--Get additional information not related to performance:
	--> text_size, language, date_format, date_first, quoted_identifier, arithabort, ansi_null_dflt_on, ansi_defaults, ansi_warnings, ansi_padding, ansi_nulls, concat_null_yields_null, transaction_isolation_level, lock_timeout, deadlock_priority, row_count, command_type
	--> If a SQL Agent Job Step is running, a subnode called agent_info is completed with: job_id, job_name, step_id, step_name, msdb_query_error
	--> If @get_task_info is 2 and a lock wait is detected, a subnode called block_info is created: lock_type, database_name, object_id, file_id, hobt_id, applock_hash, metadata_resource, metadata_class_id, object_name, schema_name
, @get_additional_info = 0
--It walks through the blockchain and counts the number of total SPIDs blocked by a given session. Also enables task_info level 1 if disabled (0)
, @find_block_leaders = 0
--Extract deltas in various metrics. Interval in seconds to wait before performing the second data extraction
, @delta_interval = 0
--List of desired output columns, in the desired order
	--Note that the final output will be the intersection of all enabled features and all
	--list columns. Therefore, only columns associated with features enabled
	--actually appear in the output. Also, removing columns from this list may disable features, even if they are enabled.
, @output_column_list = '[dd%][session_id][sql_text][sql_command][login_name][wait_info][tasks][tran_log%][cpu%][temp%][block%][reads%][writes%][context%][physical%][query_plan][locks][%]'
--Column(s) by which to sort the output. Sorting instructions (ASC-DESC) can be included
	-- session_id, physical_io, reads, physical_reads, writes, tempdb_allocations,
	-- tempdb_current, CPU, context_switches, used_memory, physical_io_delta, reads_delta,
	-- physical_reads_delta, writes_delta, tempdb_allocations_delta, tempdb_current_delta,
	-- CPU_delta, context_switches_delta, used_memory_delta, tasks, tran_start_time,
	-- open_tran_count, blocking_session_id, blocked_session_count, percent_complete,
	-- host_name, login_name, database_name, start_time, login_time, program_name
, @sort_order = '[start_time] ASC'
--Format some of the output columns in a more "human readable" way
	-- 0: disable output formatting
	-- 1: format the output for variable-width fonts
	-- 2: format the output for fixed-width fonts
, @format_output = 1
--Specify a table into which the results are inserted: can be in one-, two-, or three-part format
, @destination_table = ''
--If set to 1, no data collection will be performed and no result set will be returned.
--Instead, a CREATE TABLE statement will be returned via the @schema parameter
, @return_schema = 0
, @schema = NULL --OUTPUT
--To get help of sp_WhoIsActive
, @help = 0
*/

/**************
	FILTERS

@filter to include
@not_filter to exclude
Valid filter types are: session, program, database, login, and host
**************/
--Filter by session
sp_WhoIsActive @filter = '4979'
, @filter_type = 'session'

--Filter by program
sp_WhoIsActive @filter = '%Agent%'
, @filter_type = 'program'

--Filter by database
sp_WhoIsActive @filter = 'master'
, @filter_type = 'database'

--Filter by login
sp_WhoIsActive @filter = 'someLogin'
, @filter_type = 'login'

sp_WhoIsActive @filter = 'DOMAIN\svc'
, @filter_type = 'login'

--Filter by host
sp_WhoIsActive @filter = 'computerName'
, @filter_type = 'host'

----------------------------------------------------------

--Exclude session
sp_WhoIsActive @not_filter = '102'
, @not_filter_type = 'session'

--Exclude program
sp_WhoIsActive @not_filter = '%Operating%'
, @not_filter_type = 'program'

--Exclude database
sp_WhoIsActive @not_filter = 'master'
, @not_filter_type = 'database'

--Exclude login
sp_WhoIsActive @not_filter = 'someLogin'
, @not_filter_type = 'login'

--Exclude host
sp_WhoIsActive @not_filter = 'computerName'
, @not_filter_type = 'host'

-----------------------------------------------------------
sp_WhoIsActive @show_sleeping_spids = 1 --0: No mostrar conexiones en sleeping / 1: Mostrar s�lo las que tienen una transacci�n abierta / 2: Mostrar todas las conexiones en sleeping
-----------------------------------------------------------
sp_WhoIsActive @get_full_inner_text = 0 --0: obtener solo el statement que se est� ejecutando / 1: obtener el SP o Batch, cuando est� disponible
-----------------------------------------------------------
sp_WhoIsActive @get_plans = 2 --0: no mostrar el plan / 1: obtiene el plan bas�ndose en "request's statement offset" / 2: obtiene el plan completo seg�n el plan_handle
-----------------------------------------------------------
sp_WhoIsActive @get_transaction_info = 1
-----------------------------------------------------------
sp_WhoIsActive @get_task_info = 0 --0: no extrae ninguna informaci�n relacionada con la tarea / 1: modo liviano que extrae la espera superior que no es CXPACKET, dando preferencia a los bloqueadores / 2: extrae todas las m�tricas basadas en tareas, que incluyen: n�mero de tareas activas, estad�sticas de espera actuales, E/S f�sicas, conmutadores de contexto e informaci�n de bloqueadores
-----------------------------------------------------------
sp_WhoIsActive @get_locks = 1 --Obtener bloqueos para cada solicitud, en formato XML (es medio lento)
-----------------------------------------------------------
sp_WhoIsActive @get_avg_time = 1 --Obtener el tiempo promedio de ejecuciones pasadas de una consulta activa
-----------------------------------------------------------
sp_WhoIsActive @get_additional_info = 1 --Obtener informaci�n adicional no relacionada con el rendimiento de la sesi�n o solicitud
-----------------------------------------------------------
sp_WhoIsActive @find_block_leaders = 1 --Agrega un campo blocked_session_count
-----------------------------------------------------------
sp_WhoIsActive @delta_interval = 10 --Para ver la diferencia en distintas m�tricas en el intervalo de segundos que se le especifique (en este caso: 10)
-----------------------------------------------------------
