%plot_dives

function plot_dives(T, time_sec, p)
    for k= 1:length(T(:, 1))
        dive_durs(k) = T(k, 2)- T(k, 1);
    end
     for k= 1:length(T(:, 1))-1
        surf_durs(k) = T(k+1, 1) -T(k, 2);
    end
    
    figure
    subplot(2, 3, [1 2 4 5])
    plot(time_sec, p); hold on
    plot(T(:, 1), zeros(length(T(:, 1)), 1), 'g*');
    plot(T(:, 2), zeros(length(T(:, 2)), 1), 'r*');
    set(gca, 'ydir', 'reverse')
    xlabel('Time (s)'); ylabel('Depth (m)');
    legend('Depth', 'Start of dive', 'End of dive');
    
    % Plot summary dive metrics
    subplot(2, 3, 3)
    for k = 1:length(T(:, 1))
        scatter(k, dive_durs(k)./60, 20,'k'); hold on
    end
    ylabel('Dive Duration (min)'); box on;
    box on; axis square
    
    subplot(2, 3, 6)
    for k = 1:length(T(:, 1))
        scatter(k, T(k, 3), 20, 'k'); hold on
    end
    xlabel('Dive Number'); ylabel('Dive Depth (m)');
    set(gca, 'ydir', 'reverse');
    box on; axis square
end