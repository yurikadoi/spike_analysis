% last edits 4:42pm 11-27-18

%% *** IMPORTANT IMPORTANT - NEED TO VERIFY ALL TRIALS ARE LINED UP CORRECTLY, I.E. DATA TAKEN DIFFERENT WAYS - LICK, SPEED VS. SPIKES ETC ETC ETC

%% Part 1: Extract trial data

% CONFIRM correct timings between patchOn, patchStop, patchLeave, reward
% deliveries, etc

%load ADC files: 1 = speed, 2= lick sensor, 3 = reward valve, 4 = event
%signals

% 30,000 indices per second
[ADC_data{1}, ADC_ts] = load_open_ephys_data_fast('100_ADC1.continuous');
[ADC_data{2}] = load_open_ephys_data_fast('100_ADC2.continuous');
[ADC_data{3}] = load_open_ephys_data_fast('100_ADC3.continuous');
[ADC_data{4}] = load_open_ephys_data_fast('100_ADC4.continuous');

%save('ADC_data.mat','ADC_data');
%save('ADC_ts.mat','ADC_ts');

% convert ts from s to ms and round
ADC_ts = round(ADC_ts*1000);

%find first 'patchOn' signal
firstPatchOn = find(ADC_data{4}>0,1);

currADC_indx = 0;
patchOn_indx = [];
patchOn_ts = [];

nextPatchOn = 0;
nextpatchOnNull = 0;

patchStop_indx = [];
patchStop_ts = [];
patchStopTrue = [];

patchOff1s_indx = [];
patchOff1s_ts = [];

maxVoltsID = []; %max voltage between patchOn and patchOff to

lastPatchOn = find(ADC_data{4}>0,1, 'last');

while currADC_indx < lastPatchOn
    
    %display(currADC_indx)
    
    nextPatchOn = find(ADC_data{4}(currADC_indx+1:end)>.5,1)+currADC_indx;
    patchOn_indx = [patchOn_indx nextPatchOn];
    %display(patchOn_indx)
    
    currADC_indx = nextPatchOn;
    %display(currADC_indx);
    
    nextpatchOnNull = find(ADC_data{4}(currADC_indx+1:end)<.2,1)+currADC_indx;
    
    currADC_indx = nextpatchOnNull;
    
    maxVoltsID = [maxVoltsID max(ADC_data{4}(nextPatchOn:nextpatchOnNull))];
    %voltage = trial type ID
    
    
    nextPatchOff1s = find(ADC_data{4}(currADC_indx+1:end)<-.5,1)+currADC_indx;
    if isempty(nextPatchOff1s)
        display('empty')
        display(nextPatchOn)
        display(nextpatchOnNull)
    end
    patchOff1s_indx = [patchOff1s_indx nextPatchOff1s];
    
    rewValveMaxTemp = max(ADC_data{3}(nextPatchOn:nextPatchOff1s));
    patchStopTrue = [patchStopTrue rewValveMaxTemp>2];
    if patchStopTrue(end)==1
        patchStop_indx = [patchStop_indx find(ADC_data{3}(nextPatchOn+1:nextPatchOff1s)>2,1)+nextPatchOn];
    else
        patchStop_indx = [patchStop_indx 1]; %use 1 instead of 0 so indx isn't out of bounds later
    end
    currADC_indx = nextPatchOff1s;
    
end
display(length(patchOff1s_indx))
display(length(patchStop_indx))
display(length(patchOn_indx))


% store timestamps for patchOn, patchStop, and patchOff
patchOn_ts = ADC_ts(patchOn_indx);
patchStop_ts = ADC_ts(patchStop_indx);
patchOff1s_ts = ADC_ts(patchOff1s_indx);

%remove last trial from patchOn *if* session ended before mouse left final
%patch (if there is one more patchOn signal than patchOff
if length(patchOn_ts) > length(patchOff1s_ts)
    disp('this shit ran')
    patchOn_indx = patchOn_indx(1:end-1);
    patchOn_ts = patchOn_ts(1:end-1);
    
    if length(patchStop_indx) > length(patchOff1s_ts)
        patchStop_indx = patchStop_indx(1:end-1);
        patchStop_ts = patchStop_ts(1:end-1);
        patchStopTrue = patchStopTrue(1:length(patchStopTrue(1:end-1)));
        
    end
    
    if length(maxVoltsID) > length(patchOff1s_ts)
        disp('maxvolt shortened')
        maxVoltsID = maxVoltsID(1:length(maxVoltsID(1:end-1)));
    end
end

% 30,000 = one second
patchOn_speed(1,:) = zeros(1,300001);
patchOn_lick(1,:) = zeros(1,300001);
patchStop_speed(1,:) = zeros(1,600001);
patchStop_lick(1,:) = zeros(1,600001);
patchLeave_speed(1,:) = zeros(1,300001);
patchLeave_lick(1,:) = zeros(1,300001);

try
    %for iTrial = 1:length(patchStop_indx)
    for iTrial = 35:length(patchStop_indx)
        % making arrays of each trial based on distance from index for
        % patch on, patch stop, or patch leave
        patchOn_speed(iTrial,:) = ADC_data{1}(patchOn_indx(iTrial)-150000:patchOn_indx(iTrial)+150000);
        patchOn_lick(iTrial,:) = ADC_data{2}(patchOn_indx(iTrial)-150000:patchOn_indx(iTrial)+150000);
        patchStop_speed(iTrial,:) = ADC_data{1}(patchStop_indx(iTrial)-150000:patchStop_indx(iTrial)+450000);
        patchStop_lick(iTrial,:) = ADC_data{2}(patchStop_indx(iTrial)-150000:patchStop_indx(iTrial)+450000);
        patchLeave_speed(iTrial,:) = ADC_data{1}(patchOff1s_indx(iTrial)-150000:patchOff1s_indx(iTrial)+150000);
        patchLeave_lick(iTrial,:) = ADC_data{2}(patchOff1s_indx(iTrial)-150000:patchOff1s_indx(iTrial)+150000);
        
    end
catch
    display(iTrial)
    display('removes the last trial if not enough time after trial ends to fill the desired window')
    patchOn_speed = patchOn_speed(1:iTrial-1,:);
    patchOn_lick = patchOn_lick(1:iTrial-1,:);
    patchStop_speed = patchStop_speed(1:iTrial-1,:);
    patchStop_lick = patchStop_lick(1:iTrial-1,:);
    patchLeave_speed = patchLeave_speed(1:iTrial-1,:);
    patchLeave_lick = patchLeave_lick(1:iTrial-1,:);
    
    maxVoltsID = maxVoltsID(1:iTrial-1);
    
    patchOn_indx = patchOn_indx(1:iTrial-1);
    patchOn_ts = patchOn_ts(1:iTrial-1);
    patchOff1s_indx = patchOff1s_indx(1:iTrial-1);
    patchOff1s_ts = patchOff1s_ts(1:iTrial-1);
    patchStop_indx = patchStop_indx(1:iTrial-1);
    patchStop_ts = patchStop_ts(1:iTrial-1);
    
    patchStopTrue = patchStopTrue(1:iTrial-1);
end

% indices for patchOn signal to use voltage later to identify patch type
voltsOn = ADC_data{4}(patchOn_indx);
voltsOn20 = ADC_data{4}(patchOn_indx+20);

% idenitfy patch type by multplying voltage * 20 - tens place = A, ones place = B (from CBA)
trialID = round(maxVoltsID*20)';

%check for stop by detecting rewValve opening
for iPatch = 1:length(patchOn_ts)
    rewValveMax(iPatch) = max(ADC_data{3}(patchOn_indx(iPatch):patchOff1s_indx(iPatch)));
end

stopID = trialID(patchStopTrue==1); %trial IDs for patch stops

PRTs = (patchOff1s_ts(:)-patchStop_ts(:))/1000-.5; % patch leave signal = .5 seconds AFTER patchleave
PRTsTest = (patchOff1s_ts(patchStopTrue==1)-patchStop_ts(patchStopTrue==1))/1000-.5;

PRTs1 = PRTs(patchStopTrue==1);

PRTsLg = PRTs1(stopID>=40 & stopID<50);
PRTsMd = PRTs1(stopID>=20 & stopID<30);
PRTsSm = PRTs1(stopID>=10 & stopID<20);
LgMdSm = [mean(PRTsLg) mean(PRTsMd) mean(PRTsSm)]; %display(LgMdSm);

patchOn_didstop_ts = patchOn_ts(patchStopTrue==1);
patchOn_didnotstop_ts = patchOn_ts(patchStopTrue==0);

patchStopLg_ts = patchStop_ts(stopID>=40 & stopID<50);
patchStopMd_ts = patchStop_ts(stopID>=20 & stopID<30);
patchStopSm_ts = patchStop_ts(stopID>=10 & stopID<20);

patchStop_ts = patchStop_ts(patchStopTrue==1);

patchStop_speed = patchStop_speed(patchStopTrue==1,:);
    patchStop_lick = patchStop_lick(patchStopTrue==1,:);
    
    meanStop.speed = mean(patchStop_speed(patchStopTrue==1,:));
    meanStop.lick = mean(patchStop_lick(patchStopTrue==1,:));
    
    patchStop.speed{4} = patchStop_speed(stopID>=40,:);
    patchStop.speed{2} = patchStop_speed((stopID>=20 & stopID<= 30),:);
    patchStop.speed{1} = patchStop_speed(stopID<20,:);
    patchStop.lick{4} = patchStop_lick(stopID>=40,:);
    patchStop.lick{2} = patchStop_lick((stopID>=20 & stopID<= 30),:);
    patchStop.lick{1} = patchStop_lick(stopID<20,:);
    
    meanpatchStop.speed{4} = mean(patchStop.speed{4});
    meanpatchStop.speed{2} = mean(patchStop.speed{2});
    meanpatchStop.speed{1} = mean(patchStop.speed{1});
    meanpatchStop.lick{4} = mean(patchStop.lick{4});
    meanpatchStop.lick{2} = mean(patchStop.lick{2});
    meanpatchStop.lick{1} = mean(patchStop.lick{1});
    
    patchLeave_speed = patchLeave_speed(patchStopTrue==1,:);
    patchLeave_lick = patchLeave_lick(patchStopTrue==1,:);
    
    meanLeave.speed = mean(patchStop_speed(patchStopTrue==1,:));
    meanLeave.lick = mean(patchStop_lick(patchStopTrue==1,:));
    
    patchLeave.speed{4} = patchLeave_speed(stopID>=40,:);
    patchLeave.speed{2} = patchLeave_speed((stopID>=20 & stopID<= 30),:);
    patchLeave.speed{1} = patchLeave_speed(stopID<20,:);
    patchLeave.lick{4} = patchLeave_lick(stopID>=40,:);
    patchLeave.lick{2} = patchLeave_lick((stopID>=20 & stopID<= 30),:);
    patchLeave.lick{1} = patchLeave_lick(stopID<20,:);
    
    meanpatchLeave.speed{4} = mean(patchLeave.speed{4});
    meanpatchLeave.speed{2} = mean(patchLeave.speed{2});
    meanpatchLeave.speed{1} = mean(patchLeave.speed{1});
    meanpatchLeave.lick{4} = mean(patchLeave.lick{4});
    meanpatchLeave.lick{2} = mean(patchLeave.lick{2});
    meanpatchLeave.lick{1} = mean(patchLeave.lick{1});

%% SAVE TRIAL EXTRACTION DATA

save('extractedData.mat','patchStop_ts','patchStopLg_ts','patchStopMd_ts','patchStopSm_ts', ...
    'patchOn_didstop_ts','patchOn_didnotstop_ts','PRTsLg','PRTsMd','PRTsSm','PRTs1','stopID','trialID', ...
    'patchOn_indx','patchOff1s_indx','patchStop_indx','patchOn_ts','patchOff1s_ts', ...
    'patchStopTrue','maxVoltsID','PRTs','meanStop','meanLeave','meanpatchStop', ...
    'meanpatchLeave');

save('patchLeave_lickspeed.mat','patchLeave_speed','patchLeave_lick');
save('patchStop_lickspeed.mat','patchStop_speed','patchStop_lick');
save('patchOn_lickspeed.mat','patchOn_speed','patchOn_lick');
%save('patchStopSpeed.mat','patchStopSpeed');
%save('patchStopLick.mat','patchStopLick');
%save('patchStopSpeedLM.mat','patchStopSpeedLM');
%save('patchStopLickLM.mat','patchStopLickLM');


    
