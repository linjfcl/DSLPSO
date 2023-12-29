addpath('../FitnessFunc');

% Due to the relatively large amount of calculation, parallel computing is used, 
% and the runtime is run through the batchRun.m file

%% 1. clear
clc;
clear;
close all;


%% 2. parameter

Para.NIoT  = 100;              
Para.totaltime  = 10;          
Para.maxEvaluations = 100000;  

Para.NSP    = Para.NIoT; 


arrange = 1000;
Para.lu = [ 
          0,        0,    200;
    arrange,  arrange,    200
];


Para.p      = 0.1;
Para.K      = 5;   
Para.rho    = 1e-6;
Para.sigma  = 1e-28;
Para.B      = 1e6;
Para.ph     = 1000;
Para.phd    = 1000;
Para.speed  = 10; 
Para.F      = 0.6;
Para.CR     = 0.5;

Para.print  = false;
Para.save   = true;


%% 3. data
% Data.IoTPosition = rand(Para.NIoT, 3) * arrange;   % 3D
% Data.IoTPosition = [rand(Para.NIoT, 2) * arrange, zeros(Para.NIoT, 1)]; % 2D

% Data.D = rand(1, Para.NIoT) * 1e9;

%% 4. running

maxIoT = 6;
maxEva = 6;
estep = 100000;

tic
t1 = toc;
for n = 1:maxIoT
    niot = n * 100;

    Para.NIoT = niot;
    Para.NSP  = Para.NIoT;
    Data.IoTPosition    = [rand(Para.NIoT, 2) * arrange, zeros(Para.NIoT, 1)];
    Data.D              =  rand(1, Para.NIoT) * 1e9;

    parfor qtime = 2:5
        for eva = 1:maxEva
            maxEvaluations = eva * estep;
            name = "SLPSO_" + qtime + "_" + niot + "_" + maxEvaluations;
            SLPSO(Para, Data, qtime, name, maxEvaluations)
        end
    end
end
t2 = toc;
fprintf("运行时间%.2f秒\n", t2-t1);

%% 5. statistic


maxIoT = 6;
maxEva = 6;
estep = 100000;

output = zeros(8, maxIoT*maxEva);   
outlist = {                         
    zeros(maxIoT, maxEva), ...  
    zeros(maxIoT, maxEva), ...  
    zeros(maxIoT, maxEva), ...  
    zeros(maxIoT, maxEva)};     

for qtime = 2:5
    for n = 1:maxIoT
        niot = n * 100;
        for eva = 1:maxEva
            maxEvaluations = eva * estep;
            name = "SLPSO_" + qtime + "_" + niot + "_" + maxEvaluations;
            load(name, "record");
            fprintf("mean:%.3d | std:%.3d          ", mean(record), std(record))
            output((qtime-2)*2+1, maxEva*(niot/100-1) + eva) = mean(record);
            output((qtime-2)*2+2, maxEva*(niot/100-1) + eva) = std(record);
            outlist{qtime-1}(n, eva) = mean(record);
        end
    end
    fprintf("\n")
end

%% plot

tiledlayout(3,2);

Marker = ["o", "+", "*", "s", "d", "^", "h", "x", 'o'];
for eva = 1:6
    nexttile;

    hold on
    base = outlist{1}(:, eva);
    for qtime = 1:4
        style = Marker(qtime) + '-';
        plot(outlist{qtime}(:, eva) - base, style)
    end

    legend("qtime=2", "qtime=3", "qtime=4", "qtime=5", 'Location', "southwest")
    title("feMax=" + eva + "00k")
    ylim([-30000, 10000])
    xlabel("Number of IoT devices")
    ylabel("Energy comsumption(W)")
    set(gcf, "position", [600,0,1000,800]);
end
