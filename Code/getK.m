% function to estimate K value for an unbroken clip
%
% created by Jordan Boyle
% If using, please cite:
% S. Berri, J.H. Boyle, M. Tassieri, I.A. Hope, and N. Cohen, 
% Forward locomotion of the nematode C. elegans is achieved 
% through modulation of a single gait, 
% HFSP J. 3 (2009), pp. 186­193.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% allX (allY) is a (Nt x Np) matrix,
	% where Nt is the total number of time points,
	% and Np is the total number of midline points for a single time-point.
	% Thus, each column contains a list of x-coordinates (y-coordinates) Np midline point in a single time-point.
% errTol is...
% lastK is...
% FPS is frames per second.
% ArcLength is the length of the worm in mm (10^(-3)m).
	% If ArcLength is 0, it means that the input coordinates are already given in mm so they will NOT be converted.
	% If ArcLength > 0, its value specifies the arc length of the worm in mm and will be used to set the segment length (Ls)
		% (i.e. the auclidean distance between consecutive midline\skeleton coordinates)
		% to Ls = (ArcLength / Np), assuming the midline\skeleton coordinates are equidistant.
		
% Example: [Kout,D_error,Success] = getK(X,Y,10^(-3),5,25,);

function [Kout,D_error,Success] = getK(allX,allY,errTol,lastK,FPS,ArcLength)
	
	% fprintf('\n In getK');
	
	[Nt,Np] = size(allX); % [# of time-points , # of midline points].
	
	% Parameters for upsampling
	Duration = Nt/FPS; % In seconds.
	Dt_input = 1/FPS;
	Dt = 0.25e-3;
	
	x = Dt_input:Dt_input:Duration; % Time points vector (in seconds).
	xx = Dt_input:Dt:Duration;
	
	Npts = length(xx);
	
	% Scale from pixels to meters
	if(ArcLength)
		L = zeros(1,Nt);
		L_m = ArcLength; % 1e-3;
		
		for i = 1:Nt
			L(i) = 0;
			for j = 2:Np
				L(i) = L(i) + sqrt((allX(i,j) - allX(i,j-1))^2 + (allY(i,j) - allY(i,j-1))^2);
			end    
		end
		allX = allX.*(L_m/mean(L));
		allY = allY.*(L_m/mean(L));
	end
	
	% Variables 25 segs
	COM_actual = zeros(3,Npts);
	x_global_actual = zeros(Np,Npts);
	y_global_actual = zeros(Np,Npts);
	local_axis_angle = zeros(Np,Npts);
	x_local = zeros(Np,Npts);

	y_local = zeros(Np,Npts);
	COMrawX = zeros(1,Nt);
	COMrawY = zeros(1,Nt);
    
	for i = 1:Nt
		mean_x = mean(allX(i,:));
		mean_y = mean(allY(i,:)); 
		
		% Record COM
		COMrawX(i) = mean_x;
		COMrawY(i) = mean_y;
    end
    
	% Smoothing spline
	%{
	P = 0.9;
	clear COMsmooth;
	COMsmooth(1,:) = fnval(csaps(x,COMrawX(:),P),xx);
	COMsmooth(2,:) = fnval(csaps(x,COMrawY(:),P),xx);
	%}
	
	% Time interpolation
	for i = 1:Np
		% Smoothing spline
		x_global_actual(i,:) = fnval(csaps(x,allX(:,i)),xx);    
		y_global_actual(i,:) = fnval(csaps(x,allY(:,i)),xx);       
    end
    
	% Get local axis angles
	for i = 1:Npts
		dx = x_global_actual(2,i) - x_global_actual(1,i);
		dy = y_global_actual(2,i) - y_global_actual(1,i); 
		local_axis_angle(1,i) = atan2(dy,dx);
        
		for j = 2:Np-1
			dx = x_global_actual(j+1,i) - x_global_actual(j-1,i);
			dy = y_global_actual(j+1,i) - y_global_actual(j-1,i); 
			local_axis_angle(j,i) = atan2(dy,dx);
        end
        
		dx = x_global_actual(Np,i) - x_global_actual(Np-1,i);
		dy = y_global_actual(Np,i) - y_global_actual(Np-1,i); 
		local_axis_angle(Np,i) = atan2(dy,dx);
    end
    
	% Ensure COM is at zero
	for i = 1:Npts   
        
		mean_x = mean(x_global_actual(:,i));
		mean_y = mean(y_global_actual(:,i));
        
		x_local(:,i) = x_global_actual(:,i) - mean_x;
		y_local(:,i) = y_global_actual(:,i) - mean_y;
        
		% Record COM
		COM_actual(1,i) = mean_x;
		COM_actual(2,i) = mean_y;
    end
	
	% Rotate so mean angle is zero
	for i = 1:Npts
		rotation_angle = mean(local_axis_angle(:,i));
		x_tmp = x_local(:,i).*cos(-rotation_angle) - y_local(:,i).*sin(-rotation_angle);
		y_tmp = x_local(:,i).*sin(-rotation_angle) + y_local(:,i).*cos(-rotation_angle);
		x_local(:,i) = x_tmp;
		y_local(:,i) = y_tmp;
		local_axis_angle(:,i) = local_axis_angle(:,i) - rotation_angle;
        
		% Record rotation angle    
		COM_actual(3,i) = rotation_angle;    
        
    end
	
	CL = (1.6e-3/Np).*ones(1,Np);
	K = lastK;
	
	% Variables
	COM_simulated = zeros(3,Npts);
	D_error = 1;
	error = 0;
	Success = 1;
	loopCount = 0;
	
	while abs(D_error) > errTol && error == 0
		
		% Variables
		COM_location = zeros(3,Npts);
		COM_error = zeros(3,Npts);
		x_global = zeros(Np,Npts);
		y_global = zeros(Np,Npts);
        
		% Initialize
		COM_location(:,1) = COM_actual(:,1);    
        
		tmpCount = 0;
		D_actual = 0;
		D_simulated = 0;
        
		for i = 2:Npts 
            
			CN = CL.*K;
			
			dx = x_local(:,i) - x_local(:,i-1);
			dy = y_local(:,i) - y_local(:,i-1);
			
			dl = dx.*cos(-local_axis_angle(:,i)) - dy.*sin(-local_axis_angle(:,i));
			dn = dx.*sin(-local_axis_angle(:,i)) + dy.*cos(-local_axis_angle(:,i));
			
			Vl = dl./Dt;
			Vn = dn./Dt;
			
			% Force opposes velocity
			Fl = -Vl.*CL';
			Fn = -Vn.*CN';
			
			Fx = Fl.*cos(local_axis_angle(:,i)) - Fn.*sin(local_axis_angle(:,i));
			Fy = Fl.*sin(local_axis_angle(:,i)) + Fn.*cos(local_axis_angle(:,i));
			
			Fnet(1) = sum(Fx);
			Fnet(2) = sum(Fy);    
			
			% Now get moment arms for torque    
			MA_mag = sqrt(x_local(:,i).^2 + y_local(:,i).^2);                
			MA_angle = atan2(y_local(:,i),x_local(:,i));  
			
			% Get forces that contribute to torque
			Fx_torque = Fx - Fnet(1)/Np;
			Fy_torque = Fy - Fnet(2)/Np;
			
			% Now to get torques, first get the tangenital components
			rotation_angle = MA_angle - pi/2;
			FT_torque = Fx_torque.*cos(-rotation_angle) - Fy_torque.*sin(-rotation_angle);
			
			% Torque is the negative of the sum of the tangential components, weighted by MA length
			Torque = -sum(FT_torque.*MA_mag);
			last_Torque = Torque;
			
			% Initialize holder for this step's COM motion
			COM_step = zeros(3,1);
			
			% Starting value for Tgrad (used for finding correct rotation)
			Tgrad = 3.4e-9;
			
			% Now search for acceptably low F and T
			while sqrt(Fnet(1)^2 + Fnet(2)^2) > 1e-11  || abs(Torque) > 1e-13;    
				
				COM_step(1) = COM_step(1) + (Fnet(1)/(Np*CN(1,10))*Dt);
				COM_step(2) = COM_step(2) + (Fnet(2)/(Np*CN(1,10))*Dt);
				% The following expression aims to compensate for the fact that
				% larger COM rotations are needed to get rid of the last bit of
				% torque
				COM_step(3) = COM_step(3) + 80*(3.4e-9/Tgrad)*Dt*(Torque/(sum(MA_mag)*CN(1,10))); 
				
				% Include test rotation and translation of COM
				x_local_rotated = x_local(:,i).*cos(COM_step(3)) - y_local(:,i).*sin(COM_step(3));
				y_local_rotated = x_local(:,i).*sin(COM_step(3)) + y_local(:,i).*cos(COM_step(3));
				
				dx = x_local_rotated + COM_step(1) - x_local(:,i-1);
				dy = y_local_rotated + COM_step(2) - y_local(:,i-1);
				
				% Local axis angle is increased by current COM angle
				rotation_angle = local_axis_angle(:,i) + COM_step(3);
				dl = dx.*cos(-rotation_angle) - dy.*sin(-rotation_angle);
				dn = dx.*sin(-rotation_angle) + dy.*cos(-rotation_angle);
				
				Vl = dl./Dt;
				Vn = dn./Dt;
				
				Fl = -Vl.*CL'; % Now must update candidate K           
				
				Fn = -Vn.*CN';
				
				Fx = Fl.*cos(rotation_angle) - Fn.*sin(rotation_angle);
				Fy = Fl.*sin(rotation_angle) + Fn.*cos(rotation_angle);
				
				Fnet(1) = sum(Fx);
				Fnet(2) = sum(Fy);                        
				
				% Get forces that contribute to torque (moment arms are unchanged)
				Fx_torque = Fx - Fnet(1)/Np;
				Fy_torque = Fy - Fnet(2)/Np;
				
				% Now to get torques, first get the tangenital components
				rotation_angle = MA_angle + COM_step(3) - pi/2;
				FT_torque = Fx_torque.*cos(-rotation_angle) - Fy_torque.*sin(-rotation_angle);
				
				% Must record last torque for gradient
				last_Torque = Torque;
				
				% Torque is the negative of the sum of the tangential components, weighted by MA length        
				Torque = -sum(FT_torque.*MA_mag); 
				
				% In order to keep changes in torque happening at decent speed, we
				% use the current gradient in torque change. This is prevented from
				% getting too small by the max()
				Tgrad = max(abs(Torque - last_Torque),10e-11);  
			end
			COM_location(3,i) = COM_location(3,i-1) + COM_step(3);
			
			COM_rotated(1) = COM_step(1)*cos(COM_location(3,i)) - COM_step(2)*sin(COM_location(3,i));
			COM_rotated(2) = COM_step(1)*sin(COM_location(3,i)) + COM_step(2)*cos(COM_location(3,i));
			
			COM_location(1,i) = COM_location(1,i-1) + COM_rotated(1);
			COM_location(2,i) = COM_location(2,i-1) + COM_rotated(2);  
			
		end
		
		% Now must update candidate K 
		%{
		plot(COM_actual(1,:),COM_actual(2,:),'k',COM_location(1,:),COM_location(2,:),'r')
		axis equal
		pause(0.2)
		%}
		
		D_simulated = sqrt((COM_location(1,end) - COM_location(1,1))^2 + (COM_location(2,end) - COM_location(2,1))^2);
		D_actual = sqrt((COM_actual(1,end) - COM_actual(1,1))^2 + (COM_actual(2,end) - COM_actual(2,1))^2);
		
		Kout = K;
		D_error = (D_simulated - D_actual)/max(D_simulated,D_actual);
		
		K = K^(1-(D_error + 0.001*randn)); 
		loopCount = loopCount + 1;
		
		if Kout < 1.0
			Kout = 1;
			error = 1;
			Success = 0;
		elseif Kout > 200
			Kout = 200;
			error = 1;
			Success = 0;
		elseif loopCount > 100
			error = 1;
			Success = 0;
		end   
    end