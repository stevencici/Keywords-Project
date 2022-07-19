/*
CREATE TABLE [Brand]
(
	[id] INT IDENTITY(1,1),
	[alias] NVARCHAR(20),
	[name] NVARCHAR(20)
)
*/

WITH T1
AS
(
	SELECT [id]
	FROM [dbo].[VOGUE]
)
,T2
AS
(
	SELECT B.[Keyword],B.[Cnt]
	FROM T1 AS A 
	CROSS APPLY 
	[dbo].[GetJsonKeywords](A.[id]) AS B
)
,T3
AS
(
SELECT [Keyword],SUM(Cnt) AS Cnts
FROM T2
GROUP BY [Keyword]
)
SELECT B.[name],SUM(A.[Cnts]) AS TotalCnts
FROM T3 AS A JOIN [Brand] AS B ON A.[Keyword]=B.[alias]
GROUP BY B.[name]
ORDER BY [TotalCnts] DESC
GO

SELECT * FROM [dbo].[Brand]

INSERT INTO [Brand]([alias],[name]) VALUES('YSL','YSL')
INSERT INTO [Brand]([alias],[name]) VALUES('ÄõçM','ÄõçM')
INSERT INTO [Brand]([alias],[name]) VALUES('¶®¸ÖÄõÂL','¶®¸ÖÄõÂL')
INSERT INTO [Brand]([alias],[name]) VALUES('SABON','SABON')
INSERT INTO [Brand]([alias],[name]) VALUES('­»©`¨à','­»©`¨à')
INSERT INTO [Brand]([alias],[name]) VALUES('chanel','­»©`¨à')
INSERT INTO [Brand]([alias],[name]) VALUES('diptyque','diptyque')
INSERT INTO [Brand]([alias],[name]) VALUES('©gºû¶®','©gºû¶®')
INSERT INTO [Brand]([alias],[name]) VALUES('»®½¬®R','»®½¬®R')
INSERT INTO [Brand]([alias],[name]) VALUES('¸ê¥Í°ó','¸ê¥Í°ó')
INSERT INTO [Brand]([alias],[name]) VALUES('SK-II','SK-II')
INSERT INTO [Brand]([alias],[name]) VALUES('KIEHL','kiehls')
INSERT INTO [Brand]([alias],[name]) VALUES('«´º¸¤ó','kiehls')
INSERT INTO [Brand]([alias],[name]) VALUES('kiehls','kiehls')
INSERT INTO [Brand]([alias],[name]) VALUES('Dior','Dior')
INSERT INTO [Brand]([alias],[name]) VALUES('­}¶ø','Dior')
INSERT INTO [Brand]([alias],[name]) VALUES('®ü¬v©Ô®R','®ü¬v©Ô®R')

