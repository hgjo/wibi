function getDCM (data_path, sub_path, model)
% creates 6 models, model is one integer from 1 to 6
% data_path, data path for SPM file
% sub_path, sub director for DCM files

%--------------------------------------------------------------------------
spm('defaults','EEG');

% Data and analysis directories
%--------------------------------------------------------------------------
Panalysis = fullfile(data_path, sub_path);  % analysis directory in Pbase
if exist(fullfile(Panalysis,sprintf('DCM_M%d',model)),'file')
    return;
end

% Data filename
%--------------------------------------------------------------------------
DCM.xY.Dfile = data_path;

% Parameters and options used for setting up model
%--------------------------------------------------------------------------
DCM.options.analysis = 'ERP'; % analyze evoked responses
DCM.options.model    = 'ERP'; % ERP model
DCM.options.spatial  = 'ECD'; % spatial model
DCM.options.trials   = 1:4;   % index of ERPs within ERP/ERF file
DCM.options.Tdcm(1)  = 0;     % start of peri-stimulus time to be modelled
DCM.options.Tdcm(2)  = 200;   % end of peri-stimulus time to be modelled
DCM.options.Nmodes   = 8;     % nr of modes for data selection
DCM.options.h        = 1;     % nr of DCT components
DCM.options.onset    = 50;    % selection of onset (prior mean)
DCM.options.D        = 1;     % downsampling
DCM.options.han      = 0;     % windowing (hanning)

%--------------------------------------------------------------------------
% Data and spatial model
%--------------------------------------------------------------------------
DCM  = spm_dcm_erp_data(DCM);

%--------------------------------------------------------------------------
% Location priors for dipoles
%--------------------------------------------------------------------------
DCM.Lpos  = [[-10; -96; -8] [22; -100; -8] [-40; -88; -4] [48; -76; -2]...
    [48; -4; -42]];
DCM.Sname = {'left V1'; 'right V1'; 'left V4'; 'right V4'; 'right IT'};
Nareas    = size(DCM.Lpos,2);

%--------------------------------------------------------------------------
% Spatial model
%--------------------------------------------------------------------------
DCM = spm_dcm_erp_dipfit(DCM);

%--------------------------------------------------------------------------
% Specify connectivity model
%--------------------------------------------------------------------------
cd(Panalysis)

DCM.A{1} = zeros(Nareas, Nareas);               % forward connections
DCM.A{1}(3,1) = 1;
DCM.A{1}(4,2) = 1;
DCM.A{1}(5,4) = 1;

DCM.A{2} = zeros(Nareas,Nareas);                % backward connections
if (model == 3) || (model == 4)
    DCM.A{2}(1,3) = 1;
    DCM.A{2}(2,4) = 1;
elseif (model == 5) || (model == 6)
    DCM.A{2}(1,3) = 1;
    DCM.A{2}(2,4) = 1;
    DCM.A{2}(4,5) = 1;
end

DCM.A{3} = zeros(Nareas,Nareas);                % lateral connections
if (model == 2) || (model == 4) || (model == 6)
    DCM.A{3}(3,4) = 1;
    DCM.A{3}(4,3) = 1;
end

DCM.B{1,1} = DCM.A{1} + DCM.A{2} + DCM.A{3};    % modulation effects
DCM.B{1,2} = DCM.B{1,1};
DCM.B{1,3} = DCM.B{1,1};
                          
DCM.C = [1; 1; 0; 0; 0];                        % input

%--------------------------------------------------------------------------
% Between trial effects
%--------------------------------------------------------------------------
DCM.xU.name{1,1} = 'trial2';
DCM.xU.name{1,2} = 'trial3';
DCM.xU.name{1,3} = 'trial4';
DCM.xU.X = [-1 -1 -1; eye(3)];

%--------------------------------------------------------------------------
% Save DCM
%--------------------------------------------------------------------------
DCM.name = sprintf('DCM_M%d',model);
save(DCM.name,'DCM');

%--------------------------------------------------------------------------
% Run DCM
%--------------------------------------------------------------------------
spm_dcm_erp(DCM);
