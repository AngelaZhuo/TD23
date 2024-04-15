%% subfunctions
function s= revCase(s) 
% reverse string case between capital and lowercase letters
if isstring(s)
    s = char(s);
    ifstring = true;
else
    ifstring = false;
end

ilo=regexp(s,'([a-z])');
iup=regexp(s,'([A-Z])');
s(iup)=lower(s(iup));
s(ilo)=upper(s(ilo));

if ifstring
    s = string(s);
end

end