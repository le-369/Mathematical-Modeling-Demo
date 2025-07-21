clc,clear,close all;
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

%% 提取新质生产力
dataMatrix = [];
for k = 1:11
   Matrix = every_score{k,1};
   dataMatrix = [dataMatrix,Matrix];
end

%% 
data = dataMatrix;

% 获取年份数量和城市数量
[numCities, numYears] = size(data);

% 预设颜色列表用于区分不同年份
colors = lines(numYears);

% 创建图形窗口
figure;
hold on;

% 循环每一年
for year = 1:numYears
    % 获取当前年份的数据并进行排序
    data_year = sort(data(:, year));
    
    % 计算累积比例
    cumulative_data = cumsum(data_year);
    total_data = sum(data_year);
    x = (1:numCities) / numCities; % 横轴：累积城市数的比例
    y = cumulative_data / total_data; % 纵轴：累积新质生产力评分的比例
    
    % 绘制洛伦茨曲线
    plot(x, y, '-o', 'LineWidth', 2, 'Color', colors(year, :), 'DisplayName', ['Year ' num2str(year+2011)]);
end

% 绘制45度参考线
plot([0 1], [0 1], '--k', 'LineWidth', 1.5, 'DisplayName', 'Line of Equality');

% 设置图形标题和轴标签
title('Lorenz Curve for Multiple Years');
xlabel('Cumulative Share of Cities');
ylabel('Cumulative Share of Productivity');
legend('show', 'Location', 'southeast');
grid on;

hold off;
