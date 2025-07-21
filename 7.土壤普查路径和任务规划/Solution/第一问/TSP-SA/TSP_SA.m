clc,clear

%% 加载经纬度数据
a = readtable('../../B题/附件1：xx地区.xlsx');
rows = [31, 44, 61, 83, 100, 115, 147, 158];
data = a{rows,2:3};
time_minute = a{rows,4};
% data = a{:,2:3};
% time_minute = a{:,4};
%% 将经纬度数据转换为距离矩阵
n = size(data, 1);
distMatrix = zeros(n, n);
for i = 1:n
    for j = i+1:n
        distMatrix(i,j) = haversine(data(i,1), data(i,2), data(j,1), data(j,2));
        distMatrix(j,i) = distMatrix(i,j);
    end
end

%% 计算总时间
% 假设初始温度为10000，终止温度为1，降温系数为0.99，每温度迭代10000次
[best_route, best_dist] = simulated_annealing(distMatrix, 10000, 1, 0.99, 10000);

% 计算所需时间
plane_speed = 20; % km/h
total_time = best_dist / plane_speed + sum(time_minute)/60;
disp(['Total travel time: ', num2str(total_time), ' hours']);
%%
fprintf('最短路径为：\n');
for i = 1:length(best_route)
    fprintf('%d ', best_route(i));
    if mod(i, 10) == 0
        fprintf('\n');
    end
end
if mod(length(best_route), 10) ~= 0
    fprintf('\n');
end


%% 运行可视化函数
% 提取最佳路径的经纬度
longitudes = data(best_route, 1);
latitudes = data(best_route, 2);

% 创建地图
figure;
geoplot(latitudes, longitudes, '-o', 'MarkerSize', 5, 'LineWidth', 2);
title('Optimal Route on Map');
geobasemap landcover;  % 选择一个底图类型

% 添加标签
for i = 1:length(best_route)
    % 获取对应的rows值
    row_label = rows(best_route(i));
    % 在图上为每个点添加标签
    text(latitudes(i), longitudes(i), num2str(row_label), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% figure;
% % 绘制路径
% plot(longitudes, latitudes, '-o', 'MarkerSize', 5, 'LineWidth', 2);
% title('Optimal Route');
% xlabel('Longitude');
% ylabel('Latitude');
% grid on;
% axis equal;
% 
% % 添加标签
% for i = 1:length(best_route)
%     % 获取对应的rows值
%     row_label = rows(best_route(i));
%     % 在图上为每个点添加标签
%     text(longitudes(i), latitudes(i), num2str(row_label), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
% end
