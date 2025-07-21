import pandas as pd
from scipy.signal import welch
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')


for i in range(3):
    # Load the Excel file for the first person (SY1)
    df = pd.read_excel(f'..\附件1\person3\SY{i+1}.xlsx') 

    # 提取加速度计和陀螺仪数据
    acc_data = df[['acc_x(g)', 'acc_y(g)', 'acc_z(g)']].values
    gyro_data = df[['gyro_x(dps)', 'gyro_y(dps)', 'gyro_z(dps)']].values

    # 定义每列的标签
    labels1 = ['acc_x', 'acc_y', 'acc_z']
    labels2 = ['gyro_x','gyro_y','gyro_z']

    plt.figure(figsize=(14,6))

    plt.subplot(1,2,1)
    # 对每一列数据计算功率谱密度
    for i in range(acc_data.shape[1]):
        f, Pxx = welch(acc_data[:, i], 100, nperseg=512)
        plt.semilogx(f, Pxx, label=labels1[i])
    
    plt.title('3-axial accelerometer')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Power Spectral Density (V^2/Hz)')
    plt.legend()
    plt.grid()

    plt.subplot(1,2,2)
    # 对每一列数据计算功率谱密度
    for i in range(gyro_data.shape[1]):
        f, Pxx = welch(gyro_data[:, i], 100, nperseg=512)
        plt.semilogx(f, Pxx, label=labels2[i])
    plt.title('3-axial gyroscope')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Power Spectral Density (V^2/Hz)')
    plt.legend()
    plt.grid()

    plt.suptitle('Power Spectral Density using Welch\'s Method')
    plt.show()