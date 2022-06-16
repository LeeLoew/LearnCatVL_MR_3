function testoptim
prompt={'Enter the subject ID','Old v. New run number'};
name='Input for PV run';
numlines=1;
defaultanswer={'x','000'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
commandwindow;
subID = answer{1};
runNum = answer{2};

% TODO: check that this run doesn't have a data file

% load subject configuration file
load(['Configurations/' subID '.mat']);

% load the par file
fp_par = fopen(['PVSchedules/' subID '-' runNum '.par'], 'r');
parData = textscan(fp_par, '%f\t%d\t%f\t%f\t%s');

CS1_stick = zeros(1,sum(parData{3}));
CS2_stick = zeros(1,sum(parData{3}));
CD1_stick = zeros(1,sum(parData{3}));
CD2_stick = zeros(1,sum(parData{3}));
CSing_stick = zeros(1,sum(parData{3}));
NS1_stick = zeros(1,sum(parData{3}));
NS2_stick = zeros(1,sum(parData{3}));
ND1_stick = zeros(1,sum(parData{3}));
ND2_stick = zeros(1,sum(parData{3}));
NSing_stick = zeros(1,sum(parData{3}));
Novel_stick = zeros(1,sum(parData{3}));

for idx = 1:length(parData{1})
    switch parData{5}{idx}
        case 'CS1'
            CS1_stick(parData{1}(idx)+1) = 1;
        case 'CS2'
            CS2_stick(parData{1}(idx)+1) = 1;
        case 'CD1'
            CD1_stick(parData{1}(idx)+1) = 1;
        case 'CD2'
            CD2_stick(parData{1}(idx)+1) = 1;
        case 'CSing'
            CSing_stick(parData{1}(idx)+1) = 1;
        case 'NS1'
            NS1_stick(parData{1}(idx)+1) = 1;
        case 'NS2'
            NS2_stick(parData{1}(idx)+1) = 1;
            
        case 'ND1'
            ND1_stick(parData{1}(idx)+1) = 1;
        case 'ND2'
            ND2_stick(parData{1}(idx)+1) = 1;
        case 'NSing'
            NSing_stick(parData{1}(idx)) = 1;
        case 'NOVEL'
            Novel_stick(parData{1}(idx)+1) = 1;
    end
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

CS1_ev = CS1_ev(1:sum(parData{3}));
CS2_ev = CS2_ev(1:sum(parData{3}));
CD1_ev = CD1_ev(1:sum(parData{3}));
CD2_ev = CD2_ev(1:sum(parData{3}));
CSing_ev = CSing_ev(1:sum(parData{3}));
NS1_ev = NS1_ev(1:sum(parData{3}));
NS2_ev = NS2_ev(1:sum(parData{3}));
ND1_ev = ND1_ev(1:sum(parData{3}));
ND2_ev = ND2_ev(1:sum(parData{3}));
NSing_ev = NSing_ev(1:sum(parData{3}));
Novel_ev = Novel_ev(1:sum(parData{3}));

design_matrix = [CS1_ev',  CS2_ev', CD1_ev', CD2_ev', CSing_ev', ...
                 NS1_ev',  NS2_ev', ND1_ev', ND2_ev', NSing_ev', Novel_ev']; 
             
corrmat = corr(design_matrix);
corrmat(corrmat==1) = 0;
disp(max(max(abs(corrmat))))

end


