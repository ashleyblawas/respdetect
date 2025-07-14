function results = evaluate_detections(ref_times, test_times, tolerance)
    arguments
        ref_times (:, 1) double
        test_times (:, 1) double
        tolerance (1,1) double {mustBePositive}
    end
    % Evaluate how well test detections match reference breath detections
    %
    % Inputs:
    %   ref_times   - vector of reference breath times (in seconds or datetimes)
    %   test_times  - vector of detected breath times
    %   tolerance   - allowable difference (in seconds) to count as a match
    %
    % Output:
    %   results     - struct with TP, FP, FN, Precision, Recall, F1, and match index
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Ensure input vectors are column vectors
    ref_times = ref_times(:);
    test_times = test_times(:);
    
    % Match each test breath to a reference breath
    matched_ref = false(size(ref_times));
    matched_test = false(size(test_times));
    matched_pairs = [];
    
    matched = 0;
    for i = 1:length(test_times)
        time_diffs = abs(ref_times - test_times(i));
        [min_diff, idx] = min(time_diffs);
        
        if min_diff <= tolerance && ~matched_ref(idx)
            matched_ref(idx) = true;
            matched_test(i) = true;
            matched_pairs = [matched_pairs; ref_times(idx), test_times(i)];
            matched = matched + 1;
        end
    end
    
 
    % Compute stats
    TP = sum(matched_test);
    FP = sum(~matched_test);
    FN = sum(~matched_ref);
    
    Precision = TP / (TP + FP);
    Recall = TP / (TP + FN);
    F1 = 2 * (Precision * Recall) / (Precision + Recall);
    
    % Output
    results = struct();
    results.TP = TP;
    results.FP = FP;
    results.FN = FN;
    results.Precision = Precision;
    results.Recall = Recall;
    results.F1 = F1;
    results.MatchedPairs = matched_pairs;
    
    % Display summary
    fprintf('\n--- Detection Evaluation ---\n');
    fprintf('Tolerance: ±%.2f sec\n', tolerance);
    fprintf('True Positives: %d | False Positives: %d | False Negatives: %d\n', TP, FP, FN);
    fprintf('Precision: %.2f | Recall: %.2f | F1 Score: %.2f\n', Precision, Recall, F1);
    fprintf('\nMatched breaths within %.1f sec: %d/%d (%.1f%%)\n', ...
        tolerance, matched, length(ref_times), 100 * matched / length(ref_times));

end