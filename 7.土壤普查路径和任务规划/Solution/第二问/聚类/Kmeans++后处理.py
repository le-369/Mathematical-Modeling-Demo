import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from geopy.distance import great_circle
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap

# 1. 导入数据
data = pd.read_excel('../B题/附件1：xx地区.xlsx')
coords = data[['WD', 'JD']].values

# 2. 定义计算地理距离的函数
def haversine_distance(coord1, coord2):
    return great_circle(coord1, coord2).kilometers

# 3. 使用KMeans++进行初步聚类
kmeans = KMeans(n_clusters=28, init='k-means++')
labels = kmeans.fit_predict(coords)

# 4. 处理每个聚类中的数据，确保每个类最多有8个点
clusters = {}
for i in range(28):
    clusters[i] = np.where(labels == i)[0]  # 获取属于当前聚类的所有点的索引

# 5. 对每个类进行检查和重新分配
for cluster_id, indices in clusters.items():
    if len(indices) > 8:
        # 计算到聚类中心的距离，并移出最远的点
        center = coords[indices].mean(axis=0)  # 计算当前类的聚类中心
        distances = np.array([haversine_distance(coords[i], center) for i in indices])
        sorted_indices = indices[np.argsort(distances)]  # 根据距离从小到大排序
        clusters[cluster_id] = sorted_indices[:8]  # 保留前8个最近的点
        extra_points = sorted_indices[8:]  # 需要重新分配的点

        for point in extra_points:
            # 寻找最近的聚类中心并分配
            min_dist = float('inf')
            closest_cluster = -1
            for target_cluster_id, target_indices in clusters.items():
                if len(target_indices) < 8:  # 目标类必须少于8个点
                    target_center = coords[target_indices].mean(axis=0)  # 计算目标类的聚类中心
                    dist = haversine_distance(coords[point], target_center)
                    if dist < min_dist:
                        min_dist = dist
                        closest_cluster = target_cluster_id
            # 更新最近类的点集
            clusters[closest_cluster] = np.append(clusters[closest_cluster], point)

# 6. 打印每一类的序号
for cluster_id, indices in clusters.items():
    print(f"Cluster {cluster_id+1}: {', '.join(map(str, data.iloc[indices]['序号'].values))}")

# 7. 创建一个DataFrame保存结果
# 创建一个DataFrame保存结果
cluster_results = []
for cluster_id, indices in clusters.items():
    cluster_str = '/'.join(map(str, indices))
    cluster_results.append([f'Cluster {cluster_id + 1}', cluster_str])
# 转换为DataFrame
df = pd.DataFrame(cluster_results, columns=['Cluster ID', 'Indices'])
# 保存为Excel文件
df.to_excel('cluster_results.xlsx', index=False)

# 8. 可视化聚类结果
colors = plt.cm.tab20(np.linspace(0, 1, 28))
plt.figure(figsize=(12, 8))
for cluster_id, indices in clusters.items():
    cluster_coords = coords[indices]
    plt.scatter(cluster_coords[:, 0], cluster_coords[:, 1], s=50, c=colors[cluster_id], label=f'Cluster {cluster_id+1}')

plt.title('KMeans++ Clustering of Sampling Points')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.legend(loc='upper right', bbox_to_anchor=(1.1, 1))
plt.show()