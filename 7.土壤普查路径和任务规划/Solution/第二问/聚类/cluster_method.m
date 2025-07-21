clc;
clear all;

% 1. 导入数据
data = readtable('../B题/附件1：xx地区.xlsx');
lon = data{:,"JD"}; % 经度
lat = data{:,'WD'}; % 纬度

% 2. 计算相似度矩阵
n = size(data, 1);
distances = zeros(n, n);
for i = 1:n
    for j = i+1:n
        distances(i, j) = haversine(lon(i),lat(i),lon(j),lat(j)); % 使用haversine公式计算球面距离
        distances(j, i) = distances(i, j); % 对称矩阵
    end
end

sigma = mean(distances(:)); % 选择一个合适的 sigma 值
W = exp(-distances.^2 / (2 * sigma^2));

% 3. 使用谱聚类算法（可以指定K近邻或Kmeans方法）
num_clusters = 28;

% 使用k近邻构建相似度矩阵
k = 8; % 设定k近邻中的k值
[idx_nn, ~] = knnsearch([lon, lat], [lon, lat], 'K', k+1); % 找到k个最近邻
W_knn = zeros(n, n);
for i = 1:n
    W_knn(i, idx_nn(i, 2:end)) = W(i, idx_nn(i, 2:end)); % 保留k近邻的相似度
    W_knn(idx_nn(i, 2:end), i) = W(i, idx_nn(i, 2:end)); % 确保对称
end

% 进行谱聚类
idx_spectral = spectralcluster(W_knn, num_clusters);

% 使用kmeans算法
idx_kmeans = kmeans([lon, lat], num_clusters);

% 4. 输出每个类别的原始节点
disp('谱聚类结果（基于k近邻）：');
for i = 1:num_clusters
    disp(['Cluster ', num2str(i), ':']);
    disp(data(idx_spectral == i, :)); % 输出每个聚类的原始节点
end

disp('kmeans聚类结果：');
for i = 1:num_clusters
    disp(['Cluster ', num2str(i), ':']);
    disp(data(idx_kmeans == i, :)); % 输出每个聚类的原始节点
end

% 5. 可视化聚类结果
figure;
subplot(1, 2, 1);
gscatter(lon, lat, idx_spectral);
xlabel('Longitude');
ylabel('Latitude');
title('Spectral Clustering with k-NN');

subplot(1, 2, 2);
gscatter(lon, lat, idx_kmeans);
xlabel('Longitude');
ylabel('Latitude');
title('K-means Clustering');
