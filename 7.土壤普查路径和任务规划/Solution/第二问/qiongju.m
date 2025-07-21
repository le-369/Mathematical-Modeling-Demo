clear;
clc;
%%载入数据
da=readtable("../B题/附件1：xx地区.xlsx");
load class.mat;
da=table2array(da);
data=da(:,[2,3]);
class=class+1;      %从1开始

s=[];       %距离
idx={};     %顺序

for m=1:length(class)   %%每类
    c=rmmissing(class(m,:));
    cc=data(c,:);
    cd = cc * pi / 180;
    R = 6370; % 地球半径
    % 求解距离矩阵
    for i = 1:length(cd)
        for j = 1:length(cd)
            D(i,j) = R*acos(cos(cd(i,1)-cd(j,1))*cos(cd(i,2))*cos(cd(j,2))+sin(cd(i,2))*sin(cd(j,2)));
        end
    end
    
    P = perms(1:length(c));     %%所有的排列
    Sum = inf;
    for i=1:length(P)
        tem=0;
        for j=1:length(cd)-1 
            tem=D(P(i,j),P(i,j+1))+tem;
        end
        if tem<Sum
            Sum=tem;
            idx{m}=c(P(i,:));
        end
    end
    s=[s;Sum];
    t(m)=Sum/20+sum(da(idx{m},4)/60);
end