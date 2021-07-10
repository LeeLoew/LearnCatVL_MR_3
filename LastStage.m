function LastStage
%LAST STAGE Recognition task

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

% set up trial sequence for this run

trial

% random seed
randseed = rng('shuffle');



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

while (GetSecs-expStart) > endTime
end

% clean up screen stuff
sca;

% TODO :  - Test this program
%         - Make passive viewing task for scanner
%         - Make recognition test program

end

