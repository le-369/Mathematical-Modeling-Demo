clc,clear;
%% 数据加载
every_score=[];
every_w=[];
for i=1:11
    id=2012:2022;
    [data,header]=xlsread("../指标.xlsx",num2str(id(i)));
    data(:,5:6)=-data(:,5:6);
    [w,S]=topsis(data);
    every_score=[every_score;S];
    every_w=[every_w;w];
end

%% 存储every_score数据
% 创建一个空矩阵来存储转换后的数据
% 每个行代表一个年份 (11 年), 每个年份有 4 个指标, 每个指标有 7 个数
dataMatrix = zeros(11, 4 * 7);

% 填充 dataMatrix
for i = 1:11  % 对每一年
    for j = 1:4  % 对每个指标
        startCol = (j-1)*7 + 1;  % 当前指标的起始列索引
        endCol = startCol + 6;   % 当前指标的结束列索引
        dataMatrix(i, startCol:endCol) = every_score{i, j};  % 填入数据
    end
end

% 定义年份和指标名称
years = (2012:2022)';  % 年份列
indicators = {'Indicator1', 'Indicator2', 'Indicator3', 'Indicator4'};  % 自定义指标名称

% 创建表格 (table)，包括年份列
T = array2table(dataMatrix, 'VariableNames', strcat(repelem(indicators, 7), '_', string(repmat(1:7, 1, 4))));

% 添加年份列到表格中
T.Year = years;

% 将 'Year' 列移动到表格的第一列
T = movevars(T, 'Year', 'Before', 1);

% 将表格写入 Excel 文件
writetable(T, 'everyscore.xlsx');



%% 绘制2021年的图
% 将1x4的cell数组转换为7x4的矩阵
dataMatrix = [];
for i = 1:4
   Matrix = every_score{10,i};
   dataMatrix = [dataMatrix,Matrix];
end

% 绘制分组柱状图
figure;
bar(dataMatrix);

% 设置x轴刻度标签为城市名称
set(gca, 'XTickLabel', {'上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'});

% 添加图例，表示每个分组的含义
legend('科技创新生产力', '经济发展生产力', '资源与环境生产力', '综合评分');

% 设置图形标题和轴标签
title('2021年城市评分');
xlabel('Cities');
ylabel('Scores');

% 显示网格线
grid on;


%% 绘制2022年的图
% 将1x4的cell数组转换为7x4的矩阵
dataMatrix = [];
for i = 1:4
   Matrix = every_score{11,i};
   dataMatrix = [dataMatrix,Matrix];
end

% 绘制分组柱状图
figure;
bar(dataMatrix);
% 设置x轴刻度标签为城市名称
set(gca, 'XTickLabel', {'上海', '杭州', '苏州', '宁波', '嘉兴', '绍兴', '合肥'});
% 添加图例，表示每个分组的含义
legend('科技创新生产力', '经济发展生产力', '资源与环境生产力', '综合评分');

% 设置图形标题和轴标签
title('2022年城市评分');
xlabel('Cities');
ylabel('Scores');

% 显示网格线
grid on;
