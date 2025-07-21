clc,clear

%% 加载经纬度数据
a = readtable('../../B题/附件1：xx地区.xlsx');
data = a{:,2:3};
time_minute = a{:,4};
%% 将经纬度数据转换为距离矩阵
n = size(data, 1);
distMatrix = zeros(n, n);
for i = 1:n
    for j = i+1:n
        distMatrix(i,j) = haversine(data(i,1), data(i,2), data(j,1), data(j,2));
        distMatrix(j,i) = distMatrix(i,j);
    end
end
% 计算距离时间矩阵
TimMatrix = 60.*distMatrix./20;

%% 遗传算法
% 遗传算法参数设置
popSize = 10;          % 种群大小
numGenerations = 100;   % 迭代次数
mutationRate = 0.05;    % 变异率
crossRate = 0.7;        % 交叉率

% 模拟退火参数设置
T0 = 1000;              % 初始温度 
alpha = 0.99;           % 温度降低速率
% numSAIterations = 1000;  % 每次退火的迭代次数 
Tmin = 1e-1;

indexMatrix = readtable("cluster.xlsx");
indexMatrix = table2array(indexMatrix);
indexMatrix = indexMatrix';
indexVector = indexMatrix(~isnan(indexMatrix));
indexVector = indexVector'+1;

% 初始化种群
population = zeros(popSize, n);
for i = 1:popSize
    population(i, :) = indexVector;
end

% 初始化保存最优解的变量
bestFitness = -Inf;         % 初始化最优适应度
bestRoute = [];             % 保存最优路径
bestDays = Inf;             % 保存最少天数
bestDailyWorkTimes = [];    % 保存每天的工作时间

% 开始遗传算法
for gen = 1:numGenerations
    % 计算适应度
    fitness = zeros(popSize, 1);
    daysRequired = zeros(popSize, 1);  % 保存每个个体的所需天数
    dailyWorkTimesArray = cell(popSize, 1);  % 保存每天的工作时间
    
    for i = 1:popSize
        [fitness(i), daysRequired(i), dailyWorkTimesArray{i}] = calculateFitness(population(i, :), TimMatrix, time_minute);
    end
    
    % 更新最优解
    [currentBestFitness, bestIdx] = max(fitness);
    currentBestRoute = population(bestIdx, :);
    currentBestDays = daysRequired(bestIdx);
    currentBestDailyWorkTimes = dailyWorkTimesArray{bestIdx};

    if currentBestFitness > bestFitness
        bestFitness = currentBestFitness;
        bestRoute = currentBestRoute;
        bestDays = currentBestDays;
        bestDailyWorkTimes = currentBestDailyWorkTimes;
    end
    
    % 应用模拟退火优化最优解
    [optimizedRoute, ~] = simulated_annealing(currentBestRoute, TimMatrix, time_minute, T0,alpha, Tmin);
    [optimizedFitness,optimizedDays,optimizedDailyWorkTimes] = calculateFitness(optimizedRoute, TimMatrix, time_minute);
    
    if optimizedFitness > bestFitness
        bestFitness = optimizedFitness;
        bestRoute = optimizedRoute;
        bestDays = optimizedDays;
        bestDailyWorkTimes = optimizedDailyWorkTimes;
    end
    
    % 选择与产生下一代
    newPopulation = zeros(popSize, n);
    for i = 1:popSize
        parent = selection(population, fitness);
        
        % 交叉（在同一条染色体内部）
        if rand < crossRate
            offspring = crossover_single_chromosome(parent);
        else
            offspring = parent;
        end
        
        % 变异
        if rand < mutationRate
            offspring = mutate(offspring);
        end
        
        newPopulation(i, :) = offspring;
    end
    
    % 更新种群
    population = newPopulation;
end

% 输出最优解
disp(['最优路径的天数: ', num2str(bestDays)]);
disp(['最优路径: ', num2str(bestRoute)]);
disp('每天的工作时间 (小时): ');
disp(bestDailyWorkTimes./60);
disp('工作总时间为：(小时)：')
disp(sum(bestDailyWorkTimes)/60);