function progressBar(fraction, clearBar)
% Creates a 'loading bar' effect using ASCII characters in stdout.
% John McNelly - August 2017
%
% Usage
%	Initialize a new progress bar (start bar at 0%, don't clear first instance):
%		progressBar() or progressBar(0, false)
%	Update current progress bar to 57%:
%		progressBar(0.57)
%
% Inputs
%	fraction - Fraction between 0 and 1 inclusive indicating progress to be displayed.
%	clearBar - Optional boolean indicating whether to clear the last progress bar (assumes that
%				progress bars are printed consecutively).

	LOADED_CHAR = '#';
	UNLOADED_CHAR = ' ';
	PROGRESS_STEP = 2; % progress percentage denoted by a single LOADED_CHAR
	MAX_NUM_STEPS = round(100 / PROGRESS_STEP);
	PROGRESS_BAR_LEN = (MAX_NUM_STEPS * length(LOADED_CHAR)) + 8;

	if (nargin == 0)
		% progress bar is being initialized with progress_bar()
		fraction = 0; % start progress bar at 0%
		clearBar = false; % do not erase text before progress bar
	elseif (nargin == 1)
		% progress bar percentage is being updated with progress_bar(0.XXX)
		clearBar = true; % no clearBar override specified, overwrite last bar
	end

	if (fraction < 0)
		fraction = 0;
	elseif(fraction > 1)
		fraction = 1;
	end

	percent = round(100 * fraction, 0); % make fraction an integer percent
	numSteps = floor(percent / PROGRESS_STEP);

	if (~clearBar)
		backspaceStr = ''; % don't clear last bar
	else
		backspaceStr = repmat(char(8), 1, PROGRESS_BAR_LEN); % clear last bar
	end
	
	loadedBar = repmat(LOADED_CHAR, 1, numSteps);
	unloadedBar = repmat(UNLOADED_CHAR, 1, MAX_NUM_STEPS - numSteps);

	fprintf('%s %3.0d%%\n', [backspaceStr '[' loadedBar unloadedBar ']'], percent);
end