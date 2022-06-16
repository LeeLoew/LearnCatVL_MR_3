function Training
%TRAINING Task to train on images (either categorize or perform 2-back)

% 8 mini-blocks -- 4 category, 4 nback
% In each mini-block, 6 of the images repeat
% Each image repeats once in the entire block

% images only appear once (except for n-back duplicates) per mini-block

prompt={'Enter the subject ID','Training run number'};
name='Input for training run';
numlines=1;
defaultanswer={'x','0'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
commandwindow;
subID = answer{1};
runNum = str2num(answer{2});

% timing variables
ISI = 1;
upDur = 1;
instructionPause = 5; 
instructionBlank = 5;

% check if the subject ID is valid, if so load configuration...

load(['Configurations/' subID '.mat']);

thisTaskOrder = trainingOrder{runNum};

savepathmat = ['Data/SubID_' subID '_trainingrun_' num2str(runNum) '.mat'];
savepathcsv = ['Data/SubID_' subID '_trainingrun_' num2str(runNum) '.csv'];

if exist(savepathmat) || exist(savepathcsv)
    disp('A previous file with same subject ID and run number was found. Overwrite or quit? O for overwrite, Q for quit');
    while 1
        [keyDown, secs, keyCodes] = KbCheck(-1);
        if keyDown
            if keyCodes(KbName('q'))
                return;
            elseif keyCodes(KbName('o'))
                break;
            end
        end
    end
end

% set up trial sequence for this run

% random seed
randseed = rng('shuffle');

startTask = trainingOrder{runNum};
nMiniBlocks = 4; % per condition
nBacksPerImage = 1;
repsPerBlock = 1; % how many times a pair repeats in a single mini-block
drawFromEachPerBlock = 2;

% pairs 1 to 8
% 1-1 is pair 1 1st item 2-back
% 1-2 is pair 1 2nd item 2-back
% 1-1, 1-2, 2-1, 2-2, 3-1, 3-2, 4-1, 4-2, 5-1, 5-2, 6-1, 6-2, 7-1, 7-2,
% 8-1, 8-2, 9-1, 10-1, 11-1, 12-1, 13-1, 14-1, 15-1, 16-1



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
    imNames = {};
    
    for jdx = 1:length(pairOrder.pairID)
        if strmatch(curTask, 'cat')
            imOrder = [imOrder, catItems(pairOrder.pairID(jdx)).im1idx];
            imNames = {imNames{:}, catItems(pairOrder.pairID(jdx)).im1name};
            pairType = {pairType{:}, catItems(pairOrder.pairID(jdx)).pairType};
            correctResp = {correctResp{:}, catItems(pairOrder.pairID(jdx)).im1cat};
            if strmatch(pairType{end}, 'singleton');
                trialType = {trialType{:}, 'cat_singleton'};
                if pairOrder.repFlag(jdx) == 3
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            else
                trialType = {trialType{:}, ['cat_' catItems(pairOrder.pairID(jdx)).pairType '_pair1']};
                if pairOrder.repFlag(jdx) == 1
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
                % insert the 2nd item
                imOrder = [imOrder, catItems(pairOrder.pairID(jdx)).im2idx];
                imNames = {imNames{:}, catItems(pairOrder.pairID(jdx)).im2name};
                pairType = {pairType{:}, catItems(pairOrder.pairID(jdx)).pairType};
                correctResp = {correctResp{:}, catItems(pairOrder.pairID(jdx)).im2cat};
                trialType = {trialType{:}, ['cat_' catItems(pairOrder.pairID(jdx)).pairType '_pair2']};
                if pairOrder.repFlag(jdx) == 2
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            end
        else
            imOrder = [imOrder, nbackItems(pairOrder.pairID(jdx)).im1idx];
            imNames = {imNames{:}, nbackItems(pairOrder.pairID(jdx)).im1name};
            pairType = {pairType{:}, nbackItems(pairOrder.pairID(jdx)).pairType};
            correctResp = {correctResp{:}, 'n'};
            if strmatch(pairType{end}, 'singleton');
                trialType = {trialType{:}, 'nback_singleton'};
                if pairOrder.repFlag(jdx) == 3
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
            else
                trialType = {trialType{:}, ['nback_' nbackItems(pairOrder.pairID(jdx)).pairType '_pair1']};
                if pairOrder.repFlag(jdx) == 1
                    upcoming2back = [upcoming2back, 1];
                else
                    upcoming2back = [upcoming2back, 0];
                end
                % insert the 2nd item
                imOrder = [imOrder, nbackItems(pairOrder.pairID(jdx)).im2idx];
                imNames = {imNames{:}, nbackItems(pairOrder.pairID(jdx)).im2name};
                pairType = {pairType{:}, nbackItems(pairOrder.pairID(jdx)).pairType};
                correctResp = {correctResp{:}, 'n'}; % not a 2-back, respond 'n'
                trialType = {trialType{:}, ['nback_' nbackItems(pairOrder.pairID(jdx)).pairType '_pair2']};
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
            thisTrialType = trialType{curIdx};
            if (strmatch(curTask, 'cat'))
                thisCorrectResp = correctResp{curIdx};
            else
                thisCorrectResp = 'm';
            end
            imOrder = [imOrder(1:(curIdx+1)) repItem imOrder(min(length(imOrder)+1, (curIdx+2)):end)];
            imNames = {imNames{1:(curIdx+1)}, imNames{curIdx}, imNames{min(length(imOrder)+1, (curIdx+2)):end}};
            upcoming2back = [upcoming2back(1:(curIdx+1)) 0 upcoming2back(min(length(upcoming2back),(curIdx+2)):end)];
            pairType = {pairType{1:(curIdx+1)} thisPairType pairType{min(length(pairType)+1,(curIdx+2)):end}};
            trialType = {trialType{1:(curIdx+1)} [thisTrialType '_2back'] trialType{min(length(trialType)+1,(curIdx+2)):end}};
            correctResp = {correctResp{1:(curIdx+1)} thisCorrectResp correctResp{min(length(correctResp),(curIdx+2)):end}};
        end
    end
    thisTrainBlock = [];
    thisTrainBlock.imOrder = imOrder;
    thisTrainBlock.upcoming2back = upcoming2back;
    thisTrainBlock.pairType = pairType;
    thisTrainBlock.correctResp = correctResp;
    thisTrainBlock.task = curTask;
    thisTrainBlock.imNames = imNames;
    thisTrainBlock.trialType = trialType;
    
    trainingBlocks = [trainingBlocks, thisTrainBlock];
end

% configure timing
curTime = 0;
for block = 1:length(trainingBlocks)
    trainingBlocks(block).InstUp = curTime;
    trainingBlocks(block).InstDown = curTime + instructionPause;
    curTime = curTime + instructionPause + instructionBlank;
    trainingBlocks(block).ImUp = [];
    for trial = 1:length(trainingBlocks(block).imOrder)
        trainingBlocks(block).ImUp = [trainingBlocks(block).ImUp curTime+ISI+upDur];
        curTime = curTime + ISI + upDur;
    end
    curTime = curTime + ISI;
end
endTime = curTime + 10;

% configure screen
Screen('Preference', 'SkipSyncTests', 1);
[w, wrect] = Screen('OpenWindow',0,[127, 127, 127], [0 0 800 600]); % [0 0 1920 1080]);  % DEBUG -- change to full screen

fixRect = CenterRect([0 0 20 20], wrect);

% load images
imTexs = [];
for idx = 1:48 % hard coded -- this is the number of images used across both tasks
    imTexs = [imTexs Screen('MakeTexture', w, imread(['TaskImages/' imageList(idx).name]))];
end
imRect = CenterRect([0 0 200 200], wrect);

% TO DO : Show instructions here
DrawFormattedText(w, 'Get ready for the next run of training. Pay close attention to the instructions and use the two buttons to respond. Try to be as accurate as possible.\n', 'center', 'center');
instructionsUpTime = Screen(w, 'Flip');

while 1
    [keyDown, secs, keyCodes] = KbCheck(-1);
    if keyDown
        if keyCodes(KbName('5%'))
            break;
        end
    end
end
expStart = Screen(w, 'Flip');
while keyDown
    [keyDown, secs, keyCodes] = KbCheck(-1);
end

catperf = 0;
nbackperf = 0;

fp = fopen(savepathcsv, 'w');


for block = 1:length(trainingBlocks)
    trainingBlocks(block).RT = [];
    trainingBlocks(block).AC = [];
    trainingBlocks(block).upTimeErr = [];
    cataccount = 0;
    nbackaccount = 0;
    
    % block break / instructions
    % TODO : Make this a timed break!!!
    if strmatch(trainingBlocks(block).task, 'cat')
        blockbreakstring = 'Categorization block beginning... \n Press the left button for category A images \n and the right button for category B images. Try to be as accurate as possible.';
        if block > 2
            blockbreakstring = [blockbreakstring '\nYou were ' num2str(catperf) '% correct on the last categorization block.'];
        end
    else
        blockbreakstring = '2-back block beginning... \n Press the left button when the image displayed is NOT an image that appeared immmediately before the last image \n and the right button if it did appear immediately before the last image. Try to be as accurate as possible.';
        if block > 2
            blockbreakstring = [blockbreakstring '\nYou were ' num2str(nbackperf) '% correct on the last 2-back block.'];
        end
    end
    DrawFormattedText(w, blockbreakstring, 'center', 'center', [0 0 0]);
    
    instructionsUpTime = Screen(w, 'Flip', expStart+trainingBlocks(block).InstUp);
   
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    instructionsDownTime = Screen(w, 'Flip', expStart+trainingBlocks(block).InstDown);
    for trial = 1:length(trainingBlocks(block).imOrder)
        RT = -1;
        Screen('DrawTexture', w, imTexs(trainingBlocks(block).imOrder(trial)), [], imRect);
        imUptime = Screen(w, 'Flip', expStart + trainingBlocks(block).ImUp(trial) - .001);
        trainingBlocks(block).upTimeErr(trial) = imUptime-(trainingBlocks(block).ImUp(trial)+expStart);
        respReceived = 0; 
        resp = [];
        while (GetSecs - imUptime) < (upDur - .001)
            [keyDown, secs, keyCodes] = KbCheck(-1);
            if keyDown
                if any(keyCodes([KbName('n'), KbName('m'), KbName('q')]))
                    respReceived = 1;
                    resp = find(keyCodes);
                    RT = secs - imUptime;
                    break;
                end
            end
        end
        while (GetSecs - imUptime) < (upDur - .001)
        end
        
        if keyCodes(KbName('q'))
            sca; return;
        end
        
        if length(resp) > 1
            acc = 0;
        elseif length(resp) == 0
            acc = 0;
        elseif strmatch(KbName(resp), trainingBlocks(block).correctResp{trial})
            acc = 1;
            if strmatch(trainingBlocks(block).task, 'cat')
                cataccount = cataccount + 1;
            else
                nbackaccount = nbackaccount + 1;
            end
        else
            acc = 0;
        end
        
        
        if acc
            Screen(w, 'FillOval', [0 255 0], fixRect);
        elseif length(resp) == 0
            DrawFormattedText(w, 'TOO SLOW!', 'center','center',[255 0 0]);
        else
            Screen(w, 'FillOval', [255 0 0], fixRect);
        end
        lastMarker = Screen(w, 'Flip', expStart+trainingBlocks(block).ImUp(trial) + upDur);
        
        trainingBlocks(block).RT = [trainingBlocks(block).RT RT];
        trainingBlocks(block).AC = [trainingBlocks(block).AC acc];
        
        fprintf(fp, '%s, %d, %d, %s, %d, %d, %s, %s, %d, %s, %s, %s, %2.4f, %d, %2.4f\n', ... 
        subID, runNum, block, trainingBlocks(block).task, ...
        trial, respReceived, KbName(resp), trainingBlocks(block).correctResp{trial}, ...
        trainingBlocks(block).imOrder(trial), trainingBlocks(block).imNames{trial}, ...
        trainingBlocks(block).pairType{trial}, trainingBlocks(block).trialType{trial}, ...
        trainingBlocks(block).upTimeErr(trial), ...
        acc, RT);
    end
      
    if strmatch(trainingBlocks(block).task, 'cat')
        catperf = round(100*cataccount/length(trainingBlocks(block).imOrder));
    else
        nbackperf = round(100*nbackaccount/length(trainingBlocks(block).imOrder));
    end
   
end

% save data
save(savepathmat);
fclose(fp);

while (GetSecs-expStart) < endTime
end

% clean up screen stuff
sca;

% TODO :  - Test this program
%         - Make passive viewing task for scanner
%         - Make recognition test program

end

