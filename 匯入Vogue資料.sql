
INSERT INTO [dbo].[VOGUETEST]
EXEC sp_execute_external_script
	@language=N'Python'
	,@script=N'
import vogue
import pandas

df = vogue.vogue(page=1,topage=40,articlebefore="2021-07-01", forum="beauty")
print(df)
OutputDataSet = pandas.DataFrame(df)
'


SELECT * FROM [dbo].[VOGUETEST]
--TRUNCATE TABLE  [dbo].[VOGUETEST]


SELECT * from duplicate_table as a join [dbo].[VOGUETEST] as b
on a.title=b.title


SELECT title,date,content
INTO duplicate_table
FROM [dbo].[VOGUETEST]
GROUP BY title,date,content
HAVING COUNT(title) > 1

DELETE [dbo].[VOGUETEST]
WHERE title
IN (SELECT title
FROM duplicate_table)

INSERT [dbo].[VOGUETEST]
SELECT *
FROM duplicate_table

DROP TABLE duplicate_table



/*
CREATE TABLE [dbo].[VOGUETEST](
	[id] INT IDENTITY(1,1),
	[title] [nvarchar](100) NOT NULL,
	[date] [nvarchar](20) NOT NULL,
	[content] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO [dbo].[VOGUE](title, [date], content) VALUES ('{0}','{1}','{2}')

DROP TABLE [dbo].[VOGUE]

SELECT * FROM [dbo].[VOGUE]

--¿À¨dº“≤’
EXECUTE sp_execute_external_script @language = N'Python'
    , @script = N'
import pkg_resources
import pandas
dists = [str(d) for d in pkg_resources.working_set]
OutputDataSet = pandas.DataFrame(dists)
'
WITH RESULT SETS(([Package] NVARCHAR(max)))
GO


*/