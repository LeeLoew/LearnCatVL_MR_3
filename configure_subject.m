function configure_subject
%CONFIGURE_SUBJECT Make experiment details for each subject that will
%persist throughout experiment (pairings, assignment to condition, etc)

% get subject identifier
prompt={'Enter the subject ID','Counterbalance Cond (A or B)'};
name='Input for configuration creation';
numlines=1;
defaultanswer={'x','A'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

subID = answer{1};
counterCond = answer{2};

if ~((counterCond == 'A') || (counterCond == 'B'))
    disp('Counterbalance condition must be A or B');
    return;
end
 
% check to make sure subject is not used
if exist(['Configurations/' subID '.mat'], 'file')
    disp('ERROR: DUPLICATE');
    return;
end


% parameters
nPairs = 8; % per condition -- nback / cat
nSingletons = 8; % per condition -- nback / cat

% random seed
randseed = rng('shuffle');

imageList = Shuffle(dir("TaskImages/*.jpg"));

% each of these arrays will have a struct member for each pair / singleton
% fields are im1 index, im1 name, im2 index, im2 name, im1 catID, im2 catID, pairtype
nbackItems = [];
catItems = [];
curIdx = 1;
for idx = 1:nPairs
    if (idx <= nPairs/4) 
        imCat1 = 'n';
        imCat2 = 'n';
        pairType = 'same';
    elseif (idx <= nPairs/2) 
        imCat1 = 'm';
        imCat2 = 'm';
        pairType = 'same';
    elseif (idx <= 3*nPairs/4) 
        imCat1 = 'm';
        imCat2 = 'n';
        pairType = 'different';
    else
        imCat1 = 'n';
        imCat2 = 'm';
        pairType = 'different';
    end
    catItems = [catItems; struct('im1idx', curIdx, ...
                                     'im1name', imageList(curIdx).name, ...
                                     'im2idx', (curIdx + 1), ...
                                     'im2name', imageList(curIdx+1).name, ...
                                     'im1cat', imCat1, ...
                                     'im2cat', imCat2, ...
                                     'pairType', pairType)];
    curIdx = curIdx + 2;
end
for idx = 1:nSingletons
    if (idx <= nPairs/2) 
        imCat1 = 'n';
    else
        imCat1 = 'm';
    end
    pairType = 'singleton';
    catItems = [catItems; struct('im1idx', curIdx, ...
                                     'im1name', imageList(curIdx).name, ...
                                     'im2idx', NaN, ...
                                     'im2name', '', ...
                                     'im1cat', imCat1, ...
                                     'im2cat', NaN, ...
                                     'pairType', pairType)];
    curIdx = curIdx + 1;
end
for idx = 1:nPairs
    % categories / pairTypes are "virtual" for nback pairs/items, since the
    % nback has no such distinctions...preserving in case of analysis
    % needs (e.g., equating trial numbers in contrasts)
    if (idx <= nPairs/4) 
        imCat1 = 'n';
        imCat2 = 'n';
        pairType = 'same';
    elseif (idx <= nPairs/2) 
        imCat1 = 'm';
        imCat2 = 'm';
        pairType = 'same';
    elseif (idx <= 3*nPairs/4) 
        imCat1 = 'm';
        imCat2 = 'n';
        pairType = 'different';
    else
        imCat1 = 'n';
        imCat2 = 'm';
        pairType = 'different';
    end
    nbackItems = [nbackItems; struct('im1idx', curIdx, ...
                                     'im1name', imageList(curIdx).name, ...
                                     'im2idx', (curIdx + 1), ...
                                     'im2name', imageList(curIdx+1).name, ...
                                     'im1cat', imCat1, ...
                                     'im2cat', imCat2, ...
                                     'pairType', pairType)];
    curIdx = curIdx + 2;
end
for idx = 1:nSingletons
    if (idx <= nPairs/2) 
        imCat1 = 'n';
    else
        imCat1 = 'm';
    end
    pairType = 'singleton';
    nbackItems = [nbackItems; struct('im1idx', curIdx, ...
                                     'im1name', imageList(curIdx).name, ...
                                     'im2idx', NaN, ...
                                     'im2name', '', ...
                                     'im1cat', imCat1, ...
                                     'im2cat', NaN, ...
                                     'pairType', pairType)];
    curIdx = curIdx + 1;
end

catFoils = catItems(1:(nPairs));
nbackFoils = nbackItems(1:(nPairs));

for idx = 1:nPairs
    % for most pairs, swap in the second item from the next pair. 
    if (idx == (nPairs/4)) % for last 'same' pair of n/n, use the first pair's second item
        catFoils(idx).im2idx = catItems(1).im2idx;
        catFoils(idx).im2name = catItems(1).im2name;
        nbackFoils(idx).im2idx = nbackItems(1).im2idx;
        nbackFoils(idx).im2name = nbackItems(1).im2name;
    elseif (idx == (nPairs/2)) % for last 'same' pair of m/m, use the first m/m pair's second item
        catFoils(idx).im2idx = catItems(1+nPairs/4).im2idx;
        catFoils(idx).im2name = catItems(1+nPairs/4).im2name;
        nbackFoils(idx).im2idx = nbackItems(1+nPairs/4).im2idx;
        nbackFoils(idx).im2name = nbackItems(1+nPairs/4).im2name;
    elseif (idx == (3*nPairs/4)) % for last 'diff' pair of n/m, use the first pair's second item
        catFoils(idx).im2idx = catItems(1+nPairs/2).im2idx;
        catFoils(idx).im2name = catItems(1+nPairs/2).im2name;
        nbackFoils(idx).im2idx = nbackItems(1+nPairs/2).im2idx;
        nbackFoils(idx).im2name = nbackItems(1+nPairs/2).im2name;
    elseif (idx == nPairs) % for last 'diff' pair of m/n, use the first pair's second item
        catFoils(idx).im2idx = catItems(1+3*nPairs/4).im2idx;
        catFoils(idx).im2name = catItems(1+3*nPairs/4).im2name;
        nbackFoils(idx).im2idx = nbackItems(1+3*nPairs/4).im2idx;
        nbackFoils(idx).im2name = nbackItems(1+3*nPairs/4).im2name;
    else
        catFoils(idx).im2idx = catItems(idx+1).im2idx;
        catFoils(idx).im2name = catItems(idx+1).im2name;
        nbackFoils(idx).im2idx = nbackItems(idx+1).im2idx;
        nbackFoils(idx).im2name = nbackItems(idx+1).im2name;
    end
end

% training run order 
if counterCond == 'A'
    % this tells the script which task to start with on each training run
    trainingOrder = {'cat','nback','cat','nback','cat','nback','cat','nback' ...
        'cat','nback','cat','nback','cat','nback','cat','nback', ...
        'cat','nback','cat','nback','cat','nback','cat','nback'};
else
    trainingOrder = {'nback','cat','nback','cat','nback','cat','nback' ...
        'cat','nback','cat','nback','cat','nback','cat','nback', ...
        'cat','nback','cat','nback','cat','nback','cat'};
end

%% generate passive view runs for scanner
pvruns = 6; % won't use all these, generating just in case

% parameters / constants for pvruns

% trial types:
CS1 = 1; % cat, same, 1st item
CS2 = 2; % cat, same, 2nd item
CD1 = 3; %      diff, 1
CD2 = 4; %      diff, 2
CSing = 5; %    singleton
NS1 = 6; % n-back, "same", 1st
NS2 = 7;
ND1 = 8;
ND2 = 9; 
NSing = 10;
Novel = 11; 

novelPerRun = 8;
nPVreps = 2; % for each of above trial types other than Novel, how many times to repeat same image in PV phase

threshCor = .15; % we won't tolerate a correlation that exceeds this value

ITIs = 5:10; % average 7.5 ITI...evenly distributed amongst these ITIs (trialOrder length must be divisible by 6

startDelay = 5; % seconds following trigger before first trial onset

% key responses for old / new response 
buttonOld = '1!';
buttonNew = '2@'; 

trialOrder = repmat(1:10, 1, nPVreps*nPairs/4); % nPairs/4 bit -- there are nPairs/4 of each type to place in each run
% example: if there are 8 pairs, 4 are same-category, but only 2 of those
% will appear in a given run. Odd runs feature odd pairs, even runs feature
% even pairs.
trialOrder = [trialOrder, repmat(Novel, 1, novelPerRun)]; % add the novel images.

ITIs = repmat(ITIs, 1, length(trialOrder)/6);

pvDesigns = {};

for thisrun = 1:pvruns
    maxCor = 1; % compute maximum absolute correlation, if it exceeds threshold, regenerate sequence
    while maxCor > threshCor
        while 1
            trialOrder = Shuffle(trialOrder);
            % don't allow back-to-back repetition of condition
            if ~any(trialOrder(1:(end-1))==trialOrder(2:end))
                break;
            end
        end
        
        ITI_orders = Shuffle(ITIs);
        
        CS1_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        CS2_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        CD1_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        CD2_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        CSing_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        NS1_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        NS2_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        ND1_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        ND2_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        NSing_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        Novel_stick = zeros(1,sum(ITI_orders) + length(ITI_orders));
        
        curTime = 1;
        for idx = 1:length(trialOrder)
            switch trialOrder(idx)
                case 1
                    CS1_stick(curTime) = 1;
                case 2
                    CS2_stick(curTime) = 1;
                case 3
                    CD1_stick(curTime) = 1;
                case 4
                    CD2_stick(curTime) = 1;
                case 5
                    CSing_stick(curTime) = 1;
                case 6
                    NS1_stick(curTime) = 1;
                case 7
                    NS2_stick(curTime) = 1;
                case 8
                    ND1_stick(curTime) = 1;
                case 9
                    ND2_stick(curTime) = 1;
                case 10
                    NSing_stick(curTime) = 1;
                case 11
                    Novel_stick(curTime) = 1;
            end
            curTime = curTime + 1 + ITI_orders(idx);
        end
        
        CS1_ev = conv(spm_hrf(1), CS1_stick);
        CS2_ev = conv(spm_hrf(1), CS2_stick);
        CD1_ev = conv(spm_hrf(1), CD1_stick);
        CD2_ev = conv(spm_hrf(1), CD2_stick);
        CSing_ev = conv(spm_hrf(1), CSing_stick);
        NS1_ev = conv(spm_hrf(1), NS1_stick);
        NS2_ev = conv(spm_hrf(1), NS2_stick);
        ND1_ev = conv(spm_hrf(1), ND1_stick);
        ND2_ev = conv(spm_hrf(1), ND2_stick);
        NSing_ev = conv(spm_hrf(1), NSing_stick);
        Novel_ev = conv(spm_hrf(1), Novel_stick);
        
        CS1_ev = CS1_ev(1:sum(ITI_orders) + length(ITI_orders));
        CS2_ev = CS2_ev(1:sum(ITI_orders) + length(ITI_orders));
        CD1_ev = CD1_ev(1:sum(ITI_orders) + length(ITI_orders));
        CD2_ev = CD2_ev(1:sum(ITI_orders) + length(ITI_orders));
        CSing_ev = CSing_ev(1:sum(ITI_orders) + length(ITI_orders));
        NS1_ev = NS1_ev(1:sum(ITI_orders) + length(ITI_orders));
        NS2_ev = NS2_ev(1:sum(ITI_orders) + length(ITI_orders));
        ND1_ev = ND1_ev(1:sum(ITI_orders) + length(ITI_orders));
        ND2_ev = ND2_ev(1:sum(ITI_orders) + length(ITI_orders));
        NSing_ev = NSing_ev(1:sum(ITI_orders) + length(ITI_orders));
        Novel_ev = Novel_ev(1:sum(ITI_orders) + length(ITI_orders));
        
        design_matrix = [CS1_ev',  CS2_ev', CD1_ev', CD2_ev', CSing_ev', ...
            NS1_ev',  NS2_ev', ND1_ev', ND2_ev', NSing_ev', Novel_ev'];
        
        corrmat = corr(design_matrix);
        corrmat(1:1+size(corrmat,1):end) = 0; % zero out diagonal correlations
        maxCor = max(max(abs(corrmat))); % keep this below our threshold r=.15
        disp(max(max(abs(corrmat))))
    end
    
    % design is cleared, now specify trial-wise details
    
    done = 0;
while ~done % while loop -- test that there are no back-to-back repetitions of specific image
    % in this loop specify imageSequence, corrRespSequence, and onsetSequence
    done = 1;
    imageSequence = {}; % constrain so no back-to-back presentation of the same image
    onsetSequence = []; % onset times of each trial
    corrRespSequence = {}; % old/new response -- button 1 for old, button 2 for new
    conditionSequence = {}; % condition ID for output / par file generation
    % odd runs use different images than even runs, for MVPA
    if mod(thisrun, 2)
        % use odd "pairs"
        CS1_pool = Shuffle(repmat(1:2:(nPairs/2),1,nPVreps));
        CS2_pool = Shuffle(repmat(1:2:(nPairs/2),1,nPVreps));
        CD1_pool = Shuffle(repmat((1+nPairs/2):2:nPairs,1,nPVreps));
        CD2_pool = Shuffle(repmat((1+nPairs/2):2:nPairs,1,nPVreps));
        CSing_pool = Shuffle(repmat((nPairs+1):2:(nPairs+nSingletons),1,nPVreps));
        NS1_pool = Shuffle(repmat(1:2:(nPairs/2),1,nPVreps));
        NS2_pool = Shuffle(repmat(1:2:(nPairs/2),1,nPVreps));
        ND1_pool = Shuffle(repmat((1+nPairs/2):2:nPairs,1,nPVreps));
        ND2_pool = Shuffle(repmat((1+nPairs/2):2:nPairs,1,nPVreps));
        NSing_pool = Shuffle(repmat((nPairs+1):2:(nPairs+nSingletons),1,nPVreps));
    else
        % use even "pairs"
        CS1_pool = Shuffle(repmat(2:2:(nPairs/2),1,nPVreps));
        CS2_pool = Shuffle(repmat(2:2:(nPairs/2),1,nPVreps));
        CD1_pool = Shuffle(repmat((2+nPairs/2):2:nPairs,1,nPVreps));
        CD2_pool = Shuffle(repmat((2+nPairs/2):2:nPairs,1,nPVreps));
        CSing_pool = Shuffle(repmat((nPairs+2):2:(nPairs+nSingletons),1,nPVreps));
        NS1_pool = Shuffle(repmat(2:2:(nPairs/2),1,nPVreps));
        NS2_pool = Shuffle(repmat(2:2:(nPairs/2),1,nPVreps));
        ND1_pool = Shuffle(repmat((2+nPairs/2):2:nPairs,1,nPVreps));
        ND2_pool = Shuffle(repmat((2+nPairs/2):2:nPairs,1,nPVreps));
        NSing_pool = Shuffle(repmat((nPairs+2):2:(nPairs+nSingletons),1,nPVreps));
    end
    
    % set up the novel image pool
    firstNovel = 2*nPairs*2+2*nSingletons+1+(thisrun-1)*novelPerRun;
    novelPool = {};
    for jdx = 1:novelPerRun
        novelPool = {novelPool{:}, imageList((firstNovel+jdx-1)).name};
    end
    curOnset = startDelay;
    
    for idx = 1:length(trialOrder)
        corrRespSequence{idx} = buttonOld; % just change this if it's a novel trial
        onsetSequence(idx) = curOnset;
        curOnset = curOnset + 1 + ITI_orders(idx); % stimulus is up for 1 second, then ITI
        switch trialOrder(idx)
            case 1
                imageSequence = {imageSequence{:}, catItems(CS1_pool(1)).im1name};
                conditionSequence = {conditionSequence{:}, 'CS1'};
                CS1_pool = CS1_pool(2:end);
            case 2
                imageSequence = {imageSequence{:}, catItems(CS2_pool(1)).im2name};
                conditionSequence = {conditionSequence{:}, 'CS2'};
                CS2_pool = CS2_pool(2:end);
            case 3
                imageSequence = {imageSequence{:}, catItems(CD1_pool(1)).im1name};
                conditionSequence = {conditionSequence{:}, 'CD1'};
                CD1_pool = CD1_pool(2:end);
            case 4
                imageSequence = {imageSequence{:}, catItems(CD2_pool(1)).im2name};
                conditionSequence = {conditionSequence{:}, 'CD2'};
                CD2_pool = CD2_pool(2:end);
            case 5
                imageSequence = {imageSequence{:}, catItems(CSing_pool(1)).im1name};
                conditionSequence = {conditionSequence{:}, 'CSing'};
                CSing_pool = CSing_pool(2:end);
            case 6
                imageSequence = {imageSequence{:}, nbackItems(NS1_pool(1)).im1name};
                conditionSequence = {conditionSequence{:}, 'NS1'};
                NS1_pool = NS1_pool(2:end);
            case 7
                imageSequence = {imageSequence{:}, nbackItems(NS2_pool(1)).im2name};
                conditionSequence = {conditionSequence{:}, 'NS2'};
                NS2_pool = NS2_pool(2:end);
            case 8
                imageSequence = {imageSequence{:}, nbackItems(ND1_pool(1)).im1name};
                conditionSequence = {conditionSequence{:}, 'ND1'};
                ND1_pool = ND1_pool(2:end);
            case 9
                imageSequence = {imageSequence{:}, nbackItems(ND2_pool(1)).im2name};
                conditionSequence = {conditionSequence{:}, 'ND2'};
                ND2_pool = ND2_pool(2:end);
            case 10
                imageSequence = {imageSequence{:}, nbackItems(NSing_pool(1)).im1name};
                conditionSequence = {conditionSequence{:}, 'NSing'};
                NSing_pool = NSing_pool(2:end);
            case 11
                imageSequence = {imageSequence{:}, novelPool{1}};
                novelPool(1) = [];
                conditionSequence = {conditionSequence{:}, 'Novel'};
                corrRespSequence{idx} = buttonNew;
        end
        % duplicate?
        if idx > 1
            if strmatch(imageSequence{idx}, imageSequence{idx-1})
                done = 0;
                break;
            end
        end
    end
end
    % save for run
    pvDesigns = {pvDesigns{:}, struct()}; % am I stupid, or is it matlab?
    
    pvDesigns{thisrun}.imageSequence = imageSequence;
    pvDesigns{thisrun}.onsetSequence = onsetSequence;
    pvDesigns{thisrun}.corrRespSequence = corrRespSequence;
    pvDesigns{thisrun}.conditionSequence = conditionSequence;

end


%% save everything
                                     
save(['Configurations/' subID], 'catItems', 'nbackItems', 'randseed', 'imageList', 'nPairs', 'nSingletons', ...
    'trainingOrder', 'counterCond', 'catFoils', 'nbackFoils', 'pvDesigns');

end

