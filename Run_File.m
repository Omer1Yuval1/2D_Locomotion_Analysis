function Run_File()
	
	addpath(genpath(cd));
	P = Parameters();
	
	if(isempty(P.FileName)) % A temporary option to set the path of a movie manually in the parameters to save time during development.
		[file,path] = uigetfile('*.hdf5');
		FileName = [path,file];
	end
	
	[Time_Series_Features_Struct,Worms_Indices,featNames] = HDF5_2_MATLAB(P.FileName,P.Min_Frames_Number,P.Features_OnOff_Vector,P.Chosen_Worms_Indices);
	
	if(isempty(P.Chosen_Worms_Indices))
		P.Chosen_Worms_Indices = [Time_Series_Features_Struct.worm_index];
	end
	
	Plot_Time_Series_Feature(P.FileName,P.Feature_Name,Time_Series_Features_Struct,P.Chosen_Worms_Indices);
end