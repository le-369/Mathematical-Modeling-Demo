import numpy as np
import pandas as pd
from scipy.signal import welch,savgol_filter
from sklearn.cluster import SpectralClustering,KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt
from sklearn.metrics import silhouette_score
import os
import warnings
from scipy.stats import kurtosis, skew
warnings.filterwarnings('ignore')

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
    f, Pxx = welch(data, fs, nperseg=512)
    # 提取功率谱密度的特征
    mean_freq = np.mean(Pxx,axis=0)
    max_freq = np.max(Pxx,axis=0)
    min_freq = np.min(Pxx,axis=0)
    std_freq = np.std(Pxx,axis=0)
    var_freq = np.var(Pxx,axis=0)
    return np.concatenate([mean_freq, max_freq, min_freq, std_freq, var_freq])

def extract_features(df):
    # 提取前10秒的数据（假设每秒100个样本）
    sample_length = 1000  # 10秒 * 100样本/秒
    df = df.iloc[:sample_length]  # 仅保留前1000行
    
    # 提取加速度计和陀螺仪数据
    acc_data = df[['acc_x(g)', 'acc_y(g)', 'acc_z(g)']].values
    gyro_data = df[['gyro_x(dps)', 'gyro_y(dps)', 'gyro_z(dps)']].values
    
    smoothed_acc_data = np.apply_along_axis(savgol_filter_data, 0, acc_data)
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
    # 创建一个列表来存储所有的DataFrame
    all_data = []
    all_y = []
    for i in range(1, 13):  # 对应 a1 到 a12
        for j in range(1, 6):  # 对应 t1 到 t5
            folder_name = f'../../附件2/Person12'
            file_path = os.path.join(folder_name, f'a{i}t{j}.xlsx')
            df = pd.read_excel(file_path)
            all_data.append(df)
            all_y.append(i)

    # 提取每个Excel文件的特征
    features = np.array([extract_features(df) for df in all_data])

    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(features)

    spectral = SpectralClustering(n_clusters=12, affinity='nearest_neighbors', assign_labels='kmeans')
    clusters = spectral.fit_predict(scaled_features)

    ########################################################## 存储数据 ##########################################################################
    # 创建一个字典，用于存储每个类别对应的文件名
    cluster_dict = {i: [] for i in range(12)}
    
    # 将文件夹名称根据聚类结果添加到字典中
    for i, label in enumerate(clusters):
        # 根据索引生成文件夹名称，如 a1t1, a1t2, ..., a12t5
        folder_index = i // 5 + 1  # 计算 a1 到 a12 的编号
        file_index = i % 5 + 1  # 计算 t1 到 t5 的编号
        folder_name = f'a{folder_index}t{file_index}'
        cluster_dict[label].append(folder_name)
    
    # 将聚类结果字典转换为 DataFrame
    cluster_df = pd.DataFrame(dict([(k, pd.Series(v)) for k, v in cluster_dict.items()]))
    
    # 将结果保存为 Excel 文件
    cluster_df.to_excel('../result2/person12_cluster.xlsx', index=False)