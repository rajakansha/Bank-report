USE [Homework]
GO
/****** Object:  StoredProcedure [dbo].[Report_Bank]    Script Date: 29-10-2022 14:23:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER     PROCEDURE  [dbo].[Report_Bank_All]

AS


BEGIN
-------------------------------------------------------------------------------------------------------------------------------
--Procedure to calculate the variance for all quarters

DECLARE
 @CurrentReportDate DATE
begin


DROP TABLE IF EXISTS #ReportBank

SELECT A.* INTO #ReportBank FROM (
SELECT
AA.*
FROM ReportBank AA ) A 

--SET @CurrentReportDate = (SELECT MAX([ReportDate]) FROM #ReportBank)


END

------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
--Variance Calculations


DECLARE @reportdate DATE,
@priorreportdate DATE,
@Minreportdate DATE

Begin

SET @reportdate = (SELECT MAX(ReportDate) FROM #ReportBank) --june
SET @priorreportdate = (SELECT DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @reportdate), 0)))--march
SET @Minreportdate = (SELECT MIN(ReportDate) FROM #ReportBank)--dec

--select @reportdate as CurrentDT, @priorreportdate as priorreportdate

----------------------------------------------------------------------------------------------------------------------

While (@reportdate <> @Minreportdate)
Begin

		DROP TABLE IF EXISTS #ReportBank_Variance_Temp

		SELECT
		AA.*
		INTO #ReportBank_Variance_Temp from (

		SELECT 
		A.[ReportDate] as ReportDate_current,
		B.[ReportDate] as ReportDate_prior,
		A.[Fund_Type] as [Fund_Type],
		A.[Fund_Name] as [Fund_Name],
		A.[Company_Name] as [Company_Name],
		A.[Year] as [Year],
		A.[Period] as [Period],
		A.[Amount] as Amount_Current,	
		B.[Amount] as Amount_Prior,	
		case 
			when A.[Amount] IS NULL  then (0 - B.[Amount]) 
			when B.[Amount] IS NULL  then (A.[Amount] - 0)
			else  (A.[Amount] - B.[Amount])
		END as Variance,

		case 
			when A.[Amount] IS NULL  then  cast(ROUND((100.00),2, 1) as decimal(30,2))
			when B.[Amount] IS NULL  then   cast(ROUND((100.00),2, 1) as decimal(30,2)) 
			else  cast(ROUND((((A.[Amount] - B.[Amount]) / B.[Amount])*100),2, 1) as decimal(30,2))
		END as Variance_Per

		  FROM
		   (SELECT * FROM #ReportBank WHERE ReportDate = @reportdate) A
		LEFT JOIN 
		   (SELECT * FROM #ReportBank WHERE ReportDate = @priorreportdate) B
		ON A.[Fund_Type] = B.[Fund_Type]
		)AA
	

--select * from ReportBank_Variance
--truncate table ReportBank_Variance



		INSERT INTO ReportBank_Variance
		SELECT AA.* from (
		select
		ReportDate_current	,
		ReportDate_prior,	
		[Fund_Type],
		[Fund_Name],
		[Company_Name],
		[Year],
		[Period],
		case 
			when Amount_Current IS NULL  then 0 
			else  Amount_Current
		END as Amount_Current,
		case 
			when Amount_Prior IS NULL  then 0 
			else  Amount_Prior
		END as Amount_Prior,
		 Variance,
		 Variance_Per

		from
		#ReportBank_Variance_Temp
		)AA

	SET @reportdate = @priorreportdate
	SET @priorreportdate = (SELECT DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @reportdate), 0)))

	END

END

end

