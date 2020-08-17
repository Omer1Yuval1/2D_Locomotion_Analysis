function Plot_Speed_Frequency(Time_Series_Features_Merged_wt,Time_Series_Features_Merged_mutant)
	
    % Run Examples:
        % Run the Run_File.m and choose an features.hdf5 file.
        % To plot a single group:    
            % Plot_Speed_Frequency(Time_Series_Features_Merged,Time_Series_Features_Merged);
        % To plot two groups:
            % Rename the "Time_Series_Features_Merged" to "Time_Series_Features_Merged_wt".
            % Then run the Run_File.m and choose an features.hdf5 file.
            % Rename the "Time_Series_Features_Merged" to "Time_Series_Features_Merged_mutant".
            % Plot_Speed_Frequency(Time_Series_Features_Merged_wt,Time_Series_Features_Merged_mutant)
		%}
	
    Speed_wt = Time_Series_Features_Merged_wt.midbody_speed;
    Freq_wt = Time_Series_Features_Merged_wt.midbody_crawling_frequency;
    Speed_wt = Speed_wt .* 0.001; % um to mm.
    
    if(nargin == 2)
        Speed_mutant = Time_Series_Features_Merged_mutant.midbody_speed;
        Freq_mutant = Time_Series_Features_Merged_mutant.midbody_crawling_frequency;
        Speed_mutant = Speed_mutant .* 0.001; % um to mm.
    end
	
	P = Params();
	
	% Speed
	% *****
	[xx_wt,yy_wt] = Get_Fit(Speed_wt,P.Speed_Hist_Edges_1,P.Speed_Smoothing_Param,P.Fit_Res);
	[Py_wt,Px_wt] = findpeaks(yy_wt,xx_wt,'MinPeakProminence',P.Speed_Min_Peak_Prominence);
    
    if(nargin == 2)
        [xx_mutant,yy_mutant] = Get_Fit(Speed_mutant,P.Speed_Hist_Edges_1,P.Speed_Smoothing_Param,P.Fit_Res);
        [Py_VC1433,Px_mutant] = findpeaks(yy_mutant,xx_mutant,'MinPeakProminence',P.Speed_Min_Peak_Prominence);
    end
    
	figure('WindowState', 'maximized');
		histogram(Speed_wt,P.Speed_Hist_Edges_1,'Normalization','Probability','FaceAlpha',P.Alpha_Hist);
		hold on;
		
        if(nargin == 2)
            histogram(Speed_mutant,P.Speed_Hist_Edges_1,'Normalization','Probability','FaceAlpha',P.Alpha_Hist);
            plot([Px_mutant ; Px_mutant],[zeros(1,length(Py_VC1433)) ; Py_VC1433'],'--','Color',[.2,.2,.2],'LineWidth',1);
            plot(xx_mutant,yy_mutant,'Color',P.Colormap_1(2,:),'LineWidth',P.Line_Width_1);
        end
        
        plot([Px_wt ; Px_wt],[zeros(1,length(Py_wt)) ; Py_wt'],'--','Color',[.2,.2,.2],'LineWidth',1);
		plot(xx_wt,yy_wt,'Color',P.Colormap_1(1,:),'LineWidth',P.Line_Width_1);
		
		legend({'wild-type','mutant'},'Location','Best');
        
        if(nargin == 2)
            Set_Style(['$$Translocation \; Speed \; (',P.Speed_Unit,' m \cdot s^{-1})$$'],'$$Probability$$',P.Speed_Hist_Edges_1,[0,max([yy_wt;yy_mutant]).*P.YLIM_Ratio],P.Font_Size_1);
        else
            Set_Style(['$$Translocation \; Speed \; (',P.Speed_Unit,' m \cdot s^{-1})$$'],'$$Probability$$',P.Speed_Hist_Edges_1,[0,max(yy_wt).*P.YLIM_Ratio],P.Font_Size_1);
        end
	% return;
	figure('WindowState', 'maximized');
		area(xx_wt,yy_wt,'FaceColor',P.Colormap_1(1,:),'FaceAlpha',P.Alpha_Area);
		hold on;
		
        if(nargin == 2)
            area(xx_mutant,yy_mutant,'FaceColor',P.Colormap_1(2,:),'FaceAlpha',P.Alpha_Area);
            plot([Px_mutant ; Px_mutant],[zeros(1,length(Py_VC1433)) ; Py_VC1433'],'--','Color',[.2,.2,.2],'LineWidth',1);
            plot(xx_mutant,yy_mutant,'Color',P.Colormap_1(2,:),'LineWidth',P.Line_Width_1);
        end
            
		plot([Px_wt ; Px_wt],[zeros(1,length(Py_wt)) ; Py_wt'],'--','Color',[.2,.2,.2],'LineWidth',1);
		plot(xx_wt,yy_wt,'Color',P.Colormap_1(1,:),'LineWidth',P.Line_Width_1);
		
		legend({'wild-type','mutant'},'Location','Best');
		
        if(nargin == 2)
            Set_Style(['$$Translocation \; Speed \; (',P.Speed_Unit,' m \cdot s^{-1})$$'],'$$Probability$$',P.Speed_Hist_Edges_1,[0,max([yy_wt;yy_mutant]).*P.YLIM_Ratio],P.Font_Size_1);
        else
            Set_Style(['$$Translocation \; Speed \; (',P.Speed_Unit,' m \cdot s^{-1})$$'],'$$Probability$$',P.Speed_Hist_Edges_1,[0,max(yy_wt).*P.YLIM_Ratio],P.Font_Size_1);
        end
	
	% Frequency
	% *********
	[xx_wt,yy_wt] = Get_Fit(Freq_wt,P.Freq_Hist_Edges_1,P.Freq_Smoothing_Param,P.Fit_Res);
	[Py_wt,Px_wt] = findpeaks(yy_wt,xx_wt,'MinPeakProminence',P.Freq_Min_Peak_Prominence);
	
    if(nargin == 2)
        [xx_mutant,yy_mutant] = Get_Fit(Freq_mutant,P.Freq_Hist_Edges_1,P.Freq_Smoothing_Param,P.Fit_Res);
        [Py_VC1433,Px_mutant] = findpeaks(yy_mutant,xx_mutant,'MinPeakProminence',P.Freq_Min_Peak_Prominence);
    end
    
	figure('WindowState', 'maximized');
		histogram(Freq_wt,P.Freq_Hist_Edges_1,'Normalization','Probability','FaceAlpha',P.Alpha_Hist);
		hold on;
		
        if(nargin == 2)
            histogram(Freq_mutant,P.Freq_Hist_Edges_1,'Normalization','Probability','FaceAlpha',P.Alpha_Hist);
            plot([Px_mutant ; Px_mutant],[zeros(1,length(Py_VC1433)) ; Py_VC1433'],'--','Color',[.2,.2,.2],'LineWidth',1);
            plot(xx_mutant,yy_mutant,'Color',P.Colormap_1(2,:),'LineWidth',P.Line_Width_1);
        end
            
        plot([Px_wt ; Px_wt],[zeros(1,length(Py_wt)) ; Py_wt'],'--','Color',[.2,.2,.2],'LineWidth',1);
		plot(xx_wt,yy_wt,'Color',P.Colormap_1(1,:),'LineWidth',P.Line_Width_1);
		
		legend({'wild-type','mutant'},'Location','Best');
		
        if(nargin == 2)
            Set_Style('$$Undulation \; Frequency \; (Hz)$$','$$Probability$$',P.Freq_Hist_Edges_1,[0,max([yy_wt;yy_mutant]).*P.YLIM_Ratio],P.Font_Size_1);
        else
            Set_Style('$$Undulation \; Frequency \; (Hz)$$','$$Probability$$',P.Freq_Hist_Edges_1,[0,max(yy_wt).*P.YLIM_Ratio],P.Font_Size_1);
        end

	figure('WindowState', 'maximized');
		area(xx_wt,yy_wt,'FaceColor',P.Colormap_1(1,:),'FaceAlpha',P.Alpha_Area);
		hold on;
		
        if(nargin == 2)
            area(xx_mutant,yy_mutant,'FaceColor',P.Colormap_1(2,:),'FaceAlpha',P.Alpha_Area);
            plot([Px_mutant ; Px_mutant],[zeros(1,length(Py_VC1433)) ; Py_VC1433'],'--','Color',[.2,.2,.2],'LineWidth',1);
            plot(xx_mutant,yy_mutant,'Color',P.Colormap_1(2,:),'LineWidth',P.Line_Width_1);
        end
        
		plot([Px_wt ; Px_wt],[zeros(1,length(Py_wt)) ; Py_wt'],'--','Color',[.2,.2,.2],'LineWidth',1);
		plot(xx_wt,yy_wt,'Color',P.Colormap_1(1,:),'LineWidth',P.Line_Width_1);
		
		legend({'wild-type','mutant'},'Location','Best');
		
        if(nargin == 2)
            Set_Style('$$Undulation \; Frequency \; (Hz)$$','$$Probability$$',P.Freq_Hist_Edges_1,[0,max([yy_wt;yy_mutant]).*P.YLIM_Ratio],P.Font_Size_1);
        else
            Set_Style('$$Undulation \; Frequency \; (Hz)$$','$$Probability$$',P.Freq_Hist_Edges_1,[0,max(yy_wt).*P.YLIM_Ratio],P.Font_Size_1);
        end
        
    figure; % ('WindowState', 'maximized');
		scatter(Freq_wt,Speed_wt,1,P.Colormap_1(1,:),'filled');
		hold on;
		
        if(nargin == 2)
            scatter(Freq_mutant,Speed_mutant,1,P.Colormap_1(2,:),'filled');
        end
		
		Set_Style('$$Undulation \; Frequency \; (Hz)$$',['$$Translocation \; Speed \; (',P.Speed_Unit,' m \cdot s^{-1})$$'],P.Freq_Hist_Edges_1,P.Speed_Hist_Edges_1([1,end]),P.Font_Size_1);
		set(gcf,'Position',[10,50,740,700]);
		set(gca,'unit','normalize','Position',[0.09,0.1100,0.9100,0.8700]);
		axis square;
		legend({'wild-type','mutant'});
end