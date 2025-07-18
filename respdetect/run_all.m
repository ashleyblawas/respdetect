%%% The main script for running respdetect

%%% Author: Ashley Blawas
%%% Last Updated: 1/23/2024
%%% Duke University, Stanford University

% Getting started:

% 1. You will need to change the data_path at the top of Step 1

% 2. Make sure your prh files are in a folder called "prh" that is in your
% data folder under a two letter species code

% Variables you may consider changing:

% 1. dive_thres, the dive threshold - in Step 3, dive_thres. You will get prompted to
% set this. If you want it to be the same value for your analysis and save
% yourself some time, you can comment out the lines under "Set dive
% threshold and find dives" and instead set dive_thres = 5; or whatever
% value you want it to be. FYI, these dives are not currently used, but if
% you want to do further analysis in Matlab they are helpful to have

% 2. n_sec, The # of seconds to distinguish between single-breath surfacing and
% logging surfacing. At the start, this is set to 10 seconds. This is set in
% the Step 5c: Identify surface periods section and the variable is called
% n_sec. If you suspect that your animal may be taking breaths more
% frequently during a surfacing interval, you may want to set this lower. 

% 3. min_sec_apart, The minimum # of seconds between peaks detected in
% movement signals during logging period. This can be found in section Step
% 5h: Peak detection of movement signals and is currently set to 3 seconds.
% This allows for a maximum breathing rate during logging of 20
% breaths/min. This is obviously quite high and therefore will tend to
% overdetect breaths. If this is a porblem with you dataset, you could
% consider increasing this number to say 6 seconds, which would allow for
% a maximum breathing rate of 12 breaths/min. 

% 4. win_sec, The window size for finding aligning peaks in jerk, surge, and pitch.
% In section Step 5i: Detect windows for breaths during logging periods
% there is a variable called win_sec. This specifies how close in time a
% peak in each of these three signal needs to be to be counted as
% co-occuring. Currently this is set to 5 seconds which should be plenty to
% capture all potential peaks (e.g., this errs on the side of
% overdetecting) 

% 5. samp_per, this is the percentage of breaths that we want to randomly
% sample for auditing. This can be found under Step 8: Pull breaths to
% audit in video and is currently set to 5%. Depending on the size of your
% dataset you may be able to sample a greater percentage than this. 

%% Step 1: Set paths and tag variables
% Clear workspace and command window and close all figures
clear; clc; close all

% Manually enter the path where your data files are stored...
data_path = 'C:\Users\ashle\Dropbox\Ashley\Graduate\Manuscripts\respdetect\tests\';

% Set the species code of the folder for analysis
speciesCode = 'gm';

% Set the data and tool paths
set_paths(data_path);

% Allow the user to select the prh files to analyze from a given species
% folder
taglist = load_data(data_path, speciesCode);

%% Step 2: Make metadata file

make_metadata(taglist, data_path);

%% Step 3: Find dives

% Set the minimum depth to count a dive
dive_thres = 5;

make_dives(taglist, data_path, dive_thres);

%% Step 4: Process movement data

make_move(taglist, data_path)

%% Step 5: Detect breaths

% The # of seconds to distinguish between single-breath surfacing and logging surfacing
n_sec = 10;

% The minimum # of seconds between peaks detected in movement signals during logging period.
min_sec_apart = 3;

% The window size (# of sec) for finding aligning peaks in jerk, surge, and pitch.
win_sec = 5;

detect_breaths(taglist, data_path, n_sec, min_sec_apart, win_sec)

%% Step 6: Plot all breaths

for k = 1:length(taglist)
    
  plot_breaths(data_path, taglist, k);
        
end

%% Step 7: Run tests

%% Step 7a: Test detections for gm08_143b
% For these detections I used the following parameters:
%   Tag on: 201.40 seconds (default)
%   Tag off: 15835.21 seconds (manual)
%   Tag version: D2 (default)
%
% Set the minimum depth to count a dive
%   dive_thres = 5;
%
% The # of seconds to distinguish between single-breath surfacing and logging surfacing
%   n_sec = 10;
%
% The minimum # of seconds between peaks detected in movement signals during logging period.
%   min_sec_apart = 3;
%
% The window size (# of sec) for finding aligning peaks in jerk, surge, and pitch.
%   win_sec = 5;

% Tolerance for matching detections (in seconds)
tolerance = 0.2;

test_breaths(data_path, "gm08_143bbreaths_val.mat", "gm08_143bbreaths.mat", tolerance)

%% Step 7b: Test detections for mn17_310a
% For these detections I used the following parameters:
%   Tag on: 0.0 seconds, i.e., on at start (default)
%   Tag off:  24322.00 seconds (default)
%   Tag version: D2 (default)
%
% Set the minimum depth to count a dive
%   dive_thres = 5;
%
% The # of seconds to distinguish between single-breath surfacing and logging surfacing
%   n_sec = 10;
%
% The minimum # of seconds between peaks detected in movement signals during logging period.
%   min_sec_apart = 3;
%
% The window size (# of sec) for finding aligning peaks in jerk, surge, and pitch.
%   win_sec = 5;

% Tolerance for matching detections (in seconds)
tolerance = 0.2;

test_breaths(data_path, "mn17_310abreaths_val.mat", "mn17_310abreaths.mat", tolerance)
