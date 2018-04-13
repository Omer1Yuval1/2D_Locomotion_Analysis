function [features,numWorms,ave_features] = MergeWorms (Struct)
numWorms = size(Struct,2);

midbody_speed = [];
midbody_frequency = [];
midbody_amplitude = [];
primary_wavelength = [];
len = [];
area = [];
midbody_width = [];
head_speed = [];
tail_speed = [];


for i = 1: size(Struct,2)
    fldnm = 'midbody_speed';
    speed_temp = Struct(i).(fldnm);
    midbody_speed = [midbody_speed; speed_temp];
    temp_ave = speed_temp(~isnan(speed_temp));
    ave_midbody_speed = mean(temp_ave);
    
    fldnm ='midbody_crawling_frequency';
    freq_temp = Struct(i).(fldnm);
    midbody_frequency = [midbody_frequency; freq_temp];
    temp_ave = abs(freq_temp(~isnan(freq_temp)));
    ave_midbody_frequency = mean(temp_ave);
    
    %compute speed and frequency of forward and backward crawling:
    ind =  speed_temp < 0;
    freq_temp = abs(freq_temp);
    freq_temp(ind) =  (-1)*abs(freq_temp(ind));
    
    ave_forward_midbody_speed =  mean(speed_temp(speed_temp>0));
    ave_backward_midbody_speed =  mean(speed_temp(speed_temp<0));
    ave_forward_midbody_frequency = mean(freq_temp(freq_temp>0));
    ave_backward_midbody_frequency = mean(freq_temp(freq_temp<0));
    
    fldnm = 'midbody_crawling_amplitude';
    temp = Struct(i).(fldnm);
    midbody_amplitude = [midbody_amplitude; temp];
    temp_ave = temp(~isnan(temp));
    ave_midbody_amplitude = mean(temp_ave);
    
    fldnm = 'primary_wavelength';
    temp = Struct(i).(fldnm);
    primary_wavelength = [primary_wavelength; temp];
    temp_ave = temp(~isnan(temp));
    ave_primary_wavelength = mean(temp_ave);
    
    fldnm = 'length';
    temp = Struct(i).(fldnm);
    len = [len; temp];
    temp_ave = temp(~isnan(temp));
    ave_len = mean(temp_ave);
    
    fldnm = 'area';
    temp = Struct(i).(fldnm);
    area = [area; temp];
    temp_ave = temp(~isnan(temp));
    ave_area = mean(temp_ave);
    
    fldnm = 'midbody_width';
    temp = Struct(i).(fldnm);
    midbody_width = [midbody_width; temp];
    temp_ave = temp(~isnan(temp));
    ave_midbody_width = mean(temp_ave);
    
    fldnm = 'head_speed';
    temp = Struct(i).(fldnm);
    head_speed = [head_speed; temp];
    temp_ave = temp(~isnan(temp));
    ave_head_speed = mean(temp_ave);
    
    fldnm = 'tail_speed';
    temp = Struct(i).(fldnm);
    tail_speed = [tail_speed; temp]; 
    temp_ave = temp(~isnan(temp));
    ave_tail_speed = mean(temp_ave);
    
    if i == 1
        ave_features = table(ave_midbody_speed,ave_forward_midbody_speed,...
            ave_backward_midbody_speed, ave_midbody_frequency, ave_forward_midbody_frequency,...
            ave_backward_midbody_frequency,ave_midbody_amplitude,ave_primary_wavelength,...
            ave_len,ave_area,ave_midbody_width,ave_head_speed,ave_tail_speed);
    else
        table_addition =  table(ave_midbody_speed,ave_forward_midbody_speed,...
            ave_backward_midbody_speed, ave_midbody_frequency, ave_forward_midbody_frequency,...
            ave_backward_midbody_frequency,ave_midbody_amplitude,ave_primary_wavelength,...
            ave_len,ave_area,ave_midbody_width,ave_head_speed,ave_tail_speed);
        ave_features = outerjoin(ave_features, table_addition,'MergeKeys',true);
            
    end

%associate moving direction to midbody_frequency, + means moving forward, - means backward crawling
temp = midbody_speed < 0;
midbody_frequency = abs(midbody_frequency);
midbody_frequency(temp) = (-1)*midbody_frequency(temp);

midbody_amplitude =  abs(midbody_amplitude);

end
features = table(midbody_speed, midbody_frequency, midbody_amplitude, ...
        primary_wavelength, len, area, midbody_width, head_speed, tail_speed);

