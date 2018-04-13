function PlotPopulationHistogram(table,StrainName)

names = char('Translocation Speed of Midbody', 'Undulation Frequency of Midbody',...
    'Undulation Amplitude of Midbody','Primary Wavelength', 'Body Length',...
    'Body Area', 'Midbody Width','Translocation Speed of Head', 'Translocation Speed of Tail');

for i = 1: size(table,2)
figure;
temp = table2array(table(:,i));
feature =  temp (~isnan(temp));
hist(feature,50);
figname = [strtrim(char(names(i,:))), ' of ', char(StrainName)];
title ( figname);
xlabel(names(i,:));
ylabel('Frequency');

saveas(gcf, ['Histogram of ',figname '.fig']);
end


