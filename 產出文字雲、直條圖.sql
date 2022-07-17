---------------------------------------------------------------------------------------
--產生文字雲
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

#設定中文字體
fontPath="C:\Windows\Fonts\kaiu.ttf"
wc=WordCloud(font_path=fontPath,width=800,height=800,background_color="white",min_font_size=10)
wc.generate_from_frequencies(my_dict)
wc.to_file("D:\myPython\AIProject\Beauty.png")
'
,@input_data_1=@sqlQuery
GO
---------------------------------------------------------------------------------------
--產生直條圖
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

SELECT TOP(20)[Keyword],SUM(Cnt) AS Cnts
FROM T2
GROUP BY [Keyword]
ORDER BY [Cnts] DESC;
'
GO
