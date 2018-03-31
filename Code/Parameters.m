function P = Parameters()
	
	P = struct();
	
	P(1).FileName = '';
	P.FileName = 'D:\Work\Leeds\Movies\Tierpsy\20180328\Results\Basler acA4024-29um (22602116)_20180328_105333684_features.hdf5'; % Single worm sample file.
	% P.FileName = 'D:\Work\Leeds\Movies\Tierpsy\20180322_Lan_CB177\Results\CB177 20uL OP50\20uL_OP50_1_20180322_151132160_features.hdf5'; % Lan's sample file.
	
	P.Min_Frames_Number = 5;
	P.Features_OnOff_Vector = true(1,726); % Features_OnOff_Vector([5,9,29]) = 1;
	
	P.Chosen_Worms_Indices = [];
	P.Feature_Name = 'midbody_crawling_frequency';
	
end