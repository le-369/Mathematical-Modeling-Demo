clear;
clc;
da=readtable("../../B题/附件1：xx地区.xlsx");
da=table2array(da);
data=da([31,44,61,83,100,115,147,158],2:3);
data = data * pi / 180;
R = 6370; % 地球半径
% 求解距离矩阵
for i = 1:length(data)
    for j = 1:length(data)
        D(i,j) = R*acos(cos(data(i,1)-data(j,1))*cos(data(i,2))*cos(data(j,2))+sin(data(i,2))*sin(data(j,2)));
    end
end

% 用蒙特卡洛方法进行验证
% 初始化总路径长度为无穷大
    S=randperm(8);
    Sum=0;
    for j=1:7 
        Sum=D(S(j),S(j+1))+Sum;
    end
for i = 1:1000
    change =randperm(8);
    change = sort(change(1:2));
    u = change(1);
    v = change(2);
    S1=S;
    t=S1(u);
    S1(u)=S1(v);
    S1(v)=t;
    temp = 0;
    for j=1:7 
        temp=D(S1(j),S1(j+1))+temp;
    end
    if temp < Sum
        S = S1;
        Sum = temp;
    end 
end
hold on
% 画线
for i = 1:7
    plot([data(S(i),1),data(S(i+1),1)], [data(S(i),2),data(S(i+1),2)],'r-')
end
title("路线图");
hold off
Time = Sum/20+sum(da([31,44,61,83,100,115,147,158],4))/60;
fprintf('总路程为%.4f km\n花费时间为%.4f h\n',Sum,Time);