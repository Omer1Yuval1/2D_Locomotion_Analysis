function [xx,yy] = Get_Fit(X,Edges,Smoothing_Param,Fit_Res)
    [Count_Speed_wt,~] = histcounts(X,Edges,'Normalization','Probability');
    Fit_Object = fit( ((Edges(1:end-1)+Edges(2:end))./2)' ,Count_Speed_wt','smoothingspline','smoothingparam',Smoothing_Param);
    xx = linspace(Edges(1),Edges(end),Fit_Res);
    yy = Fit_Object(xx);
end