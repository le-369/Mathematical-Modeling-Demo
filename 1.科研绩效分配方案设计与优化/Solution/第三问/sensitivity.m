%% 灵敏度分析
% 初始参数
rho_range = linspace(0.01, 1, 10); % 分辨系数的变化范围，从0到1，分成10个点
sensitivity_results = zeros(length(rho_range), 3); % 存储每组总绩效的结果
% 灵敏度分析循环
for i = 1:length(rho_range)
    rho = rho_range(i); % 更新分辨系数
    t=w2-w1;
    mmin =min(min(t));
    mmax = max(max(t));
    xishu = (mmin+rho*mmax)./(t+rho*mmax);
    xd=xishu.*w3;
    for j=1:7
        w4(j)=sum(xd(:,j));
    end
    for j=1:7
        w5(j) = w4(j)/sum(w4);
    end
    c=w5.*w1;
    c1=sum(c,2);
    c2 = [c1(1:5,1)'; c1(6:10,1)'; c1(11:15,1)'];
    c3(1) = sum(c1(1:5,1));
    c3(2) = sum(c1(6:10,1));
    c3(3) = sum(c1(11:15,1));
    c4=sum(c3);
    c5=c2./c4*10;
    mo2=mo3.*mo./mo1;
    mo4 = mo2+c5;
    mm(1)=sum(mo(1,:))*sum(mo3(1,:))/sum(mo1(1,:))/7+c3(1)*10/c4;
    mm(2)=sum(mo(2,:))*sum(mo3(2,:))/sum(mo1(2,:))/7+c3(2)*10/c4;
    mm(3)=sum(mo(3,:))*sum(mo3(3,:))/sum(mo1(3,:))/7+c3(3)*10/c4;
    
    % 存储不同rho值情况下各组绩效结果
    sensitivity_results(i, :) = mm;
end
%输出结果
for i = 1:length(rho_range)
    fprintf('%.2f\t%.2f\t%.2f\t%.2f\n', rho_range(i), sensitivity_results(i, 1), sensitivity_results(i, 2), sensitivity_results(i, 3));
end
% 定义颜色
color1 = [215/255, 99/255, 100/255]; % 红色
color2 = [84/255, 179/255, 69/255]; % 绿色
color3 = [95/255, 151/255, 210/255]; % 蓝色

% 绘制曲线
plot(rho_range, sensitivity_results(:,1), 'Color', color1, 'LineStyle', '--', 'Marker', 'o', 'DisplayName', '第一组')
hold on
plot(rho_range, sensitivity_results(:,2), 'Color', color2, 'LineStyle', '--', 'Marker', 'x', 'DisplayName', '第二组')
hold on
plot(rho_range, sensitivity_results(:,3), 'Color', color3, 'LineStyle', '--', 'Marker', '*', 'DisplayName', '第三组')
xlabel('分辨系数');
ylabel('每组的绩效');
title('每组绩效与分辨系数关系图')
legend show
hold off

%相对变化率
relativeChangeRates = zeros(size(sensitivity_results));
for i = 1:size(sensitivity_results, 1) 
    relativeChangeRates(i, :) = (sensitivity_results(i, :) - m(1, :)) ./ m(1, :);
end
disp(relativeChangeRates);