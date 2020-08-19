function Plot_Curvature_Kymogram(Compact_Worm_Index,Time_Series_Features_Individual_Objects,FPS)
	
    % Run example:
        % Plot_Curvature_Kymogram(1,Time_Series_Features_Individual_Objects,FPS);
	% Save example:
        % print(gcf,['wt_1_SP=0.99.svg'],'-dsvg','-painters');
        
	Max_Time = 15; % seconds.
	Curvature_Min_Max = 0.010; % Curvature range. in micrometers.
	SP = 0.8; % Smoothing parameter for K vs K' (smoothing spline). [0.8,0.99].
	FontSize = 18;
	
	f1 = find([Time_Series_Features_Individual_Objects.Compact_Worm_Index] == Compact_Worm_Index);
	
	X = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(1,:,:))';
	Y = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(2,:,:))';
	
	X = double(X);
	Y = double(Y);
	
	Nt = size(X,1); % # of time points (= frames).
	Np = size(X,2); % # of midline points.
	
	% Calculate the x and y differences
	dX = diff(X,1,2);
	dY = diff(Y,1,2);
	
	% calculate tangent angles.  atan2 uses angles from -pi to pi
	angles = atan2(dY,dX);
	
	% Deal with cases where angle changes discontinuously within [-pi,pi] and [pi,-pi]  
	angles = unwrap(angles,[],2);
	
	% Rotate skeleton angles so that mean orientation is zero
	% meanAngles = mean(angles,2);
	% angles = angles - meanAngles(:,ones(1, size(X,2) - 1));
	angles = angles - mean(angles,2); % TODO: if you have Matlab version 2016a or later, you can do expansion of meanAngles implicitly.
	
	% Calculate the curvature
	% ***********************
	C = nan(Nt,Np); % Nt x Np.
	for f=1:Nt % For each time point (= frame).
		for i=2:Np-1 % For each midline point (end-points NOT included).
            Pi = [X(f,i) , Y(f,i) , 0];
			P1 = [X(f,i-1) , Y(f,i-1) , 0];
			P2 = [X(f,i+1) , Y(f,i+1) , 0];
			
            Ri = Get_Radius_Of_Curvature(Pi,P1,P2);
			
			C(f,i) = (1 / Ri);
		end
		C(f,2:end-1) = C(f,2:end-1) .* sign(angles(f,2:end));
	end
	
	% Rescale the curvature
	% *********************
	C = rescale(C,'InputMin',-Curvature_Min_Max,'InputMax',Curvature_Min_Max);
	
	% Plot the curvature
	% ******************
	h = pcolor(C');
	h.FaceColor = 'interp';
	h.EdgeColor = 'none';
	
	xlim([0,Max_Time*FPS]+1);
	ylim([2,Np-1]);
	axis on;
	xlabel('Time [s]','Interpreter','Latex');
	%set(gca,'YDir','normal','XTick',1:50:Nt+1,'XTickLabels',(0:50:Nt)./FPS,'YTick',[2,Np-3],'YTickLabels',{'H','T'},'FontSize',FontSize,'TickLabelInterpreter','latex');
    set(gca,'YDir','reverse','XTick',1:(FPS):(Max_Time*FPS+1),'XTickLabels',(0:FPS:(Max_Time*FPS))./FPS,'YTick',[2,Np-1],'YTickLabels',{'H','T'},'FontSize',FontSize,'TickLabelInterpreter','latex');
	% colormap(gca,'jet');
	set(gcf,'Units','Normalized','Position',[0.01,0.3,0.9,0.45]);
	set(gca,'Position',[0.025,0.18,0.96,0.78]);
	
    % Uncomment to plot a color bar:
	%{
	figure;
	%colorbar(gca,'Ticks',0,'TickLabels',{'$$\kappa=0$$'},'TickLabelInterpreter','latex');
    colorbar(gca,'Ticks',[0,max(C(:))],'TickLabels',{['$$',num2str(-Curvature_Min_Max),'\; [mm ^{-1}]$$'],['$$',num2str(Curvature_Min_Max(1)),'\; [mm ^{-1}]$$']},'FontSize',FontSize,'TickLabelInterpreter','latex');
	set(gcf,'Units','Normalized','Position',[0.01,0.3,0.9,0.45]);
	set(gca,'Position',[0.025,0.18,0.5,0.78]);
	%}
	
	%{
	% Plot the angle array as a kymogram
	figure;
	imagesc(angles') % Transpose so x-axis is time.
	% colormap('cool');
	caxis([min(angles(:)), max(angles(:))] * 0.4) % adjust color range
	pbaspect([3,1,1]);
	set(gca,'FontSize',18);
	xlabel('Frame Number');
	ylabel('Segment Number');
	title(['Worm Index: ',num2str(Compact_Worm_Index)]);
	%}
	
	% Plot K vs K'
	% ************
	H2 = figure;
	set(H2,'WindowState','maximized');
	Vp = [10,20,30,40];
	for i=1:length(Vp)
		F = fit((1:Nt)',C(:,Vp(i)),'smoothingspline','smoothingparam',SP);
		xx = linspace(1,Nt,200*Nt);
		Fx = differentiate(F,xx);
        % figure; plot((1:Nt)',C(:,Vp(i))); hold on; plot(xx,F(xx)); % Used to compare the fit and raw data.
		
		subplot(2,2,i);
		scatter(F(xx),Fx,5,jet(length(xx)),'filled'); % plot K vs K'.
		xlabel('$$\kappa$$','Interpreter','Latex');
		ylabel('$$\dot{\kappa}  $$','Interpreter','Latex');
		title(['$$u = ',num2str(round(Vp(i)./Np,1)),'$$'],'Interpreter','Latex');
		
		switch(SP)
		case 0.8
			axis([-0.2,1.2,-0.6,0.6]);
			set(gca,'FontSize',FontSize,'YTick',[-0.6:0.2:0.6],'TickLabelInterpreter','latex');
		case 0.99
			axis([-0.2,1.2,-1.2,1.2]);
			set(gca,'FontSize',FontSize,'YTick',[-1.2:0.2:1.2],'TickLabelInterpreter','latex');
		end
	end
	
	% Radius of curvature
	% *******************
	function Ri = Get_Radius_Of_Curvature(pi,p1,p2)
		D = cross(p1-pi,p2-pi);
		a = norm(p1-p2);
		b = norm(pi-p2);
		c = norm(pi-p1);
		
		Ri = (a*b*c/2) / norm(D);
	end
end