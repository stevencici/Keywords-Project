import requests
import time
import bs4
import json
import pandas as pd
import pyodbc
import random
import datetime



def vogue(page,topage,articlebefore='', forum='beauty'):
    '''不同文章版面。可輸入FASHION,BEAUTY,ENTERTAINMENT,LIFESTYLE,LUXURY,SHOPPING,VIDEO,VOGUE有意識'''
    baseurl = "https://www.vogue.com.tw"
    url1 = baseurl + '/{}'.format(forum)
    #page = 1
    keepgoing = 1
    headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36'}
    dict_article = {}
    title_list = []
    date_list = []
    content_list = []

    while keepgoing:
        url = url1 + '?page={}'.format(page)
        try:
            htmlFile = requests.get(url,headers=headers)
            if htmlFile.status_code == requests.codes.ok:
                print('成功進入vogue網頁')

            soup = bs4.BeautifulSoup(htmlFile.text, "html.parser")
            links = soup.find_all('a', {"class": "SummaryItemHedLink-cgPsOZ kPWpPh summary-item-tracking__hed-link summary-item__hed-link"})
            linkselement = []
            for link in links:
                linkselement.append(link['href'].encode('utf-8'))
        except Exception:
            time.sleep(5)
            print("Error, reconnect in 5 seconds")
            continue


        i = 1
        while linkselement:
            try:
                linkpart = linkselement.pop(0)
                articleUrl = baseurl + '{}'.format(str(linkpart)[2:-1].replace('\\x', '%'))
                request = requests.get(articleUrl,headers=headers)
                articleSoup = bs4.BeautifulSoup(request.text,'html.parser')
                data_title = articleSoup.find('title').text[:-15].replace('\n', '').replace(',', '')
                data_date = articleSoup.find('time').text    #%年%月%日
                data_date = datetime.datetime.strptime(data_date, "%Y年%m月%d日")  #"%Y-%m-%d"
                if articlebefore == '':
                    today = datetime.datetime.today()
                    time_before = today - datetime.timedelta(days=7)  # weekago
                else:
                    time_before = datetime.datetime.strptime(str(articlebefore), "%Y-%m-%d")
                if data_date <= time_before:
                    keepgoing = 0
                    break

                if page > topage:
                    keepgoing = 0
                    break

                scripttag = articleSoup.find("script", {"type": "application/ld+json"})
                list_ = scripttag.contents  # jsonarray
                str_ = "".join(list_)
                url_dict = json.loads(str_)

                article1 = url_dict['articleBody'].replace('\n', '').replace(',', '')
                data_article = article1.replace('article', '').replace('image', '').replace('articles', '')
                print('成功匯入第', page, '頁的第', i, '篇文章網頁')

                title_list.append(data_title)
                date_list.append(data_date)
                content_list.append(data_article)
                i += 1
                time.sleep(random.random())
            except KeyError:
                i += 1
                with open(r'D:\myPython\AIProject\雜誌爬蟲\FailRecord.txt', mode='a', encoding='utf-8') as fileobj:
                    fileobj.write(str(data_date) + articleUrl + '\n')
                continue
        page += 1


    dict_article = {'title':title_list, 'date':date_list, 'content':content_list }
    articleframe = pd.DataFrame(dict_article)
    #print(articleframe)
    return articleframe



if __name__ == '__main__':
    vogue(page=25,topage=25,articlebefore='2021-07-01', forum='beauty')

