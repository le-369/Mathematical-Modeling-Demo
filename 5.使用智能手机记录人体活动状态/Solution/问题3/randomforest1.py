import numpy as np
import pandas as pd
from scipy.signal import welch,savgol_filter
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler,LabelEncoder
from sklearn import metrics,preprocessing,tree,svm
from sklearn.tree import export_graphviz
import seaborn as sns
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from sklearn.datasets import load_iris
import os
import pickle
import warnings
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
    f, Pxx = welch(data, fs, nperseg=512)
    # 提取功率谱密度的特征
    mean_freq = np.mean(Pxx,axis=0)
    max_freq = np.max(Pxx,axis=0)
    min_freq = np.min(Pxx,axis=0)
    std_freq = np.std(Pxx,axis=0)
    var_freq = np.var(Pxx,axis=0)
    return np.concatenate([mean_freq, max_freq, min_freq, std_freq, var_freq])

def evaluate_classification(model, name, X_train, X_test, y_train, y_test):
    train_accuracy = metrics.accuracy_score(y_train, model.predict(X_train))
    test_accuracy = metrics.accuracy_score(y_test, model.predict(X_test))
    
    train_precision = metrics.precision_score(y_train, model.predict(X_train), average='micro')
    test_precision = metrics.precision_score(y_test, model.predict(X_test), average='micro')
    
    train_recall = metrics.recall_score(y_train, model.predict(X_train), average='micro')
    test_recall = metrics.recall_score(y_test, model.predict(X_test), average='micro')
    
    kernal_evals[str(name)] = [train_accuracy, test_accuracy, train_precision, test_precision, train_recall, test_recall]
    print("Training Accuracy " + str(name) + " {}  Test Accuracy ".format(train_accuracy*100) + str(name) + " {}".format(test_accuracy*100))
    print("Training Precesion " + str(name) + " {}  Test Precesion ".format(train_precision*100) + str(name) + " {}".format(test_precision*100))
    print("Training Recall " + str(name) + " {}  Test Recall ".format(train_recall*100) + str(name) + " {}".format(test_recall*100))
    
    actual = y_test
    predicted = model.predict(X_test)
    confusion_matrix = metrics.confusion_matrix(actual, predicted)
    conf_matrix_norm = confusion_matrix.astype('float') / confusion_matrix.sum(axis=1)[:, np.newaxis]
    
    # Display confusion matrix as heatmap with percentages
    plt.figure(figsize=(10, 10))
    sns.heatmap(conf_matrix_norm, annot=True, fmt='.2%', cmap='Blues', 
                xticklabels=['4', '5','6','7','8','9','10','11','12','13'], 
                yticklabels=['4', '5','6','7','8','9','10','11','12','13'])
    plt.xlabel('Predicted labels')
    plt.ylabel('True labels')
    plt.title('Normalized Confusion Matrix')
    plt.show()

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
    features_file = 'features.pkl'
    labels_file = 'labels.pkl'
    scaler_file = 'scaler.pkl'

    # 检查是否已经有保存的特征文件
    if os.path.exists(features_file) and os.path.exists(labels_file) and os.path.exists(scaler_file):
        # 直接加载保存的特征和标签
        with open(features_file, 'rb') as f:
            X = pickle.load(f)
        with open(labels_file, 'rb') as f:
            y = pickle.load(f)
        with open(scaler_file, 'rb') as f:
            scaler = pickle.load(f)
        print("Data loaded successfully.")
    else:
        # 创建一个列表来存储所有的DataFrame
        all_data = []
        all_y = []
        # 遍历文件夹
        for k in range(4,14):
            for i in range(1, 13):  # 对应 a1 到 a12
                for j in range(1, 6):  # 对应 t1 到 t5
                    folder_name = f'../../附件2/Person{k}'
                    file_path = os.path.join(folder_name, f'a{i}t{j}.xlsx')
                    df = pd.read_excel(file_path)
                    all_data.append(df)
                    all_y.append(k)

        # 提取每个Excel文件的特征
        features = np.array([extract_features(df) for df in all_data])

        # 标准化
        scaler = StandardScaler()
        X = scaler.fit_transform(features)
        y = pd.Series(all_y)

        # 保存特征、标签和标准化器
        with open(features_file, 'wb') as f:
            pickle.dump(X, f)
        with open(labels_file, 'wb') as f:
            pickle.dump(y, f)
        with open(scaler_file, 'wb') as f:
            pickle.dump(scaler, f)
        print("Data saved successfully.")

    x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=True)
    
    kernal_evals = dict()
    
    file_paths = [f'../../附件5/unknow1/a{i}t1.xlsx' for i in range(1, 13)]
    person1_data = [pd.read_excel(file_path) for file_path in file_paths]
    features = np.array([extract_features(df) for df in person1_data])
    scaler = StandardScaler()
    xx = scaler.fit_transform(features)

    rf = RandomForestClassifier().fit(x_train, y_train)
    # evaluate_classification(rf, "RandomForestClassifier", x_train, x_test, y_train, y_test)
    Y_predict = rf.predict(xx)
    print(Y_predict)
    