function [] = plot_dive2surfb(dive_dur, breathing_dur, c)
%Plot dive duration versus surface duration
figure
if iscell(dive_dur) == 1
for k = 1:length(dive_dur)
    for i = 1:length(dive_dur{k})-1
        scatter(dive_dur{k}(i), breathing_dur{k}(i), 24, c(k, :), 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on
    end
end
else 
     for i = 1:length(dive_dur)-1
        scatter(dive_dur(i), breathing_dur(i), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on
     end
end

xlabel('Dive Duration (min)'); ylabel('Time Spent Breathing at Surface (min)');
box on; axis square;
