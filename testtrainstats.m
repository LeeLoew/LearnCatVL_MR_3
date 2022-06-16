% simulate 1000 experiments and calculate statistics (transition
% probabilities)

load(['Configurations/x.mat']);
thisTaskOrder = trainingOrder{1};

randseed = rng('shuffle');

startTask = trainingOrder{1};

nSims = 1000;


nMiniBlocks = 4; % per condition
nBacksPerImage = 1;
repsPerBlock = 1; % how many times a pair repeats in a single mini-block
drawFromEachPerBlock = 2; 

% pairs 1 to 8
% 1-1 is pair 1 1st item 2-back
% 1-2 is pair 1 2nd item 2-back
% 1-1, 1-2, 2-1, 2-2, 3-1, 3-2, 4-1, 4-2, 5-1, 5-2, 6-1, 6-2, 7-1, 7-2,
% 8-1, 8-2, 9-1, 10-1, 11-1, 12-1, 13-1, 14-1, 15-1, 16-1

trainingsequences = [];

for thisSim = 1:nSims
disp(thisSim);
keepTrying = 1;
while keepTrying
    keepTrying = 0;
    sets_pair1 = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_pair2 = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_singletons = (repmat((nPairs+1):(nPairs+nSingletons), 1, nBacksPerImage));
    pair1order = [];
    pair2order = [];
    singletonorder = [];
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair1));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair1order = [pair1order; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair1 == candidates(idx));
            sets_pair1(indices(1)) = [];
        end
    end
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair2));
        [C,IA,IB] = intersect(candidates, pair1order(block,:));
        candidates(IA) = [];
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair2order = [pair2order; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair2 == candidates(idx));
            sets_pair2(indices(1)) = [];
        end
    end
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_singletons));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        singletonorder = [singletonorder; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_singletons == candidates(idx));
            sets_singletons(indices(1)) = [];
        end
    end
end
pair1order_Cat = []; 
pair2order_Cat = [];
singletonorder_Cat = [];
keepTrying = 1;
while keepTrying
    keepTrying = 0;
    sets_pair1_Cat = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_pair2_Cat = (repmat(1:nPairs, 1, nBacksPerImage));
    sets_singletons_Cat = (repmat((nPairs+1):(nPairs+nSingletons), 1, nBacksPerImage));
    drawFromEachPerBlock = length(sets_pair1_Cat)/nMiniBlocks; % assuming length(sets_pair1) == length(sets_singletons)
    pair1order_Cat = [];
    pair2order_Cat = [];
    singletonorder_Cat = [];
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair1_Cat));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair1order_Cat = [pair1order_Cat; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair1_Cat == candidates(idx));
            sets_pair1_Cat(indices(1)) = [];
        end
    end
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_pair2_Cat));
        [C,IA,IB] = intersect(candidates, pair1order_Cat(block,:));
        candidates(IA) = [];
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        pair2order_Cat = [pair2order_Cat; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_pair2_Cat == candidates(idx));
            sets_pair2_Cat(indices(1)) = [];
        end
    end
    for block = 1:nMiniBlocks
        candidates = Shuffle(unique(sets_singletons_Cat));
        if length(candidates) < drawFromEachPerBlock
            keepTrying = 1;
            break;
        end
        singletonorder_Cat = [singletonorder_Cat; candidates(1:drawFromEachPerBlock)];
        for idx = 1:drawFromEachPerBlock
            indices = find(sets_singletons_Cat == candidates(idx));
            sets_singletons_Cat(indices(1)) = [];
        end
    end
end

trainingBlocks = [];

catBlockIdx = 0;
nbackBlockIdx = 0;

for idx = 1:(2*nMiniBlocks)
    thisBlock = [];
    if strmatch(thisTaskOrder, 'cat')
        if mod(idx,2) == 1
            curTask = 'cat';
        else
            curTask = 'nback';
        end
    else
        if mod(idx,2) == 1
            curTask = 'nback';
        else
            curTask = 'cat';
        end
    end
    if strmatch(curTask, 'cat')
        catBlockIdx = catBlockIdx + 1;
        pair1reps = pair1order_Cat(catBlockIdx,:);
        pair2reps = pair2order_Cat(catBlockIdx,:);
        singletonreps = singletonorder_Cat(catBlockIdx,:);
    else
        nbackBlockIdx = nbackBlockIdx + 1;
        pair1reps = pair1order(nbackBlockIdx,:);
        pair2reps = pair2order(nbackBlockIdx,:);
        singletonreps = singletonorder(nbackBlockIdx,:);
    end
    thisBlock.curTask = curTask;
    
    % thisBlock will have a vector of "pair" orders pairOrder, which will
    % be a struct with an index (pairID) of the pair/singleton and an 
    % indicator variable (repFlag) of whether or not it is associated with 
    % a two-back repetition
    pairOrder = [];
    
    pairOrder.pairID = Shuffle(repmat(1:(nPairs+nSingletons), 1, repsPerBlock));
    
    % check to make sure that the last "pair" is not associated with an
    % n-back
    while (ismember(pairOrder.pairID(end), [pair1reps, pair2reps, singletonreps]))
        pairOrder.pairID = Shuffle(repmat(1:(nPairs+nSingletons), 1, repsPerBlock));
    end
    
    pairOrder.repFlag = zeros(1,length(pairOrder.pairID));
    
    for jdx = 1:length(pair1reps)
        repidx = Shuffle(find(pairOrder.pairID == pair1reps(jdx)));
        % pick 1 randomly
        repidx = repidx(1);
        pairOrder.repFlag(repidx) = 1; % 1st-item two-back
        
        % repeat for 2nd items, singletons
        repidx = Shuffle(find(pairOrder.pairID == pair2reps(jdx)));
        % pick 1 randomly
        repidx = repidx(1);
        pairOrder.repFlag(repidx) = 2; % 2nd-item two-back
        
        repidx = Shuffle(find(pairOrder.pairID == singletonreps(jdx)));
        % pick 1 randomly
        repidx = repidx(1);
        pairOrder.repFlag(repidx) = 3; % singleton two-back
    end
    
    % now configure the trial sequence
    % thisBlock will have a vector of image indices called imOrder which
    % will be image indices for each trial
    imOrder = [];
    correctResp = {}; % what is the correct keyboard response
    trialType = {}; % identifier for the trial type 
    pairType = {}; 
    upcoming2back = [];
    
    for jdx = 1:length(pairOrder.pairID)
        if strmatch(curTask, 'cat')
            imOrder = [imOrder, catItems(pairOrder.pairID(jdx)).im1idx];
            pairType = {pairType{:}, catItems(pairOrder.pairID(jdx)).pairType};
            correctResp = {correctResp{:}, catItems(pairOrder.pairID(jdx)).im1cat};
            if strmatch(pairType{end}, 'singleton');
                trialType = {trialType{:}, 'singleton'};
                if pairOrder.repFlag(jdx) == 3
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            else
                trialType = {trialType, 'catpair1'};
                if pairOrder.repFlag(jdx) == 1
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
                % insert the 2nd item
                imOrder = [imOrder, catItems(pairOrder.pairID(jdx)).im2idx];
                pairType = {pairType{:}, catItems(pairOrder.pairID(jdx)).pairType};
                correctResp = {correctResp{:}, catItems(pairOrder.pairID(jdx)).im2cat};
                if pairOrder.repFlag(jdx) == 2
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            end
        else
            imOrder = [imOrder, nbackItems(pairOrder.pairID(jdx)).im1idx];
            pairType = {pairType{:}, nbackItems(pairOrder.pairID(jdx)).pairType};
            correctResp = {correctResp{:}, 'z'};
            if strmatch(pairType{end}, 'singleton');
                trialType = {trialType{:}, 'singleton'};
                if pairOrder.repFlag(jdx) == 3
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            else
                trialType = {trialType{:}, 'catpair1'};
                if pairOrder.repFlag(jdx) == 1
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
                % insert the 2nd item
                imOrder = [imOrder, nbackItems(pairOrder.pairID(jdx)).im2idx];
                pairType = {pairType{:}, nbackItems(pairOrder.pairID(jdx)).pairType};
                correctResp = {correctResp{:}, 'z'}; % not a 2-back, respond 'z'
                if pairOrder.repFlag(jdx) == 2
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            end
        end
    end
    % insert the 2-back events 
    curIdx = 0;
    while curIdx < length(imOrder)
        curIdx = curIdx + 1;
        if upcoming2back(curIdx) 
            repItem = imOrder(curIdx);
            thisPairType = pairType{curIdx};
            if (strmatch(curTask, 'cat'))
                thisCorrectResp = correctResp{curIdx};
            else
                thisCorrectResp = 'm';
            end
            % update next few statements in main code
            imOrder = [imOrder(1:(curIdx+1)) repItem imOrder(min(length(imOrder)+1, (curIdx+2)):end)];
            upcoming2back = [upcoming2back(1:(curIdx+1)) 0 upcoming2back(min(length(upcoming2back),(curIdx+2)):end)];
            pairType = {pairType{1:(curIdx+1)} thisPairType pairType{min(length(pairType)+1,(curIdx+2)):end}};
            correctResp = {correctResp{1:(curIdx+1)} thisCorrectResp correctResp{min(length(correctResp),(curIdx+2)):end}};
        end
    end
    if length(imOrder) > 30
        disp('whoops');
    end
    thisTrainBlock = [];
    thisTrainBlock.imOrder = imOrder;
    thisTrainBlock.upcoming2back = upcoming2back;
    thisTrainBlock.pairType = pairType;
    thisTrainBlock.correctResp = correctResp;
    trainingBlocks = [trainingBlocks, thisTrainBlock];
    trainingsequences = [trainingsequences; imOrder];
end
end

% items 1-16 (odd) are 1st (cat)
% items 25-40 (odd) are 1st (nBack)
% items 1-16 (even) are 2nd (cat)
% items 25-40 (even) are 2nd (nBack)
% items 17-24 are singletons (cat)
% items 41-48 are singletons (nBack)

ABs_pair = [];
ABs_nonpair = [];
BBs = [];
BSs = [];
BAs = [];
ASs = [];
SAs = [];
SSs = [];
SBs = [];
AAs = [];
A = 1; B = 2; S = 3;
transitions = size(trainingsequences,2)-1;
for idx = 1:size(trainingsequences,1)
    % step through sequence and determine A->B transition probability,
    % A->S, B->A, B->S, B->B, etc
    AB_pair = 0; AB_nonpair = 0; BA = 0; AS = 0; BS = 0; SS = 0; SA = 0; SB = 0; BB = 0;
    AA = 0;
    for jdx = 1:(size(trainingsequences,2)-1)
        if jdx == 1
            if mod(trainingsequences(idx,jdx), 2)
                if trainingsequences(idx,jdx) <= 16
                    curItem = A;
                elseif (trainingsequences(idx,jdx) > 24) && (trainingsequences(idx,jdx) <= 40)
                    curItem = A;
                else
                    curItem = S;
                end
            else
                if trainingsequences(idx,jdx) <= 16
                    curItem = B;
                elseif (trainingsequences(idx,jdx) > 24) && (trainingsequences(idx,jdx) <= 40)
                    curItem = B;
                else
                    curItem = S;
                end
            end   
        else
            curItem = nextItem;
        end
        if mod(trainingsequences(idx,jdx+1), 2)
            if trainingsequences(idx,jdx+1) <= 16
                nextItem = A;
            elseif (trainingsequences(idx,jdx+1) > 24) && (trainingsequences(idx,jdx+1) <= 40)
                nextItem = A;
            else
                nextItem = S;
            end
        else
            if trainingsequences(idx,jdx+1) <= 16
                nextItem = B;
            elseif (trainingsequences(idx,jdx+1) > 24) && (trainingsequences(idx,jdx+1) <= 40)
                nextItem = B;
            else
                nextItem = S;
            end
        end
    if (curItem == A) && (nextItem == B)
        if (trainingsequences(idx,jdx+1) == (trainingsequences(idx,jdx)+1))
            AB_pair = AB_pair+1;
        else
            AB_nonpair = AB_nonpair+1;
        end
    elseif (curItem == A) && (nextItem == A)
        AA = AA + 1;
    elseif (curItem == B) && (nextItem == A)
        BA = BA + 1;
    elseif (curItem == A) && (nextItem == S)
        AS = AS + 1;
    elseif (curItem == B) && (nextItem == S)
        BS = BS + 1;
    elseif (curItem == B) && (nextItem == B)
        BB = BB + 1;
    elseif curItem == S
        if nextItem == A
            SA = SA + 1;
        elseif nextItem == B
            SB = SB + 1;
        elseif nextItem == S
            SS = SS + 1;
        else 
            disp('what?'); % shouldna happen
        end
    else
        disp('what?'); % shouldna happen
    end
    end
    
    ABs_pair = [ABs_pair, AB_pair];
    ABs_nonpair = [ABs_nonpair, AB_nonpair];
    BSs = [BSs, BS];
    BAs = [BAs, BA];
    ASs = [ASs, AS];
    SAs = [SAs, SA];
    SSs = [SSs, SS];
    SBs = [SBs, SB];
    AAs = [AAs, AA];
    BBs = [BBs, BB];
end

AB_pair_rate = ABs_pair./(ABs_pair+ABs_nonpair+ASs+AAs);
AB_nonpair_rate = ABs_nonpair./(ABs_pair+ABs_nonpair+ASs+AAs);
AS_rate= ASs./(ABs_pair+ABs_nonpair+ASs+AAs);
AA_rate = AAs./(ABs_pair+ABs_nonpair+ASs+AAs);
BA_rate = BAs./(BAs+BSs+BBs);
BS_rate = BSs./(BAs+BSs+BBs);
BB_rate = BBs./(BAs+BSs+BBs);
SA_rate = SAs./(SAs+SSs+SBs);
SS_rate = SSs./(SAs+SSs+SBs);
SB_rate = SBs./(SAs+SSs+SBs);