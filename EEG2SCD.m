function EEG = EEG2SCD(EEG)
% converts EEGlab data structure to CSD
% It calls ExtractMontage() and GetGH() that can be download here
% http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/

%%% Get EEG list of electrodes from EEGlab data structure
for site = 1:EEG.nbchan
    trodes{site}=(EEG.chanlocs(site).labels);
end;
trodes=trodes';


%%% Get Montage for use with CSD Toolbox
data_path = '';         % data path for '10-5-System_Mastoids_EGI129.csd'
Montage = ExtractMontage(data_path,trodes);
% Derive G and H!
[G,H] = GetGH(Montage); % loading G and H files save time, than run every trial! 


%%% apply CSD
if length(EEG.epoch) > 1
    disp('applying CSD for epochs...');
    data = zeros(size(EEG.data,1),size(EEG.data,2),size(EEG.data,3));
    for ne = 1:length(EEG.epoch)               % loop through all epochs
        myEEG = single(EEG.data(:,:,ne));      % reduce data precision to reduce memory demand
        MyResults = CSD(myEEG,G,H);            % compute CSD for <channels-by-samples> 2-D epoch
        data(:,:,ne) = MyResults;              % assign data output
    end
    EEG.data = data;
else
    disp('applying CSD for continuous EEG...');
    MyResults = CSD(EEG.data(:,:),G,H);        % compute CSD for <channels-by-samples> 2-D epoch
    EEG.data = MyResults;
end