%% Step S1: Save all breath information for analysis in  R
clearvars -except taglist tools_path mat_tools_path data_path; clc; close all

for k = 1:length(taglist);
tag = taglist{k};

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));
clear tag

% Load in dives
load(strcat(data_path, "\diving\", metadata.tag, "dives"))

% Load in dive table
load(strcat(data_path, "\diving\", metadata.tag, "divetable"))

% Load in breathing information
load(strcat(data_path, "\breaths\", metadata.tag, "breaths.mat"));

% Load full p from prh file - this will replace appended p from breathing
% file
load(strcat(data_path, "\prh\", metadata.tag, "prh.mat"),'p');

[time_sec, time_min, time_hour] =calc_time(metadata.fs, p); %Recalculate time

depth{k} = p;
fs_temp{k} = metadata.fs;
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

fs = fs_temp;

% Save data to bring into R
save(strcat(data_path, '\all_breath_data.mat'),'dive_start_s', 'dive_end_s', 'taglist', 'breath_idx', 'breath_type', 'depth', 'fs', 'odba', 'logging_intervals_s')

%% Step S2: Kinematic audit for DTAGs or CATS tags

% If you want to go through and manurally inspect all detections, this
% section will allow you to do so

%% Step S2a: Load in information for a tag

clearvars -except tools_path data_path mat_tools_path taglist

% YOU HAVE TO MANUALLY CHANGE THIS K VALUE!
k = 1;

tag = taglist{k};

% Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));
clear tag

%Set path for prh files
settagpath('prh',strcat(data_path,'\prh'));

% Load the existing prh file
loadprh(metadata.tag);

% Load in movement data
load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"));

% Load in diving data
load(strcat(data_path, "\diving\", metadata.tag, "dives.mat"));
load(strcat(data_path, "\diving\", metadata.tag, "divetable.mat"));

% Calculate time variables for full tag deployment
[time_sec, time_min, time_hour] =calc_time(metadata.fs, p);


start_idx = find(abs(time_sec-metadata.tag_on)==min(abs(time_sec-metadata.tag_on)));
end_idx = find(abs(time_sec-metadata.tag_off)==min(abs(time_sec-metadata.tag_off)));

if end_idx == length(time_sec)
    end_idx = end_idx-1;
end

if p(start_idx)<1 % Start audit on first dive to > 1 m
    start_idx = find(p(start_idx:end_idx)>=1, 1)+start_idx; 
end

% Subset p to only when tag is on
p_tag = p(start_idx:end_idx);

if strcmp(metadata.tag_ver, "CATS") == 1
    % Create date variable
    date = datetime(DN, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    date_on = datetime(DN(start_idx:end_idx), 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    xval = date_on;
else
    time_min_on = time_min(start_idx:end_idx);
    xval = time_min_on;
end

%% Step S2b: Audit breath detections - looking at depth & kinematics

% Here we are loading breaths from the text file

R = breath_loadaudit(strcat(data_path, '\breaths\', metadata.tag, 'breaths'), metadata); % Load an audit if one exists
tcue =  0; % Time cue in data to start analysis, should be 0 when you first begin
Rnew = breath_audit(taglist{k}, tcue, R, xval, p_tag, jerk_filt(start_idx:end_idx), rad2deg(roll(start_idx:end_idx)), metadata);
if ~isequal(R.cue, Rnew.cue) % Save if you actually changed stuff 
    [Rnew.cue, order] = sort(Rnew.cue);
    Rnew.stype = Rnew.stype(order);
    breath_saveaudit(strcat(data_path, '\breaths\', metadata.tag, 'breaths'), Rnew); % Save audit
end

%% Step S2c: Quick plot to look at breathing rates

% Load in breath audit
R = breath_loadaudit(strcat(data_path, '\breaths\', metadata.tag, 'breaths'), metadata); % Load an audit if one exists

if strcmp(metadata.tag_ver, "CATS") == 1
    % Create date variable
    date = datetime(DN, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    xval = date;
    fR = 1./minutes(diff(R.cue(:, 1)))
else
    xval = time_min;
    fR = 60./(diff(R.cue(:, 1)))
end

figure;

bx(1) = subplot(211);
scatter(R.cue(2:end, 1), fR); hold on
ylabel("Breathing Rate (breaths/min)");

bx(2) = subplot(212);
plot(xval, p, 'k'); hold on
% Reverse the depth axis
set(gca, "Ydir", "reverse")
% Add axis labels and a title
xlabel("Date Time"); ylabel("Depth (m)");
linkaxes(bx,'x');
 
%% Step S3: Optional - Dropping initial breaths after tagging for CATS

hours_to_drop = 1; % Set the # of hours to drop

% Load in breath audit
R = breath_loadaudit(strcat(data_path, '\breaths\', metadata.tag, 'breaths')); % Load an audit if one exists

breaths.cue = R.cue;
tagon_datetime = date(find(tagon ==1, 1, 'first'));
tagon_datetime_xhour = tagon_datetime + hours(hours_to_drop);
breaths_datetime_afterxhour = breaths.cue(breaths.cue > tagon_datetime_xhour);
tagon_duration_afterxhour = date(find(tagon ==1, 1, 'last'))-date(find(tagon ==1, 1, 'first'))-hours(hours_to_drop);
fr_overall = length(breaths_datetime_afterxhour)/minutes(tagon_duration_afterxhour);

tag = {metadata.tag};
num_breaths = length(breaths_datetime_afterxhour);
tag_duration = tagon_duration_afterxhour;
fr = fr_overall;
date_analyzed = datetime("today");

T = table(tag, num_breaths, tag_duration, fr_overall, date_analyzed);

if isfile(strcat(data_path, '\breaths\', 'breathdata.csv')) == 1
    writetable(T,strcat(data_path, '\breaths\', 'breathdata.csv'),'WriteMode','Append',...
        'WriteVariableNames', false)
else
    writetable(T,strcat(data_path, '\breaths\', 'breathdata.csv'),'WriteMode','Append',...
        'WriteVariableNames', true)
end 

%% Step S4: Optional - Random sampling of breaths to audit for CATS tag

% We want to pull the video on times and randomly subset some percent of breaths from each tag
% A version of this for DTAG data exists in the Rmd file

clearvars -except tools_path data_path mat_tools_path taglist

% Set percentage that you want to sample here:
% samp_per = 5 means you would be sampling 5% of all breaths 
samp_per = 5;

for k = 1:length(taglist)
    %% Load tag information
    
    tag = taglist{k};

    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));

    %Set path for prh files
    settagpath('prh',strcat(data_path,'\prh'));
    
    % Load the existing prh file
    loadprh(metadata.tag);

    % Import and count breaths
    breaths = breath_loadaudit(strcat(data_path, '\breaths\', INFO.whaleName, 'breaths')); % Load an audit if one exists
    
    breaths_DN = breaths.cue;
    
    % Number of total breaths
    n_breath = length(breaths_DN);
    
    % Number of breaths to audit
    audit_n_breath = ceil(samp_per*0.01*n_breath);
    
    %% Determine video on/off times
    
    idx_rm = find(isnan(vidDN)==1|isnan(vidDurs)==1);
    vidDN(idx_rm) = [];
    vidDurs(idx_rm) = [];
    
    vid_start = datetime(vidDN, 'ConvertFrom', 'datenum');
    
    vid_durs = seconds(vidDurs); % Video durations in seconds
    
    if length(vid_start) == length(vid_durs)
        vid_end = vid_start + vid_durs;
    end
    
    % Filter breaths to those when camera is on
    breaths_in_vid = breaths_DN;
    
    for i = length(breaths_DN):-1:1
        if sum(breaths_DN(i)> vid_start) > sum(breaths_DN(i)> vid_end) % Then happens when video is on
        else
            breaths_in_vid(i) = [];
        end
    end
    
    if length(breaths_in_vid) ~= 0 % If the video recorded any breaths...
        
        % If the # of breaths to audit is more than the # the video
        % recorded then replace # of breaths to audit with total # recorded
        if audit_n_breath > length(breaths_in_vid)
            audit_n_breath = length(breaths_in_vid);
        end
        
        rng(123) % Set seed for random sampling
        
        % Select breaths to audit
        breaths_to_audit = sort(randsample(breaths_in_vid,  audit_n_breath));
        
        % Build tag variable for a table 
        tag = repmat(string(tag), audit_n_breath, 1);
        
        % Build table 
        if k == 1
            audit_table = table(tag, breaths_to_audit);
        else
            audit_table = [audit_table; table(tag, breaths_to_audit)];
        end
    else
    end
    
clearvars -except tools_path data_path mat_tools_path taglist audit_table
   
end

% Write breaths to a csv file
writetable(audit_table, strcat(data_path, '\breaths\', 'breathaudit.csv'),'WriteMode','Append',...
    'WriteVariableNames', true) 

%% Step S5: Acoustic auditing for DTAG detection validation
% This step is totally separate from any breath detections
% You are going to go through the timing of randomly sampled logging
% periods from R and mark all breaths
% This does not currently exist for CATS tags!

%% Step S5a: Acoustic auditing for D2s

settagpath('audit', strcat(data_path, '\audit\'));
settagpath('prh', strcat(data_path, '\prh\'));
settagpath('audio', 'D:\gm', 'cal', strcat('D:\gm', '\cal\'));

tag = 'gm08_143a';
tcue = 0;

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));

R = loadaudit(tag);
R = tagaudit(tag, tcue, R);
saveaudit(tag, R);

%% Step S5b: Acoustic auditing for D3s

settagpath('audit', strcat(data_path, '\audit\'));
settagpath('prh', strcat(data_path, '\prh\'));
settagpath('audio', data_path, 'cal', strcat(data_path, '\cal\'));

tag = 'gm15_153a';
recdir = strcat(data_path, '\gm15\gm15_153a');
tcue = 0;

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));

R = loadaudit(tag);
R = d3audit(recdir, tag,  tcue, R);
saveaudit(tag, R);

%% Step S5c: Plot detections accuracy after acoustic validation

% Load in validation breathing information
load(strcat(tools_path, "\tests\gm\breaths\gm08_143bbreaths_val.mat"));

% Load in breaths
true_breath_idx = all_breath_locs.breath_idx;
true_breath_s = true_breath_idx/fs;

% Load in breathing information generated by user
load(strcat(tools_path, "\tests\gm\breaths\gm08_143bbreaths.mat"));

% Load in breaths
breath_idx = all_breath_locs.breath_idx;
breath_s = breath_idx/fs;

% Calculate similarity between true and users detections
breath_idx_diff = true_breath_s - breath_s;

% Print out similarity metrics
fprintf('The mean difference between your detections and the true detections is: %0.1f seconds\n', mean(breath_idx_diff)); 
fprintf('The max difference between your detections and the true detections is: %0.1f seconds\n', max(breath_idx_diff)); 
