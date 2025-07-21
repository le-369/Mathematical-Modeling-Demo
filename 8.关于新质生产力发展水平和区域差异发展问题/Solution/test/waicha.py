import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
plt.rcParams['font.sans-serif']=['SimHei']
plt.rcParams['axes.unicode_minus']=False

# 已知年份（转换为相对数值）和两个指标的数据
years_relative = np.array([1, 2, 3, 4, 5, 6, 7])  # 对应2016~2022年
indicator1 = np.array([97.1151, 99.5509, 120.2789, 131.4831, 136.6547, 146.2258, 157.0741])
indicator2 = np.array([22.8725, 26.0669, 31.5725, 46.8932, 30.7165, 35.5868, 41.8552])

# 创建并拟合线性回归模型
model1 = LinearRegression().fit(years_relative.reshape(-1, 1), indicator1)
model2 = LinearRegression().fit(years_relative.reshape(-1, 1), indicator2)

# 准备预测的年份（2012~2015对应的相对数值-3到0）
years_to_predict = np.array([-3, -2, -1, 0])

# 预测2012~2015年的数据
predicted_indicator1 = model1.predict(years_to_predict.reshape(-1, 1))
predicted_indicator2 = model2.predict(years_to_predict.reshape(-1, 1))

# 输出预测结果
for i, year in enumerate(range(2012, 2016)):
    print(f"{year}年 - 指标1: {predicted_indicator1[i]:.4f}, 指标2: {predicted_indicator2[i]:.4f}")

# 可视化预测结果与原始数据
plt.figure(figsize=(10, 5))
plt.scatter(years_relative + 2015, indicator1, color='blue', label='教育支出')
plt.scatter(years_relative + 2015, indicator2, color='red', label='科学技术支出')
plt.scatter(years_to_predict + 2015, predicted_indicator1, color='blue', marker='x', label='教育支出 - 预测数据')
plt.scatter(years_to_predict + 2015, predicted_indicator2, color='red', marker='x', label='科学技术支出 - 预测数据')
plt.plot(years_relative + 2015, model1.predict(years_relative.reshape(-1, 1)), color='blue', linestyle='--')
plt.plot(years_relative + 2015, model2.predict(years_relative.reshape(-1, 1)), color='red', linestyle='--')
plt.xlabel('年份')
plt.ylabel('指标值')
plt.title('2012~2015年的数据外插预测')
plt.legend()
plt.grid(True)
plt.show()
