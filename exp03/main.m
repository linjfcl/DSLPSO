% 汇总模型，并测试
addpath('../FitnessFunc');

% 预期运行时间16h

%% 1. 清空数据，设置运行路径
clc;
clear;
close all;


%% 2. 设置运算的基本参数

% 运行参数
Para.NIoT  = 100;                   % 传感器的数量
Para.totaltime  = 100;             	% 算法的运行次数，多次运行求平均
Para.maxEvaluations = 100000;       % 算法的迭代次数

Para.NSP    = Para.NIoT;            % 初始种群的个数，最多的情况下与传感器数量一致

% 范围参数
arrange = 1000;
Para.lu = [ 
          0,        0,    200;
    arrange,  arrange,    200
];

% 算法设定参数
Para.p      = 0.1;
Para.K      = 5;                    % 对应文章中的M，表示无人机在一个站点上能负责的传感器的数量的上限
Para.rho    = 1e-6;
Para.sigma  = 1e-28;
Para.B      = 1e6;
Para.ph     = 1000;
Para.phd    = 1000;                 % 飞行时的功率消耗，实际上四旋翼无人机在最经济的巡航速度下甚至可能达到悬停时的80%
Para.speed  = 10;                   % 无人机的平均飞行速度
Para.F      = 0.6;
Para.CR     = 0.5;                  % 在DE算法中的变异率

Para.print  = false;                 % 是否需要打印信息
Para.save   = true;                 % 这个参数为true的时候，会根据Param.name来保存数据


%% 3. 生成测试数据
% 随机生成传感器的信息，根据无人机的坐标限制来生成的
% Data.IoTPosition = rand(Para.NIoT, 3) * arrange;   % 生成三维坐标
% Data.IoTPosition = [rand(Para.NIoT, 2) * arrange, zeros(Para.NIoT, 1)]; % 生成二维坐标


% D表示某一个传感器要发送的数据量
% Data.D = rand(1, Para.NIoT) * 1e9;

%% 4. 运行

for niot=100:100:500
    for arrange=1000:1000:3000
        Para.NIoT = niot;
        Para.NSP  = Para.NIoT;
        Para.lu = [0,       0,      200;    arrange,    arrange,    200];
        Data.D              =  rand(1, Para.NIoT) * 1e9;
        Data.IoTPosition    = [rand(Para.NIoT, 2) * arrange, zeros(Para.NIoT, 1)];
        Para.name = "SLPSO_" + niot + "_" + arrange;
        SLPSO(Para, Data);
        Para.name = "DEVIP_" + niot + "_" + arrange;
        DEVIPS(Para, Data);
    end
end

%% 5. 统计输出
for niot=100:100:500
    for arrange=1000:1000:3000
        name = "SLPSO_" + niot + "_" + arrange;
        load(name, "record", "UAVPosition", "Data", "Para");
        r = result_test(UAVPosition, record(length(record)), Data, Para);
        fprintf("%d SLPSO_%d_%d AVG: %d  |  std: %d  |  rate: %.3f\n", niot, arrange, niot, mean(record), std(record), r)

        name = "DEVIP_" + niot + "_" + arrange;
        load(name, "record", "UAVPosition", "Data", "Para");
        r = result_test(UAVPosition, record(length(record)), Data, Para);
        fprintf("%d DEVIP_%d_%d AVG: %d  |  std: %d  |  rate: %.3f\n", niot, arrange, niot, mean(record), std(record), r)
    end
end
