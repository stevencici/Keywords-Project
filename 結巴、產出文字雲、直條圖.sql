
--Stored Procedure : CREATE WORD DATA(JSON FORM)
ALTER PROC GetKeyWordsToJson @id INT,@result NVARCHAR(MAX) OUTPUT
AS
	CREATE TABLE #TT( [Txt] NVARCHAR(20));
    DECLARE @sqlQuery NVARCHAR(MAX)=N'SELECT [content] FROM [dbo].[VOGUE_FINAL] WHERE [id]=' +CONVERT(NVARCHAR,@id);
	INSERT INTO #TT
	EXEC sp_execute_external_script
	@language=N'Python'
	,@script=N'
import jieba
import pandas as pd
#jieba.set_dictionary("dict.txt.big")

stopWords=[]
with open("D:\myPython\AIProject\MyStopWord.txt","r",encoding="UTF-8") as fileObj:
	for ss in fileObj.readlines():
		ss = ss.strip()
		stopWords.append(ss)
	
txt_data=pd.DataFrame(InputDataSet)
df = pd.DataFrame(txt_data)
sentence = df.iloc[0,0] 

#load keywords
jieba.load_userdict("D:\myPython\AIProject\MyKeyword.txt")

words = jieba.cut(sentence, cut_all=False)
remainedWords = []
remainedWords = list(filter(lambda a : a not in stopWords and len(a)>1, words))  #DELETE WORD
#for word in remainedWords:
#	print(word)

OutputDataSet=pd.DataFrame(remainedWords)
'
	,@input_data_1 = @sqlQuery

	--DELETE FROM #TT WHERE SUBSTRING([Txt],1,1)=CHAR(13);(�h�ť�)
	SET @result=( SELECT [Txt] AS [Keywords],COUNT(*) AS Cnt
	FROM #TT
	GROUP BY [Txt]
	HAVING COUNT(*)>1
	ORDER BY Cnt DESC
	FOR JSON AUTO);
GO
---------------------------------------------------------------------------------------
--ADD NEW COLUMNS
ALTER TABLE [dbo].[VOGUE_FINAL] ADD [Keywords] NVARCHAR(MAX)
GO
---------------------------------------------------------------------------------------
--WHILE LOOP TO CREATE KEYWORDS DATA FOR EACH ARTICLE(JSON FORM)
DECLARE @rr NVARCHAR(MAX)
DECLARE @nid INT=1;
WHILE @nid<=1225
 BEGIN
	EXEC GetKeywordsToJson @nid, @rr OUTPUT;
    UPDATE [dbo].[VOGUE_FINAL] SET [Keywords]=@rr WHERE [id]=@nid;
	SET @nid=@nid+1;
 END
GO
---------------------------------------------------------------------------------------
--Function : COUNT EACH KEYWORD
ALTER FUNCTION GetJsonKeywords(@newsId INT)
RETURNS @tt TABLE
(
	Keyword NVARCHAR(20),
	Cnt INT
)
AS
 BEGIN
	DECLARE @data NVARCHAR(MAX);
	SELECT @data=[Keywords] FROM [dbo].[VOGUE_FINAL] WHERE [id]=@newsId;
	INSERT INTO @tt
		SELECT * FROM OPENJSON(@data)
		WITH(
			[Keyword] NVARCHAR(20) '$.Keywords',
			[Cnt] INT '$.Cnt'
		);
	RETURN
 END
GO

---------------------------------------------------------------------------------------
--KEYWORDS STATISTICS
WITH T1
AS
(
	SELECT [id]
	FROM [dbo].[VOGUE_FINAL]
)
,T2
AS
(
	SELECT B.[Keyword],B.[Cnt]
	FROM T1 AS A CROSS APPLY [dbo].[GetJsonKeywords](A.[id]) AS B
)
SELECT [Keyword],SUM(Cnt) AS Cnts
FROM T2
GROUP BY [Keyword]
ORDER BY [Cnts] DESC;
GO

---------------------------------------------------------------------------------------
--WORDCLOUD
DECLARE @sqlQuery NVARCHAR(2048)=N'
WITH T1 AS
(
	SELECT [id]
	FROM [dbo].[VOGUE_FINAL]
)
,T2
AS
(
	SELECT B.[Keyword],B.[Cnt]
	FROM T1 AS A CROSS APPLY [dbo].[GetJsonKeywords](A.[id]) AS B
)
SELECT [Keyword],SUM(Cnt) AS Cnts
FROM T2
GROUP BY [Keyword];
'

EXEC sp_execute_external_script
	@language=N'Python'
	,@script = N'
import jieba
import pandas as pd
from wordcloud import WordCloud 
import matplotlib.pyplot as plt

text_data = InputDataSet
df = pd.DataFrame(text_data)
kk=list(df.Keyword)
vv=list(df.Cnts)
my_dict=dict(zip(kk,vv))

#SET CHINESESS FONT
fontPath="C:\Windows\Fonts\kaiu.ttf"
wc=WordCloud(font_path=fontPath,width=800,height=800,background_color="white",min_font_size=10)
wc.generate_from_frequencies(my_dict)
wc.to_file("D:\myPython\AIProject\Beauty.png")
'
,@input_data_1=@sqlQuery
GO
---------------------------------------------------------------------------------------
--HISTOGRAM
EXEC sp_execute_external_script
	@language = N'Python'
	,@script = N'
import pandas as pd
import matplotlib.pyplot as plt
import datetime

sqlData=pd.DataFrame(InputDataSet)
plt.rcParams["font.sans-serif"] = ["Microsoft JhengHei"] 
plt.rcParams["axes.unicode_minus"] = False
sqlData.set_index(["Keyword"],inplace=True)
print(sqlData)


sqlData.plot(title="KeywordCounts", kind = "bar")
plt.xlabel("Keyword")
plt.xticks(rotation=0)
plt.ylabel("Cnt")
plt.savefig(r"D:\myPython\AIProject\{0}VOGUE_KeywordHistogram.png".format(datetime.date.today()))
'
, @input_data_1 = N'
WITH T1 AS
(
	SELECT [id]
	FROM [dbo].[VOGUE_FINAL]
)
,T2
AS
(
	SELECT B.[Keyword],B.[Cnt]
	FROM T1 AS A CROSS APPLY [dbo].[GetJsonKeywords](A.[id]) AS B
)

SELECT [Keyword],SUM(Cnt) AS Cnts
FROM T2
GROUP BY [Keyword]
ORDER BY [Cnts] DESC;
'
GO


