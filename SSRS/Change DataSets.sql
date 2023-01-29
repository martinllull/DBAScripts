/* Part 1 - Create a new Data Set from another defined in SSRS */

/* Part 2 - Change the Data Source defined in a DataSet (Search by name and replace) */

Declare @DataSetDef varchar(64)
Declare @DataSource varchar(64)

if object_id('tempdb..#TempDataSetsDef') is not null
	Drop table #TempDataSetsDef

Create table #TempDataSetsDef (
DataSetDef varchar(64) not null,
DataSource varchar(64) not null)

/* Insert the name of the DataSet and the new DataSource */
Insert into #TempDataSetsDef (DataSetDef, DataSource) Values
 ('DataSet','NewDataSource')
--...
,('DataSet','NewDataSource');

Declare DataSetsDef_Cursor Cursor Fast_Forward Read_only for
	Select DataSetDef, DataSource
	from #TempDataSetsDef

	Open DataSetsDef_Cursor

	Fetch next from DataSetsDef_Cursor
	into @DataSetDef, @DataSource

		WHILE @@FETCH_STATUS = 0  
		
		Begin
			Begin tran

			if EXISTS (select top 1 itemid 
				from ReportServer.dbo.Catalog (nolock)
				where name = @DataSource
				and [type] = 5)
				and Exists
				(
				Select top 1 ItemID from ReportServer.dbo.Catalog (nolock)
				where name = @DataSetDef
				and type = 8)

			Begin

				Update ReportServer.dbo.DataSource set Link = (Select top 1 ItemID from ReportServer.dbo.Catalog (nolock)
				where name = @DataSource
				and type = 5)
				where ItemID = 
				(
					Select top 1 ItemID from ReportServer.dbo.Catalog (nolock)
					where name = @DataSetDef
					and type = 8
				)

				print 'The DataSet ' + @DataSetDef + ' change to DataSource ' + @DataSource + '.'
			end

			else
			Begin
				print 'The DataSet ' + @DataSetDef + ' or the DataSource ' + @DataSource + ' does not exists.'
			End

			Commit

			Fetch next from DataSetsDef_Cursor
			into @DataSetDef, @DataSource
		End
		

	CLOSE DataSetsDef_Cursor
	DEALLOCATE DataSetsDef_Cursor
GO;

/* Part 3 - Change DataSets of reports in some path */

Declare @Path varchar(64) = '/Folder' --Path where reports to be modified are located
select @Path = @Path + '%'

Declare @Command varchar(1024)
Declare @Reports varchar (1024) = ''
Declare @ReportsPaths varchar(1024) = ''

-- Comment the next lines to avoid filtering by Report or Path (always within the path defined above)
--SET @Reports = 'ReportName'
--SET @ReportsPaths = '/Folder/Folder/Report, /Folder/Folder/Report'

Declare @OldDataSet varchar(64)
Declare @NewDataSet varchar(64)

if object_id('tempdb..#TempDataSets') is not null
	Drop table #TempDataSets

Create table #TempDataSets (
OldDataSet varchar(64) not null,
NewDataSet varchar(64) not null)

/* Insert the name of the DataSet and the new DataSet */
Insert into #TempDataSets (OldDataSet, NewDataSet) Values
 ('OldDataSet','NewDataSet')
--...
,('OldDataSet','NewDataSet');

Declare DataSets_Cursor Cursor Fast_Forward Read_only for
Select OldDataSet, NewDataSet
from #TempDataSets

Open DataSets_Cursor

Fetch next from DataSets_Cursor
into @OldDataSet, @NewDataSet

    WHILE @@FETCH_STATUS = 0  
	
	Begin
		Begin Tran

		If exists (
			Select top 1 ItemID
			from ReportServer.dbo.Catalog (nolock)
			where name = @NewDataSet
			and [type] = 8
		)

		begin
			
			If @Reports = '' and @ReportsPaths = ''
			begin
				Select @Command = 'update ReportServer.dbo.DataSets set LinkID = (select top 1 ItemID from ReportServer.dbo.Catalog (nolock)
							where name = ''' + @NewDataSet  + '''
							and [type] = 8)
					where ItemID in (
						select ItemID 
						from ReportServer.dbo.Catalog (nolock) 
						Where path like ''' + @Path  + '''
					)
					and LinkID in (
						Select ItemID
						from ReportServer.dbo.Catalog (nolock)
						where name = ''' + @OldDataSet  + '''
						and type = 8
					)'
			end
			else
				if @ReportsPaths = ''
				begin
					Select @Command = 'update ReportServer.dbo.DataSets set LinkID = (select top 1 ItemID from ReportServer.dbo.Catalog (nolock)
							where name = ''' + @NewDataSet  + '''
							and [type] = 8)
					where ItemID in (
						select ItemID 
						from ReportServer.dbo.Catalog (nolock) 
						Where path like ''' + @Path  + '''
						and cat.name in (''' + Replace(Replace(Replace(@Reports, ' ,',','),', ',','), ',' , ''',''' ) + ''')
					)
					and LinkID in (
						Select ItemID
						from ReportServer.dbo.Catalog (nolock)
						where name = ''' + @OldDataSet  + '''
						and type = 8
					)'
				end
				else
				begin
					Select @Command = 'update ReportServer.dbo.DataSets set LinkID = (select top 1 ItemID from ReportServer.dbo.Catalog (nolock)
							where name = ''' + @NewDataSet  + '''
							and [type] = 8)
					where ItemID in (
						select ItemID 
						from ReportServer.dbo.Catalog (nolock) 
						Where path like ''' + @Path  + '''
						and cat.Path in (''' + Replace(Replace(Replace(@ReportsPaths, ' ,',','),', ',','), ',' , ''',''' ) + ''')
					)
					and LinkID in (
						Select ItemID
						from ReportServer.dbo.Catalog (nolock)
						where name = ''' + @OldDataSet  + '''
						and type = 8
					)'
				end

				--Select @Command
				Exec (@Command)

				print convert(varchar, @@ROWCOUNT) + ' reports change from Dataset ' + @OldDataSet + ' to ' +  @NewDataSet + '.'
		end

		else
		Begin
			print 'DataSet ' + @NewDataSet + ' does not exists.'
		End
		
		commit

		Fetch next from DataSets_Cursor
		into @OldDataSet, @NewDataSet

	End
	

CLOSE DataSets_Cursor
DEALLOCATE DataSets_Cursor
GO