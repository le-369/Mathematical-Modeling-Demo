function id= jl(data,meth)
%%聚类优化方案
%meth==1,谱密度聚类
%meth==2,问题2的FCA聚类
%meth==3,kmeans; 
%%使用模拟退火求全局最优路径作为路线方案
%%进行kmeans聚类后求最优路径作为路线方案
if meth==1
idx=spectralcluster(data,24);;%计算轮廓系数选取较优的分类数24
id={};
s=[];
for m=1:24
    c=[];
    for j=1:222
        if m==idx(j)
            c=[c,j];
        end
    end
    id{m}=c;
end
end

if meth==2
    load class.mat;
    class=class+1;      %从1开始
    id={};
    s=[];
    for m=1:length(class)
        c=class(m,:);
        id{m}=c;
    end
end

if meth==3
    idx=kmeans(data,24);%计算轮廓系数选取较优的分类数24
    id={};
    s=[];
    for m=1:24
        c=[];
        for j=1:222
            if m==idx(j)
                c=[c,j];
            end
        end
        id{m}=c;
    end
end
    
end