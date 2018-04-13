close all;
clear;
clc;
prompt = {'Strain Name:'};
dlg_title = 'Input';
num_lines = 1;
StrainName = cellstr(inputdlg (prompt,dlg_title,num_lines));
NameS1 = StrainName(1);

start_path = 'C:\Users\Lan\Desktop\My folder\LAB\2017 Leedz\Data of New worm tracker\Lan_Data\20180322_Lan_CB177\Results\';
filepath = uigetdir(start_path);

cd(filepath);
AllFiles = ls; 

NoFiles = 0;
ListFiles = []; %ListFiles will be char, not cell or string array
for i = 1:size(AllFiles,1) %m = size(X,dim) returns the size of the dimension of X specified by scalar dim.
    cFile = AllFiles(i,:);
    cFile = strtrim(strcat(cFile));
    if length(cFile)>13
            if strncmp(cFile(end-12:end),'features.hdf5',13)
            NoFiles = NoFiles + 1;
            ListFiles = [ListFiles; cFile];
            end
    end
    
end

P = struct();
	P(1).FileName = '';
	% P.FileName = 'D:\Work\Leeds\Movies\Tierpsy\20180328\Results\Basler acA4024-29um (22602116)_20180328_105333684_features.hdf5'; % Single worm sample file.
	% P.FileName = 'D:\Work\Leeds\Movies\Tierpsy\20180322_Lan_CB177\Results\CB177 20uL OP50\20uL_OP50_1_20180322_151132160_features.hdf5'; % Lan's sample file.
	
	P.Min_Frames_Number = 5;
	P.Features_OnOff_Vector = true(1,726); % Features_OnOff_Vector([5,9,29]) = 1;
	
	P.Chosen_Worms_Indices = [];
	%P.Feature_Name = 'midbody_crawling_frequency';

    
    cFilePath = char(1,NoFiles);
    for i = 1: NoFiles
    cFilePath = [filepath,'\',ListFiles(i,:)];
    [Time_Series_Features_Struct,Time_Series_Features,Worms_Indices,featNames] = ...
        HDF5_2_MATLAB(cFilePath,P.Min_Frames_Number,P.Features_OnOff_Vector,P.Chosen_Worms_Indices);
    
        if i == 1
            [featuresOI, numWorms,ave_featuresOI] =  MergeWorms (Time_Series_Features_Struct);
        else
            [tempFeatures, tempWorms,temp_ave_featuresOI] = MergeWorms(Time_Series_Features_Struct);
            featuresOI = outerjoin(featuresOI, tempFeatures, 'MergeKeys',true);
            ave_featuresOI = outerjoin(ave_featuresOI, temp_ave_featuresOI,'MergeKeys',true);
            numWorms = numWorms + tempWorms;
        end
    end
    
   
    %Plot Population Histogram         
    PlotPopulationHistogram(featuresOI,StrainName);
    
    %Plot NotBox 
    %notBoxPlot 
   
    %notBoxPlot of forward and backward translocation speed
    temp = table2array(ave_featuresOI(:,2:3));
    %temp = temp (~isnan(temp));
    figure;
    notBoxPlot(temp);
    figname =['notBoxPlot of Forward and Backward Translocation Speed of ' char(StrainName)];
    title(figname);
    ylabel('Speed(\mum/s)');
    set(gca,'XTickLabel',{'Forward','Backward'});
    set(gca,'FontSize',10);
    saveas(gcf, ['notBoxplot ',figname '.fig']);
    
    %notBoxPlot of overall, forward and backward undulation frequency
    temp = table2array(ave_featuresOI(:,4:6));
    %temp = temp (~isnan(temp));
    figure;
    notBoxPlot(temp);
    figname = ['notBoxPlot of Undulation Frequency of ' char(StrainName)];
    title(figname);
    ylabel('Hz');
    set(gca,'XTickLabel',{'Overall','Forward','Backward'});
    set(gca,'FontSize',10);
    saveas(gcf, ['notBoxplot ',figname '.fig']);
    
        
    
    


    
    
    
    
	