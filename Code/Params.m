function P = Params()
	
	P.Speed_Unit = 'm'; % '\mu';
	
	P(1).Font_Size_1 = 18;
    P.Line_Width_1 = 4;
    P.Colormap_1 = lines(5); % [0 1 1 ; 1 0 0]
    P.Alpha_Hist = 0.3;
    P.Alpha_Area = 0.2;
    P.YLIM_Ratio = 1.1;
    
    P.Fit_Res = 1000;
    
    P.Speed_Hist_Edges_1 = (-1:0.02:1.5);
    P.Speed_Smoothing_Param = 0.999999;
    P.Speed_Min_Peak_Prominence = 0.005;
    
    P.Freq_Hist_Edges_1 = -3:0.05:3;
    P.Freq_Smoothing_Param = 0.9999;
    P.Freq_Min_Peak_Prominence = 0.005;
end