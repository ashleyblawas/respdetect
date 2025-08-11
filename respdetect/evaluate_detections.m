function results = evaluate_detections(ref_times, test_times, tolerance)
    arguments
        ref_times (:, 1) double
        test_times (:, 1) double
        tolerance (1,1) double {mustBePositive}
    end
    % EVALUATE_DETECTIONS Compares detected breath times against reference times.
    %
    %   This function compares a set of test detections (e.g., from an automated
    %   algorithm) against reference breath times (e.g., manually annotated) and
    %   evaluates performance using standard classification metrics.
    %
    %   A match is defined as a test time occurring within ±`tolerance` seconds
    %   of a reference time. Each reference breath can only be matched once.
    %
    %   Inputs:
    %     ref_times   - [Nx1] vector of reference breath times (seconds or datetime)
    %     test_times  - [Mx1] vector of predicted or detected breath times
    %     tolerance   - Scalar, allowable difference (in seconds) for a valid match
    %
    %   Output:
    %     results     - Struct containing evaluation metrics:
    %                TP           - Number of true positives (correct matches)
    %                FP           - Number of false positives (extra detections)
    %                FN           - Number of false negatives (missed detections)
    %                Precision    - TP / (TP + FP)
    %                Recall       - TP / (TP + FN)
    %                F1           - Harmonic mean of Precision and Recall
    %                MatchedPairs - [Px2] matrix of matched reference and test times
    %
    %   Notes:
    %     - Input vectors are automatically reshaped to column format.
    %     - One-to-one matching: each reference breath is matched at most once.
    %     - Precision and Recall are set to NaN if division by zero occurs.
    %
    %   Example:
    %     results = evaluate_detections(ref_breaths, detected_breaths, 2.0);
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    % Ensure input vectors are column vectors
    ref_times = ref_times(:);
    test_times = test_times(:);
    
    % Match each test breath to a reference breath
    matched_ref = false(size(ref_times));
    matched_test = false(size(test_times));
    
    % Preallocate for speed
    max_matches = length(test_times);  % Worst case: every test_time has a match
    matched_pairs = zeros(max_matches, 2);  % Preallocate as 2-column matrix
    matched = 0;
    
    for i = 1:length(test_times)
        time_diffs = abs(ref_times - test_times(i));
        [min_diff, idx] = min(time_diffs);
        
        if min_diff <= tolerance && ~matched_ref(idx)
            matched_ref(idx) = true;
            matched_test(i) = true;
            matched = matched + 1;
            matched_pairs(matched, :) = [ref_times(idx), test_times(i)];
        end
    end
    
    % Trim unused preallocated rows
    matched_pairs = matched_pairs(1:matched, :);
    
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