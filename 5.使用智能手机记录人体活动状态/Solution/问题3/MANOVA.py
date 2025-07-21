import numpy as np
import pandas as pd
from scipy.signal import welch,savgol_filter
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import load_iris
from statsmodels.multivariate.manova import MANOVA
import os
from sklearn.decomposition import PCA
import seaborn as sns
import pickle
import warnings
import statsmodels.api as sm
import matplotlib.pyplot as plt
from scipy.stats import kurtosis, skew
warnings.filterwarnings('ignore')

iris = load_iris()

# 平滑数据的函数
def savgol_filter_data(data, window_length=11, polyorder=2):
    return savgol_filter(data, window_length=window_length, polyorder=polyorder, axis=0)

# 提取时间域特征
def extract_time_domain_features(data):
    mean = np.mean(data, axis=0)
    std = np.std(data, axis=0)
    var = np.var(data, axis=0)
    min_val = np.min(data, axis=0)
    max_val = np.max(data, axis=0)
    kurt = kurtosis(data, axis=0)   # 峰度
    skewness = skew(data, axis=0)   # 偏度
    rms = np.sqrt(np.mean(data**2, axis=0)) # 均方根
    energy = np.sum(data**2, axis=0) # 总能量
    return np.concatenate([mean, std, var, min_val, max_val, kurt,
                           skewness, rms,energy])

def extract_frequency_domain_features(data, fs=100):
    all_features = []
    for i in range(data.shape[1]):
        f, Pxx = welch(data[:, i], fs, nperseg=512)
        # 提取功率谱密度的特征
        mean_freq = np.mean(Pxx)
        max_freq = np.max(Pxx)
        min_freq = np.min(Pxx)
        std_freq = np.std(Pxx)
        var_freq = np.var(Pxx)
        # 将所有特征合并为一个数组
        features = np.array([mean_freq, max_freq, min_freq, std_freq, var_freq])
        all_features.extend(features)
    return np.array(all_features)

def extract_features(df):
    # 提取前10秒的数据（假设每秒100个样本）
    sample_length = 1000  # 10秒 * 100样本/秒
    df = df.iloc[:sample_length]  # 仅保留前1000行
    
    # 提取加速度计和陀螺仪数据
    acc_data = df[['acc_x(g)', 'acc_y(g)', 'acc_z(g)']].values
    gyro_data = df[['gyro_x(dps)', 'gyro_y(dps)', 'gyro_z(dps)']].values
    
    smoothed_acc_data =  np.apply_along_axis(savgol_filter_data, 0, acc_data)
    smoothed_gyro_data = np.apply_along_axis(savgol_filter_data, 0, gyro_data)

    # 提取时间域特征
    acc_time_features = extract_time_domain_features(smoothed_acc_data)
    gyro_time_features = extract_time_domain_features(smoothed_gyro_data)
    
    # 提取频域特征
    acc_freq_features = extract_frequency_domain_features(smoothed_acc_data)
    gyro_freq_features = extract_frequency_domain_features(smoothed_gyro_data)

    # 融合特征
    combined_features = np.concatenate([acc_time_features, gyro_time_features,
                                         acc_freq_features, gyro_freq_features])
        
    return combined_features

if __name__ == "__main__":
    all_data_file = 'all_data.pkl'
    all_y_file = 'all_y.pkl'
    if os.path.exists(all_data_file) and os.path.exists(all_y_file):
        # 加载保存的数据
        with open('all_data.pkl', 'rb') as f:
            all_data = pickle.load(f)

        with open('all_y.pkl', 'rb') as f:
            all_y = pickle.load(f)

        print("Data loaded successfully.")
    else:
        # 创建一个列表来存储所有的DataFrame
        all_data = []
        all_y = []
        for k in range(4,14):
            for i in range(1, 13):  # 对应 a1 到 a12
                for j in range(1, 6):  # 对应 t1 到 t5
                    folder_name = f'../../附件2/Person{k}'
                    file_path = os.path.join(folder_name, f'a{i}t{j}.xlsx')
                    df = pd.read_excel(file_path)
                    all_data.append(df)
                    all_y.append(i)
        # 保存读取的数据到一个文件 (如pickle文件)
        with open(all_data_file, 'wb') as f:
            pickle.dump(all_data, f)
        with open(all_y_file, 'wb') as f:
            pickle.dump(all_y, f)
        print("Data saved successfully.")
    
    # 提取每个Excel文件的特征
    features = np.array([extract_features(df) for df in all_data])

    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(features)

    # 将 NumPy 数组转换为 DataFrame
    scaled_df = pd.DataFrame(scaled_features)

    # 创建一个空列表来存储每个实验人员的第一个活动的数据
    activity_data = []

    # 遍历每个人的特征矩阵，提取第一个活动类型的5行数据
    for i in range(3, scaled_df.shape[0], 60):
        activity_data.append(scaled_df.iloc[i:i+5, :])

    # 创建一个空列表来存储每个人的标准差
    std_data = []

    # 遍历每个人的数据
    for person_df in activity_data:
        # 计算每行的标准差
        row_std = np.std(person_df, axis=1)
        row_mean = np.mean(person_df,axis=1)
        # 将标准差结果转为 DataFrame 并添加到列表
        std_df = pd.DataFrame({'MeanDev': row_mean, 'StdDev': row_std})
        std_data.append(std_df)

    # 将提取的数据合并成新的 DataFrame
    # 将所有人的标准差数据合并成一个 DataFrame
    all_std_df = pd.concat(std_data, axis=0).reset_index(drop=True)
    person_labels = np.repeat(np.arange(1, 11), 5)

    data = all_std_df.copy()
    data['Person'] = person_labels
    # data.to_excel('mean_std_features.xlsx',index=False)

    # 定义因变量和自变量
    Y = data.iloc[:, :-1]  # 84列特征
    X = data[['Person']]  # 实验人员身份
    
    # 构建MANOVA模型并拟合
    manova = MANOVA(endog=Y, exog=X)
    result = manova.mv_test()

    # 打印结果
    print(result)

    # 箱线图
    plt.figure(figsize=(12, 6))

    plt.subplot(1, 2, 1)
    sns.boxplot(x='Person', y='MeanDev', data=data, palette='Set2')
    plt.title('MeanDev by Person')

    plt.subplot(1, 2, 2)
    sns.boxplot(x='Person', y='StdDev', data=data, palette='Set2')
    plt.title('StdDev by Person')

    # 绘制成对关系图
    sns.pairplot(data[['MeanDev', 'StdDev', 'Person']], hue='Person', palette='Set2')

    plt.tight_layout()
    plt.show()