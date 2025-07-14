function test_breaths(dataPath, ref_filename, test_filename, tolerance);
    arguments
        dataPath (1,:) char
        ref_filename (1,:) char
        test_filename (1,:) char
        tolerance (1,:) double {mustBePositive}
    end
    % Compare user generated breath detections to reference.
    %
    % Inputs:
    %   dataPath
    %   ref_times   - vector of reference breath times (in seconds or datetimes)
    %   test_times  - vector of detected breath times
    %   tolerance   - allowable difference (in seconds) to count as a match
    %
    % Output:
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    ref_data = load(fullfile(dataPath, ref_filename(1:2), "breaths", ref_filename));
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
