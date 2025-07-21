% 假设 data 是一个 m x n 的矩阵，其中 m 是样本数，n 是特征数
data = rand(100, 4);  % 生成随机数据作为示例
num_clusters = 3;     % 设定要分的簇数

% 定义适应度函数
fitnessFcn = @(x) fitnessFunction(x, data, num_clusters);

% 设置变量的范围，即每个数据点的簇编号在 [1, num_clusters] 之间
nvars = size(data, 1); % 变量数等于样本数
IntCon = 1:nvars; % 定义所有变量都是整数

% 设置遗传算法选项
options = optimoptions('ga', ...
    'PopulationSize', 100, ...
    'MaxGenerations', 50, ...
    'CrossoverFraction', 0.8, ...
    'MutationFcn', {@mutationuniform, 0.01}, ...
    'Display', 'iter', ...
    'UseParallel', true);  % 使用并行计算加快速度

% 使用遗传算法进行聚类
[bestSolution, fval] = ga(fitnessFcn, nvars, [], [], [], [], ...
                          ones(1, nvars), num_clusters * ones(1, nvars), [], IntCon, options);
clusters = unique(bestSolution);
for i = 1:length(clusters)
    cluster_idx = find(bestSolution == clusters(i));
    disp(['Cluster ', num2str(i), ':']);
    disp(cluster_idx');  % 显示属于该簇的数据点索引
end

% 你还可以绘制聚类结果的散点图（适用于二维或三维数据）
figure;
gscatter(data(:,1), data(:,2), bestSolution);
title('Clustering Result by Genetic Algorithm');
xlabel('Feature 1');
ylabel('Feature 2');

