load('extractedData.mat')
%%
%get general info about the experiment data and mouseID
currentFolder = pwd;
folder_date=currentFolder(end-16:end-9);
mouseID=currentFolder(end-21:end-20);
%%
% compile list of tetrode files
ttfiles = dir('TT*');

save_flag=0;

%get general info about the experiment data and mouseID
currentFolder = pwd;
folder_date=currentFolder(end-16:end-9);
mouseID=currentFolder(end-21:end-20);

% get timestamps for each neuron
for iNeuron = 1:length(ttfiles)
    % load spikes
    tsSpikes = LoadSpikes(ttfiles(iNeuron).name);
    %this_one = [iNeuron ttfiles(iNeuron).name]; display(this_one); % this line for display only
    
    % convert sec to ms
    msSpikeOccur = (tsSpikes{1}.T * 1000 );
    msSpikeOccur = round(msSpikeOccur); 
    data.tsSpikes{iNeuron} = msSpikeOccur;
    
end

%%
stops = zeros(length(stopID),1); stops(stopID>10)=1; stops(stopID>15)=2; stops(stopID>20)=3; stops(stopID>25)=4; stops(stopID>40)=5; stops(stopID>45)=6; stops(stopID>50)=0;
%group
stops2 = zeros(length(stops),1);
stops2(stops==1 | stops==2) = 1;
stops2(stops==3 | stops==4) = 2;
stops2(stops==5 | stops==6) = 3;

[sorted_PRTsLg, LgSortIndx]=sort(PRTsLg);
Lg_quartileSize=floor(length(PRTsLg)/4);

Lg_shortPRTs_indx=LgSortIndx(1:Lg_quartileSize);
Lg_longPRTs_indx=LgSortIndx(end-Lg_quartileSize+1:end);


Lg_general_indx=find(stops2==3);
Lg_general_shortPRTs_indx=Lg_all_indx(Lg_shortPRTs_indx);
Lg_general_LongPRTs_indx=Lg_all_indx(Lg_longPRTs_indx);

stops3 = zeros(length(stops2),1);
stops3(Lg_general_shortPRTs_indx)=1;
stops3(Lg_general_LongPRTs_indx)=2;
trials2plot=[Lg_general_shortPRTs_indx' Lg_general_LongPRTs_indx']
%%
iNeuron=6;

plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOn_didstop_ts(trials2plot), -500, 12000, stops3(trials2plot))

figure_name=[mouseID, '-', folder_date  'MClust-PatchOn',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
title(figure_name)
