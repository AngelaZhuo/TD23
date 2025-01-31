function label = get_event_label_TD23(case_num)
% Modified from get_event_label.m (DW)

switch case_num
    case 196
        label = 'YY';
    case 315
        label = 'PB';
    case 320
        label = 'BL6';
    case 321
        label = 'juv';
    case 322
        label = 'CD1';
    case 323
        label = 'familiar';
    case 324
        label = 'novel 1';
    case 310
        label = '30 Hz laser';
    case 325
%         label = 'CD1 post ASD';
        label = 'novel 2';
    case 330
        label = '40 Hz 5ms 1s';
    case 331
        label = '30 Hz 5ms 2s';
    case 332
        label = '30 Hz 5 ms 1s';
    case 333
        label = '20 Hz 5 ms 1s';
    case 334
        label = '10 Hz 5 ms 1s';
        
end

end