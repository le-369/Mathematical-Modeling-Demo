%% 求大气透射率
clear; clc;

% 读取数据
w1 = xlsread("附件.xlsx", 'sheet1');
w2 = xlsread("附件.xlsx", 'sheet2');

% 本地纬度
wd = deg2rad(30.58);      
% 检测时间（小时）
t = 24 * w1(:, 1);
% 到地强度
I_DN = w1(:, 2);           
% 太阳时角
sj = pi / 12 * (t - 12);  
% 太阳赤纬角，2023年5月23日
D = 143; 
delta = 23.45 * sind((360 / 365) * (D - 81));  % 太阳赤纬角
delta = deg2rad(delta);  % 转换为弧度

% 太阳高度角
sin_gdj = cos(delta) * cos(wd) * cos(sj) + sin(delta) * sin(wd);
gdj = asin(sin_gdj);

% 太阳方位角
cos_fwj = (sin(delta) - sin(gdj) .* sin(wd)) ./ (cos(gdj) .* cos(wd));
fwj = acos(cos_fwj);

%% 计算K值
% 大气层外层的辐射强度
I0 = 1334;
KL = sin(gdj).*log(I0./I_DN);
KL0 = movmean(KL,3);
KL0 = mean(KL0);