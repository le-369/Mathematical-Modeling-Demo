clear;
% clc;
%%载入数据
da=readtable("../B题/附件1：xx地区.xlsx");
da=table2array(da);
data=da(:,[2,3]);
    cc=data;
    cd = cc * pi / 180;
    R = 6370; % 地球半径
    % 求解距离矩阵
    for i = 1:length(cd)
        for j = 1:length(cd)
            D(i,j) = R*acos(cos(cd(i,1)-cd(j,1))*cos(cd(i,2))*cos(cd(j,2))+sin(cd(i,2))*sin(cd(j,2)));
        end
    end
% 初始化各种参数
id= jl(data,1);
S0=[];
for i=randperm(length(id))
    S0=[S0,id{i}];
end
S0=rmmissing(S0);
%初始解
[t,s,day,dt]=fitness(S0,da,D);
tz=sum(t);
sz=sum(s);

% 模拟退火进行优化
% 初始化各种参数
for mm=1:5
T = 1000000;       % 设置初始温度
derate = 0.99;  % 设置退火率
T_min = 1e-100;  % 设置最小温度
while T > T_min
    % 变换法产生新解
    if rand(1)>0.5
        S1=[];
        for i=randperm(length(id))
            S1=[S1,id{i}];
        end
        S1=rmmissing(S1);
    else
        S1=S0;
    end
    change = randperm(222);
    change = sort(change(1:2));
    u = change(1);
    v = change(2);
    tm=S1(u);
    S1(u)=S1(v);
    S1(v)=tm;
    % 求与上一个解的差
    [t1,s1,day1,dt1]=fitness(S1,da,D);
    %适应度 delta_Sum
    delta_Sum=(day1+sum(t1)/10)-(day+sum(t)/10);
    % 接受准则
    if delta_Sum < 0
       t=t1;s=s1;day=day1;dt=dt1;
       S0=S1;
    elseif exp(-delta_Sum/T)>rand(1)*5
        t=t1;s=s1;day=day1;dt=dt1;
        S0=S1;
    end
    T = T*derate;
end
tz(mm)=sum(t);
sz(mm)=sum(s);
dd(mm)=day;
end