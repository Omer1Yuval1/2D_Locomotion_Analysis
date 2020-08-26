function Plot_Curvature_Kymogram(Compact_Worm_Index,Time_Series_Features_Individual_Objects,FPS)
	
    % Run example:
        % Plot_Curvature_Kymogram(1,Time_Series_Features_Individual_Objects,FPS);
	% Save example:
        % print(gcf,['wt_1_SP=0.99.svg'],'-dsvg','-painters');
    
	Record_Skel = 0;
	
	XLIM = 10; % Seconds.
	Max_Time = 10; % Seconds.
	Curvature_Min_Max = 0.01; % Curvature range. in micrometers.
	SP = 0.8; % Smoothing parameter for K vs K' (smoothing spline). [0.8,0.99].
	smoothn_SP = 10;
	FontSize = 18;
	
	f1 = find([Time_Series_Features_Individual_Objects.Compact_Worm_Index] == Compact_Worm_Index);
	
	X = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(1,:,:))';
	Y = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(2,:,:))';
	
	X = double(X);
	Y = double(Y);
	
	Nt = size(X,1); % # of time points (= frames).
	Max_Frames = min(Nt,Max_Time*FPS) + 1;
	
	% Uncomment to smooth and add points:
	%
	Np = 128;
	X1 = [];
	Y1 = [];
	Fx = [];
	Fxx = [];
	for t=1:Max_Frames
		XY = cell2mat(smoothn(num2cell([X(t,:)',Y(t,:)'],1),smoothn_SP));
		[XY,~,~,Skel_Fit_Object] = Distribute_Equidistantly(XY,Np,1000); % [Nx3].
		X1(t,:) = XY(:,1);
		Y1(t,:) = XY(:,2);
	end
	X = X1;
	Y = Y1;
	%}
	% figure; subplot(121); scatter(X1(1,:),Y1(1,:),20,jet(128),'filled'); subplot(122); scatter(1:127,angles(1,:),20,jet(127),'filled');
	
	Np = size(X,2); % # of midline points.
	
	% Calculate the x and y differences
	dX = diff(X,1,2);
	dY = diff(Y,1,2);	
	
	angles = atan2(dY,dX); % Find the angles between skeleton points.
	angles = unwrap(angles,[],2);
	
	angles = angles - angles(:,1); % Use the head point as a reference point for the angles.
	% angles = angles - mean(angles,2); % old.
	
	dAngles = diff(angles,1,2); % Find the difference between the angles. Comment to use old version.
	
	% Calculate the curvature
	% ***********************
	C = nan(Max_Frames,Np); % Max_Frames x Np.
	for f=1:Max_Frames % For each time point (= frame).
		for i=2:Np-1 % For each midline point (end-points NOT included).
            Pi = [X(f,i) , Y(f,i) , 0];
			P1 = [X(f,i-1) , Y(f,i-1) , 0];
			P2 = [X(f,i+1) , Y(f,i+1) , 0];
			
            Ri = Get_Radius_Of_Curvature(Pi,P1,P2);
			
			C(f,i) = (1 / Ri);
		end
		C(f,2:end-1) = C(f,2:end-1) .* sign(dAngles(f,1:end)); % Use the difference between the angles to add a sign to the curvature.
		% C(f,2:end-1) = C(f,2:end-1) .* sign(angles(f,2:end)); % old.
	end
	
	% Rescale the curvature
	% *********************
	C = rescale(C,-1,1,'InputMin',-Curvature_Min_Max,'InputMax',Curvature_Min_Max);
	C = (C(1:Max_Frames,:));
	
	% Plot the curvature
	% ******************
	h = pcolor(C');
	h.FaceColor = 'interp';
	h.EdgeColor = 'none';
	
	xlim([0,XLIM*FPS]+1);
	ylim([2,Np-1]);
	axis on;
	xlabel('Time [s]','Interpreter','Latex');
	% set(gca,'YDir','normal','XTick',1:50:Max_Frames+1,'XTickLabels',(0:50:Max_Frames)./FPS,'YTick',[2,Np-3],'YTickLabels',{'H','T'},'FontSize',FontSize,'TickLabelInterpreter','latex');
    set(gca,'YDir','reverse','XTick',1:(FPS):(XLIM*FPS+1),'XTickLabels',(0:FPS:(XLIM*FPS))./FPS,'YTick',[2,Np-1],'YTickLabels',{'H','T'},'FontSize',FontSize,'TickLabelInterpreter','latex');
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
	
	% Uncomment to plot the angle array as a kymogram:
	%{
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
	%{
	H2 = figure;
	set(H2,'WindowState','maximized');
	Vp = round([0.2,0.4,0.6,0.8] .* Np);
	for i=1:length(Vp)
		F = fit((1:Max_Frames)',(C(1:Max_Frames,Vp(i))),'smoothingspline','smoothingparam',SP);
		xx = linspace(1,Max_Frames,200*Max_Frames);
		Fx = differentiate(F,xx);
        % figure; plot((1:Max_Frames)',C(:,Vp(i))); hold on; plot(xx,F(xx)); % Used to compare the fit and raw data.
		
		subplot(2,2,i);
		scatter(F(xx),Fx,5,jet(length(xx)),'filled'); % plot K vs K'.
		xlabel('$$\kappa$$','Interpreter','Latex');
		ylabel('$$\dot{\kappa}  $$','Interpreter','Latex');
		title(['$$u = ',num2str(round(Vp(i)./Np,1)),'$$'],'Interpreter','Latex');
		
		switch(SP)
		case 0.8
			% axis([-1.2,1.2,-1.2,1.2]);
			% set(gca,'FontSize',FontSize,'YTick',[-1.2:0.2:1.2],'TickLabelInterpreter','latex');
			axis([-1,1,-0.2,0.2]);
			set(gca,'FontSize',FontSize,'YTick',[-0.2:0.2:0.2],'TickLabelInterpreter','latex');
		case 0.99
			% axis([-1.2,1.2,-2,2]);
			axis([-1,1,-0.5,0.5]);
			set(gca,'FontSize',FontSize,'YTick',[-0.5:0.1:0.5],'TickLabelInterpreter','latex');
		end
		
		grid on;
		
	end
	%}
	
	% Plot postures over time using a curvature colormap.
	%{
	H3 = figure; 
	set(H3,'Position',[50,50,500,500]);
	set(gca,'Units','Normalized','Position',[0,0,1,1]);
	
	Mx = mean(nanmean(X(1:Max_Frames,:)));
	My = mean(nanmean(Y(1:Max_Frames,:)));
	Dxy = 2000;
	CM = parula(Np);
	
	if(min(C(:)) < 0)
		rgb = transpose(rescale(C(1,:),0,1,'InputMin',-1,'InputMax',1));
	else
		rgb = transpose(C(1,:));
	end
	cm = [Np/2 ; ceil(rgb(2:end-1).*Np) ; Np/2];
	cm(cm < 1) = 1;
	cm(cm > Np) = Np;
	
	
	Hp = plot(X(1,:),Y(1,:),'k','LineWidth',2);
	hold on;
	% Hs = scatter(X(1,:),Y(1,:),20,[rgb,0.*rgb,1-rgb],'filled');
	Hs = scatter(X(1,:),Y(1,:),20,CM(cm,:),'filled');
	
	axis([Mx+[-Dxy,+Dxy] , My+[-Dxy,+Dxy]]);
	
	if(Record_Skel)
        writerObj1 = VideoWriter('skel_test_1.mp4','MPEG-4');
		writerObj1.FrameRate = FPS;
		writerObj1.Quality = 100;
		open(writerObj1);
	end
	
	for t=1:Max_Frames
		
		if(min(C(:)) < 0)
			rgb = transpose(rescale(C(t,:),0,1,'InputMin',-1,'InputMax',1));
		else
			rgb = transpose(C(t,:));
		end
		
		Hp.XData = X(t,:);
		Hp.YData = Y(t,:);
		
		Hs.XData = X(t,:);
		Hs.YData = Y(t,:);
		% Hs.CData = [rgb,0.*rgb,1-rgb];
		
		cm = [Np/2 ; ceil(rgb(2:end-1).*Np) ; Np/2];
		cm(cm < 1) = 1;
		cm(cm > Np) = Np;
		Hs.CData = CM(cm,:);
		
		if(Record_Skel)
			frame = getframe(gca);
			writeVideo(writerObj1,frame);
		end
		pause(0.01);
	end
	
	if(Record_Skel)
		close(writerObj1);
	end
	%}
	
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