%% 1.使用熵权法对指标项进行权重排序
% a.数据标准化
clc,clear
a = load("data1.mat");
a = a.data1;
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

% 寻找最优最劣方案
z_max = max(Z);
z_min = min(Z);

% 计算最优最劣距离
d_max = sqrt(sum((Z-z_max).^2,2));
d_min = sqrt(sum((Z-z_min).^2,2));

% 构造相对接近度
S = d_min ./ (d_max + d_min);

% 评分归一化
S = S./sum(S);

sum_bonus = 500000;
dis_bonus = sum_bonus*S;
writematrix(dis_bonus,'distribution.xlsx','Sheet','Range'); % 记录分配的绩效           
writematrix(w,'ww.xlsx','sheet','Range');
writematrix(S,'ss.xlsx','sheet','Range');





