import numpy as np
import skfuzzy as fuzz
import pandas as pd
import matplotlib.pyplot as plt

# 读取数据
data = pd.read_excel('../B题/附件1：xx地区.xlsx')
coords = data[['WD', 'JD']].values

# 设定聚类数
n_clusters = 28

# 运行模糊C均值聚类
cntr, u, _, _, _, _, _ = fuzz.cluster.cmeans(coords.T, n_clusters, 2, error=0.005, maxiter=1000, init=None)

# 初步分配点到簇
labels = np.argmax(u, axis=0)

# 检查每个簇的点数
counts = np.bincount(labels, minlength=n_clusters)
print("初始每簇点数:", counts)

# 可视化初始聚类结果
plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
for i in range(n_clusters):
    plt.scatter(coords[labels == i, 1], coords[labels == i, 0], label=f'Cluster {i+1}')
plt.title('Initial Clustering')
plt.xlabel('Longitude (JD)')
plt.ylabel('Latitude (WD)')
plt.legend(loc='upper right')

# 调整超过8个点的簇
for cluster_idx, count in enumerate(counts):
    if count > 8:
        # 找出属于这个簇的点
        cluster_points = np.where(labels == cluster_idx)[0]
        # 选出隶属度最低的点并重新分配到其他簇
        distances = u[cluster_idx, cluster_points]
        indices_to_move = np.argsort(distances)[:(count - 8)]
        
        for idx in indices_to_move:
            # 找出第二高隶属度的簇，并确保目标簇未超员
            new_cluster = np.argsort(u[:, cluster_points[idx]])[::-1]
            for nc in new_cluster:
                if counts[nc] < 8:  # 检查目标簇是否已经满员
                    labels[cluster_points[idx]] = nc
                    counts[cluster_idx] -= 1
                    counts[nc] += 1
                    break

# 再次检查每个簇的点数
final_counts = np.bincount(labels, minlength=n_clusters)
print("调整后每簇点数:", final_counts)

# 可视化调整后的聚类结果
plt.subplot(1, 2, 2)
for i in range(n_clusters):
    plt.scatter(coords[labels == i, 1], coords[labels == i, 0], label=f'Cluster {i+1}')
plt.title('Adjusted Clustering')
plt.xlabel('Longitude (JD)')
plt.ylabel('Latitude (WD)')
plt.legend(loc='upper right')

plt.tight_layout()
plt.show()

# 将聚类结果保存到Excel文件中
output_df = pd.DataFrame(labels, columns=["Cluster"])
output_df.to_excel("模糊C均值后处理.xlsx", header=False, index=False)
