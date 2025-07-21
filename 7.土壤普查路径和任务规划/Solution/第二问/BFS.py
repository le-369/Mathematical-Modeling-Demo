import numpy as np
from geopy.distance import great_circle
import pandas as pd
import matplotlib.pyplot as plt
from collections import deque
import matplotlib.cm as cm

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

# 读取数据
data = pd.read_excel('../B题/附件1：xx地区.xlsx')
index = pd.read_excel('cluster.xlsx').values
coords = data[['WD', 'JD']].values

# 计算距离
def haversine_distance(coord1, coord2):
    return great_circle(coord1, coord2).kilometers

# 最短路径的 BFS 算法
def bfs_shortest_path(dist_matrix):
    n = len(dist_matrix)
    visited = [False] * n
    queue = deque([(0, [0], 0)])  # (当前节点，路径，当前总距离)
    shortest_path = None
    min_distance = float('inf')
    
    while queue:
        current, path, path_dist = queue.popleft()
        
        # 检查是否到达最后一个节点
        if len(path) == n:
            if path_dist < min_distance:
                min_distance = path_dist
                shortest_path = path
            continue
        
        for next_node in range(n):
            if not visited[next_node] and next_node not in path:
                queue.append((next_node, path + [next_node], path_dist + dist_matrix[current][next_node]))
    
    return shortest_path, min_distance

# 保存路径和时间信息
output_file = open('paths_and_time.txt', 'w')

# 不同颜色
colors = cm.rainbow(np.linspace(0, 1, len(index)))

# 开始绘图
plt.figure(figsize=(12, 10))

for cluster_num, cluster_indices in enumerate(index):
    cluster_indices = cluster_indices.astype(int)
    cluster_indices = cluster_indices[(cluster_indices >= 0)]
    cluster_coords = coords[cluster_indices, :]
    
    # 初始化距离矩阵
    dist = np.zeros((len(cluster_coords), len(cluster_coords)))
    
    for i in range(len(cluster_coords)):
        for j in range(i + 1, len(cluster_coords)):
            dist[i][j] = haversine_distance(cluster_coords[i], cluster_coords[j])
            dist[j][i] = dist[i][j]
    
    # 求解最短路径
    shortest_path, min_distance = bfs_shortest_path(dist)
    
    # 绘制路径
    color = colors[cluster_num]
    for i in range(len(shortest_path) - 1):
        start = cluster_coords[shortest_path[i]]
        end = cluster_coords[shortest_path[i + 1]]
        plt.plot([start[1], end[1]], [start[0], end[0]], 'o-', color=color)
    
    # 计算时间
    walking_speed = 20  # km/h
    working_time = sum(data.iloc[cluster_indices[shortest_path], 3])  # 从第四列获取工作时间
    travel_time = min_distance / walking_speed
    total_time = travel_time + working_time/60
    
    # 保存到文件
    output_file.write(f"簇 {cluster_num}: 路径 = {cluster_indices[shortest_path]}, 总距离 = {min_distance:.2f} 公里, 总时间 = {total_time:.2f} 小时\n")

# 标注和显示图
plt.xlabel('经度')
plt.ylabel('纬度')
plt.title('基于BFS的所有簇的最短路径')
plt.grid()
plt.show()

# 关闭文件
output_file.close()
