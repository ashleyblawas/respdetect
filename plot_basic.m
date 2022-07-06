%plot_basic

function [] = plot_basic(time_min, p, pitch, roll, head, j)
    figure ;
    q(1) = subplot(3, 1, 1);
    %Plot dive profile
    plot(time_min, p, 'b'); grid; hold on;
    set(gca,'Ydir','reverse')
    title('Dive Profile')
    xlabel('Time (min)'); ylabel('Depth (m)');
    
    % Plot pitch, roll, heading
    q(2) = subplot(3, 1, 2);
    plot(time_min, pitch*180/pi); grid
    hold on
    plot(time_min, roll*180/pi);
    plot(time_min, head * 180 / pi);
    legend('Pitch','Roll','Heading')
    
    q(3) = subplot(3, 1, 3);
    plot(time_min(1:end-1), j); grid; hold on;
    xlabel('Time (min)'); ylabel('Jerk (g s^{-1})');
    linkaxes(q,'x');
    
end
