function [fitness, total_days, daily_work_times] = calculateFitness(chromosome, TimMatrix, time_minute)
    daily_work_hours = 8.5 * 60;  % 转换为分钟
    total_days = 0;
    time_accum = 0;
    
    % 偏差惩罚的累积
    total_deviation = 0;
    daily_work_times = [];  % 记录每天的工作时间

    for i = 1:length(chromosome) - 1
        % 累积当前点的工作时间和下一个点的行程时间
        time_accum = time_accum + time_minute(chromosome(i));
        time_accum = time_accum + TimMatrix(chromosome(i), chromosome(i+1));
        % 检查是否超过了每日工作时间限制
        if time_accum > daily_work_hours
            total_days = total_days + 1;
            time_accum = time_accum - TimMatrix(chromosome(i), chromosome(i+1));
            if time_accum > daily_work_hours
                time_accum = time_accum - time_minute(chromosome(i)) - TimMatrix(chromosome(i-1), chromosome(i));
            end
            % 记录当天工作时间
            daily_work_times = [daily_work_times, time_accum];
            
            % 计算本天的时间偏差
            deviation = abs(time_accum - daily_work_hours);
            total_deviation = total_deviation + deviation;
            
            % 重置时间累积器为当前任务的时间（新的一天开始）
            time_accum = time_minute(chromosome(i)) + TimMatrix(chromosome(i), chromosome(i+1));
        end
    end

    % 记录最后一天的工作时间
    total_days = total_days + 1;
    deviation = abs(time_accum - daily_work_hours);
    total_deviation = total_deviation + deviation;
    daily_work_times = [daily_work_times, time_accum];

    % 适应度：主要目标是最小化天数，同时考虑偏差
    w1 = 0.9;  % 天数权重
    w2 = 0.1;  % 偏差权重

    fitness = 1 / (w1 * total_days + w2 * (total_deviation / total_days));
end
