function Set_Style(XLabel,YLabel,Edges,YLIM,Font_Size)
    xlabel(XLabel,'Interpreter','Latex');
    ylabel(YLabel,'Interpreter','Latex');
    xlim([Edges(1),Edges(end)]);
    ylim(YLIM);
    set(gca,'FontSize',Font_Size,'TickLabelInterpreter','latex');
	set(gca,'unit','normalize','Position',[0.07,0.1100,0.91,0.87]);
end