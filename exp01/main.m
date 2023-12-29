
addpath('../FitnessFunc');


clc;
clear;
close all;




Para.NIoT  = 100;                 
Para.totaltime  = 100;             	
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


Data.IoTPosition = [rand(Para.NIoT, 2) * arrange, zeros(Para.NIoT, 1)]; 


Data.D = rand(1, Para.NIoT) * 1e9;

names = ["SAPSO", "SLPSO", "VPPSO"];

for i=1:length(names)
    t0 = now();
    name = names{i};
    Para.name = name;
    eval(name + "(Para, Data);")
    t1 = now();
end

fprintf("run time:%d\n", (t1 - t0) * 24*60*60);

res = zeros(3, Para.totaltime);
for i = 1:3
    name = names{i};
    load(name, "record");
    res(i, :) = record;
end

sum(res == min(res), 2)