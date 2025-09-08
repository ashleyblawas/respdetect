function test_breaths(dataPath, ref_filename, test_filename, tolerance)
    arguments
        dataPath (1,:) char
        ref_filename (1,:) char
        test_filename (1,:) char
        tolerance (1,:) double {mustBePositive}
    end
    % TEST_BREATHS Compare user-generated breath detections against a reference file.
    %
    % This function compares detected breath events (from a test file) to a known
    % reference file and prints out a summary of detection performance, including:
    %   - Number of breaths
    %   - Instantaneous breathing rate (breaths per minute)
    %   - Inter-breath interval (IBI)
    %   - Detection count mismatch (over-/under-detection)
    %   - Suggestions for improving detection if mismatch exists
    %
    % The function also calls `evaluate_detections` to match detected events
    % against the reference within a given time `tolerance`.
    %
    % Inputs:
    %   dataPath     - Base path to data directory (e.g., 'C:\my_data\')
    %   ref_filename - Filename of reference breath detections (e.g., 'gm09_123a_breaths.mat')
    %   test_filename- Filename of test breath detections to evaluate
    %   tolerance    - Allowable time difference (in seconds) to count a detection
    %                  as a match
    %
    % Outputs:
    %   (None returned; outputs printed to console. Matching logic handled by
    %   evaluate_detections.)
    %
    % Assumptions:
    %   - Both input .mat files contain a struct named `all_breath_locs` with the
    %     field `breath_idx`, and a scalar `fs` (sampling rate in Hz).
    %   - Filenames begin with species code (first two characters), used to locate
    %     the 'breaths' subfolder (e.g., `dataPath/gm/breaths/filename.mat`).
    %
    % Usage:
    %   test_breaths('C:\data\', 'gm08_123a_breaths.mat', 'gm08_123a_test.mat', 2)
    %
    % Related Functions:
    %   evaluate_detections
    %
    % Author: Ashley Blawas
    % Last Updated: August 11, 2025
    % Stanford University
    
    ref_data = load(fullfile(dataPath, ref_filename(1:2), ref_filename));
    ref_breath_idx = ref_data.all_breath_locs.breath_idx;
    ref_breath_s = ref_breath_idx / ref_data.fs;
    ref_ibi = diff(ref_breath_s);
    ref_breath_fr = 60 ./ ref_ibi;
    
    
    % Load test breath detection data
    test_data = load(fullfile(dataPath, test_filename(1:2), "breaths", test_filename));
    test_breath_idx = test_data.all_breath_locs.breath_idx;
    test_breath_s = test_breath_idx / test_data.fs;
    test_ibi = diff(test_breath_s);
    test_breath_fr = 60 ./ test_ibi;
    
    % Summary stats
    fprintf('--- Breath Detection Summary ---\n\n');
    fprintf('Reference:\n');
    fprintf('  Number of breaths: %d\n', length(ref_breath_idx));
    fprintf('  Mean rate: %.2f breaths/min\n', mean(ref_breath_fr));
    fprintf('  Mean IBI: %.2f s (± %.2f)\n', mean(ref_ibi), std(ref_ibi));
    
    fprintf('\nTest:\n');
    fprintf('  Number of breaths: %d\n', length(test_breath_idx));
    fprintf('  Mean rate: %.2f breaths/min\n', mean(test_breath_fr));
    fprintf('  Mean IBI: %.2f s (± %.2f)\n', mean(test_ibi), std(test_ibi));
    
    % Compare counts
    n_ref = length(ref_breath_idx);
    n_test = length(test_breath_idx);
    diff_count = n_test - n_ref;
    
    if diff_count == 0
        fprintf('\n Breath detection count matches the reference.\n');
    elseif diff_count > 0
        fprintf('\n Over-detection: Detected %d extra breaths.\n', diff_count);
        fprintf('Suggestions:\n');
        fprintf('- Check tag-on/off times for accuracy.\n');
        fprintf('- Increase the minimum time between breath events.\n');
    else
        fprintf('\n Under-detection: Missed %d breaths.\n', abs(diff_count));
        fprintf('Suggestions:\n');
        fprintf('- Reduce the minimum separation between breaths.\n');
        fprintf('- Ensure tag-on period is not accidentally excluded.\n');
    end
    
    if n_test == 0
        fprintf('\n No breaths detected in test file.\n');
    end
    
    % Match events within tolerance
    evaluate_detections(ref_breath_s, test_breath_s, tolerance);
end
