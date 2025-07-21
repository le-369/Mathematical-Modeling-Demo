clc,clear;close all;
%% 数据加载
every_score=[];
every_w=[];
for i=1:11
    id=2012:2022;
    [data,header]=xlsread("../支撑材料/指标.xlsx",num2str(id(i)));
    data(:,5:6)=-data(:,5:6);
    [w,S]=topsis(data);
    every_score=[every_score;S];
    every_w=[every_w;w];
end

%% 绘制每个城市11年间新质生产力的变化图
dataMatrix = [];
for k = 1:11
   Matrix = every_score{k,4};
   dataMatrix = [dataMatrix,Matrix];
end

years = 2012:2022;  % 时间范围
% 城市名称
cities = {'上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'};
% 创建一个新的图形窗口
figure;
hold on;  % 保持绘图窗口，以便在同一个图中绘制多个曲线
% 设置颜色和线条样式的选择
colors = lines(size(dataMatrix, 2));  % 使用MATLAB内置的颜色方案
lineStyles = {'-', '--', ':', '-.', '-', '--', ':'};  % 不同的线条风格
% 绘制每个城市的评分变化
for i = 1:size(dataMatrix, 1)
    plot(years, dataMatrix(i,:), 'Color', colors(i, :), 'LineStyle', lineStyles{i}, ...
        'LineWidth', 1.5, 'Marker', 'o', 'DisplayName', cities{i});  % 绘制每个城市的评分变化曲线
end
% 添加图例
legend('show', 'Location', 'best', 'FontSize', 10);
% 添加标题和轴标签
title('2012~2022城市生产力水平变化', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('年份', 'FontSize', 12);
ylabel('生产力水平', 'FontSize', 12);
% 设置网格线和其他图形属性
grid on;  % 打开网格线
set(gca, 'FontSize', 10, 'FontWeight', 'bold');  % 设置坐标轴字体和大小
hold off;
%% 绘制每个城市11年间科技创新生产力的变化图
dataMatrix = [];
for k = 1:11
   Matrix = every_score{k,1};
   dataMatrix = [dataMatrix,Matrix];
end

years = 2012:2022;  % 时间范围
% 城市名称
cities = {'上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'};
% 创建一个新的图形窗口
figure;
hold on;  % 保持绘图窗口，以便在同一个图中绘制多个曲线
% 设置颜色和线条样式的选择
colors = lines(size(dataMatrix, 2));  % 使用MATLAB内置的颜色方案
lineStyles = {'-', '--', ':', '-.', '-', '--', ':'};  % 不同的线条风格
% 绘制每个城市的评分变化
for i = 1:size(dataMatrix, 1)
    plot(years, dataMatrix(i,:), 'Color', colors(i, :), 'LineStyle', lineStyles{i}, ...
        'LineWidth', 1.5, 'Marker', 'o', 'DisplayName', cities{i});  % 绘制每个城市的评分变化曲线
end
% 添加图例
legend('show', 'Location', 'best', 'FontSize', 10);
% 添加标题和轴标签
title('2012~2022城市创新生产力变化', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('年份', 'FontSize', 12);
ylabel('生产力水平', 'FontSize', 12);
% 设置网格线和其他图形属性
grid on;  % 打开网格线
set(gca, 'FontSize', 10, 'FontWeight', 'bold');  % 设置坐标轴字体和大小
hold off;
%% 绘制每个城市11年间经济发展生产力的变化图
dataMatrix = [];
for k = 1:11
   Matrix = every_score{k,2};
   dataMatrix = [dataMatrix,Matrix];
end

years = 2012:2022;  % 时间范围
% 城市名称
cities = {'上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'};
% 创建一个新的图形窗口
figure;
hold on;  % 保持绘图窗口，以便在同一个图中绘制多个曲线
% 设置颜色和线条样式的选择
colors = lines(size(dataMatrix, 2));  % 使用MATLAB内置的颜色方案
lineStyles = {'-', '--', ':', '-.', '-', '--', ':'};  % 不同的线条风格
% 绘制每个城市的评分变化
for i = 1:size(dataMatrix, 1)
    plot(years, dataMatrix(i,:), 'Color', colors(i, :), 'LineStyle', lineStyles{i}, ...
        'LineWidth', 1.5, 'Marker', 'o', 'DisplayName', cities{i});  % 绘制每个城市的评分变化曲线
end
% 添加图例
legend('show', 'Location', 'best', 'FontSize', 10);
% 添加标题和轴标签
title('2012~2022城市经济发展生产力变化', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('年份', 'FontSize', 12);
ylabel('生产力水平', 'FontSize', 12);
% 设置网格线和其他图形属性
grid on;  % 打开网格线
set(gca, 'FontSize', 10, 'FontWeight', 'bold');  % 设置坐标轴字体和大小
hold off;
%% 绘制每个城市11年间资源与环境生产力的变化图
dataMatrix = [];
for k = 1:11
   Matrix = every_score{k,3};
   dataMatrix = [dataMatrix,Matrix];
end

years = 2012:2022;  % 时间范围
% 城市名称
cities = {'上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'};
% 创建一个新的图形窗口
figure;
hold on;  % 保持绘图窗口，以便在同一个图中绘制多个曲线
% 设置颜色和线条样式的选择
colors = lines(size(dataMatrix, 2));  % 使用MATLAB内置的颜色方案
lineStyles = {'-', '--', ':', '-.', '-', '--', ':'};  % 不同的线条风格
% 绘制每个城市的评分变化
for i = 1:size(dataMatrix, 1)
    plot(years, dataMatrix(i,:), 'Color', colors(i, :), 'LineStyle', lineStyles{i}, ...
        'LineWidth', 1.5, 'Marker', 'o', 'DisplayName', cities{i});  % 绘制每个城市的评分变化曲线
end
% 添加图例
legend('show', 'Location', 'best', 'FontSize', 10);
% 添加标题和轴标签
title('2012~2022城市资源与环境生产力变化', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('年份', 'FontSize', 12);
ylabel('生产力水平', 'FontSize', 12);
% 设置网格线和其他图形属性
grid on;  % 打开网格线
set(gca, 'FontSize', 10, 'FontWeight', 'bold');  % 设置坐标轴字体和大小
hold off;