USE [Homework]
GO
/****** Object:  StoredProcedure [dbo].[Report_Bank]    Script Date: 29-10-2022 14:23:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER     PROCEDURE  [dbo].[Report_Bank]

AS


BEGIN
-------------------------------------------------------------------------------------------------------------------------------
--Procedure to calculate the variance from current quarter with prior quarter

DECLARE
 @CurrentReportDate DATE
begin

/* Inserting data from Main staging table to temp table #ReportBank
*/
DROP TABLE IF EXISTS #ReportBank

SELECT A.* INTO #ReportBank FROM (
SELECT
AA.*
FROM ReportBank AA ) A 


--SET @CurrentReportDate = (SELECT MAX([ReportDate]) FROM #ReportBank)


-- Delete from ReportBank_Variance where ReportDate_current = '2021-06-30'

select * from ReportBank
-------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
--Variance Calculations

-- Variable declaretion 
DECLARE @reportdate DATE,
@priorreportdate DATE

Begin

--Inserting max date (current date) in variable @reportdate
SET @reportdate = (SELECT MAX(ReportDate) FROM #ReportBank)

--Inserting prior quarter date in variable @priorreportdate
SET @priorreportdate = (SELECT DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @reportdate), 0)))

--select @reportdate as CurrentDT, @priorreportdate as priorreportdate

----------------------------------------------------------------------------------------------------------------------
-- 1.Variance Calculations  compairing Current quarter and prior quarter data
-- 2. Inserting data into temp table #ReportBank_Variance_Temp

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
			when A.[Amount] IS NULL  then (0 - B.[Amount])   -- Null Value handling if current amount is null for Variance 
			when B.[Amount] IS NULL  then (A.[Amount] - 0)   -- Null Value handling if prior amount is null for Variance
			else  (A.[Amount] - B.[Amount])
		END as Variance,

		case 
			when A.[Amount] IS NULL  then  cast(ROUND((100.00),2, 1) as decimal(30,2))  -- Null Value handling if current amount is null for Variance%
			when B.[Amount] IS NULL  then   cast(ROUND((100.00),2, 1) as decimal(30,2))  -- Null Value handling if prior amount is null for Variance%
			else  cast(ROUND((((A.[Amount] - B.[Amount]) / B.[Amount])*100),2, 1) as decimal(30,2))
		END as Variance_Per

		  FROM
		   (SELECT * FROM #ReportBank WHERE ReportDate = @reportdate) A --Current Quarter data
		LEFT JOIN													--Left Joining current quarter data with prior quarter data
		   (SELECT * FROM #ReportBank WHERE ReportDate = @priorreportdate) B-- Prior Quater data
		ON A.[Fund_Type] = B.[Fund_Type]
		)AA
	

--select * from ReportBank_Variance
--truncate table ReportBank_Variance

--Inserting data into final Variance table (ReportBank_Variance)  from Temp table #ReportBank_Variance_Temp

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
			when Amount_Current IS NULL  then 0 -- Null Value handling if current amount is null for Amount_Current
			else  Amount_Current
		END as Amount_Current,
		case 
			when Amount_Prior IS NULL  then 0 -- Null Value handling if current amount is null for Amount_Prior
			else  Amount_Prior
		END as Amount_Prior,
		 Variance,
		 Variance_Per

		from
		#ReportBank_Variance_Temp
		)AA

END

end

end