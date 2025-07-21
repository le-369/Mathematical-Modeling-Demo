import numpy as np
import pandas as pd
from scipy.signal import welch,savgol_filter
import warnings
from scipy.stats import kurtosis, skew
import os
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
    return np.concatenate([mean, std, var, min_val, max_val, kurt,skewness, rms,energy])       # 返回27维

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
    return np.array(all_features)       # 返回15维

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
    person1_data = []
    # file_paths = [f'../附件1/Person1/SY{i}.xlsx' for i in range(1, 61)]
    # person1_data = [pd.read_excel(file_path) for file_path in file_paths]
    for i in range(1, 13):  # 对应 a1 到 a12
        for j in range(1, 6):  # 对应 t1 到 t5
            folder_name = f'../../附件2/Person4'
            file_path = os.path.join(folder_name, f'a{i}t{j}.xlsx')
            df = pd.read_excel(file_path)
            person1_data.append(df)

    # 将所有数据文件合并为一个DataFrame
    combined_data = pd.concat(person1_data, ignore_index=True)
    
    # 提取每个Excel文件的特征
    features = np.array([extract_features(df) for df in person1_data])
    
    # 定义特征名称
    time_feature_names = ['mean', 'std', 'var', 'min', 'max', 'kurt', 'skewness', 'rms', 'energy']  # 9
    freq_feature_names = ['mean_freq', 'max_freq', 'min_freq', 'std_freq', 'var_freq']              # 5
    
    acc_feature_names = [f'acc_{name}' for name in time_feature_names]
    gyro_feature_names = [f'gyro_{name}' for name in time_feature_names]

    acc_freq_feature_names = [f'acc_{name}' for name in freq_feature_names]
    gyro_freq_feature_names = [f'gyro_{name}' for name in freq_feature_names]

    feature_names = acc_feature_names*3 + gyro_feature_names*3 + acc_freq_feature_names*3 + gyro_freq_feature_names*3

    # 将 features 转换为 DataFrame，并将特征名称添加为列名称
    features_df = pd.DataFrame(features,columns=feature_names)

    # 保存到 Excel 文件
    features_df.to_excel('features.xlsx', index=False)