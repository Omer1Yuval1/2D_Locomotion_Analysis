function Plot_Curvature_Kymogram(Compact_Worm_Index,Time_Series_Features_Individual_Objects)
	
	% Run Example:
	% Plot_Curvature_Kymogram(1,Time_Series_Features_Individual_Objects);
	
	f1 = find([Time_Series_Features_Individual_Objects.Compact_Worm_Index] == Compact_Worm_Index);
	
	X = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(1,:,:))';
	Y = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(2,:,:))';
	
	% X(find(isnan(X(:,1))),:) = [];
	% Y(find(isnan(Y(:,1))),:) = [];
	
	X = double(X);
	Y = double(Y);
	
	% Calculate the x and y differences
	dX = diff(X,1,2);
	dY = diff(Y,1,2);
	
	% calculate tangent angles.  atan2 uses angles from -pi to pi
	angles = atan2(dY, dX);
	
	% Deal with cases where angle changes discontinuously within [-pi,pi] and [pi,-pi]  
	angles = unwrap(angles,[],2);
	
	% Rotate skeleton angles so that mean orientation is zero
	meanAngles = mean(angles,2);
	angles = angles - meanAngles(:,ones(1, size(X,2) - 1));
	
	% angles = angles - mean(angles,2); % TODO: if you have Matlab version 2016a or later, you can do expansion of meanAngles implicitly.
	
	% Plot the angle array as a kymogram
	figure;
	imagesc(angles') % Transpose so x-axis is time.
	% colormap('cool');
	caxis([min(angles(:)), max(angles(:))] * 0.4) % adjust colour range
	pbaspect([3,1,1]);
	set(gca,'FontSize',18);
	xlabel('Frame Number');
	ylabel('Segment Number');
	title(['Worm Index: ',num2str(Compact_Worm_Index)]);
end
