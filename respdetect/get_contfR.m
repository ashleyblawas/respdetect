function [fR] = get_contfR(breath_times, breath_idx, p, date, metadata)
    % Gets the instantaneous respiration rate of the breath detections
    %
    % Inputs:
    %   breath_times    - Time of each breath relative to x variable used
    %   breath_idx      - Indicies of each breath
    %   p               - Depth 
    %   date            - X variable
    %   metadata        - Tag metadata
    %
    % Output:
    %   fR       - Instantaneous respiration rate (from get_contfR)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    if strcmp(metadata.tag_ver, "CATS") == 1
        fR = 1./minutes(diff(breath_times)); % Take diff of all breath time
    else
        fR = 1./diff(breath_times); % Take diff of all breath time
    end
    
    % If there is a 5 m dive between two breaths... remove that fR
% for k = 1:length(breath_times)-1;
%     if any(p(breath_idx(k):breath_idx(k+1))>5)
%         fR(k) = NaN;
%     end
% end

% Plot continuous fR with dive profile
figure;
ax(1) = subplot(311);
stairs(breath_times(2:end), fR, 'ko','MarkerSize', 8, 'MarkerFaceColor', 'yellow'); 
set(gca,'Xticklabel',[])
ylabel('{\it f}_R (breaths min^{-1})');
POS1 = get(ax(1), 'Position');
POS1(2) = POS1(2)+0.05;
set(ax(1), 'Position', POS1);
title(metadata.tag, 'Interpreter', 'none');

hold on; 
ax(2) = subplot(3, 1, [2 3]);
plot(date, p, 'k', 'LineWidth', 1.5); xlabel('Date Time'); ylabel('Depth (m)');
set(gca, 'Ydir', 'reverse');
linkaxes(ax, 'x'); ylim([-1 max(p)]);
POS = get(ax(2), 'Position');
POS(4) = POS(4)+0.1;
set(ax(2), 'Position', POS) ;

end