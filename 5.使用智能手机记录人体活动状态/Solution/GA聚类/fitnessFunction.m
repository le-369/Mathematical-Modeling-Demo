function score = fitnessFunction(cluster_assignments, data, num_clusters)
    % cluster_assignments 是一个 1 x m 的数组，表示每个数据点的簇分配
    % data 是一个 m x n 的矩阵
    % num_clusters 是簇的数量
    [m, ~] = size(data);
    sse = 0;
    for i = 1:num_clusters
        cluster_points = data(cluster_assignments == i, :);
        if ~isempty(cluster_points)
            center = mean(cluster_points, 1);
            sse = sse + sum(sum((cluster_points - center).^2));
        end
    end
    score = 1 / (1 + sse);  % 适应度值越高越好，故取1/SSE
end
