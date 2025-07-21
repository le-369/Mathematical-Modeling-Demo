function selected = selection(population, fitness)
    % 轮盘赌选择方法
    fitness_sum = sum(fitness);
    pick = rand * fitness_sum;
    current = 0;
    
    for i = 1:length(fitness)
        current = current + fitness(i);
        if current > pick
            selected = population(i, :);
            return;
        end
    end
end
