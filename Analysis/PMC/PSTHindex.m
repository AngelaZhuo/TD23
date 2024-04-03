function  DesiredIndex = PSTHindex(TM, TrialType,Manip)
% The DesiredIndex is a zeros-and-ones matrix of size [Neurons, 1, Trials]
% where a 1 is found where the trial in the TrialMatrix matches the 3-array
% of TrialType.
C = IndexGenerator(TrialType);
[units, ~, trials] = size(TM);
DesiredIndex = zeros(units, 1, trials);
for u = 1:units
    for t = 1:trials
        check1 = C(1) == TM(u, 1, t) || C(2) == TM(u, 1, t) ;
        check2 = C(3) == TM(u, 2, t) || C(4) == TM(u, 2, t) ;
        check3 = C(5) == TM(u, 3, t) || C(6) == TM(u, 3, t) ;
        if size(TM,2)==4
            check4 = TM(u,4,t) == Manip;
            DesiredIndex(u, 1, t) = check1 & check2 & check3 & check4;
        else
            DesiredIndex(u, 1, t) = check1 & check2 & check3;
        end
    end
end
DesiredIndex = logical(DesiredIndex);
end