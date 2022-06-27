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
    'gm16_181a'%,...
%     'gm15_145b',...
%     'gm15_153a',...
%     'gm17_234a',...
%     'gm18_157a',...
%     'gm18_157b',...
%     'gm18_159a',...
%     'gm18_227a',...
%     'gm18_239a'
    };

% I want to remove everything from the rest of the functions that has to do
% with tag processing because I am operating under the assumption that tag
% processing is DONE by this point

% 5/26/22 - Thinking I will just use D2s and I need to redo/check all
% calibrations to make sure they are perfectly at zero

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

% Add good color schemes to path
addpath('C:\Users\ashle\Dropbox\Ashley\Graduate\Toolboxes\linspecer')
addpath('C:\Users\ashle\Dropbox\Ashley\Graduate\Toolboxes\export_fig')

%% For tag data processing - ONLY DO ONCE 
% Read in data
tag = taglist{25};
recdir = 'D:\gm\gm11\gm11_165a';
prefix = 'gm165a';
deploy_name = prefix;

% X=d3readswv(recdir,prefix,df); %often a df of 10 or 20 is good. Want final sampling rate of 10-20Hz
X = d3readswv(recdir,prefix,5); %Read in sensor files
warning('off','last')

% Apply bench calibration
[CAL, D] = d3deployment(recdir,prefix,deploy_name);

% Perform pressure calibration
%Pick all data points on the lower broken line. Redo if 2nd order fitting error is more than 0-20cm
close all
[p6,CAL6] = d3calpressure(X,CAL,'full');

% For D3s...
% gm15_145b
%p = [p1(1:10*1556); p2(10*1556+1:10*10542); p3(10*10542+1:10*16285); p4(10*16285+1:10*21550); p5(10*21550+1:10*60925);...
%    p6(10*60925+1:10*65752); p7(10*65752+1:10*69731); p8(10*69731+1:10*74473); p9(10*74473+1:10*79808); p10(10*79808+1:10*85481);...
%    p11(10*85481+1:10*112578); p12(10*112578+1:length(p1))];

% gm15_153a
%p = [p1(1:10*411); p2(10*411+1:10*7714); p3(10*7714+1:10*14847); p4(10*14847+1:10*23056); p5(10*23056+1:10*32267);...
%    p6(10*32267+1:10*40728); p7(10*40728+1:10*49686); p8(10*49686+1:10*57649); p9(10*57649+1:10*64766); p10(10*64766+1:length(p1))];
% This is dealing with random spike in pressure
%p(180500:180700) = mean([p4(180500-1), p4(180700+1)]);

% gm17_234a
%p = [p1(1:10*11721); p2(10*11721+1:10*13536); p3(10*13536+1:10*16584); p4(10*16584+1:10*19487); p5(10*19487+1:10*21520);...
%    p6(10*21520+1:10*23987); p7(10*23987+1:10*61512); p8(10*61512+1:10*66665); p9(10*66665+1:10*70875); p10(10*70875+1:10*73342);... 
%    p11(10*73342+1:10*80673); p12(10*80673+1:10*83213); p13(10*83213+1:10*87205); p14(10*87205+1:10*91560); p15(10*91560+1:length(p1))];

% gm18_157a
% p = [p1(1:10*185); p2(10*185+1:10*1306); p3(10*1306+1:10*7627); p4(10*7627+1:length(p1))];
 
% gm18_157b
%p = [p1(1:10*25678); p2(10*25678+1:10*27541); p2a(10*27541+1:10*33553); p3(10*33553+1:10*34103); p3a(10*34103+1:10*39523);  p4(10*39523+1:10*50008); p5(10*50008+1:length(p1))];

% gm18_159a
%p = [p1(1:10*6884); p2(10*6884+1:10*10654); p3(10*10654+1:10*16925);  p4(10*16925+1:length(p1))];

% gm18_227a
%p = [p1(1:10*7711); p2(10*7711+1:10*9405); p3(10*9405+1:10*32752);  p4(10*32752+1:10*33961); p5(10*33961+1:10*54828);...
%p6(10*54828+1:10*76844); p7(10*76844+1:length(p1))];

% gm18_239a
p = [p1(1:10*35253); p2(10*35253+1:10*46233); p3(10*46233+1:10*50350);  p4(10*50350+1:10*54331); p5(10*54331+1:10*59142);...
p6(10*59142+1:length(p1))];

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
%PRH = prhpredictor(p,A,fs,500,1,'both'); %Look at output for moves, large unexpected changes in either the pitch, roll, or heading between dives
%Changes from 0 to 180 or -180 are normal, just the way the sensors work

% Define any moves
%move1=[t1,t2,p0,r0,h0]; prh must be in RADIANS 
%Define the number of moves (aka slips) here
%move1=[0 0 -0.0330 3.1155 -0.1961];%If there are no slips, you will only have a move1
% Importing OTAB from archived version from Jeanne


%OTAB=[move1]; %Create array of moves
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

%% For D2 processing
settagpath('raw', 'D:\gm\gm12\gm12_125a');
settagpath('audio', 'D:\gm', 'cal', 'D:\gm\cal');
settagpath('prh', 'D:\gm\prh');
tag = 'gm12_125a';

% Have to do this once - saving raw file in deployment folder
%settagpath('raw',rawdir) % add raw directory to paths
[s,fs] = swvread(tag, [], 1) ; % read the .swv files
saveraw(tag,s,fs) % save a raw file

% Bring in CAL file from cal folder
[s,fs] = loadraw(tag) ; % if workspace was cleared after step 5
CAL= TAGID ; % read the calibration for the device used

[p_c,tempr_c,CAL] = calpressure(s_chopped, CAL, 'full') ; % follow screen directions
[M,CAL] = autocalmag(s,CAL) ; % accept or reject test results
[A,CAL] = autocalacc(s,p,tempr,CAL) ; % accept or reject test results

savecal(tag,'CAL',CAL) % save calibration results
saveprh(tag, 'p','tempr','fs','A', 'M') % save tag frame results

loadprh(tag) % if workspace was cleared
[Aw Mw] = tag2whale(A,M,OTAB,fs) ;
makeprhfile(tag);

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
            [recdir, prefix, acousaud_filename, breathaud_filename] = setup_dirs(tag, tag_ver, data_path, mat_tools_path);
            
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
        %str = input("Do you want to make a diving table now? (y/n)\n",'s');
        %if strcmp(str, "y") == 1
            % Set dive threshold, calculate dive and surface durations
            dive_thres = 5; % Quick et al., 2017
            [dive_thres, T]=get_dives(p, metadata.fs, dive_thres); % Give p(depth) and fs(sampling frequency)
            
            if size(T, 1) <= 1
                display('Only 1 deep dive! Not continuing analysis...')
                
            else
                % Plot dives
                %[dive_dur_plot, surf_dur_plot] = plot_dives(T, time_sec, p);
                
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
    %end
end

%% Load dives
clear Tab dive_table
dive_table = []; 

diving_dir = strcat(data_path, '\diving\divethres_5m\'); 
filesAndFolders = dir(diving_dir);   
filesInDir = filesAndFolders(~([filesAndFolders.isdir]));  % Returns only the files in the directory                    
temp = struct2cell(filesInDir);
temp = temp(1, :)';

tag_cols_starter = linspecer(length(taglist));

for k = 1:length(taglist);
    tag = taglist{k};
    foundStr= strfind(temp, tag);
    rel_files = find(~cellfun('isempty',foundStr));
    load(strcat(diving_dir, cell2mat(temp(rel_files(2)))))
    dive_table = [dive_table; Tab];
    tag_cols_cell{k} = tag_cols_starter(k).*ones(height(Tab), 3);
end

tag_cols = cell2mat([tag_cols_cell']);

clear diving_dir filesAndFolders filesInDir temp foundStr rel_files

%% Plot dives and do some dive EDA

f = figure;
%sgtitle('Dive depth vs. duration for all dives', 'FontSize', 14);
subplot(1, 3, 1)
scatter(dive_table.dive_dur./60, dive_table.max_depth, [], 'k', 'o', 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Max depth (m)');
ax = gca; 
ax.FontSize = 12;

subplot(1, 3, 2)
scatter(dive_table.dive_dur./60, dive_table.surf_dur./60, [], 'k', 'o', 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Post-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;

subplot(1, 3, 3)
scatter(dive_table.dive_dur(2:end)./60, dive_table.surf_dur(1:end-1)./60, [], 'k', 'o', 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Pre-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;
f.Position = [10 700 1000 300];

ax = gcf;
exportgraphics(ax,'C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\alltags_divesummary.pdf');

% Plotting clustering of dives/depths
f = figure;
%sgtitle('Dbscan cluster analysis', 'FontSize', 14);
% dbscan clustering
idx = dbscan([dive_table.dive_dur./60, dive_table.max_depth], 10, round(length(dive_table.dive_dur)/10, 0));
cluster_cols = linspecer(length(unique(idx)));
g = gscatter(dive_table.dive_dur./60, dive_table.max_depth, idx, cluster_cols, 'os',6,'MarkerEdgeAlpha',.2)
 xlabel('Dive duration (min)'); ylabel('Max depth (m)');
ax = gca; 
ax.FontSize = 12;
legend('Cluster 1','Cluster 2',...
       'Location','SE')

f.Position = [1020 700 350 300];

% Make new post pre dive interval figures with deeper/longer cluster
deep_dive_dur = dive_table.dive_dur;
deep_dive_dur(idx == 1) = [];

deep_dive_surf_dur = dive_table.surf_dur;
deep_dive_surf_dur(idx == 1) = [];

deep_color = tag_cols;
deep_color(idx == 1, :) = [];

ax = gcf;
exportgraphics(ax,'C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\alltags_dbscanclustering.pdf');

f = figure;
%sgtitle("Dive duration vs. surface duration for deep cluster", 'FontSize', 14);
subplot(1, 2, 1)
scatter(deep_dive_dur./60, deep_dive_surf_dur./60, [], 'k',  'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Post-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;

subplot(1, 2, 2)
scatter(deep_dive_dur(2:end)./60, deep_dive_surf_dur(1:end-1)./60, [], 'k', 'MarkerEdgeAlpha',.5); box on;
xlabel('Dive duration (min)'); ylabel('Pre-dive surface interval (min)');
%set(gca, 'YScale', 'log')
ax = gca; 
ax.FontSize = 12;
f.Position = [10 150 630 300];

% Fit some basic linear models 
mdl_post = fitlm(deep_dive_dur./60, deep_dive_surf_dur./60);
mdl_pre = fitlm(deep_dive_dur(2:end)./60, deep_dive_surf_dur(1:end-1)./60)

ax = gcf;
exportgraphics(ax,'C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\alltags_divevssurf_deepcluster.pdf');

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
    
     if isfile(movement_fname) == 1 %Should be 1 for actual function
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
            fny = metadata.fs/2;
            pass = [2, 15];
            [b,a]=butter(5,pass/fny,'bandpass');
            
            surge_filt = filtfilt(b,a, surge);
            sway_filt = filtfilt(b,a, sway);
            heave_filt = filtfilt(b,a, heave);
            
            %Calculate jerk using njerk
            jerk_filt = njerk([surge_filt, sway_filt, heave_filt], metadata.fs);

            %Get surge diff
            surge_diff = diff(surge_filt);
            sway_diff = diff(sway_filt);
            heave_diff = diff(heave_filt);

            %Get Shannon entropy
            surge_se = log(abs(surge_diff))*sum(abs(surge_diff));
            sway_se = log(abs(sway_diff))*sum(abs(sway_diff));
            heave_se = log(abs(heave_diff))*sum(abs(heave_diff));

            %Get smoothed Shannon entropy - over 5 second window
            surge_smooth = movmean(surge_se, 5*fs);
            sway_smooth = movmean(sway_se, 5*fs);
            heave_smooth = movmean(heave_se, 5*fs);
            
            %Get Shannon entropy of jerk
            jerk_se = log(abs(jerk_filt))*sum(abs(jerk_filt));
 
            %Get smoothed Shannon entropy
            jerk_smooth = movmean(jerk_se', 5*fs); 
            
            % Build filter for prh
            fny = metadata.fs/2;
            pass = [2, 15]; % Change to [1 5] on 5/3/2022
            [b,a]=butter(5,pass/fny,'bandpass');

            % Calculate filtered prh signals
            pitch_filt = filtfilt(b, a, pitch);
            roll_filt = filtfilt(b, a, roll);
            head_filt = filtfilt(b, a, head);

            %Get prh diff
            pitch_diff = diff(pitch_filt);
            roll_diff = diff(roll_filt);
            head_diff = diff(head_filt);

            %Get Shannon entropy
            pitch_se = log(abs(pitch_diff))*sum(abs(pitch_diff));
            roll_se = log(abs(roll_diff))*sum(abs(roll_diff));
            head_se = log(abs(head_diff))*sum(abs(head_diff));

            %Get smoothed Shannon entropy
            pitch_smooth = movmean(pitch_se, 5*fs);
            head_smooth = movmean(head_se, 5*fs);
            roll_smooth = movmean(roll_se, 5*fs);

            save(strcat(data_path, "\movement\", metadata.tag, "movement.mat"), 'p', 'Aw', 'surge', 'sway', 'heave',...
                'surge_filt', 'sway_filt', 'heave_filt',...
                'surge_diff', 'sway_diff', 'heave_diff',...
                'surge_se', 'sway_se', 'heave_se',...
                'surge_smooth', 'sway_smooth', 'heave_smooth',...
                'jerk_filt', 'jerk_se', 'jerk_smooth',...
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

%% Load movement data, plot

for k = 1%:length(taglist);
    
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
    ax(1)=subplot(4, 2, 1);
    plot(time_min, p, 'k'); hold on
    set(gca,'Ydir','reverse')
    ylabel('Depth (m)');

%     ax(2)=subplot(7, 1, 2);
%     plot(time_min, surge_filt); hold on
%     plot(time_min, sway_filt);
%     plot(time_min, heave_filt); 
%     ylabel('Filtered Acc');
% 
%     ax(3)=subplot(7, 1, 3);
%     plot(time_min(2:end), surge_se); hold on
%     ylabel('Surge SE');

    ax(2)=subplot(4, 2, 3);
    plot(time_min(2:end), surge_smooth, 'r-'); hold on 
    linkaxes(ax, 'x');
    ylabel('Smoothed Surge SE');

%     ax(5)=subplot(7, 1, 5);
%     plot(time_min(2:end), jerk_filt); hold on
%     ylabel('Jerk');
% 
%     ax(6)=subplot(7, 1, 6);
%     plot(time_min(2:end), jerk_se, 'k'); hold on
%     ylabel('Jerk SE');

    ax(3)=subplot(4, 2, 5);
    plot(time_min(2:end), jerk_smooth, 'b'); hold on
    linkaxes(ax, 'x');
    ylabel('Smoothed Jerk SE');
    
    ax(4)=subplot(4, 2, 7);
    plot(time_min(2:end), pitch_smooth, 'g'); hold on
    linkaxes(ax, 'x');
    ylabel('Smoothed Pitch SE');
    xlabel('Time (min)');
    
    ax(5)=subplot(4, 2, [2 4 6 8]);
    plot(time_min, -p, 'k'); hold on
    plot(time_min(2:end), 5*rescale(surge_smooth), 'r-');
    plot(time_min(2:end), 5*rescale(jerk_smooth), 'b'); 
    plot(time_min(2:end), 5*rescale(pitch_smooth), 'g');
    title(taglist{k}, 'interpreter', 'none');
    linkaxes(ax, 'x');
    ylabel('Depth/Normalized Movement Metrics');
    xlabel('Time (min)');
    
end

%% Breath audit 
for k = 1:length(taglist);
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

% Load in diving data
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "dives.mat"));
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "divetable.mat"));

%% Make a new section to do auto detection
% Just want to run a peak detector across jerk_smooth and pitch_smooth and
% then want it to present me with each surfacing and I can either okay it
% or edit it

% Want pitch to be positive for peak detect, so adding min
pitch_smooth = pitch_smooth + abs(min(pitch_smooth));

% Remove underwater portions
for i = 1:length(jerk_smooth)
    if p(i)>5 % The higher this threshold is the better for promience detections
        jerk_smooth(i) = NaN; 
        surge_smooth(i) = NaN; 
        pitch_smooth(i) = NaN;
    end
end

[time_sec, time_min, time_hour] =calc_time(metadata.fs, p);

%% Define start and end of tag deployment using metadata tag on/off times
start_idx = find(abs(time_sec-metadata.tag_on)==min(abs(time_sec-metadata.tag_on))); 
end_idx = find(abs(time_sec-metadata.tag_off)==min(abs(time_sec-metadata.tag_off)));

% If the tag on time is when the tag is near the surface, we are going to
% redefine the start idx as the first time the tag hits 1 m, the reason for
% this being that the tag on result in a big jerk spike that will mess with
% peak detection for breaths
if p(start_idx)<5
    start_idx = find(p(start_idx:end_idx)>=5, 1)+start_idx;
end

% Subset tag on to tag off of pressure 
p_tag = p(start_idx:end_idx);

%% First, identify minimia of pressure (aka surfacings)
% Smooth depth signal
%p_smooth = smoothdata(p, 'gaussian', fs);
p_smooth_tag = smoothdata(p_tag, 'movmean', fs);
p_smooth = smoothdata(p, 'movmean', fs);
p_shallow = p_smooth_tag;

% Define shallow as any depth less than 0.5 m
p_shallow(p_smooth_tag>0.5) = NaN; 
p_shallow_idx = find(~isnan(p_shallow));

% Plot smoothed depth with areas highlighted in red that are conditions
% where a breath could occur
figure('units','normalized','outerposition',[0 0 1 1]);
p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k', 'LineWidth', 1); hold on
%plot(time_min(start_idx:end_idx), p_shallow, 'b-', 'LineWidth', 2);
set(gca, 'YDir', 'reverse'); 
xlabel('Time (min)'); ylabel('Depth (m)');

% Find start and end of surface periods
p_shallow_breaks_end = find(diff(p_shallow_idx)>1);
p_shallow_breaks_start = find(diff(p_shallow_idx)>1)+1;

p_shallow_ints = [[1; p_shallow_breaks_start], [p_shallow_breaks_end; length(p_shallow_idx)]];

% Make third column which is duration of surfacing in indices
p_shallow_ints(:, 3) = p_shallow_ints(:, 2) - p_shallow_ints(:, 1);

% If the duration of a surfacing is >10 seconds, but the depth crosses 0.25
% m during the surfacing then divide at 0.25 m into two single surfacings 
% This works for D2s but NOT for D3s
% delete_rows = [];
% for r = 1:length(p_shallow_ints)
%     if p_shallow_ints(r, 3) > 10*metadata.fs %&& any(p_shallow(p_shallow_idx(p_shallow_ints(r, 1):p_shallow_ints(r, 2)))<0.25)
%         
%         p_temp = p_shallow(p_shallow_idx(p_shallow_ints(r, 1):p_shallow_ints(r, 2)));
%         
%         p_shallower_breaks = find(p_temp>0.35);
%         
%         % Find start and end of surface periods
%         p_shallower_breaks_end = p_shallower_breaks(find(diff(p_shallower_breaks)>1));
%         p_shallower_breaks_start = p_shallower_breaks(find(diff(p_shallower_breaks)>1)+1);
%        
%         if length(p_shallower_breaks_end>1);
%             p_shallower_breaks_end(1) = [];
%             p_shallower_breaks_start(end) = [];
%              
%             % Add these to p_ints
%             p_shallow_ints_temp =  [[p_shallow_ints(r, 1); p_shallow_ints(r, 1)+p_shallower_breaks_end-1], [p_shallow_ints(r, 1)+p_shallower_breaks_start-1; p_shallow_ints(r, 2)]];
%             p_shallow_ints_temp(:, 3) = p_shallow_ints_temp(:, 2) -p_shallow_ints_temp(:, 1);
%             
%             p_shallow_ints = [p_shallow_ints; p_shallow_ints_temp];
%             % Remove old rows from p_int
%             delete_rows = [delete_rows, r];
%         end
%     end
% end
% p_shallow_ints(delete_rows, :) = [];

% If surfacing is less than 50 indicies (which would be 1 second given 50
% Hz sampling) then remove it - likely not a surfacing anyway but a period
% where depth briefly crosses above 0.25m 
delete_rows = find(p_shallow_ints(:, 3) < 1*metadata.fs); 
p_shallow_ints(delete_rows, :) = [];

% If surfacing does not make it up to at least 0.35 m delete rows
% delete_rows = [];
% for r = 1:length(p_shallow_ints)
% delete_rows(r) = min(p_shallow(p_shallow_idx(p_shallow_ints(r, 1):p_shallow_ints(r, 2))))>0.35; 
% end
% delete_rows = find(delete_rows ==1);
% p_shallow_ints(delete_rows, :) = [];

%If minima of a surfacing is not at least within a reasonable range of the
%neighborhood (surrounding 4) of surfacings...
for r = length(p_shallow_ints):-1:1 % Go backwards so can delete as you go
    if r == length(p_shallow_ints)
        min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
        min2 = min1;
        min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
        min4 = min3;
    elseif r == length(p_shallow_ints)-1
        min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
        min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
        min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
        min4 = min3;
    elseif r == 2
        min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
        min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
        min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
        min3 = min4;
    elseif r == 1
        min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
        min1 = min2;
        min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
        min3 = min4;
    else
        min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
        min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
        min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
        min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
    end
        temp_sort = sort([min1, min2, min3, min4]);
        if min(p_shallow(p_shallow_idx(p_shallow_ints(r, 1):p_shallow_ints(r, 2))))>mean(temp_sort(1:2))+0.30
            p_shallow_ints(r, :) = [];
        end
    end
    

% If the start of the next surfacing is <1/2th of a  sec from the end of the last
% surfacing, this is probably not a full surfacing but remnant of the last one so remove...
% delete_rows = [];
% for r = 2:length(p_shallow_ints)
%     if p_shallow_idx(p_shallow_ints(r, 1)) - p_shallow_idx(p_shallow_ints(r-1, 2)) < fs
%         delete_rows = [delete_rows, find(min(p_shallow_ints(r-1:r, 3)) == p_shallow_ints(r-1:r, 3)) - 2 + r];
%     end
% end
% p_shallow_ints(delete_rows, :) = [];

% If these periods are less than 10 seconds then we say they are a breath
single_breath_surf_rows = find(p_shallow_ints(:, 3) <= 10*metadata.fs);
logging_surf_rows = find(p_shallow_ints(:, 3) > 10*metadata.fs);

% % Find the number of local minima in each period of depth <1m
% single_breath_surf_rows = [];
% logging_surf_rows = [];
%  for r = 1:length(p_shallow_ints)
%      p_int = p_shallow(p_shallow_idx(p_shallow_ints(r, 1)):p_shallow_idx(p_shallow_ints(r, 2)));
%      temp_minima = find(islocalmin(p_int, 'MinProminence', 0.5)==1);
%      if length(temp_minima) == 1
%          single_breath_surf_rows = [single_breath_surf_rows; r];
%          p_shallow_ints(r, 4) = p_shallow_ints(r, 1) - 1 + temp_minima;
%      else 
%          logging_surf_rows = [logging_surf_rows; r];
%          p_shallow_ints(r, 4) = NaN;
%      end
%      %Column four is the index of the minima
%      %p_shallow_ints(single_breath_surf_rows(r), 4) = p_shallow_ints(single_breath_surf_rows(r), 1) - 1 + find(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))) == min(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2)))), 1); 
%  end
 %p_shallow_ints(logging_surf_rows, 4) = NaN;

% Color logging periods in pink
if length(logging_surf_rows)>0
for r = 1:length(logging_surf_rows)
   p2 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 1))-1:start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 2))-1), p_shallow(p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 2))), 'm-', 'LineWidth', 2);
end
else 
    p2 = plot(NaN, NaN, 'm-', 'LineWidth', 2);
end

% Color single surfacings in cyan
for r = 1:length(single_breath_surf_rows)
    p3 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1))-1:start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))-1), p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))), 'c-', 'LineWidth', 2);
end

% Plot start and end of surfacings
p4 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(:, 1))-1), p_shallow(p_shallow_idx(p_shallow_ints(:, 1))), 'g*');
p5 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(:, 2))-1), p_shallow(p_shallow_idx(p_shallow_ints(:, 2))), 'r*');

% For single surfacings - determine minima and assign this a breath
% p_shallow_ints(single_breath_surf_rows, 4) = round(p_shallow_ints(single_breath_surf_rows, 1)+(p_shallow_ints(single_breath_surf_rows, 2)-p_shallow_ints(single_breath_surf_rows, 1))/2);
 for r = length(single_breath_surf_rows):-1:1
%     %Column four is the index of the minima
     p_shallow_ints(single_breath_surf_rows(r), 4) = p_shallow_ints(single_breath_surf_rows(r), 1) - 1 + find(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))) == min(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2)))), 1); 
 end
 p_shallow_ints(logging_surf_rows, 4) = NaN;

%Plot assumed breaths in single surfacings
p6 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4)-1)), p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4))), 'k*');

% Get the indicies of breaths assoicated with single surfacings from
% p_smooth
single_breath_idxs = p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4));

all_breath_locs.breath_idx = [single_breath_idxs]; %diff_vals_jp];
all_breath_locs.type = [repmat("ss", length(single_breath_idxs), 1)];% repmat("jp", length(diff_vals_jp), 1)];

% Define logging starts and ends
logging_start_idxs = p_shallow_idx(p_shallow_ints(logging_surf_rows, 1));
logging_end_idxs = p_shallow_idx(p_shallow_ints(logging_surf_rows, 2));

logging_start_s = time_sec(start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows, 1)));
logging_end_s = time_sec(start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows, 2)));
logging_ints_s = [logging_start_s', logging_end_s'];

legend([p1 p2 p3 p4 p5 p6],{'Dive depth' , 'Logging', 'Single-breath surfacing', 'Start of surfacing', 'End of surfacing', 'Breaths'}, 'Location', 'northeastoutside')

figfile = strcat('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\surface_detections\', metadata.tag, '_surfacedetections.fig');
savefig(figfile);

%% Now only want to do pitch/jerk detections for the logging periods
% Subset tag on to tag off of pressure 
jerk_smooth=jerk_smooth(start_idx:end_idx);
surge_smooth=surge_smooth(start_idx:end_idx);
pitch_smooth=pitch_smooth(start_idx:end_idx);

% Get idxes of p_smooth that are are logging with 5s window on each side
idx_temp = zeros(length(p_smooth_tag), 1);
for d = 1:length(logging_start_idxs);
    idx_temp(logging_start_idxs(d)-5*metadata.fs:logging_end_idxs(d)+5*metadata.fs) = 1;
end

% Remove jerk measurements for non-logging surfacing periods
jerk_smooth(idx_temp==0) = NaN;
surge_smooth(idx_temp==0) = NaN;
pitch_smooth(idx_temp==0) = NaN;

%% Normalize pitch and jerk 
% Rescale between 0 and 1 so that can set a prominence that is standard
% across tags
jerk_smooth = rescale(jerk_smooth, 0, 1);
surge_smooth = rescale(surge_smooth, 0, 1);
pitch_smooth = rescale(pitch_smooth, 0, 1);

%% Peak detection - JERK
% Whichever one is second is the one getting audited
figure('units','normalized','outerposition',[0 0 1 1]);
ax(1) = subplot(3, 5, [1 2]);
plot(time_min(start_idx:end_idx), jerk_smooth, 'k-'); grid; hold on;
xlabel('Time (min)'); ylabel('Jerk SE Smooth');

%Peak detect jerk, defining here that the max breath rate is 20 breaths/min
%given 2 second separation
% Could peak detect across smaller overlapping ranges
[j_max_height, j_max_locs, jw, jp] = findpeaks(jerk_smooth, 'MinPeakDistance', 3*metadata.fs);
jw = rescale(jw); jp = rescale(jp); j_max_height = rescale(j_max_height);

if length(j_max_height)>1
    if length(j_max_height)<10
        %jw = rescale(jw); jp = rescale(jp); j_max_height = rescale(j_max_height);
        X = [jw', jp'];
        Z = linkage(X, 'ward');
        idx = cluster(Z,'MAXCLUST', 2);
        g1_mean = mean(X(idx==1), 1); g2_mean = mean(X(idx==2), 1);
    else
        [f_jw,xi_jw] = ksdensity(jw, 'Bandwidth',0.01);
        [f_jp,xi_jp] = ksdensity(jp, 'Bandwidth',0.01);
        %figure
        %plot(xi_jw, f_jw); hold on; plot(xi_jp, f_jp);
        thres_jw = xi_jw(find(islocalmin(f_jw,2)>0, 1, 'first'));
        thres_jp = xi_jp(find(islocalmin(f_jp,2)>0, 1, 'first'));
        idx = [jw>thres_jw & jp>thres_jp];
        idx = double(idx); idx(idx==0)=2;
        g1_mean = mean(jw(idx==1)); g2_mean = mean(jw(idx==2));
    end
    

 % Remove peaks that are too far from maxes
 rm_idx = [];
 if length(jw)>0
     % Using this to find which group to remove
     rm_group = (find(min([g1_mean, g2_mean]) == [g1_mean, g2_mean]));
     for c = 1:length(j_max_locs)
         if idx(c) == rm_group
             rm_idx = [rm_idx, c];
         end
     end
     j_max_locs(rm_idx) = [];
 end
end

% Okay, so now we are saying breaths can only occur at these locations
scatter(time_min(j_max_locs+start_idx), jerk_smooth(j_max_locs), 'r*')

if length(jw)>0
    subplot(3, 5, 3)
    plot(jw(idx==rm_group), jp(idx==rm_group), '.', 'MarkerSize', 12, 'Color', [0.7 0.7 0.7])
    hold on
    plot(jw(idx~=rm_group), jp(idx~=rm_group), 'k.', 'MarkerSize', 12) 
    xlabel('Peak Width'); ylabel('Peak Prominence'); %legend('Cluster 1', 'Cluster 2')
end

%% Peak detection - SURGE JERK
ax(2) = subplot(3, 5, [6 7]);
plot(time_min(start_idx:end_idx), surge_smooth, 'k'); grid; hold on;
xlabel('Time (min)'); ylabel('Surge SE Smooth');

%Peak detect surge jerk, defining here that the max breath rate is 20 breaths/min
%given 2 second separation
[s_max_height, s_max_locs, sw, sp] =findpeaks(surge_smooth, 'MinPeakDistance', 3*metadata.fs);
sw = rescale(sw); sp = rescale(sp); s_max_height = rescale(s_max_height);

if length(s_max_height)>1
    if length(s_max_height)<10
        %sw = rescale(sw); sp = rescale(sp); s_max_height = rescale(s_max_height);
        X = [sw, sp];
        Z = linkage(X, 'ward');
        idx = cluster(Z,'MAXCLUST', 2);
        g1_mean = mean(X(idx==1), 1); g2_mean = mean(X(idx==2), 1);
    else
       [f_sw,xi_sw] = ksdensity(sw, 'Bandwidth',0.01);
       [f_sp,xi_sp] = ksdensity(sp, 'Bandwidth',0.01);
       thres_sw = xi_sw(find(islocalmin(f_sw,2)>0, 1, 'first'));
       thres_sp = xi_sp(find(islocalmin(f_sp,2)>0, 1, 'first'));
       idx = [sw>thres_sw & sp>thres_sp];
       idx = double(idx); idx(idx==0)=2;
       g1_mean = mean(sw(idx==1)); g2_mean = mean(sw(idx==2));
    end
    
% Remove peaks that are too far from maxes
rm_idx = [];
if length(sw)>0
rm_group = (find(min([g1_mean, g2_mean]) == [g1_mean, g2_mean]));
for c = 1:length(s_max_locs)
    if idx(c) == rm_group
        rm_idx = [rm_idx, c];
    end
end
end
s_max_locs(rm_idx) = [];
end

% Okay, so now we are saying breaths can only occur at these locations
scatter(time_min(s_max_locs+start_idx), surge_smooth(s_max_locs), 'b*')

if length(sw)>0
subplot(3, 5, 8)
plot(sw(idx==rm_group), sp(idx==rm_group), '.', 'MarkerSize', 12, 'Color', [0.7 0.7 0.7])
hold on
plot(sw(idx~=rm_group), sp(idx~=rm_group), 'k.', 'MarkerSize', 12)
xlabel('Peak Width'); ylabel('Peak Prominence'); %legend('Cluster 1', 'Cluster 2')
end

%% Peak detection - PITCH
ax(3) = subplot(3, 5, [11 12]);
plot(time_min(start_idx:end_idx), pitch_smooth, 'k'); grid; hold on;
xlabel('Time (min)'); ylabel('Pitch SE Smooth');

%Peak detect surge jerk, defining here that the max breath rate is 20 breaths/min
%given 2 second separation
[p_max_height, p_max_locs, pw, pp] =findpeaks(pitch_smooth, 'MinPeakDistance', 3*metadata.fs);

if length(p_max_height)>1
    if length(p_max_height)<10
        X = [pw, pp];
        Z = linkage(X, 'ward');
        idx = cluster(Z,'MAXCLUST', 2);
        g1_mean = mean(X(idx==1), 1); g2_mean = mean(X(idx==2), 1);
    else
       [f_pw,xi_pw] = ksdensity(pw, 'Bandwidth',0.01);
       [f_pp,xi_pp] = ksdensity(pp, 'Bandwidth',0.01);
       thres_pw = xi_pw(find(islocalmin(f_pw,2)>0, 1, 'first'));
       thres_pp = xi_pp(find(islocalmin(f_pp,2)>0, 1, 'first'));
       idx = [pw>thres_pw & pp>thres_pp];
       idx = double(idx); idx(idx==0)=2;
       g1_mean = mean(pw(idx==1)); g2_mean = mean(pw(idx==2));
    end

% Remove peaks that are too far from maxes
rm_idx = [];
if length(pw)>0
rm_group = (find(min([g1_mean, g2_mean]) == [g1_mean, g2_mean]));
for c = 1:length(p_max_locs)
    if idx(c) == rm_group
        rm_idx = [rm_idx, c];
    end
end
end

p_max_locs(rm_idx) = [];
end
% Okay, so now we are saying breaths can only occur at these locations
scatter(time_min(p_max_locs+start_idx), pitch_smooth(p_max_locs), 'g*')

if length(pw)>0
subplot(3, 5, 13)
plot(pw(idx==rm_group), pp(idx==rm_group), '.', 'MarkerSize', 12, 'Color', [0.7 0.7 0.7])
hold on
plot(pw(idx~=rm_group), pp(idx~=rm_group), 'k.', 'MarkerSize', 12)
xlabel('Peak Width'); ylabel('Peak Prominence'); %legend('Cluster 1', 'Cluster 2')
end
%figfile = strcat('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\logging_breath_detections\', metadata.tag, '_movementdetections.fig');
%savefig(figfile);

%% Find indexes where all conditions are met 

% Have to exactly meet pressure but for others within some window -  a
% 5 second window - 2.5 seconds on each side of max

j_max_wins = [];
for a = 1:length(j_max_locs)
    j_max_win = j_max_locs(a)-2.5*metadata.fs:1:j_max_locs(a)+2.5*metadata.fs;
    j_max_wins = [j_max_wins, j_max_win];
end

s_max_wins = [];
for b = 1:length(s_max_locs)
    s_max_win = s_max_locs(b)-2.5*metadata.fs:1:s_max_locs(b)+2.5*metadata.fs;
    s_max_wins = [s_max_wins, s_max_win];
end

p_max_wins = [];
for c = 1:length(p_max_locs)
    p_max_win = p_max_locs(c)-2.5*metadata.fs:1:p_max_locs(c)+2.5*metadata.fs;
    p_max_wins = [p_max_wins, p_max_win];
end

% Identify where one window stops and the next starts
if length(j_max_wins)>0
    j_wins_breaks = [j_max_wins(diff(j_max_wins)>1), j_max_wins(end)];
end
if length(s_max_wins)>0
    s_wins_breaks = [s_max_wins(diff(s_max_wins)>1), s_max_wins(end)];
end
if length(p_max_wins)>0
    p_wins_breaks = [p_max_wins(diff(p_max_wins)>1), p_max_wins(end)];
end

% Places where all three conditions are met
[val3] = intersect(intersect(intersect(p_shallow_idx, p_max_wins), j_max_wins), s_max_wins);

% Places where only two conditions (jerk and surge jerk) are met - NEXT THING TO DO!
[val2_js] = intersect(intersect(p_shallow_idx, j_max_wins), s_max_wins);
[val2_jp] = intersect(intersect(p_shallow_idx, j_max_wins), p_max_wins);
[val2_sp] = intersect(intersect(p_shallow_idx, s_max_wins), p_max_wins);

diff_vals_js = setdiff(val2_js, val3);
diff_vals_jp = setdiff(val2_jp, val3);
diff_vals_sp = setdiff(val2_sp, val3);

val3 = sort([val3; diff_vals_js; diff_vals_jp; diff_vals_sp]); 

% Find where there is a break in where these conditions are met
temp_diff_break = find(diff(val3)>1); 

% Save ranges of continuous periods where conditions are met
log_breath_locs = [];

% Go through continuous periods where conditions are met one by one
if length(temp_diff_break)>0
for c = 1:length(temp_diff_break)+1
   
    % If the first period...
    if c == 1 
        j_win_count = 0; s_win_count = 0; p_win_count = 0;
        cont_val3_prev = -3*fs;
        % Save the indexes of the continuous range that meets all three
        % conditions
        cont_range = [1:temp_diff_break(1)];
        % If this period is greater than 1 second 
        if length(cont_range)>1*fs 
           % Save this range of indices 
           cont_val3 = val3(cont_range);
        else 
           cont_val3 =  -3*fs; 
        end
    elseif c == length(temp_diff_break)+1 % If the last period...
        % Assign last cont_val3 to this variable to compare later
        cont_val3_prev = cont_val3;
        cont_range = [(temp_diff_break(c-1)+1):length(val3)];
        if length(cont_range)>1*fs
            cont_val3 = val3(cont_range);
        end
    elseif c > 1 && c < length(temp_diff_break)+1 % If a period between the first and last
        % Assign last cont_val3 to this variable to compare later
        cont_val3_prev = cont_val3;
        cont_range = [(temp_diff_break(c-1)+1):temp_diff_break(c)];
        if length(cont_range)>1*fs
            cont_val3 = val3(cont_range);
        end 
    end
    
    % Find the indexes where this window overlaps with the known regions
    % with jerk maxes
    % Keep in mind that for periods that are not associated with all three
    % conditions one of these will not work...
    if length(cont_val3)>1*fs
        cond = 0;
    % Save the old window 
    j_win_count_prev = j_win_count;
    % Find where this period intersects with the jerk windows
    j_temp_int = intersect(cont_val3, j_max_wins);
    % Find which window (count-wise) this period came from
    if isempty(j_temp_int)==0
        j_win_count = find(j_temp_int(end)<=j_wins_breaks, 1, 'first');
        cond = 1;
    end
    
    s_win_count_prev = s_win_count;
    s_temp_int = intersect(cont_val3, s_max_wins);
    if isempty(s_temp_int)==0
        s_win_count = find(s_temp_int(end)<=s_wins_breaks, 1, 'first');
        cond = 1;
    end
    
    p_win_count_prev = p_win_count;
    p_temp_int = intersect(cont_val3, p_max_wins);
    if isempty(p_temp_int)==0
        p_win_count = find(p_temp_int(end)<=p_wins_breaks, 1, 'first');
        cond = 1;
    end
    
    % If the same window as last time for any of these then keep first,
    % skip second instance
    if length(cont_range)>1*fs && (j_win_count>j_win_count_prev && s_win_count>s_win_count_prev && p_win_count>p_win_count_prev || cond == 1)
        if cont_val3(1)>cont_val3_prev(length(cont_val3_prev))+fs/10 || max(p_smooth_tag(cont_val3_prev))>0.5 || max(p_smooth_tag(cont_val3))>0.5 %If the first value of the range is less than 150 indices away from the last value of the last range...
            % Mark breath at halfway point of each period
            log_breath_locs = [log_breath_locs; cont_val3(floor(length(cont_val3)/2))];
        end
    end
    end
end
end

% Check to make sure that two breaths haven't been detected within 3
% seconds of eachother to limit to max fR of 20 breaths/min. If there are
% two breaths that close then select to keep the one at the minimum depth
% clear c
% for c = (length(log_breath_locs)-1):-1:1
%     diff_log_breath_locs = diff(log_breath_locs);
%     if diff_log_breath_locs(c)<3*fs
%         rm_idx = find([p_smooth(log_breath_locs(c)), p_smooth(log_breath_locs(c+1))]==max([p_smooth(log_breath_locs(c)), p_smooth(log_breath_locs(c+1))]));
%         log_breath_locs(c-1+rm_idx) = [];
%     end
% end

% If a breath detection from a single surfacing is closer than 3 seconds  
% (e.g. 20 breaths/min) to a breath detection from
% logging, then the ss breath trumps and we remove the logging breath
temp_all_breaths= [all_breath_locs.breath_idx; log_breath_locs]; 
temp_all_breaths_type = [repmat("ss", length(all_breath_locs.breath_idx), 1); repmat("log", length(log_breath_locs), 1)];%; diff_vals_ps]), 1)];

[temp_all_breaths_s, sortidx] = sort(temp_all_breaths);
temp_all_breaths_type_s = temp_all_breaths_type(sortidx, :);

sim_breaths = find(diff(temp_all_breaths_s)<3*fs);
rm_rows = [];
if isnan(sim_breaths) == 0 
    for i = 1:length(sim_breaths)
    temp_row = find(temp_all_breaths_type_s(sim_breaths(i):sim_breaths(i)+1) == "log");
    rm_rows = [rm_rows; sim_breaths(i)+temp_row-1];
    end
end

temp_all_breaths_s(rm_rows, :) = [];
temp_all_breaths_type_s(rm_rows, :) = [];

% Changing these to be in full range of "p"
all_breath_locs.breath_idx = temp_all_breaths_s + start_idx;
all_breath_locs.type = temp_all_breaths_type_s;

% Plot all locations where these three conditions are met
%figure
ax(4) = subplot(3, 5, [4, 5, 9, 10, 14, 15]);
p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k');
set(gca, 'ydir', 'reverse')
hold on
p_smooth_p2 = p_smooth_tag;
idx_temp = ismember(1:numel(p_smooth_p2),val3); % idx is logical indices
p_smooth_p2(~idx_temp) = NaN;
p2 = plot(time_min(start_idx:end_idx), p_smooth_p2, 'k-', 'LineWidth', 2);
p3 = scatter(time_min(start_idx+log_breath_locs-1), p_smooth_tag(log_breath_locs), 80, 'm*', 'LineWidth', 2);
title('Breath IDs during logging')
ylabel('Depth (m)'); xlabel('Time (min)');

legend([p1 p2],{'Dive depth' , 'Breath IDs - all three conditions'}, 'Location', 'south')%, 'Breath IDs - surge jerk + pitch'}, 'Location', 'best')

linkaxes(ax, 'x')
figfile = strcat('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\logging_breath_detections\', metadata.tag, '_loggingdetections.fig');
savefig(figfile);
 
%% Write breaths to audit 
save(strcat(data_path, "\breaths\", metadata.tag, "breaths"), 'tag', 'p_tag', 'p_smooth', 'p_smooth_tag', 'start_idx', 'end_idx', 'all_breath_locs', 'logging_ints_s');

 clearvars -except taglist tools_path mat_tools_path data_path; clc; close all
end

% Import breaths from audit - audits ONLY worked for D2s NOT D3s

for k = 1:length(taglist);
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

% Load in diving data
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "dives.mat"));
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "divetable.mat"));

% Load in movement data
load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"), 'jerk_smooth', 'surge_smooth', 'pitch_smooth');

% Load in breathing information
load(strcat(data_path, "\breaths\", metadata.tag, "breaths.mat"));

[time_sec, time_min, time_hour] =calc_time(metadata.fs, pitch); %Recalculate time

% Load in breaths
breath_idx = all_breath_locs.breath_idx;
breath_times = time_sec(all_breath_locs.breath_idx);

[breath_times, sortidx]  = sort(breath_times);
breath_type = all_breath_locs.type(sortidx, :);

%% Plot all locations where these three conditions are met
    figure
    title(metadata.tag, 'Interpreter', 'none');
    ax(1)=subplot(4, 1, 1);
    plot(time_min, p_smooth, 'k', 'LineWidth', 1.5); hold on
        set(gca,'Ydir','reverse')
        ylabel('Depth (m)');

    hold on
    scatter(breath_times(breath_type == 'ss')/60, p_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, p_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)

    legend('Depth', 'Single surface breaths', 'Log breaths');

    ax(2)=subplot(4, 1, 2);
    plot(time_min(2:end), surge_smooth, 'r', 'LineWidth', 1.5); hold on 
    scatter(breath_times(breath_type == 'ss')/60, surge_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, surge_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    ylabel('Smoothed Surge SE');

    ax(3)=subplot(4, 1, 3);
    plot(time_min(2:end), jerk_smooth, 'b', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == 'ss')/60, jerk_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, jerk_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    ylabel('Smoothed Jerk SE');
    
    ax(4)=subplot(4, 1, 4);
    plot(time_min(2:end), pitch_smooth, 'g', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == 'ss')/60, pitch_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, pitch_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    linkaxes(ax, 'x');
    ylabel('Smoothed Pitch SE');
    xlabel('Time (min)');
    
figfile = strcat('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\all_breaths\', metadata.tag, '_allbreaths.fig');
savefig(figfile);

%Calculate and plot fR
[fR] = get_contfR(breath_times, breath_idx, p, time_min);
title(taglist{k}, 'Interpreter', 'none');

figfile = strcat('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\doc\figs\resp_rate\', metadata.tag, '_resprate.fig');
savefig(figfile);

clearvars -except taglist tools_path mat_tools_path data_path; clc; close all

end

%% Save for R
clearvars -except taglist tools_path mat_tools_path data_path; clc; close all

for k = 1:length(taglist);
tag = taglist{k};

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));
clear tag

% Load in dives
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "dives"))

% Load in dive table
load(strcat(data_path, "\diving\divethres_5m\", metadata.tag, "divetable"))

% Load in breathing information
load(strcat(data_path, "\breaths\", metadata.tag, "breaths.mat"));

% Load full p from prh file - this will replace appended p from breathing
% file
load(strcat(data_path, "\prh\50 Hz\", metadata.tag, "prh.mat"),'p');

[time_sec, time_min, time_hour] =calc_time(metadata.fs, p); %Recalculate time

depth{k} = p;
fs{k} = metadata.fs;
dive_start_s{k} = dive_start;
dive_end_s{k} = dive_end;
logging_intervals_s{k} = logging_ints_s;

% Load in breaths
[temp_all_breaths_s, sortidx] = sort(all_breath_locs.breath_idx);
temp_all_breaths_type_s = all_breath_locs.type(sortidx, :);

breath_idx{k} = temp_all_breaths_s;
breath_type{k} = temp_all_breaths_type_s;
breath_type{k}(breath_type{k}=="ss") = 1;
breath_type{k}(breath_type{k}=="log") = 2;

breath_type{k} = str2double(breath_type{k});

end

% Save data to bring into R
save('C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\Gm_BreathingPatterns\data\all_breath_data.mat','dive_start_s', 'dive_end_s', 'taglist', 'breath_idx', 'breath_type', 'depth', 'fs', 'logging_intervals_s')

%% Acoustic auditing
settagpath('audit', 'D:\gm\audit');
settagpath('prh', 'D:\gm\prh\50 Hz');
tag = 'gm14_167a';
tcue = 745;

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));

R = loadaudit(tag);
R = tagaudit(tag, tcue, R);
saveaudit(tag, R);