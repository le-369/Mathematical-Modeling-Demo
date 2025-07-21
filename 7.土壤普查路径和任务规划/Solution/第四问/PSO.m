clc, clear

%% 加载经纬度数据
a = readtable("../B题/附件1：xx地区.xlsx");
rows = [31, 44, 61, 83, 100, 115, 147, 158];
data = a{rows,2:3};
time_minute = a{rows,4};

%% 将经纬度数据转换为距离矩阵
distMatrix=[0	3.94	3.64	3.16	3.37	0.34	2.4	 4.69;
3.94	0	0.29	4.81	5.02	5.41	4.05	6.35;
3.65	0.3	0	4.52	4.73	5.12	3.77	6.06;
3.16	4.88	4.58	0	2.6	4.63	1.63	1.52;
3.37	5.09	4.79	2.6	0	1.61	0.98	4.14;
0.34	5.75	5.46	3.27	1.61	0	1.65	4.8;
2.4	4.12	3.83	1.63	0.98	1.65	0	3.17;
4.7	6.42	6.12	1.52	4.14	6.17	3.17	0;
];
timeMatrix = [0	10.7	10.7	5.5	7.2	1.6	7.2	9;
10.7	0	5.8	9.6	11.3	13.4	11.3	13.1;
10.7	5.8	0	9.6	11.3	13.4	11.3	13.1;
5.8	9.9	9.9	0	4.2	8.5	4.2	3.5;
7.5	11.7	11.7	4.2	0	4.3	2.2	7.7;
1.6	13.6	13.6	6.2	4.4	0	4.2	9.7;
7.2	11.3	11.3	3.9	1.9	3.9	0	7.4;
9.2	13.3	13.3	3.4	7.7	11.9	7.7	0;
];

%% 设置混合粒子群优化算法参数
numParticles = 50;       % 粒子数量
maxIterations = 1000;    % 最大迭代次数
w = 0.7;                 % 惯性权重
c1 = 1.5;                % 认知学习因子
c2 = 1.5;                % 社会学习因子
vMin = -2;               % 速度最小值
vMax = 2;                % 速度最大值
pc = 0.8;                % 交叉概率
pm = 0.1;                % 变异概率

%% 运行混合粒子群优化算法
[bestRoute, bestDist] = mixedPSOTSP(distMatrix, numParticles, maxIterations, w, c1, c2, vMin, vMax, pc, pm);

% %% 计算总时间
%% 输出最短路径
fprintf('最短路径为：\n');
for i = 1:length(bestRoute)
    fprintf('%d ', bestRoute(i));
    if mod(i, 10) == 0
        fprintf('\n');
    end
end
if mod(length(bestRoute), 10) ~= 0
    fprintf('\n');
end
q=bestRoute(1);w=bestRoute(2);
e=bestRoute(3);r=bestRoute(4);
t=bestRoute(5); y=bestRoute(6);
u=bestRoute(7);i=bestRoute(8);
time = timeMatrix(q,w)+timeMatrix(w,e)+timeMatrix(e,r)+timeMatrix(r,t)+timeMatrix(t,y)+timeMatrix(y,u)+timeMatrix(u,i);
times = time + sum(time_minute);
times = times/60
fprintf('最短时间为：\n%d分钟\n',time);
%% 可视化路径
% visualize_route(bestRoute, data);

%% 混合粒子群优化算法
function [bestRoute, bestDist] = mixedPSOTSP(distMatrix, numParticles, maxIterations, w, c1, c2, vMin, vMax, pc, pm)

%% 初始化粒子
particles = cell(numParticles, 1);
for i = 1:numParticles
    particles{i}.position = randperm(size(distMatrix, 1)); % 初始位置
    particles{i}.velocity = zeros(1, size(distMatrix, 1)); % 初始速度
    particles{i}.bestPosition = particles{i}.position;     % 个人最佳位置
    particles{i}.bestFitness = calc_total_distance(particles{i}.position, distMatrix); % 个人最佳适应度
end
globalBestPosition = particles{1}.position; % 全局最佳位置
globalBestFitness = particles{1}.bestFitness; % 全局最佳适应度

%% 迭代更新粒子
for iter = 1:maxIterations
    for i = 1:numParticles
        % 更新速度
        r1 = rand(1, size(distMatrix, 1));
        r2 = rand(1, size(distMatrix, 1));
        particles{i}.velocity = w * particles{i}.velocity + ...
                                c1 * r1 .* (particles{i}.bestPosition - particles{i}.position) + ...
                                c2 * r2 .* (globalBestPosition - particles{i}.position);
        
        % 防止速度超出边界
        particles{i}.velocity = max(min(particles{i}.velocity, vMax), vMin);
        
        % 更新位置
        particles{i}.position = update_position(particles{i}.position, particles{i}.velocity);
        
        % 计算适应度
        particles{i}.fitness = calc_total_distance(particles{i}.position, distMatrix);
        
        % 更新个人最佳
        if particles{i}.fitness < particles{i}.bestFitness
            particles{i}.bestPosition = particles{i}.position;
            particles{i}.bestFitness = particles{i}.fitness;
        end
        
        % 更新全局最佳
        if particles{i}.bestFitness < globalBestFitness
            globalBestPosition = particles{i}.bestPosition;
            globalBestFitness = particles{i}.bestFitness;
        end
        
        % 交叉操作
        if rand() < pc
            particles{i}.position = crossover(particles{i}.position, globalBestPosition);
        end
        
        % 变异操作
        if rand() < pm
            particles{i}.position = mutate(particles{i}.position);
        end
    end
end 

bestRoute = globalBestPosition;
bestDist = globalBestFitness;

end 

%% 辅助函数
function updatedPosition = update_position(position, velocity)
    n = length(position);
    for i = 1:n
        if velocity(i) > 0
            j = i + round(velocity(i));
            if j > n
                j = j - n;
            end
        else
            j = i + round(velocity(i));
            if j < 1
                j = j + n;
            end
        end
        % 交换位置
        temp = position(i);
        position(i) = position(j);
        position(j) = temp;
    end
    updatedPosition = position;
end

function newPosition = crossover(pos, gbestPos)
    % 实现交叉操作
    % pos: 当前粒子的位置
    % gbestPos: 全局最优粒子的位置
    % 返回交叉后的粒子位置
    n = length(pos);
    
    crossPoint1 = floor(rand() * n) + 1; 
    crossPoint2 = floor(rand() * n) + 1;
    
    while crossPoint2 == crossPoint1
        crossPoint2 = floor(rand() * n) + 1;
    end
    
    if crossPoint1 > crossPoint2
        temp = crossPoint1;
        crossPoint1 = crossPoint2;
        crossPoint2 = temp;
    end
    
    newSegment = pos(crossPoint1:crossPoint2); 
    remainingCities = setdiff(gbestPos, newSegment);
    newPosition = [remainingCities(1:crossPoint1-1), newSegment, remainingCities(crossPoint1:end)];
end

function mutatedPosition = mutate(position)
    % 实现变异操作
    % position: 当前粒子的位置
    % 返回变异后的粒子位置
    n = length(position);
    mutPoint1 = floor(rand() * n) + 1;
    mutPoint2 = floor(rand() * n) + 1;
    while mutPoint2 == mutPoint1
        mutPoint2 = floor(rand() * n) + 1;
    end
    temp = position(mutPoint1);
    position(mutPoint1) = position(mutPoint2);
    position(mutPoint2) = temp;
    mutatedPosition = position;
end

function totalDist = calc_total_distance(route, distMatrix)
    n = length(route);
    totalDist = 0;
    for i = 1:(n-1)
        totalDist = totalDist + distMatrix(route(i), route(i+1));
    end
    totalDist = totalDist + distMatrix(route(n), route(1)); % 返回起点
end