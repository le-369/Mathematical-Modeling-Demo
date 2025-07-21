 clc,clear;
    num = 8; % 城市数量
    load('da.mat');
    load D.mat;
    % 输入城市间的距离矩阵
    %定义全局变量
    global dist;
    global min_length;
    global min_c;
    % 初始化结果变量
        dist = D;
        min_length = inf;
    % 尝试每个城市作为起点
    for start_city = 1:num
        c=[start_city];     %开始路径
        visited = true(1, num); 
        visited(start_city) = false;
        bk(c,start_city, visited, 0, 1);
    end
    % 输出结果
    fprintf('经过所有点的最短时间为: %.2f', min_length);
    fprintf('分钟\n');
    fprintf('路径为: ');
    disp(min_c);
    t=min_length+sum(da([31,44,61,83,100,115,147,158],4));
    fprintf('总工作时间: %.2f', t/60);
    fprintf('分钟\n');

