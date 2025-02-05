function Run_File()
	
	addpath(genpath(cd));
	P = Parameters();
	
	if(isempty(P.FileName)) % A temporary option to set the path of a movie manually in the parameters to save time during development.
		[file,path] = uigetfile('*.hdf5');
		P.FileName = [path,file];
	end
	
	[Time_Series_Features_Individual_Objects,Time_Series_Features_Merged,Smoothed_Skeletons,Worms_Indices,featNames,Time_Series] = HDF5_2_MATLAB(P.FileName,P.Min_Frames_Number,P.Features_OnOff_Vector,P.Chosen_Worms_Indices);
    
    assignin('base','Time_Series_Features_Merged',Time_Series_Features_Merged);
    assignin('base','Time_Series_Features_Individual_Objects',Time_Series_Features_Individual_Objects);
    assignin('base','Time_Series',Time_Series);
    
	if(isempty(P.Chosen_Worms_Indices))
		P.Chosen_Worms_Indices = [Time_Series_Features_Individual_Objects.worm_index];
	end
	
	% Plot_Time_Series_Feature(P.FileName,P.Feature_Name,Time_Series_Features_Individual_Objects,P.Chosen_Worms_Indices);
end
