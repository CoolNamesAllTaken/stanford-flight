function courseResults = flyCourse(geom, numLaps, simParams, verbose)
	% Flies numLaps laps around the course using an aircraft geometry object geom.  Takes in a struct simParams
	% that configures simulator settings (control gains, flight conditions, etc).
	% Inputs
	%	geom = AircraftGeometry object
	%	numLaps = num laps to fly around the course
	%	simParams.CRUISE_ALT = [m] cruising altitude
	%	simParams.CRUISE_V_INF = [m/s] estimate used to calculate phi_max
	%	simparams.RHO = [kg/m^3] air density
	%	simParams.P_alt = proportional altitude control gain
	%	simparams.D_alt = derivative altitude control gain
	%	simParams.P_hdg = proportional heading control gain
	%	simParams.D_hdg = derivative heading control gain
	%	verbose = true: output plots and dialogue false: run silently
	% Returns
	%	courseResults = [totalTime[s], minLapTime[s], maxLapTime[s], capacity[mAh]]
		units = loadUnits();

		PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line
		COURSE_WIDTH = 100 / units.M_2_FT; % [m] 360 turn distance from start

		state = AircraftState();
		state.rho = simParams.RHO;
		state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

		controller = AircraftController(simParams.P_alt, simParams.D_alt, simParams.P_hdg, simParams.D_hdg);
		controller.PHI_MAX = geom.calcphi_max(0.5 * simParams.RHO * simParams.CRUISE_V_INF^2);

		sim = AircraftSim(state, geom, controller);
		sim.commandAlt = simParams.CRUISE_ALT;
		sim.commandHdg = pi/2;

		maxLapTime = 0;
		minLapTime = 9999999999999999;

		% fly the course
		for (i=1:numLaps)
			startTime = sim.time;
			sim = sim.navToPos([0, PYLON_DIST, simParams.CRUISE_ALT]);
			sim = sim.navToPos([COURSE_WIDTH, 0, simParams.CRUISE_ALT]);
			sim = sim.turnCircle(1);
			sim = sim.navToPos([COURSE_WIDTH, -PYLON_DIST, simParams.CRUISE_ALT]);
			sim = sim.navToPos([0, 0, simParams.CRUISE_ALT]);
			endTime = sim.time;
			lapTime = endTime - startTime;
			if (lapTime > maxLapTime)
				maxLapTime = lapTime;
			elseif (lapTime < minLapTime)
				minLapTime = lapTime;
			end
		end

		if (verbose)
			fprintf('==========COURSE FINISHED==========\n');
			fprintf('NUM_LAPS: %d    simParams.CRUISE_ALT: %.2f\n', numLaps, simParams.CRUISE_ALT);
			fprintf('Total Time: %.2fsec    Min Lap Time: %.2f    Max Lap Time: %.2f\n', sim.time, minLapTime, maxLapTime);
			fprintf('Capacity: %.2fmAh\n', sim.data.capacity(end))
			plotData(sim.data);
		end

		courseResults.time = sim.time;
		courseResults.minLapTime = minLapTime;
		courseResults.maxLapTime = maxLapTime;
		courseResults.capacity = sim.data.capacity(end);
	end