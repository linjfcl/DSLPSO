
close all;

clc;
clear;

names = ["VPPSO", "SAPSO", "SLPSO"];
title_names = ["VPPSO", "SAPSO", "DSLPSO"];

load(names{1}, "Para")
total = length(names);
ra = zeros(total, Para.totaltime);
for func = 1:total
    name = names{func};
    load(name)
    main2_table.(name) = zeros(1, 5);
    main2_table.(name)(1) = mean(record);
    main2_table.(name)(2) = time / Para.totaltime;
    main2_table.(name)(3) = size(UAVPosition, 1);
    main2_table.(name)(4) = mean(record0);
    main2_table.(name)(5) = mean(record) - mean(record0);
    ra(func, :) = record(:, 1:Para.totaltime);
    
    devips = zeros(1, Para.maxEvaluations);
    for k = 1 : Para.totaltime
        tempArr = FbestRec(k, :);
        tempVal = 0;
        for i = 1:Para.maxEvaluations
            if tempArr(i) == 0
                tempArr(i) = tempVal;
            else
                tempVal = tempArr(i);
            end
        end
        tempArr(tempArr == 0) = [];

        for i = 1:(min(length(tempArr), length(devips)))
            devips(i) = devips(i) + tempArr(i);
        end
        xx = i : length(devips);
        devips(xx) = [];

    end
    devips = devips / Para.totaltime;
    devips(devips == 0) = [];
    eval("devips" + string(func) + "=devips;");
end

[a, ~] = find(ra == min(ra));
bestCount = zeros(1, total);
for i = 1:total
    bestCount(i) = sum(a == i);
end

colors = ["[0, 0, 0]",       "[0, 0, 0.5]",        "[0.39, 0.58, 0.92]",  ...
          "[0.6, 0.8, 0.2]", "[0.95, 0.64, 0.37]", "[1, 0.84, 0]", ...
          "[0, 0.75, 1]",    "[0.13, 0.54, 0.13]", "[0.3, 1, 0.4]"];
Marker = ["o", "+", "*", "s", "d", "^", "h", "x", 'o'];

figure;
hold on;
leg(total) = "";
MarkerIndices = '1:'+ string(Para.maxEvaluations/10) + ':' + string(Para.maxEvaluations);
for func = 1:total
    eval("plot(devips" + func + ", 'Color', " + colors(func) + ", 'Marker', '" + Marker(func) + "', 'MarkerIndices', " + MarkerIndices + ")")
    leg(func) = title_names(func);
end
legend(leg)
xlabel('FEs')
ylabel('Average energy consumption(W)')
% ylim([1.38e6, 1.44e6])
set(gcf, "position", [600,0,600,500]);
