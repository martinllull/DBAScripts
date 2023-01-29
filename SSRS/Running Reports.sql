USE ReportServer;
GO

DECLARE @cutoff DATETIME;
SET @cutoff = DATEADD(minute, -5, GETDATE()); --Five minutes ago

SELECT JobID, JobType, JobStatus, RequestName, StartDate, ComputerName
FROM RunningJobs
WHERE StartDate < @cutoff --prunes records that haven't run for five minutes yet
ORDER BY StartDate --oldest first


---

--CPU history by minute per report
--BUG FIXED on 11/04/2016 line of where timestart missing major or equal
select distinct
Name, -- Name of the report
Path, -- Path of the report, where the RDL is located
COUNT(*) calls, -- Number of calls this report has per minute
CONVERT(VARCHAR(19),timestart) minutes, -- Shows you the last 60 minutes and reports that were called in each minute
AVG(timedataretrieval)/100 DB_Time, -- Time spend in Database
AVG(timeprocessing)/100 Processing_Time, -- Time spend in processing the report
AVG(timerendering)/100 Rendering_Time -- Time spend in rendering the report PDF, XLS, etc
from Reportserver.dbo.ExecutionLog A left join ReportServer.dbo.Catalog B
ON A.ReportID = B.itemid
where timestart >= DATEADD(mi, -60, GETDATE()) --Retrieve the information from the reports executed in the last 60 minutes
-- and UserName like '%op_kostal%' --filter the resulset by user/login id
-- and Name = 'WMS - C-Semaforizaci�n de viajes por fecha RM' --filter results by report name
group by path, name, CONVERT(VARCHAR(19),timestart)
order by CONVERT(VARCHAR(19),timestart) desc;
GO