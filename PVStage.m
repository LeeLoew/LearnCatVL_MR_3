function PVStage
% PVStage Not quite passive viewing -- detect old vs. new image

prompt={'Enter the subject ID','run number'};
name='Input for PV run';
numlines=1;
defaultanswer={'x','0'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
commandwindow;
subID = answer{1};
runNum = str2num(answer{2});

outFileMat = ['Data/PVStage_' subID '_' answer{2} '.mat'];
outFileCSV = ['Data/PVStage_' subID '_' answer{2} '.csv'];

% TODO -- overwrite protection. check that this run doesn't have a data file

fp = fopen(outFileCSV,'w'); 

% load subject configuration file
load(['Configurations/' subID '.mat']);

% pvDesigns{runNum} contains all relevant variables
thisDesign = pvDesigns{runNum};

upDur = 1; % how long to show image (response longer than this is error)
monitorDur = 3; % monitor for this many seconds for response -- record but count as error if exceeds 1 s

% set up screen
% configure screen
Screen('Preference', 'SkipSyncTests', 1);
%[w, wrect] = Screen('OpenWindow',0,[127, 127, 127], [0 0 1024 768]); %,[0 0 1920 1080]);  % DEBUG -- change to full screen
[w, wrect] = Screen('OpenWindow',0,[127, 127, 127], [0 0 1920 1080]);  % DEBUG -- change to full screen
fixRect = CenterRect([0 0 20 20], wrect);
imRect = CenterRect([0 0 200 200], wrect);

% load images
loadedImages = {};
thisDesign.imTex = [];
for idx = 1:length(thisDesign.imageSequence)
    matched = 0;
    if idx > 1
        % check if image previously loaded
        for jdx = 1:(idx-1)
            if strmatch(thisDesign.imageSequence{idx}, thisDesign.imageSequence{jdx})
                thisDesign.imTex(idx) = thisDesign.imTex(jdx);
                matched = 1;
                break;
            end
        end
    end
    if ~matched
        thisDesign.imTex(idx) = Screen('MakeTexture', w, imread(['TaskImages/' thisDesign.imageSequence{idx}]));
    end
end

% show instructions
DrawFormattedText(w, 'Indicate "brand new" or "previously viewed" for each image using the same two buttons. \n Press the first button with your pointer finger for an image you have seen before. \n Press the second button with your middle finger for new images you have never seen before. \n Be sure to respond within the one second while the image is on screen. \n Trigger proceeds, please wait. \n \n Reminder: \n Old = first button (pointer finger) \n New = second button (middle finger)', 'center', 'center');
Screen('Flip',w);

Screen(w, 'FrameOval', [0 0 0], fixRect);
while 1
    [keyDown, secs, keyCodes] = KbCheck(-1);
    if keyDown
        if keyCodes(KbName('5%'))
            break;
        end
    end
end
expStart = Screen(w, 'Flip');

% trial loop
thisDesign.upTimeErr = [];
nTrials = length(thisDesign.imageSequence);


    
for trial = 1:nTrials
    % show the image, monitor response
    RT = -1; slowRespReceived = 0; 
    Screen('DrawTexture', w, thisDesign.imTex(trial), [], imRect);
    imUptime = Screen(w, 'Flip', expStart + thisDesign.onsetSequence(trial) - .001);
    thisDesign.upTimeErr(trial) = imUptime-thisDesign.onsetSequence(trial)+expStart;
    respReceived = 0; 
    resp = []; 
    % monitor for responses -- just keep the last response
    while (GetSecs - imUptime) < (upDur - .001)
        [keyDown, secs, keyCodes] = KbCheck(-1);
        if keyDown
            if any(keyCodes([KbName('1!'), KbName('2@'), KbName('q')]))
                respReceived = 1;
                resp = keyCodes;
                RT = secs - imUptime;
                if keyCodes(KbName('q'))
                    sca; return;
                end
            end
        end
    end
    
    thisDesign.acc(trial) = 0;
    thisDesign.resp(trial) = -1;
    thisDesign.RT(trial) = -1;
    
    
    % check response accuracy
    if respReceived
        if length(find(resp)) > 1 % error -- pressed multiple buttons
            thisDesign.acc(trial) = 0;
            thisDesign.resp(trial) = -1;
        elseif keyCodes(KbName(thisDesign.corrRespSequence{trial}))
            thisDesign.acc(trial) = 1;
            thisDesign.resp(trial) = find(resp);
            thisDesign.RT(trial) = RT;
        else
            thisDesign.acc(trial) = 0;
            thisDesign.resp(trial) = find(resp);
            thisDesign.RT(trial) = RT;
        end
    end

    % remove the image
    Screen(w, 'FrameOval', [0 0 0], fixRect);
    imDowntime = Screen(w, 'Flip', expStart + thisDesign.onsetSequence(trial) + upDur - .001);
    
    slowrespReceived = 0;
    
    thisDesign.slowacc(trial) = thisDesign.acc(trial);
    thisDesign.slowresp(trial) = thisDesign.resp(trial);
    thisDesign.slowRT(trial) = thisDesign.RT(trial);
    
    if ~respReceived
        % keep monitoring for slow response
        % we will keep monitoring for additional 2 seconds, but mark as slow
        slowresp = []; slowRT = -1; slowRespReceived = 0; 
        while (GetSecs - imUptime) < monitorDur
            [keyDown, secs, keyCodes] = KbCheck(-1);
            if keyDown
                if any(keyCodes([KbName('1!'), KbName('2@'), KbName('q')]))
                    slowrespReceived = 1;
                    slowresp = keyCodes;
                    slowRT = secs - imUptime;
                    if keyCodes(KbName('q'))
                        sca; return;
                    end
                end
            end
        end
        
        
         % check response accuracy
    if slowrespReceived
        if length(find(slowresp)) > 1 % error -- pressed multiple buttons
            thisDesign.slowacc(trial) = 0;
            thisDesign.slowresp(trial) = -1;
        elseif slowresp(KbName(thisDesign.corrRespSequence{trial}))
            thisDesign.slowacc(trial) = 1;
            thisDesign.slowresp(trial) = find(slowresp);
            thisDesign.slowRT(trial) = slowRT;
        else
            thisDesign.slowacc(trial) = 0;
            thisDesign.slowresp(trial) = slowresp;
            thisDesign.slowRT(trial) = slowRT;
        end
    end
    end
    % record data
    fprintf(fp, '%s, %d, %s, %d, %d, %2.4f, %d, %d, %2.4f, %2.4f, %s, %s\n', ... 
        subID, runNum, thisDesign.conditionSequence{trial}, thisDesign.acc(trial), thisDesign.resp(trial), ...
        thisDesign.RT(trial), thisDesign.slowacc(trial), thisDesign.slowresp(trial), thisDesign.slowRT(trial), ...
        thisDesign.upTimeErr(trial), thisDesign.imageSequence{trial}, ...
        thisDesign.corrRespSequence{trial});
end

fclose(fp);

while (GetSecs - expStart) < thisDesign.totalDur
end

% save data and clean up
save(outFileMat);
sca; return;

end



        
