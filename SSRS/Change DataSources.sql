DECLARE @path VARCHAR(256) = '/Path'
SET @path = CONCAT(@path,'%')

DECLARE @Command VARCHAR(1024)
DECLARE @Reports VARCHAR(1024) = ''
DECLARE @ReportsPaths VARCHAR(1024) = ''

-- Comment the next lines to avoid filtering by Report or Path (always within the path defined above)

--SET @Reports = 'ReportName'
--SET @ReportsPaths = '/Folder/Folder/Report, /Folder/Folder/Report'

DECLARE @oldDS VARCHAR(64)
DECLARE @newDS VARCHAR(64)

IF object_id('tempdb..#TempDataSources') IS NOT NULL
	DROP TABLE #TempDataSources

CREATE TABLE #TempDataSources (
OldDataSource VARCHAR(64) NOT NULL,
NewDataSource VARCHAR(64) NOT NULL)

INSERT INTO #TempDataSources (OldDataSource, NewDataSource) VALUES
  ('OldDataSource','NewDataSource')
--...  
, ('OldDataSource','NewDataSource');

DECLARE DataSources_Cursor CURSOR FAST_FORWARD READ_ONLY FOR
SELECT OldDataSource, NewDataSource
FROM #TempDataSources

OPEN DataSources_Cursor

FETCH NEXT FROM DataSources_Cursor
INTO @oldDS, @newds

    WHILE @@FETCH_STATUS = 0  
	
	BEGIN
		BEGIN TRAN

		IF EXISTS (SELECT TOP 1 itemid 
			FROM ReportServer.dbo.Catalog
			WHERE name = @newds
			AND type = 5)

		BEGIN
			IF @Reports = '' AND @ReportsPaths = ''
				BEGIN
					SELECT @Command = 'update ReportServer.dbo.DataSource set Link = (select top 1 ItemID from ReportServer.dbo.Catalog
						where name = ''' + @newDS  + '''
						and [type] = 5)
						where ItemID in (
						select cat.ItemID
						from ReportServer.dbo.DataSource ds
						inner join ReportServer.dbo.Catalog cat
						on ds.ItemID = cat.ItemID
						where ds.link in (
						select itemid from ReportServer.dbo.Catalog cat
						where type = 5
						and name = ''' + @oldDS  + ''')
						and cat.Path like ''' + @path  + '''
						)
						and Link in (
						select ds.Link
						from ReportServer.dbo.DataSource ds
						inner join ReportServer.dbo.Catalog cat
						on ds.ItemID = cat.ItemID
						where ds.link in (
						select itemid from ReportServer.dbo.Catalog cat
						where type = 5
						and name = ''' + @oldDS  + ''')
						and cat.Path like ''' + @path  + '''
						)'
				END
			ELSE
				IF @ReportsPaths = ''
					BEGIN
						SELECT @Command = 'update ReportServer.dbo.DataSource set Link = (select top 1 ItemID from ReportServer.dbo.Catalog
						where name = ''' + @newDS  + '''
						and [type] = 5)
						where ItemID in (
						select cat.ItemID
						from ReportServer.dbo.DataSource ds
						inner join ReportServer.dbo.Catalog cat
						on ds.ItemID = cat.ItemID
						where ds.link in (
						select itemid from ReportServer.dbo.Catalog cat
						where type = 5
						and name = ''' + @oldDS  + ''')
						and cat.Path like ''' + @path  + '''
						and cat.name in (''' + Replace(Replace(Replace(@Reports, ' ,',','),', ',','), ',' , ''',''' ) + ''')
						)
						and Link in (
						select ds.Link
						from ReportServer.dbo.DataSource ds
						inner join ReportServer.dbo.Catalog cat
						on ds.ItemID = cat.ItemID
						where ds.link in (
						select itemid from ReportServer.dbo.Catalog cat
						where type = 5
						and name = ''' + @oldDS  + ''')
						and cat.Path like ''' + @path  + '''
						)'
					END
				ELSE
					BEGIN
						SELECT @Command = 'update ReportServer.dbo.DataSource set Link = (select top 1 ItemID from ReportServer.dbo.Catalog
							where name = ''' + @newDS  + '''
							and [type] = 5)
							where ItemID in (
							select cat.ItemID
							from ReportServer.dbo.DataSource ds
							inner join ReportServer.dbo.Catalog cat
							on ds.ItemID = cat.ItemID
							where ds.link in (
							select itemid from ReportServer.dbo.Catalog cat
							where type = 5
							and name = ''' + @oldDS  + ''')
							and cat.Path like ''' + @path  + '''
							and cat.Path in (''' + Replace(Replace(Replace(@ReportsPaths, ' ,',','),', ',','), ',' , ''',''' ) + ''')
							)
							and Link in (
							select ds.Link
							from ReportServer.dbo.DataSource ds
							inner join ReportServer.dbo.Catalog cat
							on ds.ItemID = cat.ItemID
							where ds.link in (
							select itemid from ReportServer.dbo.Catalog cat
							where type = 5
							and name = ''' + @oldDS  + ''')
							and cat.Path like ''' + @path  + '''
							)'
					END

			-- select @Command
			EXEC (@Command)

			PRINT CONVERT(VARCHAR, @@ROWCOUNT) + ' reports change from DataSource ' + @oldDS + ' to ' +  @newDS + '.'

		END
		ELSE
			PRINT 'DataSource ' + @newDS + ' does not exists.'

		COMMIT -- Rollback

		FETCH NEXT FROM DataSources_Cursor
		INTO @oldDS, @newds
	END
	

CLOSE DataSources_Cursor
DEALLOCATE DataSources_Cursor;
GO