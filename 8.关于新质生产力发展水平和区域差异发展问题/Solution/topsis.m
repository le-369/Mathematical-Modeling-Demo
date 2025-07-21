function [w,S] = topsis(a)
%% 1.使用熵权法对指标项进行权重排序
% a.数据标准化
[n,m] = size(a);
a(a == 0) = 0.00001;
z = a ./ sqrt(sum(a.^2));   % z是统一量纲后的矩阵

% b.计算权重
p = z./sum(z);                  % 计算概率矩阵
e = -sum(p.*log(p))/log(n);     % 计算信息熵(越小越重要)
d = 1-e;                        % 计算信息效用值
w = d./sum(d);                  % 计算权重

%% 2.使用TOPSIS方法
% 构造加权矩阵
Z = z.*w;
Z1=Z(:,1:2);
Z2=Z(:,3:4);
Z3=Z(:,5:8);
n = {Z1,Z2,Z3,Z};
S={};
for i=1:4
% 寻找最优最劣方案
    z_max = max(n{i});
    z_min = min(n{i});
    % 计算最优最劣距离
    d_max = sqrt(sum((n{i}-z_max).^2,2));
    d_min = sqrt(sum((n{i}-z_min).^2,2));
    % 构造相对接近度
    S{i} = d_min ./ (d_max + d_min);
    % 评分归一化
    S{i} = S{i}./sum(S{i});
end