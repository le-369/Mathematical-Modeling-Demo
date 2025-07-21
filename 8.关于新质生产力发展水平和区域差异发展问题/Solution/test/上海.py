from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd


# 初始化 Selenium WebDriver
driver = webdriver.Chrome()

# 访问主页面
driver.get("https://tjj.sh.gov.cn/tjnj/nj23.htm?d1=2023tjnj/C0301.htm")

# 切换到需要的 frame，使用 frame 的名字或者索引
driver.switch_to.frame('main')  # 'main' 是你的 frame 名字
driver.switch_to.frame('mainFrame')   # 继续切换到嵌套的 frame

# 获取子页面内容
html_content = driver.page_source

# 关闭浏览器
driver.quit()

# 使用 BeautifulSoup 解析 HTML 内容
soup = BeautifulSoup(html_content, 'html.parser')

# 查找表格元素
table = soup.find('table', {'id': 'MtvTab'})

# 检查是否成功找到表格
if table:
    rows = table.find_all('tr')
    data = []

    for row in rows:
        cells = row.find_all('td')
        if len(cells) > 1:
            row_data = [cell.text.strip() for cell in cells]
            data.append(row_data)
    
    # 创建 DataFrame
    df = pd.DataFrame(data)
    df.to_excel('上海市生产总值数据.xlsx', index=False)
    print("数据已成功保存到 '上海市生产总值数据.xlsx'")
else:
    print("未找到表格")

