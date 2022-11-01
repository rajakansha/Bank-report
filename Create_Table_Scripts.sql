-------------------------------------------------------------------------------------------------------------------------------------
--maintable ceate script
CREATE TABLE [dbo].[ReportBank](
	[ReportDate] [date] NULL,
	[Fund_Type] [varchar](250) NOT NULL,
	[Company_Name] [varchar](250) NOT NULL,
	[Fund_Name] [varchar](250) NOT NULL,
	[Amount] [float] NULL,
	[Year] [varchar](250) NOT NULL,
	[Period] [varchar](250) NOT NULL,
)
-------------------------------------------------------------------------------------------------------------------------------------
--Variance Table create script
Drop Table ReportBank_Variance

CREATE TABLE [dbo].ReportBank_Variance(
	[ReportDate_current] [date] NULL,
	[ReportDate_prior] [date] NULL,
	[Fund_Type] [varchar](250) NOT NULL,
	[Fund_Name] [varchar](250) NOT NULL,
	[Company_Name] [varchar](250) NOT NULL,
	[Year] [varchar](250) NOT NULL,
	[Period] [varchar](250) NOT NULL,
	Amount_Current [float] NULL,
	Amount_Prior [float] NULL,
	Variance [float] NULL,
	Variance_Per [decimal](30, 2) NULL
)

