USE ReportServer
GO

SELECT TOP 100 ItemPath, UserName, RequestType, Format, Parameters, ItemAction, TimeStart, TimeEnd, [Status]
FROM dbo.ExecutionLog3 (NOLOCK)
WHERE ItemPath = '/Folder/Folder'
ORDER BY TimeStart DESC;
GO