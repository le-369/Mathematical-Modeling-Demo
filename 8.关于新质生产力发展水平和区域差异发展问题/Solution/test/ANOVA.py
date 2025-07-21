import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import f_oneway

plt.rcParams['font.sans-serif'] = ['SimHei'] 
plt.rcParams['axes.unicode_minus'] = False 

# 读取Excel文件
data1 = pd.read_excel('data/soc1.xlsx', header=None)
data2 = pd.read_excel('data/soc2.xlsx', header=None)
data3 = pd.read_excel('data/soc3.xlsx', header=None)
data4 = pd.read_excel('data/soc4.xlsx', header=None)

# 创建一个函数来对每个城市进行方差分析并绘制箱线图
def analyze_and_plot(data, title):
    # ANOVA 分析
    f_statistic, p_value = f_oneway(*[data.iloc[i, :] for i in range(data.shape[0])])
    
    print(f"ANOVA results for {title}:")
    print(f"F-statistic: {f_statistic:.4f}, P-value: {p_value:.4f}")

    # 绘制箱线图
    plt.figure(figsize=(10, 6))
    sns.boxplot(data=data.T, palette="Set2")  # 使用调色板美化箱线图
    plt.xticks(ticks=range(data.shape[0]), labels=['上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'], fontsize=12)
    plt.ylabel('Values', fontsize=12)
    plt.title(f'{title} 箱线图', fontsize=14)
    plt.grid(axis='y', linestyle='--', alpha=0.7)  # 添加网格线
    plt.show()

# 调用函数来分析每个数据集
analyze_and_plot(data1, '科技创新生产力')
analyze_and_plot(data2, '经济发展生产力')
analyze_and_plot(data3, '资源与环境生产力')
analyze_and_plot(data4, '新质生产力')
