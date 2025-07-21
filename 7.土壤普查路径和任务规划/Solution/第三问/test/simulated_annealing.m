function [bestRoute, bestDays] = simulated_annealing(route, TimMatrix, time_minute, T0,alpha, Tmin)
    currentRoute = route;
    [~, currentDays,~] = calculateFitness(currentRoute, TimMatrix, time_minute);
    bestRoute = currentRoute;
    bestDays = currentDays;
    T = T0;
    % for iter = 1:numSAIterations
    while T>Tmin
        % 邻域搜索 - 通过交换两个位置产生新解
        newRoute = swapTwoPositions(currentRoute);
        [~, newDays,~] = calculateFitness(newRoute, TimMatrix, time_minute);
        
        % 计算适应度差
        delta = newDays - currentDays;

        % 接受准则
        if delta < 0 || rand < exp(-delta/T)
            currentRoute = newRoute;
            currentDays = newDays;
        end

        % 更新最优解
        if currentDays < bestDays
            bestRoute = currentRoute;
            bestDays = currentDays;
        end
        % 降温
        T = alpha * T;
    end
end

function newRoute = swapTwoPositions(route)
    n = length(route);
    pos1 = randi([1, n]);
    pos2 = randi([1, n]);
    newRoute = route;
    newRoute([pos1, pos2]) = route([pos2, pos1]);
end
