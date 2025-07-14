function save_fig(dataPath, speciesCode, metadata, fig_suffix)
    % saveLoggingFigure Save a logging detection figure with optional suffix if file exists
    %
    % Inputs:
    %   dataPath     - Base path to your data directory (e.g. 'C:\data\')
    %   speciesCode  - Species subfolder name (e.g. 'ZC')
    %   metadata     - Struct with field `tag` for tag name
    %   fig_suffix    - What to append to the end of the figure name
    
    % Construct full figure file path
    figDir = fullfile(dataPath, speciesCode, 'figs');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end
    
    figfile = fullfile(figDir, strcat(metadata.tag, '_', fig_suffix, '.fig'));
    
    fprintf("Figure filename: %s\n", figfile);
    
    % Check if file already exists
    if isfile(figfile)
        prompt = sprintf(['A figure with this name already exists.\n' ...
                  'Options:\n' ...
                  '  [o] Overwrite existing file\n' ...
                  '  [a] Append custom suffix\n' ...
                  '  [n] Cancel save\n' ...
                  'Choose an option (o/a/n): ']);
              txt = input(prompt, "s");
        
        switch lower(txt)
            case 'a'
                suffix = input("Enter suffix to append (e.g. _examplesection): ", "s");
                figfile = fullfile(figDir, strcat(metadata.tag, '_', fig_suffix, suffix, '.fig'));
                savefig(figfile);
                fprintf("Figure saved as: %s\n", figfile);
                
            case 'o'
                savefig(figfile);
                fprintf("Figure overwritten at: %s\n", figfile);
                
            otherwise
                disp("Figure was not saved.");
        end
        
    else
        % Save the figure if it doesn’t exist
        savefig(figfile);
        fprintf("Figure saved to: %s\n", figfile);
    end
    
end
