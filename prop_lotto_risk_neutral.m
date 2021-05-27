%calculate proportion of times we would expect a risk neutral chooser
%to choose the lottery in each set 
    %for each unique lottery in each choice set, ask what chooser would
    %choose if they only used EV (mag*prob)
    
lotto = xlsread('ETLotto_ETLearning_Data','lotto');

lottoVal = lotto(:,3);
lottoProb = lotto(:,4);
choseLotto = lotto(:,7);
isRepeat = lotto(:,12);
id = lotto(:,14);
refVal = lotto(:,17);
refProb = lotto(:,18);
manyVal = lotto(:,16);

rowsMag = 5309;
rowsMon = 5401;
numCols = 18;

rowsToDelete = zeros(size(lotto));
count = 1;

for ii = 1:length(lotto)
    if lotto(ii,12) == 1
        rowsToDelete(count,:) = lotto(ii,:);
        count = count + 1;
    elseif lotto(ii,12) ~= 1
        count = count + 1;
    end
end

count = 1;

lottoCopy = [lotto];

for ii = length(lottoCopy)
    if lottoCopy(ii,:) == rowsToDelete(count,:)
        lottoCopy(ii,:) = [];
        count = count + 1;
    elseif lottoCopy(ii,:) ~= rowsToDelete(count,:)
        ii = ii + 1;
    end
end

%choice sets
magDivUnique = zeros(rowsMon,numCols);
monDivUnique = zeros(rowsMon,numCols);

count1 = 1;
count2 = 1;

for ii = 1:length(lotto)
    if manyVal(ii) == 1 && choseLotto(ii) == 1
        monDivUnique(count1,:) = lotto(ii,:);
        count1 = count1 + 1;
    elseif manyVal(ii) == 0 && choseLotto(ii) == 1
        magDivUnique(count2,:) = lotto(ii,:);
        count2 = count2 + 1;
    end
end

evMon = zeros(rowsMon,1);
evMag = zeros(rowsMon,1);
count1 = 1;
count2 = 1;

for ii = 1:length(monDivUnique)
    evMon(count1) = monDivUnique(ii,3)*monDivUnique(ii,4);
    count1 = count1 + 1;
end

for ii = 1:length(magDivUnique)
    evMag(count2) = magDivUnique(ii,3)*magDivUnique(ii,4);
    count2 = count2 + 1;
end

choseMon = zeros(rowsMon,1);
choseMag = zeros(rowsMon,1);
count1 = 1;
count2 = 1;
evRef = 5;

for ii = 1:length(evMon)
    if evMon(ii) > evRef
        choseMon(count1) = 1;
        count1 = count1 + 1;
    else
        choseMon(count1) = 0;
        count1 = count1 + 1; 
    end
end

for ii = 1:length(evMag)
    if evMag(ii) > evRef
        choseMag(count2) = 1; %sub should choose lottery
        count2 = count2 + 1;
    elseif evMag(ii) < evRef
        choseMag(count2) = 0; %sub should choose ref
        count2 = count2 + 1;
    end
end

magDivUnique = horzcat(magDivUnique,choseMag);
monDivUnique = horzcat(monDivUnique,choseMon);

proportionMag = sum(magDivUnique(:,19)/rowsMag);
proportionMon = sum(monDivUnique(:,19)/rowsMon);

