function [M, Removed] = CleanPupil_2024(M, TM, Events, Thresh, IfPlot)
Copy = M;
Mask = ones(size(M)); Mask(isnan(M)) = NaN;
Plo = NaN(size(M));
delta = M(1, 2:end, :) - M(1, 1:end-1, :);
% The "setdiff" is because I have a jitter bin
    %STD = std(delta, 0, "all", "omitnan"); AVG = mean(delta, "all", "omitnan");
STD = std(delta(:, setdiff(1:size(delta,2), Events(3)-1), :), 0, "all", "omitnan"); AVG = mean(delta(:, setdiff(1:size(delta,2), Events(3)-1), :), "all", "omitnan");
OL = zeros(size(delta));
OL(delta<AVG-5*STD) = -1; OL(delta>AVG+5*STD) = 2; 
% OL(delta<-35) = -1; OL(delta>+35) = 2; 
Removed = 0; 
for tr = 1:150
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:size(M,2)-1
        % There is no jitter in TD23
%         if b == Events(3)-1 
%             win = 0; cou = 0;
%             ver = 0; nichte = 0;
%             continue
%         end
        if cou == Thresh
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
        if OL(1, b, tr) == 0
            if win ~= 0
                cou = cou+1;
                continue
            end
        elseif OL(1, b, tr) == 2
            if win == 0
                ver = b+1;
                win = 2;
            elseif win == -1
                nichte = b;
                win = 1;
            elseif win == 2
                cou = 0;
            end
        elseif OL(1, b, tr) == -1
            if win == 0
                ver = b+1;
                win = -1;
            elseif win == 2
                nichte = b;
                win = 1;
            elseif win == -1
                cou = 0;
            end
        end
        if win == 1
            Mask(1, ver:nichte, tr) = NaN;
            Plo(1, ver-1:nichte+1, tr) = M(1, ver-1:nichte+1, tr);
            OL(1, ver-1:nichte-1, tr) = 0;
            Removed = Removed + 1;
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
    end
end
Copy = Copy.*Mask;
delta = Copy(1, 2:end, :) - Copy(1, 1:end-1, :);
OL = zeros(size(delta));
OL(delta<AVG-5*STD) = -1; OL(delta>AVG+5*STD) = -1; 
% OL(delta<-35) = -1; OL(delta>35) = -1; 
OL(1, Events(3)-1, :) = 0;
OL(isnan(delta)) = 2;
for tr = 1:150
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:167
        if cou == Thresh || b == Events(3)-1
            win = 0; cou = 0;
            ver = 0; nichte = 0;
            continue
        end
        if OL(1, b, tr) == 0
            if win ~= 0
                cou = cou+1;
                continue
            end
        elseif OL(1, b, tr) == 2
            if win == 0
                ver = b+1;
                win = 2;
            elseif win == -1
                nichte = b;
                win = 1;
            elseif win == 2
                cou = 0;
            end
        elseif OL(1, b, tr) == -1
            if win == 0
                ver = b+1;
                win = -1;
            elseif win == 2
                nichte = b;
                win = 1;
            elseif win == -1
                cou = 0;
            end
        end
        if win == 1
            Mask(1, ver:nichte, tr) = NaN;
            Plo(1, ver-1:nichte+1, tr) = M(1, ver-1:nichte+1, tr);
            OL(1, ver-1:nichte-1, tr) = 0;
            Removed = Removed + 1;
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
    end
end
Copy = M.*Mask;

% Interpolate values
Pla = NaN(size(M));
Interpolated = 0;
for tr = 1:150
    Times = 0;
    [Copy(1, :, tr), Pla(1, :, tr), Times] = InterpolateNaN(Copy(1, :, tr), Events, 5, AVG-5*STD, AVG+5*STD);
    Interpolated = Interpolated + Times;
end

% Eliminate values between NaNs where interpolating would have been an outlier 
for tr = 1:150
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:size(M,2)
        % No jitter in TD23
%         if b == Events(3)-1 
%             win = 0; cou = 0;
%             ver = 0; nichte = 0;
%             continue
%         end
        if cou == Thresh
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
        if isnan(Copy(1, b, tr))
            if win == 0
                ver = b+1;
                win = -1;
                continue
            elseif win == 2
                win = 1;
                nichte = b;
            end
        elseif ~isnan(Copy(1, b, tr))
            if win == -1
                cou = cou + 1;
                win = 2;
            end
        end
        if win == 1
            Copy(1, ver:nichte, tr) = NaN;
            Removed = Removed + 1;
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
    end
end
% for tr = 1:150
%     Nanner = isnan(Copy(1, :, tr));
%     Zeroer = Nanner(2:end-1);
%     Twoer = Nanner(1:end-2) + Nanner(3:end);
%     Deleter =  find(Zeroer == 0 & Twoer == 2);
%     Copy(1, Deleter+1, tr) = NaN;
%     Removed = Removed + numel(Deleter);
% end
if IfPlot
    clf
    tiledlayout(2, 2)
    nexttile
        plot(squeeze(M));
        hold on
        plot(squeeze(Plo), "-r", "LineWidth", 2)
        title(["Original data"; "Trials"])
%         xline([Events(1)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(4)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(6)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(2)], "--k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(5)], "--k", "LineWidth", 2, "Alpha", 1)
        xline([Events(1)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(3)], "k", "LineWidth", 2, "Alpha", 1)

    nexttile
        plot(squeeze(Copy));
        hold on
        plot(squeeze(Pla), "-r", "LineWidth", 2)
        title(["Corrected data, " + num2str(Removed) + " spikes removed"; " and " + num2str(Interpolated) + " interpolations where NaN (max 5 in row)"])
%         xline([Events(1)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(4)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(6)], "k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(2)], "--k", "LineWidth", 2, "Alpha", 1)
%         xline([Events(5)], "--k", "LineWidth", 2, "Alpha", 1)
        xline([Events(1)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(3)], "k", "LineWidth", 2, "Alpha", 1)

%     nexttile
%        Mirko(M, TM, Events, "diam. (a.u.)", 0, 0)
%         title(["Original data"; "PSTH"])
    nexttile
        histogram(delta(:, setdiff(1:size(delta,2), Events(3)-1), :))
        xline([AVG+5*STD], "label", "5 std")
        xline([AVG-5*STD], "label", "5 std")
%         xline([-35], "label", "Hand picked -35 a.u.")
%         xline([35], "label", "Hand picked 35 a.u.")
        title("Delta in original data")
        ylim([0, 15])
    nexttile
        PlotCopy = (Copy./mean(Copy(:, 1:Events(1)-1, :), 2, "omitnan"));  %normalize to baseline
        Mirko_TD23(PlotCopy, TM, [Events(1), Events(1)+12, Events(2)-1, Events(2), Events(2)+12, Events(3), size(M,2)-1], "diam. (a.u.)", 0, 0)
        title(["Corrected data"; "BL-normalized PSTH"])
    Samax = {[1, 2]}; 
    SameYLim(gcf, Samax);
end
M = Copy;
end




