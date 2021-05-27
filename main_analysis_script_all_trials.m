%% calculates number of trials pre/post reversal for learning dataClean

%% Import
IS_IMPORT = true;
if IS_IMPORT
    opts = spreadsheetImportOptions("NumVariables", 7);
    
    % Specify sheet and range
    opts.Sheet = "learning";
    opts.DataRange = "A1:G7001";
    
    % Specify column names and types
    opts.VariableNames = ["trialNum", "rectOri", "rectValue", "rating", "RT", "id", "subjNum"];
    opts.SelectedVariableNames = ["trialNum", "rectOri", "rectValue","rating", "RT", "id", "subjNum"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double"];
    %opts = setvaropts(opts, [4, 5, 6], "WhitespaceRule", "preserve");
    %opts = setvaropts(opts, [4, 5, 6], "EmptyFieldRule", "auto");
    
    % Import the data
    TABLE_PATH = "C:\Users\ekw28\OneDrive - Yale University\Documents\MATLAB\ETLotto_ETLearning\ETLotto_ETLearning_data.xls"; % [the table's path]
    data = readtable(TABLE_PATH, opts, "UseExcel", false);
    clear opts
end

%% remove NaN row
dataClean = data(all(~isnan(table2array(data)),2),:); 

%% create results table with cols: id, acq reward ori, num acquisition trials, rev reward ori, num reversal trials
% THIS TABLE ONLY INCUDES UNREWARDED TRIALS 

unique_ids = unique(dataClean.id); % unique(dataClean.subjNum);

results = zeros(length(unique_ids),5);

% Iterate over all subjects
for ii = 1:length(unique_ids)
    % Extract the current participant's data
    current_id = unique_ids(ii);
    subject_indices = dataClean.id == current_id;
    subject_orientations = dataClean.rectOri(subject_indices);
    subject_rewards = dataClean.rectValue(subject_indices);
    
    % Identify the reversal index
    numTrials = 70;
    first_reward_index = find(subject_rewards,1);
    first_reward_orientation = subject_orientations(first_reward_index);
    reversal_index = find((subject_orientations~=first_reward_orientation) & (subject_rewards>0), 1);
    if isempty(reversal_index)
%         disp(['Did not identify reversal for subject: ' num2str(current_id)]);
        continue
    end
    reversal_reward_orientation = subject_orientations(reversal_index);
    
    % Calcualte the number of unrewarded trials before and after the reversal
    numAcquisition = sum((subject_rewards(1:(reversal_index-1))));
    numReversal = sum(subject_rewards(reversal_index:end));

    % Put everything in a nice table
    results(ii, 1) = current_id;
    results(ii, 2) = first_reward_orientation;
    results(ii, 3) = numAcquisition; % num acquisition trials
    results(ii, 4) = reversal_reward_orientation;
    results(ii, 5) = numReversal; % num reversal trials
end
