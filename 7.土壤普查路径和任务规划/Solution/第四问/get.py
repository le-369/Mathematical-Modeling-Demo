import requests
import json
import os
import time
import xlwt
import sys
import urllib.parse


flush_time = 60  # 刷新间隔，单位秒
file_name = "两地之间的开车时间.xls"

# 预置经纬度列表 (latitude, longitude)
# "纬度,经度"，-90<纬度<90,-180<经度<180
coordinates_list = [
    "38.112507,111.042637",  # 31
    "38.117061,111.073839",  # 44
    "38.116762,111.069797",  # 61
    "38.124064,111.057493",  # 83
    "38.119702,111.044954",  # 100
    "38.110755,111.040331",  # 115
    "38.118705,111.046929",  # 147
    "38.127754,111.065254"   # 158
]

workdir = os.path.dirname(os.path.realpath(sys.argv[0]))
file_path = os.path.join(workdir, file_name)
AK = "aHEBvVZ04N2wlYZGkBdhgSY4FL4eTytL"  # 百度地图API密钥


def getTimeAndDistance(start, end):
    encoded_start = urllib.parse.quote(start)
    encoded_end = urllib.parse.quote(end)
    url = f"https://api.map.baidu.com/directionlite/v1/driving?origin={encoded_start}&destination={encoded_end}&ak={AK}"
    print(f"Request URL: {url}")  # 打印请求URL
    res = requests.get(url)
    json_data = json.loads(res.text)

    if json_data["status"] == 0:
        duration = int(json_data['result']['routes'][0]['duration'])
        distance = int(json_data['result']['routes'][0]['distance'])
        return round(duration / 60, 1), round(distance / 1000, 2)
    else:
        print(json_data["message"])
        return -1, -1


# 设置标题样式
def set_title_style(blod=False, underline=False):
    style = xlwt.XFStyle()  # 初始化样式

    font = xlwt.Font()  # 为样式创建字体
    font.name = "Calibri"  # 字体类型
    font.height = 20 * 11  # 20为衡量单位,11为字号
    font.bold = blod  # 是否加粗
    font.underline = underline  # 是否添加下划线

    style.font = font
    return style

# 生成Excel文件
def createExcel(data, file_path):
    # 创建workbook和sheet对象
    workbook = xlwt.Workbook(encoding='utf-8')
    worksheet = workbook.add_sheet('计算两点间开车时间和距离')  # 设置工作表的名字
    for i in range(len(coordinates_list) + 1):
        worksheet.col(i).width = 256 * 30  # 设置每列宽, 256为衡量单位，30表示30个字符宽度

    # 写入Excel标题
    row0 = ["两点间开车时间(分钟)/距离(公里)"] + coordinates_list
    for i in range(len(row0)):
        worksheet.write(0, i, row0[i], set_title_style(True))

    for i, line in enumerate(data):
        for j, drive_time_distance in enumerate(line):
            worksheet.write(i + 1, j, str(drive_time_distance), set_title_style())
    workbook.save(file_path)
    print("[INFO] 成功创建%s" % file_path)

# 生成开车时间矩阵信息
def generateTimeMatrix(flush_time, file_path):
    while True:
        matrix_list = []  # 以矩阵的方式来存放两地之间的开车时间和距离
        alist = []  # 存放横坐标的值
        print("[INFO] 开始计算两地之间的开车时间和距离, 每隔%s秒刷新一次..." % flush_time)
        for start in coordinates_list:  # 起始位置作为纵坐标
            alist.append(start)
            for end in coordinates_list:  # 终点位置作为横坐标
                dt, dist = getTimeAndDistance(start, end)
                alist.append(f"{dt}分钟/{dist}公里" if dt != -1 else "N/A")
            matrix_list.append(alist)
            alist = []
        createExcel(matrix_list, file_path)
        time.sleep(flush_time)

if __name__ == "__main__":
    try:
        generateTimeMatrix(flush_time, file_path)
    except Exception as e:
        print('ERROR: %s' % e)
