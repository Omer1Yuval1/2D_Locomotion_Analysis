function [X,Y] = Play_Smoothed_Skeletons(Smoothed_Skeletons,Time_Series,s)
    
    if(nargin == 3)
        F = find(Time_Series == 0);
        Smoothed_Skeletons = Smoothed_Skeletons(:,:,F(s):F(s+1)-1);
    end

    X = squeeze(Smoothed_Skeletons(1,:,:))';
    Y = squeeze(Smoothed_Skeletons(2,:,:))';
    
    X(find(isnan(X(:,1))),:) = [];
    Y(find(isnan(Y(:,1))),:) = [];
    
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
        % drawnow;
        pause(.01);
    end
end