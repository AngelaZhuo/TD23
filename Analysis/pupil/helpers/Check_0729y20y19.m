    freq = 20000; % samplerate
    led_trace = dchannels(:,4);
    led_on_timestamp = find(diff(led_trace)==1)/freq;
    led_off_timestamp = find(diff(led_trace)==-1)/freq;
    
    odor_latency = 0.09 ; % EPhys double setup
    fvtrace = dchannels(:,1); 

    freq = 20000; % sample rate
    fv_off = find(diff(fvtrace)== -1)/freq + odor_latency;
    fv_on = find(diff(fvtrace)== 1)/freq + odor_latency;
    
    fv_on_before_crash = find(fv_on<led_off_timestamp(1));
    fv_off_before_crash = find(fv_off<led_off_timestamp(1));
    
    fv_on_after_crash = find(fv_on<led_off_timestamp(2) & fv_on>led_on_timestamp(2));
    fv_off_after_crash = find(fv_off<led_off_timestamp(2) & fv_off>led_on_timestamp(2));
    
    
