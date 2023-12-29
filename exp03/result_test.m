function rate = result_test(UAVPs, Fbest, Data, Para)
% 统计到达局部最优的次数

rate = 0;
delta = 10;

for i = 1:size(UAVPs, 1)

    ori = UAVPs(i, :);

    UAVPs(i, 1) = UAVPs(i, 1) + delta;
    F1 = Fitness(UAVPs(:, 1:3), Data.IoTPosition, Para, Data);
    rate = rate + (F1 < Fbest);
    UAVPs(i, :) = ori;

    UAVPs(i, 1) = UAVPs(i, 1) - delta;
    F2 = Fitness(UAVPs(:, 1:3), Data.IoTPosition, Para, Data);
    rate = rate + (F2 < Fbest);
    UAVPs(i, :) = ori;

    UAVPs(i, 2) = UAVPs(i, 2) + delta;
    F3 = Fitness(UAVPs(:, 1:3), Data.IoTPosition, Para, Data);
    rate = rate + (F3 < Fbest);
    UAVPs(i, :) = ori;

    UAVPs(i, 2) = UAVPs(i, 2) - delta;
    F4 = Fitness(UAVPs(:, 1:3), Data.IoTPosition, Para, Data);
    rate = rate + (F4 < Fbest);
    UAVPs(i, :) = ori;

end

rate = rate / size(UAVPs, 1);