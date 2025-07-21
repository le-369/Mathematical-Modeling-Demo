import numpy as np
import skfuzzy as fuzz
import pulp
import pandas as pd
import matplotlib.pyplot as plt
from geopy.distance import great_circle

# 读取数据
data = pd.read_excel('../B题/附件1：xx地区.xlsx')
coords = data[['WD', 'JD']].values
# 计算地理距离矩阵
n_points = len(coords)
distance_matrix = np.zeros((n_points, n_points))
def haversine_distance(coord1, coord2):
    return great_circle(coord1, coord2).kilometers
for i in range(n_points):
    for j in range(i + 1, n_points):
        dist = haversine_distance(coords[i],coords[j])
        distance_matrix[i,j] = dist
        distance_matrix[j,i] = dist

# 使用FCM进行初步聚类
n_clusters = 28
cntr, u, _, _, _, _, _ = fuzz.cluster.cmeans(distance_matrix, n_clusters, 2, error=0.005, maxiter=1000, init=None)
uu = pd.DataFrame(u)
uu.to_excel('隶属度矩阵.xlsx', index=False)

# 构建整数规划问题
prob = pulp.LpProblem("Cluster_Assignment", pulp.LpMaximize)

# 创建变量：定义每个点分配给某个簇的决策变量
assignment = pulp.LpVariable.dicts("Assign", (range(len(coords)), range(n_clusters)), 0, 1, pulp.LpBinary)

# 目标函数：最大化隶属度
prob += pulp.lpSum([u[j][i] * assignment[i][j] for i in range(len(coords)) for j in range(n_clusters)])

# 约束条件1：每个点只能分配给一个簇
for i in range(len(coords)):
    prob += pulp.lpSum([assignment[i][j] for j in range(n_clusters)]) == 1

# 约束条件2：每个簇中的点数要在7到8个之间
for j in range(n_clusters):
    prob += pulp.lpSum([assignment[i][j] for i in range(len(coords))]) >= 7
    prob += pulp.lpSum([assignment[i][j] for i in range(len(coords))]) <= 8

# 求解
prob.solve()

# 获取最终的簇分配
final_labels = np.zeros(len(coords), dtype=int)
clusters = {i: [] for i in range(n_clusters)}  # 初始化 clusters 字典
for i in range(len(coords)):
    for j in range(n_clusters):
        if pulp.value(assignment[i][j]) == 1:
            final_labels[i] = j
            clusters[j].append(i)
            break

# 检查结果
final_counts = np.bincount(final_labels)
print("调整后每簇点数:", final_counts)

# 保存聚类结果，确保每个数字只占一个网格
cluster_results = []
for cluster_id, indices in clusters.items():
    for idx in indices:
        cluster_results.append([f'Cluster {cluster_id + 1}', idx])
df = pd.DataFrame(cluster_results, columns=['Cluster ID', 'Index'])
df.to_excel('cluster_results_single_cell.xlsx', index=False)

# 计算聚类后的聚类中心
final_cluster_centers = np.array([np.mean(coords[final_labels == i], axis=0) for i in range(n_clusters)])
print("聚类后的聚类中心:\n", final_cluster_centers)

# 可视化结果
plt.figure(figsize=(10, 8))
for i in range(n_clusters):
    plt.scatter(coords[final_labels == i, 1], coords[final_labels == i, 0], label=f'Cluster {i + 1}')

# 绘制聚类中心
plt.scatter(final_cluster_centers[:, 1], final_cluster_centers[:, 0], c='red', marker='x', s=300,alpha=0.5 ,label='Cluster Centers')

plt.title('Adjusted Clustering with Cluster Centers')
plt.xlabel('Longitude (JD)')
plt.ylabel('Latitude (WD)')
plt.legend(loc='upper right', bbox_to_anchor=(1.1, 1))
plt.tight_layout()
plt.show()
