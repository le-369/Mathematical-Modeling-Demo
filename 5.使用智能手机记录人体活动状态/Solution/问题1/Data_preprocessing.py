import pandas as pd
from scipy.signal import savgol_filter
import matplotlib.pyplot as plt
import numpy as np

"""绘制每组的数据"""
# 平滑数据的函数
def savgol_filter_data(data, window_length=11, polyorder=2):
    return savgol_filter(data, window_length=window_length, polyorder=polyorder, axis=0)

for i in range(3):
    # Load the Excel file for the first person (SY1)
    df = pd.read_excel(f'..\附件1\person3\SY{i+1}.xlsx')  # Replace with the correct path
    # Extract data
    acc_x = df['acc_x(g)']
    acc_y = df['acc_y(g)']
    acc_z = df['acc_z(g)']

    gyro_x = df['gyro_x(dps)']
    gyro_y = df['gyro_y(dps)']
    gyro_z = df['gyro_z(dps)']

    acc_x =  np.apply_along_axis(savgol_filter_data, 0, acc_x)
    acc_y =  np.apply_along_axis(savgol_filter_data, 0, acc_y)
    acc_z =  np.apply_along_axis(savgol_filter_data, 0, acc_z)
    gyro_x =  np.apply_along_axis(savgol_filter_data, 0, gyro_x)
    gyro_y =  np.apply_along_axis(savgol_filter_data, 0, gyro_y)
    gyro_z =  np.apply_along_axis(savgol_filter_data, 0, gyro_z)

    # Assume time is in seconds, with a 100 Hz sampling rate
    time = df.index / 100.0  # Adjust if needed

    # Plot accelerometer data
    plt.figure(figsize=(14, 6))

    plt.subplot(1, 2, 1)
    plt.plot(time, acc_x, label='acc_x')
    plt.plot(time, acc_y, label='acc_y')
    plt.plot(time, acc_z, label='acc_z')
    plt.title('3-axial accelerometer')
    plt.xlabel('Seconds')
    plt.ylabel('Sample')
    plt.legend()

    # Plot gyroscope data
    plt.subplot(1, 2, 2)
    plt.plot(time, gyro_x, label='gyro_x')
    plt.plot(time, gyro_y, label='gyro_y')
    plt.plot(time, gyro_z, label='gyro_z')
    plt.title('3-axial gyroscope')
    plt.xlabel('Seconds')
    plt.ylabel('Sample')
    plt.legend()

    plt.tight_layout()
    # plt.show()
    plt.savefig(f"SY{i+1}")