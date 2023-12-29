addpath('../FitnessFunc');

%% 1. clear
clc;
clear;
close all;


%% 2. parameter

Para.NIoT  = 100;
Para.totaltime  = 1;
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

%% 4. run

for niot=100:100:300
    Para.NIoT = niot;
    Para.NSP  = Para.NIoT;
    Data.D              = load(['D_',num2str(Para.NIoT),'.dat']);
    Data.IoTPosition    = load(['IoTPosition_',num2str(Para.NIoT),'.dat']);
    Para.name = "SLPSO" + niot;
    SLPSO(Para, Data);
end

%% 5. plot
tiledlayout(2,2);

for niot=100:100:300
    nexttile;
    hold on
    name = "SLPSO" + niot;
    load(name, "UAVPosition", "Data");

    [tspLen, route] = LKH(UAVPosition(:,1:2));
    scatter(Data.IoTPosition(:,1), Data.IoTPosition(:,2), 'b')
    plot(UAVPosition(route, 1), UAVPosition(route, 2),  'ks-',...
         'MarkerSize', 10, 'MarkerFaceColor', [1, 0, 0]);

    Distance = pdist2(UAVPosition(:, 1:3), Data.IoTPosition);
    [~,a]    = min(Distance,[],1);
    for i = 1:size(UAVPosition,1)
        index = find(a == i);
        for ind = index
            plot([UAVPosition(i, 1), Data.IoTPosition(ind, 1)], ...
                 [UAVPosition(i, 2), Data.IoTPosition(ind, 2)], 'k--');
        end
    end
    xlabel("x/m");
    ylabel("y/m")

end

lgd = legend("IoT devices", "flight trajectory", "the connection between stop points and IoT devices");
lgd.Layout.Tile = 4;
