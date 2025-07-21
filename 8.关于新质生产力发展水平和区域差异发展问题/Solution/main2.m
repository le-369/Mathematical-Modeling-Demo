clc,clear,close all;
every_g=[];
soc1=[];
soc2=[];
soc3=[];
soc4=[];
%% 数据加载
every_score=[];
for i=1:11
    id=2012:2022;
    [data,header]=xlsread("指标x.xlsx",num2str(id(i)));
    data(:,5:6)=-data(:,5:6);
    [w,S]=topsis(data);
    every_score=[every_score;S];
    soc1=[soc1,S{1}];
    soc2=[soc2,S{2}];
    soc3=[soc3,S{3}];
    soc4=[soc4,S{4}];
end
%% 计算每年的城市间基尼系数；
for i=1:11
    id=2012:2022;
    [data,header]=xlsread("指标x.xlsx",num2str(id(i)));
    da=data(:,end);
    every_g= [every_g,gini(da)];
end

%基尼系数较大，区域间差异较大
plot(id, every_g, 'Color', [0, 0, 1], 'LineStyle', '-', ...
     'LineWidth', 1.5, 'Marker', 'o', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
title('基尼系数变化', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('年份', 'FontSize', 12);
ylabel('基尼系数', 'FontSize', 12);
% 设置网格线和其他图形属性
grid on;  % 打开网格线


