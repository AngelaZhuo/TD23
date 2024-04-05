function Mirko_TD23(M, TM, Events, YName, IfLegend, IfCS1)
%IfCS1=1 results in plots CS1 to US to see if CS1 can predict US
if IfCS1
    MirkoColor = {[1, 0, 0], [0.0039, 0.1765, 0.4314],...
                  [1, 0, 1], [0.0745, 0.6235, 1.0000], [0.5882, 0.0118, 0.5882], [0, 0, 1],...
                  [1, .5, .4],[.4, .4, 1],[.7, 0.1765, 0.4314],[.2, 0, 0.5]};
else
              MirkoColor = {[1, 0, 0], [0.0039, 0.1765, 0.4314],...
                  [1, 0, 1], [0.0745, 0.6235, 1.0000], [0.5882, 0.0118, 0.5882], [0, 0, 1],...
                  [0.9882, 0.7922, 0],[0.3373, 0.7216, 0.0667],[0.9804, 0.3843, 0.1255],[0.0039, 0.3216, 0.0863]};
end
[Neurons, Bins] = size(M, [1, 2]);
keep = sum(~isnan(M(end, 1, :)), "all");
M = M(:, :, 1:keep);
TM = TM(:, :, 1:keep);
First = 1:33; Second = First + 40; Third = Second(end)+8: Second(end)+8 + 90; 
Ax = PSTHindex(TM, [5, 99, 99]);
Bx = PSTHindex(TM, [6, 99, 99]);
ACx = PSTHindex(TM, [5, 7, 99]);
BCx = PSTHindex(TM, [6, 7, 99]);
ADx = PSTHindex(TM, [5, 8, 99]);
BDx = PSTHindex(TM, [6, 8, 99]);
if IfCS1
    A1x = PSTHindex(TM, [5, 99, 1]);
    A0x = PSTHindex(TM, [5, 99, 0]);
    B1x = PSTHindex(TM, [6, 99, 1]);
    B0x = PSTHindex(TM, [6, 99, 0]);
else
    C1x = PSTHindex(TM, [99, 7, 1]);
    C0x = PSTHindex(TM, [99, 7, 0]);
    D1x = PSTHindex(TM, [99, 8, 1]);
    D0x = PSTHindex(TM, [99, 8, 0]);
end

Range = (Events(1)-10):(Events(1)+22);
% A
Ma = NaN(Neurons, Bins, keep);
for u = 1:Neurons
    temp = M(u, :, squeeze(Ax(u, 1, :)));
    Ma(u, :, 1:size(temp, 3)) = temp;
end
Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
boundedline(First, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{1})
% B
Ma = NaN(Neurons, Bins, keep);
for u = 1:Neurons
    temp = M(u, :, squeeze(Bx(u, 1, :)));
    Ma(u, :, 1:size(temp, 3)) = temp;
end
Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
boundedline(First, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{2})
xline(11, '--','LineWidth', 2, 'Label', "CS1", 'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'Horizontal');
xline(23, '--', 'LineWidth', 2);  
ylabel(YName)
xlabel("Time (s)"); xlim([-1, 2.4])

% CS2.
Range = (Events(4)-10):(Events(4)+22);
% AC
Ma = NaN(Neurons, Bins, keep);
for u = 1:Neurons
    temp = M(u, :, squeeze(ACx(u, 1, :)));
    Ma(u, :, 1:size(temp, 3)) = temp;
end
Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
boundedline(Second, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{3})
% AD
Ma = NaN(Neurons, Bins, keep);
for u = 1:Neurons
    temp = M(u, :, squeeze(ADx(u, 1, :)));
    Ma(u, :, 1:size(temp, 3)) = temp;
end
Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
boundedline(Second, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{4})
% BC
Ma = NaN(Neurons, Bins, keep);
for u = 1:Neurons
    temp = M(u, :, squeeze(BCx(u, 1, :)));
    Ma(u, :, 1:size(temp, 3)) = temp;
end
Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
boundedline(Second, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{5})
% BD
Ma = NaN(Neurons, Bins, keep);
for u = 1:Neurons
    temp = M(u, :, squeeze(BDx(u, 1, :)));
    Ma(u, :, 1:size(temp, 3)) = temp;
end
Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
boundedline(Second, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{6})
xline(51, '--', 'LineWidth', 2, 'Label', "CS2", 'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'Horizontal');
xline(63, '--', 'LineWidth', 2);  

% US.
Range = (Events(6)-10):(Events(6)-10 + 90);
if IfCS1
    % A1
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(A1x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{7})
    % A0
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(A0x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{8})
    % B1
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(B1x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{9})
    % B0
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(B0x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{10})
    xline(91, '--', 'LineWidth', 2, 'Label', "US|CS1", 'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'Horizontal');
else
    % C1
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(C1x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{7})
    % C0
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(C0x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{8})
    % D1
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(D1x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{9})
    % D0
    Ma = NaN(Neurons, Bins, keep);
    for u = 1:Neurons
        temp = M(u, :, squeeze(D0x(u, 1, :)));
        Ma(u, :, 1:size(temp, 3)) = temp;
    end
    Avg = squeeze(mean(Ma, [1, 3], "omitnan"));
    SEM = squeeze(StdError(squeeze(mean(Ma, 1, "omitnan"))')); % check for the right axis of Std
    boundedline(Third, Avg(Range), SEM(Range), 'LineWidth', 2, 'alpha', 'Color', MirkoColor{10})
    xline(91, '--', 'LineWidth', 2, 'Label', "US", 'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'Horizontal');
end
% % % %

if IfLegend
    if IfCS1
        L = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ...    
        "A", "B", "AC", "AD", "BC", "BD", "A1", "A0", "B1", "B0"];
    else
        L = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ...    
        "A", "B", "AC", "AD", "BC", "BD", "C1", "C0", "D1", "D0"];
    end
    hold on
    for mi = 1:numel(MirkoColor)
        plot(Third(1:2), NaN(1, 2), "LineWidth", 2.5, "Color", MirkoColor{mi})
    end
    legend(L, "Box", "off", "Location", "northeast")
end
xlabel("Time (s)"); xlim([1, 171])
xticks([1, 11, 21, 31, 41, 51, 61, 71, 81, 91, 101, 111, 121, 131, 141, 151, 161, 171])
xticklabels([-1, 0, 1, 2, -1, 0, 1, 2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8])
hold off
end


function  DesiredIndex = PSTHindex(TM, TrialType)
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
        DesiredIndex(u, 1, t) = check1 & check2 & check3;
   end
end
DesiredIndex = logical(DesiredIndex);
end
    

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

function SEM = StdError(Data)
Valids = ~isnan(Data); Valids = sum(Valids, 1);
SEM = std(Data, 1, 1, "omitnan")./sqrt(Valids);
end

function SameYLim(fig, Samax)
for S = 1:size(Samax,1)
    MaxY = 0; MinY = inf;
    for A = 1:numel(Samax{S})
        nexttile(Samax{S}(A))
        ax = gca;
        MaxY = max(MaxY, ax.YLim(2));
        MinY = min(MinY, ax.YLim(1));
    end
    for A = 1:numel(Samax{S})
        nexttile(Samax{S}(A))
        ax = gca;
        ax.YLim(2) = MaxY;
        ax.YLim(1) = MinY;
    end
end
end