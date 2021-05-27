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
    numAcquisition = sum((subject_rewards(1:(reversal_index-1)) == 0));
    numReversal = sum(subject_rewards(reversal_index:end)==0);

    % Put everything in a nice table
    results(ii, 1) = current_id;
    results(ii, 2) = first_reward_orientation;
    results(ii, 3) = numAcquisition; % num acquisition trials
    results(ii, 4) = reversal_reward_orientation;
    results(ii, 5) = numReversal; % num reversal trials
end


%% make matrix with rows for e/ trial of e/ participant & cols with trial, stim ori, stim value, rating, rt, id, subj num, rewarded/unrewarded (binary), acquisition or reversal (binary), cs+/cs- (binary)

matrix = zeros(height(dataClean),9); % matrix with data + cols for rewarded/unrewarded and cs+/cs-
matrix(:,1) = dataClean.trialNum;
matrix(:,2) = dataClean.rectOri;
matrix(:,3) = dataClean.rectValue;
matrix(:,4) = dataClean.rating;
matrix(:,5) = dataClean.RT;
matrix(:,6) = dataClean.id;
matrix(:,7) = dataClean.subjNum;
% col 8 = acq (1) or rev (0)
% col 9 = cs+ (1) or cs- (0)

%% clean - only unrewarded trials are included in matrix (& subsequent analyses)
rewardedToDelete = matrix(:,3) == 6;
matrix(rewardedToDelete,:) = [];

%% col 8 of matrix = acq (1) or rev (0)

uniqueIDs = unique(matrix(:,6));

for ii = 1:length(uniqueIDs)
   currentID = uniqueIDs(ii);
   currSubAcq = results(ii,3);
   currSubRev = results(ii,5);
   vector = zeros(currSubAcq + currSubRev,1);
   vector(1:currSubAcq) = 1; 
   subIndices = matrix(:,6) == currentID;
   matrix(subIndices,8) = vector;
end

%% col 9 of matrix = cs+ (1) or cs- (0)
 for ii = 1:length(uniqueIDs)
     currentID = uniqueIDs(ii);
     currentResOri = results(ii,2);
     subIndices = matrix(:,6) == currentID;
     for jj = 1:length(subIndices)
         if matrix(jj,2) == currentResOri
             matrix(jj,9) = 1;
         else
             matrix(jj,9) = 0;
         end
     end
 end
 

%% clean 
% only unrewarded trials are included in matrix (& subsequent analyses)
% rewardedToDelete = matrix(:,3) == 6;
% matrix(rewardedToDelete,:) = [];
 
% replace rating of missed trials (indicated by an RT of -1) with NaN
for ii = 1:length(matrix)
    if matrix(ii,5) == -1
        matrix(ii,5) = "NaN";
    end
end

%% set thresholds (for sets), instantiate ratings matrices

thresholdAcqCSP = 14;
thresholdAcqCSM = 14;
thresholdRevCSP = 7;
thresholdRevCSM = 7;

ratings_acqCSP = zeros(100,thresholdAcqCSP + 1); % Rating of cs+ acq trials for each sub
ratings_acqCSM = zeros(100,thresholdAcqCSM + 1); % Rating of cs- acq trials for each sub
ratings_revCSP = zeros(100,thresholdRevCSP + 1); % Rating of cs+ rev trials for each sub
ratings_revCSM = zeros(100,thresholdRevCSM + 1); % Rating of cs- rev trials for each sub

% label top row by trial num 
for ii = 1:thresholdAcqCSP
    ratings_acqCSP(1,ii+1) = ii; % 1st row = acq cs+ trial num
    ratings_acqCSM(1,ii+1) = ii; % 1st row = acq cs- trial num
end

for ii = 1:thresholdRevCSP
    ratings_revCSP(1,ii+1) = ii; % 1st row = acq cs+ trial num
    ratings_revCSM(1,ii+1) = ii; % 1st row = acq cs- trial num
end



 
 %% fill tables according to set 

for ii = 1:length(uniqueIDs) % for each subject
    currentSub = uniqueIDs(ii); % identify current subject
    sub_indices = find(matrix(:,6) == currentSub); % determine subject's indices
    
    % divide e/ sub's trials into acquisition cs+, acquisition cs-,
    % reversal cs+, and reversal cs-
    acqCSP = matrix(sub_indices,8) == 1 & matrix(sub_indices,9) == 1; % is acq and is cs+
    acqCSM = matrix(sub_indices,8) == 1 & matrix(sub_indices,9) == 0; % is acq and is cs-
    revCSP = matrix(sub_indices,8) == 0 & matrix(sub_indices,9) == 1; % is rev and is cs+
    revCSM = matrix(sub_indices,8) == 0 & matrix(sub_indices,9) == 0; % is rev and is cs-
    
    % place rating from each vector above into appropriate ratings matrix
    % (only up to the number indicated by threshold)
    
    vec_acqCSP = matrix(acqCSP==1,4);
    vec_acqCSM = matrix(acqCSM==1,4);
    vec_revCSP = matrix(revCSP==1,4);
    vec_revCSM = matrix(revCSM==1,4);
   
    ratings_acqCSP(ii+1,2:end) = vec_acqCSP(1:thresholdAcqCSP);
    ratings_acqCSM(ii+1,2:end) = vec_acqCSM(1:thresholdAcqCSM);
    ratings_revCSP(ii+1,2:end) = vec_revCSP(1:thresholdRevCSP);
    ratings_revCSM(ii+1,2:end) = vec_revCSM(1:thresholdRevCSM);  
    
end
            
    




   






