function [X,Y] = Play_Smoothed_Skeletons(Compact_Worm_Index,Time_Series_Features_Individual_Objects,Time_Series,Hide_NANs_01)
	
	% Run example:
	% Play_Smoothed_Skeletons(5,Time_Series_Features_Individual_Objects,Time_Series,1);
	
	f1 = find([Time_Series_Features_Individual_Objects.Compact_Worm_Index] == Compact_Worm_Index);
	
	X = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(1,:,:))';
	Y = squeeze(Time_Series_Features_Individual_Objects(f1).Skeletons(2,:,:))';
	
	if(nargin == 4 && Hide_NANs_01)
		X(find(isnan(X(:,1))),:) = [];
		Y(find(isnan(Y(:,1))),:) = [];
	end
	
	X = double(X);
	Y = double(Y);
	
	figure(1);
	D = max(max(X(:)) - min(X(:)),max(Y(:)) - min(Y(:))) ./ 2;
	Mx = mean([min(X(:)),max(X(:))]);
	My = mean([min(Y(:)),max(Y(:))]);
	axis([Mx-D,Mx+D,My-D,My+D]); % axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:))]);
	
	for i=1:size(X,1)
		clf(1);
		plot(X(i,:),Y(i,:));
		axis([Mx-D,Mx+D,My-D,My+D]);
		pause(.05);
	end
end
