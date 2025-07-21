clear,clc;
%读取文件，
w1=xlsread('ww.xlsx');%w1权重
w2=xlsread("第1题A题-附件2.xlsx");%w2数据
ww1=w1       %权重
ww2 = [w2(:, 3:18)]; %成果数据
[q, ind] = sort(ww1, 'descend');    %将权重从大到小排列保存它们在ww1中的索引
    m=20;                         %选出最重要的20个项目
    n=zeros(1,4);                   %上报项目数
    s=zeros(1,4);                   %得分数
m_s=1000000;                        %总奖金
b=[0.35 0.28 0.22 0.15];            %奖金比例
z_s=zeros(1,20);        %每个人的奖金
x=[];
y=[];
%计算每一组得分
for z=1:4                           %每个组
    for i=1:15                              %根据权重值从大到小选出20项从每个成员中
        y_1=0;
        for j=(1+(z-1)*5):(5+(z-1)*5)       
        if n(z)+ww2(j,ind(i))<=m            
            n(z)=ww2(j,ind(i))+n(z);
            y_1 = ww2(j,ind(i))+y_1;
            s(z)=ww2(j,ind(i))*ww1(ind(i))+s(z);
        else 
            s(z)=(m-n(z))*ww1(ind(i))+s(z);
            y_1=y_1+m-n(z);
            n(z)=m;
            break;
        end
        end
        if n(z)==m
            x=[x ind(i);];
            y=[y y_1];
            break;
        else
            x=[x ind(i)];
            y=[y y_1];
        end
    end
end
xy=[x;y];     % 统计个个项目选择申报的数目
h2=[w2(:,16)];
h2 = (h2 ./ sqrt(sum(h2.^2)))*10;%归一化，横向资金范围改为【1，10】


% m1=zeros(1,4);
% for i=1:4
%     m1(i)=max(h2((1+(i-1)*5):(5+(i-1)*5),1));
%     s(i)=m1(i)*h1+s(i);       
% end
[w, id] = sort(s, 'descend'); 

%计算各组奖金
g_s(1) = b(2)*1000000;
g_s(2) = b(3)*1000000;
g_s(3) = b(4)*1000000;
g_s(4) = b(1)*1000000;

%计算每个人的得分
www2= [w2(:, 3:15) h2 w2(:, 17:18)];
r_s=zeros(4,5);
www1=w1;
for j =1:4
    for i = 1:5
        for l=1:16
            r_s(j,i)=r_s(j,i)+www2((j-1)*5+i,l)*www1(l);
        end
    end
end

%计算每个人的奖金
for j =1:4
    for i = 1:5
        z_s((j-1)*5+i)=r_s(j,i)/sum(r_s(j,:))*g_s(j);
    end
end

disp(z_s);
writematrix(z_s,'pp.xlsx');
writematrix(r_s,'j.xlsx');
