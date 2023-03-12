/*
From Brent Ozar: https://www.brentozar.com/responder/log-sp_whoisactive-to-a-table/

This code will create the logging table if it doesn’t exist, the clustered index if it doesn’t exist,
log current activity and purge older data based on the @retention variable.

You could also break the DELETE out into its own job so that it runs once a day. If you do this, 
loop through the DELETEs in batches rather than all at once.

If you run this, and then upgrade sp_WhoIsActive to a newer version that outputs more columns,
the inserts will fail because the newer columns don’t exist. 
The easiest way to fix that is drop the output table whenever you upgrade sp_WhoIsActive,
and this code will just regenerate the table with the latest results structure. 
If you need to preserve your old sp_WhoIsActive data, you’ll need to alter the output table manually
to include any new columns that have been added in the newer version of sp_WhoIsActive.
*/

SET NOCOUNT ON;

DECLARE @retention INT = 7,
        @destination_table VARCHAR(500) = 'WhoIsActive',
        @destination_database sysname = 'DBAtools',
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;

SET @destination_table = @destination_database + '.dbo.' + @destination_table;

--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
                                @return_schema = 1,
                                @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, '<table_name>', @destination_table);
        EXEC ( @schema );
    END;

--create index on collection_time
SET @SQL
    = 'USE ' + QUOTENAME(@destination_database)
      + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @exists = 0';
SET @parameters = N'@destination_table varchar(500), @exists bit OUTPUT';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;

IF @exists = 0
    BEGIN;
        SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + '(collection_time ASC)';
        EXEC ( @SQL );
    END;

--collect activity into logging table
EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
                        @destination_table = @destination_table;

--purge older data
SET @SQL
    = 'DELETE FROM ' + @destination_table + ' WHERE collection_time < DATEADD(day, -' + CAST(@retention AS VARCHAR(10))
      + ', GETDATE());';
EXEC ( @SQL );
GO
