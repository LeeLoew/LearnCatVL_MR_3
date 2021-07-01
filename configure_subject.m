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

% TODO: generate passive view runs for scanner
                                     
save(['Configurations/' subID], 'catItems', 'nbackItems', 'randseed', 'imageList', 'nPairs', 'nSingletons', ...
    'trainingOrder', 'counterCond');

end

