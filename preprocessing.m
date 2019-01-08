
%--------------------------------------------------------------------------
% Data was BCG corrected (semi-automatic) and down sampled to 500Hz using
% Brain Vision Analyzer 2.0.
% Using EEGlab, a few bad electrodes were interpolated based on visual
% inspection.
%--------------------------------------------------------------------------

% high-pass filter --------------------------------------------------------
EEG = pop_eegfiltnew(EEG, [], 0.1, 16500, true, [], 0);
EEG = eeg_hist( EEG, 'EEG = pop_eegfiltnew(EEG, [], 0.1, 16500, true, [], 0);');
EEG = eeg_checkset( EEG );

% run ICA -----------------------------------------------------------------
EEG = pop_runica(EEG, 'extended',1,'interupt','on');
EEG = eeg_hist( EEG, 'EEG = pop_runica(EEG, ''extended'',1,''interupt'',''on'');');
EEG = eeg_checkset( EEG );

% artifact ICA components were manualy identified and removed

% import and detect eye movements -----------------------------------------
% It calls pop_importeyetracker() and pop_detecteyemovements() that can be
% download here http://www2.hu-berlin.de/eyetracking-eeg/index.php
EEG = pop_importeyetracker(EEG,[Eyelink file],[1 999],[2:4],{'R_GAZE_X' 'R_GAZE_Y' 'R_AREA'},0,1,0,1);
EEG = pop_detecteyemovements(EEG,[],[64 65] ,5,3,[],1,0,25,2,0,1,1);
EEG = eeg_hist(EEG, 'EEG = pop_detecteyemovements(EEG,[],[64 65] ,5,3,[],1,0,25,2,0,1,1);');
EEG = eeg_checkset( EEG );

% save for each conditions ------------------------------------------------
EEG1 = pop_epoch( EEG, {'saccade_FreeView'}, [-0.1 0.2], 'epochinfo', 'yes');
EEG1 = pop_rmbase( EEG1, [-100 0]);
EEG1.setname = sprintf('%s_FreeView',[subject ID]);
EEG1 = pop_saveset(EEG1, 'filename',sprintf('%s_FreeViewing.set',[subject ID]),'filepath',[save path]);

EEG2 = pop_epoch( EEG, {'saccade_Search'}, [-0.1 0.2], 'epochinfo', 'yes');
EEG2 = pop_rmbase( EEG2, [-100 0]);
EEG2.setname = sprintf('%s_Search',[subject ID]);
EEG2 = pop_saveset(EEG2, 'filename',sprintf('%s_Searching.set',[subject ID]),'filepath',[save path]);

EEG3 = pop_epoch( EEG, {'saccade__Memory'}, [-0.1 0.2], 'epochinfo', 'yes');
EEG3 = pop_rmbase( EEG3, [-100 0]);
EEG3.setname = sprintf('%s_Memory',[subject ID]);
EEG3 = pop_saveset(EEG3, 'filename',sprintf('%s_Memorizing.set',[subject ID]),'filepath',[save path]);

EEG4 = pop_epoch( EEG, {'saccade_Fix'}, [-0.1 0.2], 'epochinfo', 'yes');
EEG4 = pop_rmbase( EEG4, [-100 0]);
EEG4.setname = sprintf('%s_Fix',[subject ID]);
EEG4 = pop_saveset(EEG4, 'filename',sprintf('%s_FreeViewing.set',[subject ID]),'filepath',[save path]);

