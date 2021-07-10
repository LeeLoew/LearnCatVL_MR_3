function testoptim2
% generate our own sequence order
% prompt={'Enter the subject ID','Old v. New run number'};
% name='Input for PV run';
% numlines=1;
% defaultanswer={'x','000'};
% answer=inputdlg(prompt,name,numlines,defaultanswer);
% commandwindow;
% subID = answer{1};
% runNum = answer{2};

% TODO: check that this run doesn't have a data file

% load subject configuration file
% load(['Configurations/' subID '.mat']);

% load the par file
% fp_par = fopen(['PVSchedules/' subID '-' runNum '.par'], 'r');
% parData = textscan(fp_par, '%f\t%d\t%f\t%f\t%s');

while 1
    trialorder = Shuffle([1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 11 11 11 11 11 11 11 11]);
    % don't allow back-to-back repetition of condition
    if ~any(trialorder(1:(end-1))==trialorder(2:end))
        break;
    end
end

ITI_orders = Shuffle(repmat([5 6 7 8 9 10], 1, length(trialorder)/6));

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
for idx = 1:length(trialorder)
    switch trialorder(idx)
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
corrmat(corrmat==1) = 0;
disp(max(max(abs(corrmat))))

end


