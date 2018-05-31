function Play_Smoothed_Skeletons(Smoothed_Skeletons)
    
    X = squeeze(Smoothed_Skeletons(1,:,:))';
    Y = squeeze(Smoothed_Skeletons(2,:,:))';
    
    X(find(isnan(X(:,1))),:) = [];
    Y(find(isnan(Y(:,1))),:) = [];
    
    X = double(X);
    Y = double(Y);
    
    figure(1);
    axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:))]);
	
    for i=1:size(X,1)
        clf(1);
        plot(X(i,:),Y(i,:));
        axis([min(X(:)),max(X(:)),min(Y(:)),max(Y(:))]);
        drawnow;
    end
end