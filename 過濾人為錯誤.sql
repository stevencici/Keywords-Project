

--爬蟲匯入資料欄位[id],[title],[date],[content]

--去掉id(讓重複資料浮現)
ALTER TABLE [dbo].[VOGUETEST1] DROP COLUMN [id]

--選出重複資料(避免人為錯誤)
SELECT [title], [date], [content]
INTO [dbo].[repeated_title_table]
FROM [dbo].[VOGUETEST1]
GROUP BY [title], [date], [content]
HAVING COUNT(*)>1


SELECT * FROM [dbo].[VOGUETEST1]
DELETE FROM [dbo].[VOGUETEST1] WHERE [title] IN (SELECT [title] FROM [dbo].[repeated_title_table])
INSERT INTO [dbo].[VOGUETEST1] SELECT * FROM [dbo].[repeated_title_table]



--選出重複title(vogue業配文標題一樣)
SELECT title
--INTO [dbo].[repeated_content_table1]
FROM [dbo].[VOGUETEST1]
GROUP BY title
HAVING COUNT(title)>1
----------------------------------------------
select [title], [date], [content],ROW_NUMBER() over ( order by [date] desc ) as rowIndex from [dbo].[repeated_content_table1]
-------------------------------------------------

WITH T1
AS
(
SELECT [title], [date], [content],ROW_NUMBER() OVER ( ORDER BY [date] DESC ) AS rowIndex
FROM [dbo].[VOGUETEST] WHERE [title] IN (SELECT  FROM [dbo].[repeated_content_table1]) 
)
,T2
AS
(SELECT * FROM T1
WHERE [rowIndex] <> 1
)
DELETE FROM [dbo].[VOGUETEST1] WHERE [content] IN (SELECT [content] FROM T2)



CREATE TABLE [dbo].[VOGUE_FINAL](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[date] [nvarchar](20) NOT NULL,
	[content] [nvarchar](max) NOT NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO [dbo].[VOGUE_FINAL] SELECT [title], [date], [content] FROM [dbo].[VOGUETEST1]

SELECT * FROM [dbo].[VOGUE_FINAL]