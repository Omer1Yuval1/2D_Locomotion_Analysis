function [Fit_Object,Vxyz,Vxyz_Distances,ArcLength,Vt] = Fit_And_Sample(XYZ,Res,Vt)
	
	Fit_Object = cscvn(XYZ'); % Fit a cubic spline.
	% Fit_Object = csaps(XYZ(:,1)',XYZ(:,2)');
	
	% Find the arc-length:
	Step_Length_Estimate = mean(diff(Fit_Object.breaks));
	
	if(nargin == 2)
		Vt = linspace(Fit_Object.breaks(1),Fit_Object.breaks(end),round(Res.*Step_Length_Estimate)); % The evaluation range (breaks) is extended by ExB from each side (using the polynomials at the edges to extrapolate).
	elseif(nargin == 3)
		Vt = Vt - Vt(1);
	end
	
	% Method 2 - Sum up small euclidean distances between consecutive coordinates to get the arc-length:
	Vxyz = fnval(Fit_Object,Vt); % [3,N] matrix of coordinates along the 3D curve.
	Vxyz_Distances = (sum((Vxyz(:,2:end)-Vxyz(:,1:end-1)).^2)).^.5; % Compute the euclidean distance (in pixels) between each pair of consecutive points.
	ArcLength = sum(Vxyz_Distances);
	
	Vxyz = Vxyz';
	
	%{
	% Method 1 - Integrate using a summation with dt->0.
	Fs_Der1 = fnder(Fit_Object,1); % 1st derivative.
	Vt_Der1 = fnval(Fs_Der1,Vt(1:end-1)); % The 1st derivative evaluated at many point along the curve. (end-1) because this point account for the last distance element.
	% Vt_Der1 = [Vt(1:end-1) ; fnval(Fs_Der1,Vt(1:end-1))]; % The 1st derivative evaluated at many point along the curve. (end-1) because this point account for the last distance element.
	dt = Vt(2:end)-Vt(1:end-1); % A vector of small interval lengths (in pixels) along the evaluation range (Fit_Object.breaks).
	Vxyz_Distances = sqrt(sum(Vt_Der1.^2)) .* dt; % Sum of scalar product of sqrt of sum of squared 1st derivatives, with dt.
	ArcLength = sum(Vxyz_Distances);
	%}
	
end