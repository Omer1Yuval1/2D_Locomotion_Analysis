function [XYZ,ArcLength,Step_Length,Fs,Y1] = Distribute_Equidistantly(XYZ,Eval_Points_Num,Fit_Res)
	
	% This function gets an ordered set of 3D points.
	% First, it fits a cubic spline to the data.
	% Then, it computes cumulative length along the fitted curve in order to find the step length needed to distribute
		% the points evenly.
	% Finally, it redistributes the coordinates on the fitted curve such that the distance between neighboring
		% coordinates is constant.
	
	[Fs,~,Vxyz_Distances,ArcLength,Vt] = Fit_And_Sample(XYZ,Fit_Res);
	
	X = [0,cumsum(Vxyz_Distances)]; % Vector of arc-lengths from the 1st point to each of the other points. 1st point has cumsum length of 0.
	
	Step_Length = ArcLength / (Eval_Points_Num - 1); % (*)Note: dividing the arc-length into (N-1) intervals to get (N) points.
	X1 = (0:Step_Length:ArcLength);
	Y1 = spline(X,Vt,X1); % X is a vector of cummulative arc-length. Vt are the sampled break points in the fit object.
	
	XYZ = fnval(Fs,Y1')';
	% XYZ = [Y1' , fnval(Fs,Y1')];
	
	if(0)			
		figure(4); % Plot the curve with the evaluation points XYZ (equally distant).
			fnplt(Fs);
			hold on;
			plot3(XYZ(1,:),XYZ(2,:),XYZ(3,:),'.r','MarkerSize',20);
	end
end