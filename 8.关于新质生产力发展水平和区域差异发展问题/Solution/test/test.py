import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
plt.rcParams['font.sans-serif']=['SimHei']
plt.rcParams['axes.unicode_minus']=False

# 已知年份（转换为相对数值）和两个指标的数据
years_relative = np.array([1, 2, 3, 4, 5, 6, 7,8,9])  # 对应2014~2022年
indicator1 = np.array([17456, 18789, 19957, 33029, 16885,35262, 15350,41300,39100])

# 创建并拟合线性回归模型
model1 = LinearRegression().fit(years_relative.reshape(-1, 1), indicator1)

# 准备预测的年份（2012~2013对应的相对数值-3到0）
years_to_predict = np.array([-1, 0])

# 预测2012~2015年的数据
predicted_indicator1 = model1.predict(years_to_predict.reshape(-1, 1))

# 输出预测结果
for i, year in enumerate(range(2012, 2014)):
    print(f"{year}年 - 指标1: {predicted_indicator1[i]:.4f}")

# 可视化预测结果与原始数据
plt.figure(figsize=(10, 5))
plt.scatter(years_relative + 2015, indicator1, color='blue', label='1')
plt.scatter(years_to_predict + 2015, predicted_indicator1, color='blue', marker='x', label='1 - 预测数据')
plt.plot(years_relative + 2015, model1.predict(years_relative.reshape(-1, 1)), color='blue', linestyle='--')
plt.xlabel('年份')
plt.ylabel('指标值')
plt.title('2012~2013年的数据外插预测')
plt.legend()
plt.grid(True)
plt.show()
