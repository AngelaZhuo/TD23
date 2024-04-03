function Switches = IndexGenerator(trial)
%    This is a helper function for complex indexing
%   odor1 is 5 for A, 6 for B and otherwise for both
%   odor2 is 7 for C, 8 for D and otherwise for both
%   R_NR is 1 for Reward, 0 for No Reward and otherwise for both

odor1 = trial(1); 
odor2 = trial(2); 
R_NR = trial(3);

if odor1 == 5
    sw1 = 5;
    sw2 = 5;
elseif odor1 == 6
    sw1 = 6;
    sw2 = 6;
else
    sw1 = 5;
    sw2 = 6;
end

if odor2 == 7
    sw3 = 7;
    sw4 = 7;
elseif odor2 == 8
    sw3 = 8;
    sw4 = 8;
else
    sw3 = 7;
    sw4 = 8;
end

if R_NR == 1
    sw5 = 1;
    sw6 = 1;
elseif R_NR == 0
    sw5 = 0;
    sw6 = 0;
else
    sw5 = 1;
    sw6 = 0;
end

Switches = [sw1, sw2, sw3, sw4, sw5, sw6];

end