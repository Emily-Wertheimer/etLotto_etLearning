%% Import
IS_IMPORT = true;
if IS_IMPORT
    opts = spreadsheetImportOptions("NumVariables", 7);
    
    % Specify sheet and range
    opts.Sheet = "learning";
    opts.DataRange = "A1:G7001";
    
    % Specify column names and types
    opts.VariableNames = ["trialNum", "rectOri", "rectValue", "Var4", "Var5", "Var6", "subjNum"];
    opts.SelectedVariableNames = ["trialNum", "rectOri", "rectValue", "subjNum"];
    opts.VariableTypes = ["double", "double", "double", "char", "char", "char", "double"];
    opts = setvaropts(opts, [4, 5, 6], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, [4, 5, 6], "EmptyFieldRule", "auto");
    
    % Import the data
    TABLE_PATH = "C:\Users\ekw28\OneDrive - Yale University\Documents\MATLAB\ETLotto_ETLearning\ETLotto_ETLearning_Data.xls"; % [the table's path]
    data = readtable(TABLE_PATH, opts, "UseExcel", false);
    clear opts
end
%% Alternative import

data = xlsread('ETLotto_ETLearning_Data.xls','learning');

% extract cols


%% Calculate for each participant the proportions of
unique_ids = unique(data.subjNum);
results = zeros(length(unique_ids),5);
% Iterate over all subjects
for ii = 1:length(unique_ids)
    % Extract the current participant's data
    current_id = unique_ids(ii);
    subject_indices = data.subjNum == current_id;
    subject_orientations = data.rectOri(subject_indices);
    subject_rewards = data.rectValue(subject_indices);
    
    % Identify the reversal index
   numTrials = 70;
    first_reward_index = find(subject_rewards,1);
    first_reward_orientation = subject_orientations(first_reward_index);
    reversal_index = find((subject_orientations~=first_reward_orientation) & (subject_rewards>0), 1);
    if isempty(reversal_index)
        disp(['Did not identify reversal for subject: ' num2str(current_id)]);
        continue
    end
    reversal_reward_orientation = subject_orientations(reversal_index);
    
    % Calcualte the number of unrewarded trials before and after the reversal
    sum_unrewarded_pre_reversal = sum((subject_rewards(1:(reversal_index-1)) == 0));
    sum_unrewarded_post_reversal = sum(subject_rewards(reversal_index:end)==0);

    % Put everything in a nice table
    results(ii, 1) = current_id;
    results(ii, 2) = first_reward_orientation;
    results(ii, 3) = sum_unrewarded_pre_reversal;
    results(ii, 4) = reversal_reward_orientation;
    results(ii, 5) = sum_unrewarded_post_reversal;
end

table = array2table(results);

writetable(table,['C:\Users\ekw28\Desktop\ETLotto_ETLearning','process_lotto','.csv'],'Delimiter',',')

