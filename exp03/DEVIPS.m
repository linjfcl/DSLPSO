function [record, FbestRec, record0] = DEVIPS(Para, Data)
% DEVIPS + LKH
    
    tic;
    Para = ParaInitial(Para); 
    
    
    record   = zeros(1, Para.totaltime); 
    record0  = zeros(1, Para.totaltime);   
    initFes  = zeros(1, Para.totaltime);

    FbestRec = zeros(Para.totaltime, Para.maxEvaluations);  
    
    for run = 1 : Para.totaltime
       
        Para.evaluations = 0;
        C = 1;
        
        while C~=0
            UAVPosition = repmat(Para.lu(1, :), Para.NSP, 1) + rand(Para.NSP, length(Para.lu)) .* (repmat(Para.lu(2, :) - Para.lu(1, :), Para.NSP, 1));
    
            [Fbest,C] = Fitness(UAVPosition,Data.IoTPosition,Para,Data);
            Para.evaluations = Para.evaluations + 1;
            initFes(run) = Para.evaluations;
            if(initFes(run) > Para.maxEvaluations)
                disp("error")
                break;
            end
        end

        if C ~= 0
            continue;
        end

        G = 0;

        t_ins = 0;
        t_del = 0;
        t_rep = 0;
        t_non = 0;

        while(Para.evaluations < Para.maxEvaluations) 
            
            subpop = UAVPosition;
            [NS,n] = size(subpop);  
            offpop = zeros(NS,n);  
            for i = 1 : NS
                
                nouse = randperm(NS,3);
                
                V = subpop(nouse(1), : ) + Para.F .* (subpop(nouse(2), : ) - subpop(nouse(3), : ));
    
                vioLow = find(V < Para.lu(1, : ));
                V(1, vioLow) = Para.lu(1, vioLow);
    
                vioUpper = find(V > Para.lu(2, : ));
                V(1, vioUpper) =  Para.lu(2, vioUpper);
    
                jRand = unidrnd(3);             
                t = rand(1, n) < Para.CR;               
                t(1, jRand) = 1;                        
                t_ = 1 - t;                             
    
                offpop(i,:) = t .* V + t_ .* subpop(i,  : );
                
            end
            candidatePos = offpop;
            for i = 1:size(candidatePos,1) 
                
                InsUAVPosition = [UAVPosition;candidatePos(i,:)];
                [FIns,~] = Fitness(InsUAVPosition,Data.IoTPosition,Para,Data);
                
                r = randi(size(UAVPosition,1)); 
                RepUAVPosition = UAVPosition;
                RepUAVPosition(r,:) = candidatePos(i,:);
                [FRep,~] = Fitness(RepUAVPosition,Data.IoTPosition,Para,Data);
                
                r = randi(size(UAVPosition,1));
                RemUAVPosition = UAVPosition;
                RemUAVPosition(r,:) = [];          
                [FRem,~] = Fitness(RemUAVPosition,Data.IoTPosition,Para,Data);
                
                [FitnessImprove,index] = min([FIns-Fbest,FRep-Fbest,FRem-Fbest]);
                
                if FitnessImprove<0 && index == 1
                    UAVPosition = InsUAVPosition;
                    Fbest = FIns;
                    t_ins = t_ins + 1;
                elseif FitnessImprove<0 && index == 2
                    UAVPosition = RepUAVPosition;
                    Fbest = FRep;
                    t_rep = t_rep + 1;
                elseif (FitnessImprove<0 && index == 3) || (FRem-Fbest==0)
                    UAVPosition = RemUAVPosition;
                    Fbest = FRem;
                    t_del = t_del + 1;
                else
                    t_non = t_non + 1;
                end
                Para.evaluations = Para.evaluations +3;
                FbestRec(run, Para.evaluations) = Fbest;
            end
            G = G + 1;
        end
        
        Fbest = Fitness(UAVPosition(:, 1:3),Data.IoTPosition,Para,Data);
        record(run) = Fbest;
        record0(run) = Fitness(UAVPosition,Data.IoTPosition,Para,Data);
        if(Para.print)
            fprintf("insert %d, replace %d, delete %d, error %d\n", t_ins, t_rep, t_del, t_non);
        end
    end
    
    time = toc;
    if Para.save
        save(Para.name);
    end
    
end
    