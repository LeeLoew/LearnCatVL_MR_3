function LastStage
%LAST STAGE Recognition task

prompt={'Enter the subject ID','Test run number'};
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

% check if the subject ID is valid, if so load configuration...

load(['Configurations/' subID '.mat']);

savepathmat = ['Data/SubID_' subID '_recogrun_' num2str(runNum) '.mat'];
savepathcsv = ['Data/SubID_' subID '_recogrun_' num2str(runNum) '.csv'];

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

% random seed
randseed = rng('shuffle');

% set up trial sequence for this run
trialSequence = Shuffle(1:length(recogTrials));

% configure screen
Screen('Preference', 'SkipSyncTests', 1);
[w, wrect] = Screen('OpenWindow',0,[127, 127, 127],[0 0 1920 1080]);  % DEBUG -- change to full screen

fixRect = CenterRect([0 0 20 20], wrect);

% load images
imTexs = [];
for idx = 1:48 % hard coded -- this is the number of images used across both tasks
    imTexs = [imTexs Screen('MakeTexture', w, imread(['TaskImages/' imageList(idx).name]))];
end
imRect = CenterRect([0 0 200 200], wrect);

DrawFormattedText(w, 'Starting the recognition task. \nTrigger each trial with the space bar.\nYou will see two pairs. Pick the more familiar one.\nSpace to start.\n', 'center', 'center');
instructionsUpTime = Screen(w, 'Flip');

while 1
    [keyDown, secs, keyCodes] = KbCheck(-1);
    if keyDown
        if keyCodes(KbName('space'))
            break;
        end
    end
end
expStart = Screen(w, 'Flip');
while keyDown
    [keyDown, secs, keyCodes] = KbCheck(-1);
end

fp = fopen(savepathcsv, 'w');

for idx = 1:length(trialSequence)
    trialID = trialSequence(idx);
    thisTrial = recogTrials(trialID);
    
    if strmatch(thisTrial.task, 'cat')
        targim1ID = catItems(thisTrial.targpair).im1idx;
        targim2ID = catItems(thisTrial.targpair).im2idx;
        pairType = catItems(thisTrial.targpair).pairType;
        foilim1ID = catFoils(thisTrial.foilpair).im1idx;
        foilim2ID = catFoils(thisTrial.foilpair).im2idx;
    else
        targim1ID = nbackItems(thisTrial.targpair).im1idx;
        targim2ID = nbackItems(thisTrial.targpair).im2idx;
        pairType = nbackItems(thisTrial.targpair).pairType;
        foilim1ID = nbackFoils(thisTrial.foilpair).im1idx;
        foilim2ID = nbackFoils(thisTrial.foilpair).im2idx;
    end
    
    if thisTrial.order == 1
        im1 = targim1ID;
        im2 = targim2ID;
        im3 = foilim1ID;
        im4 = foilim2ID;
    else
        im3 = targim1ID;
        im4 = targim2ID;
        im1 = foilim1ID;
        im2 = foilim2ID;
    end
    
    % wait for trial start
    DrawFormattedText(w, ['Press space to start trial ' num2str(idx) ' of ' num2str(length(trialSequence)) '.\nTask: which pair was displayed in this order during training?'], 'center','center');
    Screen('Flip',w);
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    while 1
        [keyDown, secs, keyCodes] = KbCheck(-1);
        if keyDown
            if keyCodes(KbName('space'))
                break;
            elseif keyCodes(KbName('q')) && keyCodes(KbName('p'))
                fclose(fp); save(savepathmat); sca; return;
            end
        end
    end
    
    instDown = Screen('Flip',w);
    
    DrawFormattedText(w, 'Pair #1', 'center','center');

    text1Up = Screen('Flip', w, instDown + ISI);
    
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    text1Down = Screen('Flip', w, text1Up + upDur);
    
    Screen('DrawTexture', w, imTexs(im1), [], imRect);
    im1Up = Screen('Flip', w, text1Down + ISI);
    
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    im1Down = Screen('Flip', w, im1Up + upDur);
    
    Screen('DrawTexture', w, imTexs(im2), [], imRect);
    im2Up = Screen('Flip', w, im1Down + ISI);
    
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    im2Down = Screen('Flip', w, im2Up + upDur);
    
    DrawFormattedText(w, 'Pair #2', 'center','center');
    text2Up = Screen('Flip', w, im2Down + ISI);
    
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    text2Down = Screen('Flip', w, text2Up + upDur);
    
    Screen('DrawTexture', w, imTexs(im3), [], imRect);
    im3Up = Screen('Flip', w, text2Down + ISI);
    
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    im3Down = Screen('Flip', w, im3Up + upDur);
    
    Screen('DrawTexture', w, imTexs(im4), [], imRect);
    im4Up = Screen('Flip', w, im3Down + ISI);
    
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    im4Down = Screen('Flip', w, im4Up + upDur);
    
    DrawFormattedText(w, 'Pair #1 or Pair #2? Use 1 and 2 keys.', 'center','center');
    finalTextUp = Screen('Flip', w, im4Down + ISI);
    
    while 1
        [keyDown, secs, keyCodes] = KbCheck(-1);
        if keyDown
            if keyCodes(KbName('1!'))
                resp = 1;
                rt = secs - finalTextUp;
                acc = (resp == thisTrial.order);
                break;
            elseif keyCodes(KbName('2@'))
                resp = 2;
                rt = secs - finalTextUp;
                acc = (resp == thisTrial.order);
                break;
            elseif keyCodes(KbName('q')) && keyCodes(KbName('p'))
                fclose(fp); save(savepathmat); sca; return;
            end
        end
    end
    thisTrial.resp = resp;
    recogTrials(trialID).resp = resp;
     recogTrials(trialID).acc = acc;
      recogTrials(trialID).rt = rt;
       recogTrials(trialID).pairType = pairType;
    %  save data to csv
    fprintf(fp, '%s, %d, %s, %d, %d, %d, %d, %d, %2.4f\n', ... 
        subID, runNum, pairType, thisTrial.order, thisTrial.targpair, thisTrial.foilpair, ...
        resp, acc, rt);
    
end
save(savepathmat);
fclose(fp);
sca;

end
