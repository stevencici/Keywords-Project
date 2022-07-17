

--���ζפJ������[id],[title],[date],[content]

--�h��id(�����Ƹ�ƯB�{)
ALTER TABLE [dbo].[VOGUETEST1] DROP COLUMN [id]

--��X���Ƹ��(�קK�H�����~)
SELECT [title], [date], [content]
INTO [dbo].[repeated_title_table]
FROM [dbo].[VOGUETEST1]
GROUP BY [title], [date], [content]
HAVING COUNT(*)>1


SELECT * FROM [dbo].[VOGUETEST1]
DELETE FROM [dbo].[VOGUETEST1] WHERE [title] IN (SELECT [title] FROM [dbo].[repeated_title_table])
INSERT INTO [dbo].[VOGUETEST1] SELECT * FROM [dbo].[repeated_title_table]



--��X����title(vogue�~�t����D�@��)
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