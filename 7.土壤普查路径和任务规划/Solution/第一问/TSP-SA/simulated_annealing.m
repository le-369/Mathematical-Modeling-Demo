function [best_route, best_dist] = simulated_annealing(distMatrix, initTemp, minTemp, alpha, numIter)
    n = size(distMatrix, 1);
    current_route = randperm(n);
    best_route = current_route;
    current_dist = calc_total_distance(current_route, distMatrix);
    best_dist = current_dist;
    temp = initTemp;

    while temp > minTemp
        % 每个温度迭代numIter次
        for i = 1:numIter
            % 生成新解：随机交换两个城市的位置
            new_route = current_route;
            swap_idx = randperm(n, 2);
            new_route(swap_idx) = new_route(fliplr(swap_idx));
            
            new_dist = calc_total_distance(new_route, distMatrix);
            delta = new_dist - current_dist;
            
            % 如果距离更小，或者温度较高时进行更新
            if delta < 0 || rand() < exp(-delta/temp)
                current_route = new_route;
                current_dist = new_dist;
                
                % 更新最优解
                if current_dist < best_dist
                    best_route = current_route;
                    best_dist = current_dist;
                end
            end
        end
        temp = temp * alpha;
    end
end
