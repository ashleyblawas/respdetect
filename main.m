%%% Adapted from d3makeprh_js.m, Jeanne Shearer's script to proccess D3
%%% files

%%% Author: Ashley Blawas
%%% Date: June, 19, 2020
%%% Duke University

%% Load tools
clear; clc; close all

% Load variable with tag names
taglist = {'gm08_143a',...
    'gm08_143b',...
    'gm08_147a',...
    'gm08_151a',...
    'gm08_151b',...
    'gm10_185b',...
    'gm10_187a',...
    'gm10_208a',...
    'gm10_186a',...
    'gm10_186b',...
    'gm10_187b',...
    'gm10_209a',...
    'gm10_209c',...
    'gm10_266a',...
    'gm10_267a',...
    'gm11_147a',...
    'gm11_148a',...
    'gm11_149b',...
    'gm11_149c',...
    'gm11_150a',...
    'gm11_150b',...
    'gm11_155a',...
    'gm11_156a',...
    'gm11_158b',...
    'gm11_165a',...
    'gm12_125a',...
    'gm12_125b',...
    'gm12_161a',...
    'gm12_162a',...
    'gm12_163a',...
    'gm12_163b',...
    'gm12_172a',...
    'gm12_246a',...
    'gm14_145a',...
    'gm14_167a',...
    'gm14_178a',...
    'gm14_178b',...
    'gm14_279a',...
    'gm16_133a',...
    'gm16_181a',...
    'gm15_145b',...
    'gm15_153a',...
    'gm17_234a',...
    'gm18_157a',...
    'gm18_157b',...
    'gm18_159a',...
    'gm18_227a',...
    'gm18_239a'
    };

% I want to remove everything from the rest of the functions that has to do
% with tag processing because I am operating under the assumption that tag
% processing is DONE by this point

%% Step 1: Load tools
clearvars -except taglist; clc; close all

% Place where the resp_detect tools are stored
tools_path = 'C:\Users\Ashley\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\src';

% Place where the DTAG tools are stored
mat_tools_path = 'C:\Users\Ashley\Dropbox\Ashley\Graduate\Toolboxes\DTAG3';

% Place where the DTAG records are stored
data_path = 'D:\gm';

addpath(genpath(tools_path)); %Add all of your tools to the path
addpath(genpath(mat_tools_path)); %Add all of your data to the path
addpath(genpath(data_path)); %Add all of your data to the path

%% For tag data processing - ONLY DO ONCE 
% Read in data
% X=d3readswv(recdir,prefix,df); %often a df of 10 or 20 is good. Want final sampling rate of 10-20Hz
X = d3readswv(recdir,prefix,10); %Read in sensor files
warning('off','last')

% Apply bench calibration
[CAL, D] = d3deployment(recdir,prefix,deploy_name);

% Perform pressure calibration
%Pick all data points on the lower broken line. Redo if 2nd order fitting error is more than 0-20cm
[p,CAL] = d3calpressure(X,CAL,'full');

% Calibrate accelerometer
%[A,CAL,fs]=d3calacc(X,CAL,'full',min_depth); %min_depth usually 10 for deep divers
[A,CAL,fs] = d3calacc(X, CAL,'full', 10); %Needs to have standard deviation below 0.04

% Calibrate magnetometer
%[M,CAL]=d3calmag(X,CAL,'full',min_depth); %min_depth usually 10 for deep divers
[M,CAL] = d3calmag(X, CAL, 'full', 10); %Needs to have standard deviation below 0.5

% Save the calibration
d3savecal(deploy_name, 'CAL', CAL)

% PRH predictor (see prhpredictorlmml2.docx for details)
%PRH=prhpredictor(p,A,fs,[TH,METHOD,DIR]); %choose 4-10 cycles. 
PRH = prhpredictor(p,A,fs,500,1,'both'); %Look at output for moves, large unexpected changes in either the pitch, roll, or heading between dives
%Changes from 0 to 180 or -180 are normal, just the way the sensors work

% Define any moves
%move1=[t1,t2,p0,r0,h0]; prh must be in RADIANS 
%Define the number of moves (aka slips) here
move1=[0 0 -0.0330 3.1155 -0.1961];%If there are no slips, you will only have a move1

OTAB=[move1]; %Create array of moves
d3savecal(deploy_name,'OTAB',OTAB) %Save moves into calibration folder
[Aw, Mw] = tag2whale(A,M,OTAB,fs); %Use moves to go from tag frame to whale frame

% For testing a tag...
% Aw=A;
% Mw=M;
[pitch roll] = a2pr(Aw);

%[head,mm,incl]=m2h(Mw,Aw,fs); %D4 tool version
[head,mm,incl] = m2h(Mw,pitch,roll); %D3 tool version

% Add other info (Optional)
d3savecal(deploy_name,'Location','')

% Make PRH file
%d3makeprhfile(recdir,prefix,tag,25)
%d3makeprhfile(recdir,prefix,tag,10)
saveprh(tag,'p','A','M','fs','Aw','Mw','pitch','roll','head'); %Save the prh file to your directory

%% Make metadata file if needed
for k = 1:length(taglist);
    % Step 2: Input tag names and DTAG version
    
    if exist('k','var') == 1
        tag = taglist{k};
    else
        tag = taglist{1};
    end
    
    % Make metadata file
    metadata_fname = strcat(data_path, "\metadata\", tag, "md.mat");
    if isfile(metadata_fname) == 1
        fprintf("A metadatafile exists for %s - go the next section!\n", tag)
    else
        fprintf("No metadata file exists for %s.\n", tag)
        str = input("Do you want to make a metadata file now? (y/n)\n",'s');
        if strcmp(str, "y") == 1
            % Load the tag's prh file
            loadprh(tag);
            %Print out the fs so you can check it's what you expect
            fprintf('fs = %i Hz\n', fs);
            
            % Calculate time variables for easier workup
            [time_sec, time_min, time_hour] =calc_time(fs, p);
            
            % Designate an estimated tag on/off time
            [est_time_tagon] = get_tag_on(time_sec, p);
            [est_time_tagoff] = get_tag_off(time_sec, p);
            tag_on = str2num(cell2mat(est_time_tagon));
            tag_off = str2num(cell2mat(est_time_tagoff));
            tag_dur = datestr(seconds(tag_off-tag_on),'HH:MM:SS');
            tag_ver = 'D3'; % Or D2, change this manually
            
            %Setup directories
            [tag, tag_ver, recdir, prefix, acousaud_filename, breathaud_filename] = setup_dirs(tag, tag_ver, data_path, mat_tools_path);
            
            % Make a metadata file
            [metadata] = make_metadata(tag, recdir, prefix, fs, tag_ver, acousaud_filename, breathaud_filename, tag_on, tag_off);
            save(strcat(data_path, "\metadata\", tag, "md"), 'tag', 'recdir', 'prefix', 'fs', 'tag_ver', 'tag_on', 'tag_off', 'tag_dur', 'acousaud_filename', 'breathaud_filename')
            fprintf("Made and saved a tag metadata file\n")
        end
        
    end
end

% Clear variables that are now saved in the metadata structure
clear tag prefix recdir fs tag_ver acousaud_filename breathaud_filename tag_on tag_off tag_dur metadata_fname str

%% Find dives if needed
for k = 1:length(taglist);
    
    % Load in tag
    tag = taglist{k};
    
    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
    
    % Setup directories
    [recdir, prefix, acousaud_filename, breathaud_filename] = setup_dirs(metadata.tag, metadata.tag_ver, data_path, mat_tools_path);
    
    % Set prh path to 50 Hz prh files
    settagpath('PRH', strcat(data_path,'\prh\50 Hz'))
    
    % Load the existing prh file
    loadprh(metadata.tag);
    fprintf('fs = %i Hz\n', fs);

    % Calculate other vars
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
    
    % Make diving file
    diving_fname = strcat(data_path, "\diving\divethres_5m\", metadata.tag, "dives.mat");
    if isfile(diving_fname) == 1
        fprintf("A diving table exists for %s - go the next section!\n", metadata.tag)
    else
        fprintf("No diving table  exists for %s.\n", metadata.tag)
        str = input("Do you want to make a diving table now? (y/n)\n",'s');
        if strcmp(str, "y") == 1
            % Set dive threshold, calculate dive and surface durations
            dive_thres = 5; % Quick et al., 2017
            [dive_thres, T]=get_dives(p, metadata.fs, dive_thres); % Give p(depth) and fs(sampling frequency)
            
            if size(T, 1) <= 1
                display('Only 1 deep dive! Not continuing analysis...')
                
            else
                % Plot dives
                [dive_dur_plot, surf_dur_plot] = plot_dives(T, time_sec, p);
                
                for i = 1:size(T, 1)
                    tag{i} = metadata.tag;
                    depth_thres(i) = dive_thres;
                    dive_num(i) = i;
                    dive_start(i) = T(i, 1);
                    dive_end(i) = T(i, 2);
                    max_depth(i) = T(i, 3);
                    time_maxdepth(i) = T(i, 4);
                    dive_dur(i) = dive_end(i) - dive_start(i);
                end
                for i = 1:size(T, 1)-1
                    surf_num(i) = i';
                    surf_start(i) = dive_end(i)';
                    surf_end(i) = dive_start(i+1)';
                    surf_dur(i) = surf_end(i)-surf_start(i);
                end
                surf_num(size(T, 1)) = NaN;
                surf_start(size(T, 1)) = NaN';
                surf_end(size(T, 1)) = NaN';
                surf_dur(size(T, 1)) = NaN';
                
                
                save(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "dives"), 'tag', 'depth_thres', 'dive_num', 'dive_start', 'dive_end', 'max_depth', 'time_maxdepth', 'dive_dur', 'surf_num', 'surf_start', 'surf_end', 'surf_dur');
                Tab = table(tag', depth_thres', dive_num', dive_start', dive_end', max_depth', time_maxdepth', dive_dur', surf_num', surf_start', surf_end', surf_dur');
                Tab.Properties.VariableNames = {'tag', 'depth_thres', 'dive_num', 'dive_start', 'dive_end', 'max_depth', 'time_maxdepth', 'dive_dur', 'surf_num', 'surf_start', 'surf_end', 'surf_dur'};
                save(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "divetable"), 'Tab')
                beep on; beep
                
                display('Dive detection complete!');
            end
            clear tag depth_thres dive_num dive_start dive_end max_depth time_maxdepth dive_dur surf_num surf_start surf_end surf_dur
        end
    end
end

%% Load dives
clear Tab dive_table
dive_table = []; 

diving_dir = strcat(data_path, '\diving\divethres_5m\'); 
filesAndFolders = dir(diving_dir);   
filesInDir = filesAndFolders(~([filesAndFolders.isdir]));  % Returns only the files in the directory                    
temp = struct2cell(filesInDir);
temp = temp(1, :)';

for k = 1:length(taglist);
    tag = taglist{k};
    foundStr= strfind(temp, tag);
    rel_files = find(~cellfun('isempty',foundStr));
    load(strcat(diving_dir, cell2mat(temp(rel_files(2)))))
    dive_table = [dive_table; Tab];
    colorcell{k} = rand(1,3).*ones(height(Tab), 3);
end

color = cell2mat([colorcell']);

clear diving_dir filesAndFolders filesInDir temp foundStr rel_files

%% Plot dives and do some dive EDA
f = figure;
subplot(1, 3, 1)
scatter(dive_table.dive_dur./60, dive_table.max_depth, [], color, 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Max depth (m)');
ax = gca; 
ax.FontSize = 12;

subplot(1, 3, 2)
scatter(dive_table.dive_dur./60, dive_table.surf_dur./60, [], color, 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Post-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;

subplot(1, 3, 3)
scatter(dive_table.dive_dur(2:end)./60, dive_table.surf_dur(1:end-1)./60, [], color(2:end, :), 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Pre-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;
f.Position = [100 100 1000 300];

% Plotting clustering of dives/depths
f = figure;
% dbscan clustering
idx = dbscan([dive_table.dive_dur./60, dive_table.max_depth], 10, round(length(dive_table.dive_dur)/10, 0));
gscatter(dive_table.dive_dur./60, dive_table.max_depth, idx,'gb','os',6)
 xlabel('Dive duration (min)'); ylabel('Max depth (m)');
ax = gca; 
ax.FontSize = 12;
legend('Cluster 1','Cluster 2',...
       'Location','SE')

f.Position = [100 100 315 300];

% Make new post pre dive interval figures with deeper/longer cluster
deep_dive_dur = dive_table.dive_dur;
deep_dive_dur(idx == 1) = [];

deep_dive_surf_dur = dive_table.surf_dur;
deep_dive_surf_dur(idx == 1) = [];

deep_color = color;
deep_color(idx == 1, :) = [];

f = figure;
subplot(1, 2, 1)
scatter(deep_dive_dur./60, deep_dive_surf_dur./60, [], deep_color, 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Post-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;

subplot(1, 2, 2)
scatter(deep_dive_dur(2:end)./60, deep_dive_surf_dur(1:end-1)./60, [], deep_color(2:end, :), 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Pre-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;
f.Position = [100 100 630 300];

% Fit some basic lienar models 

mdl_post = fitlm(deep_dive_dur./60, deep_dive_surf_dur./60);
mdl_pre = fitlm(deep_dive_dur(2:end)./60, deep_dive_surf_dur(1:end-1)./60)

%% Process movement information if needed

% Load in metadata and prh 
for k = 1:length(taglist)
    
    % Load in tag
    tag = taglist{k};
    
    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
    
    % Make movement filename
    movement_fname = strcat(data_path, "\movement\", metadata.tag, "movement.mat");
    
     if isfile(movement_fname) == 1
        fprintf("A movement table exists for %s - go the next section!\n", metadata.tag)
    else
        fprintf("No movement table  exists for %s.\n", metadata.tag)
        %str = input("Do you want to make a movement table now? (y/n)\n",'s');
        
        %if strcmp(str, "y") == 1

            % Setup directories
            [recdir, prefix, acousaud_filename, breathaud_filename] = setup_dirs(metadata.tag, metadata.tag_ver, data_path, mat_tools_path);

            % Set prh path to 50 Hz prh files
            settagpath('PRH', strcat(data_path,'\prh\50 Hz'))

            % Load the existing prh file
            loadprh(metadata.tag);

            %Calculate other vars
            [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);

            %Calculate filtered acceleration
            %Rename Aw vector
            surge = Aw(:, 1);
            sway = Aw(:, 2);
            heave = Aw(:, 3);

            % Filter all three accel vectors, 5th order butterworth, used 10 and 0.2
            %as upper in saved movement files
            surge_filt = filter_acc(surge, fs, 10);
            sway_filt = filter_acc(sway, fs, 10);
            heave_filt = filter_acc(heave, fs, 10);

            %Get surge diff
            surge_diff = diff(surge_filt);
            sway_diff = diff(sway_filt);
            heave_diff = diff(heave_filt);

            %Get Shannon entropy
            surge_se = log(abs(surge_diff))*sum(abs(surge_diff));
            sway_se = log(abs(sway_diff))*sum(abs(sway_diff));
            heave_se = log(abs(heave_diff))*sum(abs(heave_diff));

            %Get smoothed Shannon entropy
            surge_smooth = movavg(surge_se,'triangular', fs);
            sway_smooth = movavg(sway_se,'triangular', fs);
            heave_smooth = movavg(heave_se,'triangular', fs);

            %Calculate jerk for each direction
            %Fitler acceleration using Savitsky-Golay filter, using 3,11
            surge_sgf = sgolayfilt(surge_filt,3,11);
            sway_sgf = sgolayfilt(sway_filt,3,11);
            heave_sgf = sgolayfilt(heave_filt,3,11);

            %Calculate jerk in each vector
            surge_jerk = 9.81*fs*sqrt(diff(surge_sgf).^2);
            sway_jerk = 9.81*fs*sqrt(diff(sway_sgf).^2);
            heave_jerk = 9.81*fs*sqrt(diff(heave_sgf).^2);

            jerk = [surge_jerk, sway_jerk, heave_jerk];

            %Get Shannon entropy of jerk
            for i = 1:length(jerk)
                jerk_se(i) = sum(abs(jerk(i, :)).*log(abs(jerk(i, :))));
            end

            %Get smoothed Shannon entropy
            jerk_smooth = movavg(jerk_se','triangular', 2*fs);
            
            % Build filter for prh
            fny = fs/2;
            pass = [1, 7];
            [b,a]=butter(5,pass/fny,'bandpass');

            % Calculate filtered prh signals
            pitch_filt = filter(b, a, pitch);
            roll_filt = filter(b, a, roll);
            head_filt = filter(b, a, head);

            %Get prh diff
            pitch_diff = diff(pitch_filt);
            roll_diff = diff(roll_filt);
            head_diff = diff(head_filt);

            %Get Shannon entropy
            pitch_se = log(abs(pitch_diff))*sum(abs(pitch_diff));
            roll_se = log(abs(roll_diff))*sum(abs(roll_diff));
            head_se = log(abs(head_diff))*sum(abs(head_diff));

            %Get smoothed Shannon entropy
            pitch_smooth = movavg(pitch_se,'linear', 3*fs);
            head_smooth = movavg(head_se,'linear', 3*fs);
            roll_smooth = movavg(roll_se,'linear', 3*fs);

            save(strcat(data_path, "\movement\", metadata.tag, "movement.mat"), 'p', 'Aw', 'surge', 'sway', 'heave',...
                'surge_filt', 'sway_filt', 'heave_filt',...
                'surge_diff', 'sway_diff', 'heave_diff',...
                'surge_se', 'sway_se', 'heave_se',...
                'surge_smooth', 'sway_smooth', 'heave_smooth',...
                'surge_sgf', 'sway_sgf', 'heave_sgf',...
                'surge_jerk', 'sway_jerk', 'heave_jerk',...
                'jerk', 'jerk_se', 'jerk_smooth',...
                'pitch_filt', 'head_filt', 'roll_filt',...
                'pitch_diff', 'head_diff', 'roll_diff',...
                'pitch_se', 'head_se', 'roll_se',...
                'pitch_smooth', 'head_smooth', 'roll_smooth');
           %beep on; beep

            display('Movement information calculation complete!');
       
            clearvars -except taglist tools_path mat_tools_path data_path; clc; close all
        %end
     end
end

%% Load movement data, plot, and do some EDA

for k = 1:length(taglist);
    
    tag = taglist{k};
    
    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
      
    % Load in movement data
    load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"));
    
    % Calculate time vars
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, surge);
    %%
    figure;
    title(metadata.tag);
    ax(1)=subplot(7, 1, 1);
    plot(time_min, p); hold on
    set(gca,'Ydir','reverse')
    ylabel('Depth (m)');

    ax(2)=subplot(7, 1, 2);
    plot(time_min, surge_filt); hold on
    plot(time_min, sway_filt);
    plot(time_min, heave_filt); 
    ylabel('Filtered Acc');

    ax(3)=subplot(7, 1, 3);
    plot(time_min(2:end), surge_diff); hold on
    plot(time_min(2:end), sway_diff);
    plot(time_min(2:end), heave_diff); 
    ylabel('Diff Acc');

    ax(4)=subplot(7, 1, 4);
    plot(time_min(2:end), surge_smooth, 'r-'); hold on
    plot(time_min(2:end), sway_smooth, 'g-');
    plot(time_min(2:end), heave_smooth, 'b-'); 
    linkaxes(ax, 'x');
    ylabel('Smoothed SE');

    ax(5)=subplot(7, 1, 5);
    plot(time_min(2:end), surge_jerk); hold on
    plot(time_min(2:end), sway_jerk);
    plot(time_min(2:end), heave_jerk); 
    ylabel('Jerk');

    ax(6)=subplot(7, 1, 6);
    plot(time_min(2:end), jerk_se, 'k'); hold on
    ylabel('Jerk SE');

    ax(7)=subplot(7, 1, 7);
    plot(time_min(2:end), jerk_smooth, 'k'); 
    linkaxes(ax, 'x');
    ylabel('Smoothed Jerk SE');
    %%
    pause;
    fprintf("Press any key to view the next tag record");
end

%% Set up directories
[recdir, prefix, acousaud_filename, breathaud_filename] = setup_dirs(metadata.tag, metadata.tag_ver, data_path, mat_tools_path);

%% Find breath automatically 
k=1;
tag = taglist{k};   

findbreaths(breathaud_filename, tag, metadata.fs, time_sec, time_min, pitch_smooth, Tab, 'bp')
% saveauditbreaths(tag, R); % Save audit
%[breath_times, bp , breath_idx]=import_breaths(breathaud_filename, time_sec); % Import the breaths

%% Breath audit %USING THIS

tag = taglist{k};
%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));
clear tag

% Set up directories
[recdir, prefix, acousaud_filename, breathaud_filename] = setup_dirs(metadata.tag, metadata.tag_ver, data_path, mat_tools_path);

% Set prh path to 50 Hz prh files
settagpath('PRH', strcat(data_path,'\prh\50 Hz'))

% Load the existing prh file
loadprh(metadata.tag);

% Load in movement data
load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"));

% Want pitch to be positive for peak detect, so adding min
pitch_smooth = pitch_smooth + abs(min(pitch_smooth));

%% Make a new section to do auto detection
% Just want to run a peak detector across jerk_smooth and pitch_smooth and
% then want it to present me with each surfacing and I can either okay it
% or edit it
for i = 1:length(jerk_smooth)
    if p(i)>1
        jerk_smooth(i) = NaN;
        pitch_smooth(i) = NaN;
    end
end

[time_sec, time_min, time_hour] =calc_time(metadata.fs, p);

% Adapt find breaths to go through each surfacing and choose peaks (or
% maybe like each 2 minute period)
figure
plot(pitch_smooth)
[gx gy] = ginput(1); 
[pks, locs] = findpeaks(pitch_smooth, metadata.fs, 'MinPeakDistance', 2, 'MinPeakHeight', gy);

figure
plot(time_min(1:end-1), pitch_smooth); hold on
plot(locs/60,pks,'o')

%% Just running breath movement audit
R = loadauditbreaths(metadata.tag);
R_new = auditbreaths(0, jerk_smooth, pitch, roll, head, p, metadata.fs, pitch_smooth, R);
saveauditbreaths(metadata.tag, R_new)

%% Import breaths from audit
[time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
[breath_times, bp, breath_idx]=import_breaths(metadata.breathaud_filename, time_sec); 

%% Run acoustic audit
settagpath('PRH',strcat(data_path, '\prh\50 Hz'))
R = loadaudit(metadata.tag); % Load an audit if one exists
%R = d3audit(re                                                                                                                                                             cdir, prefix, 0, R); %Run audit (for d3s)
R = tagaudit2(metadata.tag,0, R, jerk_smooth ); % Run audit (for d2s), tagaudit2 in resp_detect
saveaudit(metadata.tag, R); % Save audit

%% Import acoustic audit
[startcom, comdur, com, acous_start_idx, acous_end_idx] = import_acous(acousaud_filename);

%% Plot detected breaths vs audited breaths from acoustics
count = 0;
for k = 1:length(acous_end_idx)
    if com(k) == 'breath'
        count = count + 1;
        matched_breath_idx(count) = find(abs(acous_end_idx(k)-breath_idx) == min(abs(acous_end_idx(k)-breath_idx)));
    end
end

breath_num = 1:1:sum(com == 'breath');
figure
count = 0;
for m  = 1:length(acous_start_idx)
    if com(m) == 'breath'
        count = count + 1;
        line([0 time_sec(acous_end_idx(m))-time_sec(acous_start_idx(m))], [breath_num(count) breath_num(count)]); 
        hold on;
        plot(breath_times(matched_breath_idx(count))-time_sec(acous_start_idx(m)), breath_num(count), 'r*');
    end
end

%% Calculate and plot fR
[fR] = get_contfR(breath_times, breath_idx, p, time_min);

%% Get surf fRs and plot
clearvars -except taglist tools_path mat_tools_path data_path; clc; close all

tag = taglist{5};

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));
clear tag

% Load in movement data
load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"));

% Load in dives
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "dives"))

% Load in dive table
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "divetable"))

% Import breaths from audit
[time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
[breath_times, bp, breath_idx]=import_breaths(metadata.breathaud_filename, time_sec);

[si_breathtimes, si_fR, surf_int_breaths, surf_int_fR]=get_surffRs(Tab, breath_times, dive_dur);

%% Plot change in fR during surface interval between various dive types... i.e. short-med, short-short, long-short, etc.
%fRbwdivetypes(T, surf_int_breaths, surf_int_fR, dive_durs);

%% To print to csv
write2csv(tag, fs, dive_thres, surf_durs, dive_durs, si_breathtimes, si_fR);
    
%% To load from csv
% You should clear all of your variables here first
clear; clc
[file_info, surf_durs, dive_durs, si_breathtimes, si_fR]=import_csv();

%% MAKE WINDOW PLOTS
%% CHANGE in FR PLOTS

%% Make simple plots with imported data

%% Get dive and surface variables
% Get surface intervals and dive durations in minutes
[dive_dur] = get_divedur(dive_durs);
[surf_dur] = get_surfdur(surf_durs);

% Get index of first breath in each surface interval
[breath_idx] = get_breathidx(dive_dur, si_breathtimes);

% Get number of breaths during surface interval as a count
[surf_breath_count] = get_breathcounts(dive_dur, si_breathtimes, breath_idx);

% Get surface interval durations
[breathing_dur] = get_breathdur(dive_dur, si_breathtimes, breath_idx);

% Assign dive type
[dive_type] = assign_divetype(dive_dur);

%% Plot dive duration versus surface duration
plot_dive2surfb(dive_dur, breathing_dur)

%% Plot dive duration versus time spent breathing at the surface 
plot_dive2surf(dive_dur, surf_dur)

%% Plot max, mean, and min fR with # breaths and dive duration for all dives
plot_maxmeanminfR(dive_dur, si_fR, breath_idx, surf_breath_count)

%% Plot dive duration and surface intervals by dive number
plot_bynum(dive_dur, surf_dur);

%% Plot surface breaths overall
plot_eachsurffR(dive_dur, breath_idx, si_breathtimes, si_fR);

%% Plot time to recovery
%plot_recov(dive_durs, recov_time)
for i = 1:length(dive_durs)
    breath_idx = find(si_breathtimes{i}==0);
    for j =1:length(dive_dur{i})-1
        recov_time{i}(j) = NaN;
        recov_breaths{i}(j) = NaN;
        if j<length(dive_dur{i})-1
            if isempty(find(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)<=baselinefr(i), 1))==0
                recov_time{i}(j) = si_breathtimes{i}(breath_idx(j)-1+find(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)<=baselinefr(i), 1));
                recov_breaths{i}(j) = find(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)<=baselinefr(i), 1);
            end
        else
            if isempty(find(si_fR{i}(breath_idx(j):end)<=baselinefr(i), 1))==0
                recov_time{i}(j) = si_breathtimes{i}(breath_idx(j)-1+find(si_fR{i}(breath_idx(j):end)<=baselinefr(i), 1));
                recov_breaths{i}(j) = find(si_fR{i}(breath_idx(j):end)<=baselinefr(i), 1);
            end
        end
    end
end

%% Figure out what proportin of dives not recovered before diving again...
for i = 1:length(dive_durs)
    count = 0;
    for j =1:length(dive_dur{i})-1
        if isnan(recov_time{i}(j)) == 1 %&& dive_dur{i}(j)<=5
            count = count+1;
        end
    end
    if count>0
        %percent_notrecov{i} = 100*count/length(dive_dur{i})-1;
        countn{i} = count;
        dives{i} = length(dive_dur{i})-1;
    else
        percent_notrecov{i} =0;
        countn{i}=0;
        dives{i} = length(dive_dur{i})-1;
    end
end
        
%% Import body lengths 
figure
body_length = table2array(readtable('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\DBLphotogram.xlsx','Range','G2:G25'));
zrange = [min(body_length), max(body_length)];
cdata = body_length;
size_data = (cdata-zrange(1)+1)*100/ diff(zrange);

for i = 1:length(dive_durs)
    for j =1:length(dive_dur{i})-1
        if dive_dur{i}(j)./60
            scatter(dive_dur{i}(j), recov_time{i}(j), 30, 'k','filled', 'MarkerFaceAlpha', 0.5); hold on
            
        end
    end
end

axis square; box on; colorbar
h = colorbar;
xlabel('Dive Duration (min)'); ylabel('Time to Recover (min)');
ylabel(h, 'Baseline f_R (breaths min^{-1})')

%% Plot pre and post window averages
figure;
subplot(2, 3, 1)
for k = 1:length(dive_durs)
    for i = 1:length(dive_dur{k})
    if dive_dur{k}(i)./60>5
        color{i} = rand(1, 3);
        scatter(dive_dur{k}(i)./60, 60./pre5_dive_avgfR{k}(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    end
    end
end
box on; axis square;
xl1 = xlim; yl1 = ylim;
xlabel('Dive Duration (min)'); ylabel('Pre-dive 5 min. Avg. f_R (breaths/min)');

subplot(2, 3, 2)
for k = 1:length(dive_durs)
    for i = 1:length(dive_dur{k})
    if dive_dur{k}(i)./60>5
       scatter(dive_dur{k}(i)./60, 60./pre3_dive_avgfR{k}(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    end
    end
end
box on; axis square;
xl2 = xlim; yl2 = ylim;
xlabel('Dive Duration (min)'); ylabel('Pre-dive 3 min. Avg. fR (breaths/min)');

subplot(2, 3, 3)
for k = 1:length(dive_durs)
    for i = 1:length(dive_dur{k})
    if dive_dur{k}(i)./60>5
        color{i} = rand(1, 3);
        scatter(dive_dur{k}(i)./60, 60./pre1_dive_avgfR{k}(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    end
    end
end
box on; axis square;
xl3 = xlim; yl3 = ylim;
xlabel('Dive Duration (min)'); ylabel('Pre-dive 1 min. Avg. fR (breaths/min)');

subplot(2, 3, 4)
for k = 1:length(dive_durs)
    for i = 1:length(dive_dur{k})
    if dive_dur{k}(i)./60>5
        color{i} = rand(1, 3);
        scatter(dive_dur{k}(i)./60, 60./post1_dive_avgfR{k}(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    end
    end
end
box on; axis square;
xl4 = xlim; yl4 = ylim;
xlabel('Dive Duration (min)'); ylabel('Post-dive 1 min. Avg. fR (breaths/min)');

subplot(2, 3, 5)
for k = 1:length(dive_durs)
    for i = 1:length(dive_dur{k})
    if dive_dur{k}(i)./60>5
        color{i} = rand(1, 3);
        scatter(dive_dur{k}(i)./60, 60./post3_dive_avgfR{k}(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    end
    end
end
box on; axis square;
xl5 = xlim; yl5 = ylim;
xlabel('Dive Duration (min)'); ylabel('Post-dive 3 min. Avg. fR (breaths/min)');

subplot(2, 3, 6)
for k = 1:length(dive_durs)
    for i = 1:length(dive_dur{k})
    if dive_dur{k}(i)./60>5
        color{i} = rand(1, 3);
        scatter(dive_dur{k}(i)./60, 60./post5_dive_avgfR{k}(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5);
    hold on;
    end
    end
end
box on; axis square;
xl6 = xlim; yl6 = ylim;
xlabel('Dive Duration (min)'); ylabel('Post-dive 5 min. Avg. fR (breaths/min)');

% Find rightmost xRight
    xRight = max([xl1(2), xl2(2), xl3(2), xl4(2), xl5(2), xl6(2)]);
    yUpper = max([yl1(2), yl2(2), yl3(2), yl4(2), yl5(2), yl6(2)]);
    
    subplot(2,3,1);
    xlim([5, xRight]); ylim([2, yUpper]);
    subplot(2,3,2);
    xlim([5, xRight]); ylim([2, yUpper]);
    subplot(2,3,3);
    xlim([5, xRight]); ylim([2, yUpper]);
    subplot(2,3,4);
    xlim([5, xRight]); ylim([2, yUpper]);
    subplot(2,3,5);
    xlim([5, xRight]); ylim([2, yUpper]);
    subplot(2,3,6);
    xlim([5, xRight]); ylim([2, yUpper]);
    
    clear xRight yUpper xl1 xl2 xl3 xl4 xl5 xl6 yl1 yl2 yl3 yl4 yl5 yl6


%% Plot si breath times as time series in colors
    
 %% To plot average fRs from excel
 boxplot(mat(:, [4, 5, 9])); hold on;
 scatter(ones(length(mat(:, 4)), 1).*(1+(rand(length(mat(:, 4)), 1)-0.5)/5),mat(:, 4),'k','filled', 'MarkerFaceAlpha', 0.3); hold on
 scatter(ones(length(mat(:, 5)), 1).*(2+(rand(length(mat(:, 5)), 1)-0.5)/10),mat(:, 5),'k','filled', 'MarkerFaceAlpha', 0.3); hold on
 scatter(ones(length(mat(:, 9)), 1).*(3+(rand(length(mat(:, 9)), 1)-0.5)/15),mat(:, 9),'k','filled', 'MarkerFaceAlpha', 0.3); hold on
 
 %% Baseline fR and mean/max dive dur
 %figure
 %subplot(122)
 for i = 1:length(dive_durs)
     max_dive_dur(i) = max(dive_dur{i});
     mean_dive_dur(i) = mean(dive_dur{i});
     %mean_surf_dur(i) = mean(surf_dur{i});
     total_surf_dur(i) = sum(surf_dur{i});
     total_dive_dur(i) = sum(dive_dur{i});
     %baselinefr(i) = mat(i, 4);
    boxplot(dive_pause_ratio{i}, body_length(i), 'positions', body_length(i), 'plotstyle', 'compact'); hold on
     %b= boxchart(ones(1, length(dive_pause_ratio{i}))*body_length(i)/10, dive_pause_ratio{i}, 'BoxFaceColor', 'k', 'LineWidth', 1, 'MarkerStyle', 'none'); hold on
     %b.MarkerColor = 'k';
     %b.BoxWidth = 0.5;
%       for j = 1:length(dive_dur{i})-1
%           if surf_dur{i}(j) == 0 
%               dive_pause_ratio{i}(j) =NaN;
%           else
%           dive_pause_ratio{i}(j) = dive_dur{i}(j)/60/surf_dur{i}(j);
%           end
%           
%           scatter(body_length(i)/10, dive_dur{i}(j)/60/surf_dur{i}(j), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.3); hold on
%       end
 end
      
 
 %xnew = linspace(min(baselinefr), max(baselinefr), 100);
 mdl = fitlm(baselinefr, total_surf_dur./(total_dive_dur/60 + total_surf_dur), 'linear');
% [yhat1,ci1] = predict(mdl,xnew','Alpha',0.1,'Simultaneous',true);
% h2 = plot(xnew,yhat1,'k-');
% h3 = plot(xnew,ci1,'r-','LineWidth',1);
 box on
 %xlabel('Baseline f_R (breaths min^{-1})');
 xlabel('Body Length (cm)'); ylabel('Mean Dive Duration (min)')
 
%% Calculate ILDIs and average fRs during each IDDIs
ildi=[];
for i = 1:length(dive_dur)
    count_long = 0;
    for j = 1:length(dive_dur{i})
        if dive_type{i}(j) == 'l' && j<length(dive_dur{i}) && count(dive_type{i}(j:end), 'l')>1
            count_long = count_long+1;
            ildi{i}(count_long) = sum(surf_dur{i}(j:j+find(dive_type{i}(j+1:end)=='l', 1)-1))+sum(dive_dur{i}(j+1:j+find(dive_type{i}(j+1:end)=='l', 1)-1));
            %ildi_ratio{i}(count_long) = sum(surf_dur{i}(j:j+find(dive_type{i}(j+1:end)=='l', 1)-1))/ildi{i}(count_long);
        end       
    end
    
end
%%
%Calc avg fR
for i = 1:length(dive_dur)
    breath_idx = find(si_breathtimes{i}==0);
    count_long = 0;
    idx =[];
    for j = 1:length(dive_dur{i})-1
        if dive_type{i}(j) == 'l' && dive_type{i}(j+1) == 'l' && j==length(dive_dur{i})-1 % If two l's back to back at the end
            count_long = count_long+1;
            idx = j;
            ildi_fR{i}(count_long)= nanmean(si_fR{i}(breath_idx(j):end));
       elseif dive_type{i}(j) == 'l' && j<length(dive_dur{i})-1 && count(dive_type{i}(j:end), 'l')>1 && dive_type{i}(length(dive_dur{i})) == 'l' % l at the end
            count_long = count_long+1;
            idx = j:j+find(dive_type{i}(j+1:end)=='l', 1)-1;
            ildi_fR{i}(count_long)= nanmean(si_fR{i}(breath_idx(idx(1)):end));
        elseif dive_type{i}(j) == 'l' && j<length(dive_dur{i})-1 && count(dive_type{i}(j:end), 'l')>1 % Normal case
            count_long = count_long+1;
            idx = j:j+find(dive_type{i}(j+1:end)=='l', 1)-1;
            ildi_fR{i}(count_long)= nanmean(si_fR{i}(breath_idx(idx(1)):breath_idx(idx(end)+1)-1));
        elseif dive_type{i}(j) == 'l' && j==length(dive_dur{i})-1 && count(dive_type{i}(j:end), 'l')==1 %For last l
            count_long = count_long+1;
            idx = j;
            ildi_fR{i}(count_long)= nanmean(si_fR{i}(breath_idx(idx):end));
        end
    end
end

%% Calculate number of short dives in ILDIs


%% Plot ILDIs
figure
for i = 1:length(dive_durs)
    countval = 0;
    for j = 1:length(dive_dur{i})
        if dive_type{i}(j) == 'l' && j<length(dive_dur{i}) && count(dive_type{i}(j:end), 'l')>1 && isnan(baselinefr(i))~=1
            countval = countval+1;
            if j>6
                if dive_type{i}(j-1) == 'l' && dive_type{i}(j-2) == 'l' && dive_type{i}(j-3) == 'l' && dive_type{i}(j-4) == 'l' && dive_type{i}(j-5) == 'l' && dive_type{i}(j-6) == 'l'
                    mark = 'k'; 
                elseif dive_type{i}(j-1) == 's'
                    mark = [0.9 0.9 0.9];
                end
            elseif j==1 || j==2 || j==3 || j==4 || j==5 || j==6
                mark = [0.9 0.9 0.9];
            end
            %if ildi_fR{i}(countval)-baselinefr(i) > baselinefr(i)
                scatter(dive_dur{i}(j), ildi{i}(countval), 30, ildi_fR{i}(countval)-baselinefr(i), 'filled', 'MarkerFaceAlpha', 0.7, 'MarkerEdgeAlpha', 0.7); hold on
            %end
        end
    end
end
set(gca,'xscale','log')
set(gca,'yscale','log')
xlabel('Dive Duration (min)'); ylabel('Inter long-dive interval (min)'); box on; axis square;


%% Short and long dive fR with average short and long dive duration
shortdivefR=mat(:, 5);
longdivefR=mat(:, 9);


for i = 1:length(dive_durs)
    temp_mat =[]; temp_mat2 =[];
    for j = 1:length(dive_dur{i})
        if dive_type{i}(j) == 's'
            temp_mat = [temp_mat dive_dur{i}(j)];
        elseif dive_type{i}(j) == 'l'
            temp_mat2 = [temp_mat2 dive_dur{i}(j)];
        end
    end
    mean_short_dive_dur(i) = mean(temp_mat)./60;
    mean_long_dive_dur(i) = mean(temp_mat2)./60;
end

figure
subplot(121)
scatter(shortdivefR, mean_short_dive_dur, 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5); hold on

subplot(122)
scatter(longdivefR, mean_long_dive_dur, 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5); hold on

xnew = linspace(2, 6, 1000);
xnew2 = linspace(4, 11, 1000);

mdl1 = fitlm(shortdivefR, mean_short_dive_dur, 'linear');
[yhat1,ci1] = predict(mdl1,xnew','Alpha',0.1,'Simultaneous',true);
subplot(121)
%h2 = plot(xnew,yhat1,'k-');
%h3 = plot(xnew,ci1,'r-','LineWidth',1);

mdl2 = fitlm(longdivefR, mean_long_dive_dur, 'linear');
[yhat1,ci1] = predict(mdl2,xnew2','Alpha',0.1,'Simultaneous',true);
subplot(122)
%h2 = plot(xnew2,yhat1,'k-');
%h3 = plot(xnew2,ci1,'r-','LineWidth',1);
axis square; box on;

%%    Transitions b/w dive types
figure;
c_ss = 0; c_sl = 0;
c_ls = 0; c_ll = 0;

h(1) = subplot(2, 2, 1); h(2) = subplot(2, 2, 2);
h(3) = subplot(2, 2, 3); h(4) = subplot(2, 2, 4);

for i = 1:length(dive_dur)
    breath_idx = find(si_breathtimes{i}==0);
    for j = 1:length(dive_dur{i})-1
        %Find short to short dives
        if strcmp(dive_type{i}(j), "s")==1 && strcmp(dive_type{i}(j+1), "s")==1
            h(1) = subplot(2, 2, 1); c_ss = c_ss+1;
            if j == length(dive_dur{i})-1
                scatter(si_breathtimes{i}(breath_idx(j):end), si_fR{i}(breath_idx(j):end), 20, ones(length(si_fR{i}(breath_idx(j):end)), 1)*dive_dur{i}(j), 'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
            else
                scatter(si_breathtimes{i}(breath_idx(j):breath_idx(j+1)-1), si_fR{i}(breath_idx(j):breath_idx(j+1)-1), 20, ones(length(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)), 1)*dive_dur{i}(j),'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
                title('short-short');  xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
                %Find long to short dives
            end
        elseif strcmp(dive_type{i}(j), "l")==1 && strcmp(dive_type{i}(j+1), "s")==1
            h(2) = subplot(2, 2, 2); c_ls = c_ls+1;
            if j == length(dive_dur{i})-1
                scatter(si_breathtimes{i}(breath_idx(j):end), si_fR{i}(breath_idx(j):end), 20, ones(length(si_fR{i}(breath_idx(j):end)), 1)*dive_dur{i}(j), 'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
            else
                scatter(si_breathtimes{i}(breath_idx(j):breath_idx(j+1)-1), si_fR{i}(breath_idx(j):breath_idx(j+1)-1), 20, ones(length(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)), 1)*dive_dur{i}(j),'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
                title('long-short'); xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
            end
            %Find long to long dives
        elseif strcmp(dive_type{i}(j), "l")==1 && strcmp(dive_type{i}(j+1), "l")==1
            h(3) = subplot(2, 2, 4); c_ll = c_ll+1;
            if j == length(dive_dur{i})-1
                scatter(si_breathtimes{i}(breath_idx(j):end), si_fR{i}(breath_idx(j):end), 20, ones(length(si_fR{i}(breath_idx(j):end)), 1)*dive_dur{i}(j), 'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
            else
                scatter(si_breathtimes{i}(breath_idx(j):breath_idx(j+1)-1), si_fR{i}(breath_idx(j):breath_idx(j+1)-1), 20, ones(length(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)), 1)*dive_dur{i}(j), 'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
                title('long-long'); xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
            end
            %Find short to long dives
        elseif strcmp(dive_type{i}(j), "s")==1 && strcmp(dive_type{i}(j+1), "l")==1
            h(4) = subplot(2, 2, 3); c_sl = c_sl+1;
            if j == length(dive_dur{i})-1
                scatter(si_breathtimes{i}(breath_idx(j):end), si_fR{i}(breath_idx(j):end), 20, ones(length(si_fR{i}(breath_idx(j):end)), 1)*dive_dur{i}(j), 'filled', 'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
            else
                scatter(si_breathtimes{i}(breath_idx(j):breath_idx(j+1)-1), si_fR{i}(breath_idx(j):breath_idx(j+1)-1), 20, ones(length(si_fR{i}(breath_idx(j):breath_idx(j+1)-1)), 1)*dive_dur{i}(j), 'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5); hold on; box on;
                title('short-long'); xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
            end
        end
    end
end

set(h,'CLim', [min(cell2mat(dive_dur_s')) max(cell2mat(dive_dur_mat))]);
    
%     %Markov chain
%     P = [c_ss/(c_ss+c_ls)  c_ls/(c_ss+c_ls);...
%         c_sl/(c_sl++c_ll) c_ll/(c_sl+c_ll)];
%     mc = dtmc(P','StateNames',  ["short"  "long"]);
%     figure
%     graphplot(mc,'ColorEdges',true);