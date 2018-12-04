%% Part 2: get those spikes then plot them spikes
% * move this to its own .m file after getting it up and running) *
load('extractedData.mat')
load('patchLeave_lickspeed.mat')
load('patchOn_lickspeed.mat')
load('patchStop_lickspeed.mat')
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
    
    %% what is this shit about ignoring spikes?
    
    % do not ignore spikes. I need to match raw waveform and spikes
    % for laser identification, and this makes # of spikes less than
    % MClustered. Do it later when generating inst_fr.
    % ignore spikes before task initiation (DAQ start)
    %     msSpikeOccur = msSpikeOccur(msSpikeOccur > 0);
    % ignore spikes after task initiation (DAQ end)
    %     msSpikeOccur = msSpikeOccur(msSpikeOccur < nData);
    
    
    data.tsSpikes{iNeuron} = msSpikeOccur;
    
end

stops = zeros(length(stopID),1); stops(stopID>10)=1; stops(stopID>15)=2; stops(stopID>20)=3; stops(stopID>25)=4; stops(stopID>40)=5; stops(stopID>45)=6; stops(stopID>50)=0;


for iNeuron = 1:length(ttfiles)
%for iNeuron=1:2
    figure;
    trials2plot=1:1:length(stops);
    plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOn_didstop_ts(trials2plot), -2000, 4000, stops(trials2plot));    
    h=get(gcf,'children');
    figure_name=[mouseID, '-', folder_date  'MClust-PatchOn',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
    
    title(figure_name)
    h(3).XLabel=xlabel('time (sec)');
    h(3).Legend.String = [{'SmNP'},{'SmP'},{'MdNP'},{'MdP'},{'LgNP'},{'LgP'}];
    h(3).Legend.Position=[0.1524    0.1072    0.1393    0.2012];
    if save_flag==1
        saveas(gcf,[figure_name '.png'])
        saveas(gcf,[figure_name '.fig'])
    end
    
    figure;
    trials2plot=1:1:length(stops);
    plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchStop_ts(trials2plot), -2000, 4000, stops(trials2plot));
    h=get(gcf,'children');
    figure_name=[mouseID, '-', folder_date  'MClust-PatchStop',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
    
    title(figure_name)
    h(3).XLabel=xlabel('time (sec)');
    h(3).Legend.String = [{'SmNP'},{'SmP'},{'MdNP'},{'MdP'},{'LgNP'},{'LgP'}];
    h(3).Legend.Position=[0.1524    0.1072    0.1393    0.2012];
    if save_flag==1
        saveas(gcf,[figure_name '.png'])
        saveas(gcf,[figure_name '.fig'])
    end
    
end


%%
% look more closely at some units when desired (alternatively can just change plots
% above to use subplots w speed, etc to make more comprehensive
Neurons = [1:length(ttfiles)]; % list neurons based on what their iNeuron # was from 'get timestamps' loop above
for i=1:length(Neurons)
    iNeuron = Neurons(i);
    
    
    figure;
    %group
    stops2 = zeros(length(stops),1);
    stops2(stops==1 | stops==2) = 1;
    stops2(stops==3 | stops==4) = 2;
    stops2(stops==5 | stops==6) = 3;
    
    
    %add switch case for weird day data
    
    trials2plot=1:1:length(stops2);
    %trials2plot=35:1:length(stops2); % for mouse 33, 11-15 <- skips a
    %bunch of trials for this day this mouse because there is some weird
    %signal at beginning on events channel that triggers false positives
    %for trials occuring
    plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOn_didstop_ts(trials2plot), -500, 4000, stops2(trials2plot))
    h=get(gcf,'children');
    figure_name=['4sec-SmMdLg-', mouseID, '-', folder_date  'MClust-PatchOn',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
    title(figure_name)
    h(3).XLabel=xlabel('time (sec)');
    h(3).Legend.String = [{'Sm'},{'Md'},{'Lg'}];
    h(3).Legend.Position=[0.1524    0.1072    0.1393    0.2012];
    if save_flag==1
        saveas(gcf,[figure_name '.png'])
        saveas(gcf,[figure_name '.fig'])
    end
    
    
    
    figure; % same thing but plot longer time window
    plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOn_didstop_ts(trials2plot), -500, 12000, stops2(trials2plot))
    h=get(gcf,'children');
    figure_name=['12sec-SmMdLg-', mouseID, '-', folder_date  'MClust-PatchOn',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
    title(figure_name)
    h(3).XLabel=xlabel('time (sec)');
    h(3).Legend.String = [{'Sm'},{'Md'},{'Lg'}];
    h(3).Legend.Position=[0.1524    0.1072    0.1393    0.2012];
    if save_flag==1
        saveas(gcf,[figure_name '.png'])
        saveas(gcf,[figure_name '.fig'])
    end
    
    % aligned to patch leave time
    figure;
    plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOff1s_ts((trials2plot))-500, -3000, 3000, stops2(trials2plot));
    h=get(gcf,'children');
    figure_name=['PatchLeave-SmMdLg-', mouseID, '-', folder_date  'MClust-PatchOn',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
    title(figure_name)
    h(3).XLabel=xlabel('time (sec)');
    h(3).Legend.String = [{'Sm'},{'Md'},{'Lg'}];
    h(3).Legend.Position=[0.1524    0.1072    0.1393    0.2012];
    if save_flag==1
        saveas(gcf,[figure_name '.png'])
        saveas(gcf,[figure_name '.fig'])
    end
    
    
    figure;
    subplot(2,1,2)
    sp2 = subplot(2,1,2);
    p2 = get(sp2,'position');
    p2(4) = p2(4)*(2/3); % reduce height
    set(sp2, 'position', p2);
    plot(-meanpatchStop.speed{4}(90001:330000),'b-'); hold on;
    plot(-meanpatchStop.speed{2}(90001:330000),'g-');
    plot(-meanpatchStop.speed{1}(90001:330000),'r-');
    
    subplot(2,1,1)
    sp1 = subplot(2,1,1);
    p1 = get(sp1,'position');
    p1(2) = p1(2)-(1/3*p1(4));
    p1(4) = p1(4)*(4/3); % reduce height
    set(sp1,'position',p1);
    plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOn_didstop_ts, -2000, 6000, stops2)
    h=get(gcf,'children');
    figure_name=['Speed-SmMdLg-', mouseID, '-', folder_date  'MClust-PatchOn',ttfiles(iNeuron).name(1:3),'-',ttfiles(iNeuron).name(5:end-4)];
    title(figure_name)
    h(3).XLabel=xlabel('time (sec)');
    h(3).Legend.String = [{'Sm'},{'Md'},{'Lg'}];
    h(3).Legend.Position=[0.1524    0.1072    0.1393    0.2012];
    if save_flag==1
        saveas(gcf,[figure_name '.png'])
        saveas(gcf,[figure_name '.fig'])
    end
    
%     
%     % plot aligned to leave time w speed subplot underneath
%     figure;
%     subplot(2,1,2)
%     sp2 = subplot(2,1,2);
%     p2 = get(sp2,'position');
%     p2(4) = p2(4)*(2/3); % reduce height
%     set(sp2, 'position', p2);
%     plot(-meanpatchLeave.speed{4}(1:180000),'b-'); hold on;
%     plot(-meanpatchLeave.speed{2}(1:180000),'g-');
%     plot(-meanpatchLeave.speed{1}(1:180000),'r-');
%     
%     subplot(2,1,1)
%     sp1 = subplot(2,1,1);
%     p1 = get(sp1,'position');
%     p1(2) = p1(2)-(1/3*p1(4));
%     p1(4) = p1(4)*(4/3); % reduce height
%     set(sp1,'position',p1);
%     plot_timecourse('timestamp', data.tsSpikes{iNeuron}, patchOff1s_ts(patchStopTrue==1)-500, -3000, 3000, stops2);
end


% add more sanity check ADD MORE CHECKS TO ENSURE NO ERRORS


%% ATTENTION ATTENTION ADD MORE SANITY CHECKS TO ENSURE NO ERRORS