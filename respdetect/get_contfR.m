%get_contfR

function [fR] = get_contfR(breath_times, breath_idx, p, time_min)
fR = 60./diff(breath_times); % Take diff of all breath times

% If there is a 5 m dive between two breaths... remove that fR
% for k = 1:length(breath_times)-1;
%     if any(p(breath_idx(k):breath_idx(k+1))>5)
%         fR(k) = NaN;
%     end
% end

% Plot continuous fR with dive profile
figure;
stairs(breath_times(2:end)./60, fR, '.','MarkerSize', 6); 

hold on; 
plot(time_min, -p, 'k'); xlabel('Time (min)'); ylabel('Depth (m), {\it f}_R (breaths min^{-1})');
end