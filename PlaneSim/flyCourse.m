function courseResults = flyCourse(geom, maxLaps, simParams, verbose)
	% Flies maxLaps laps around the course using an aircraft geometry object geom.  Takes in a struct simParams
	% that configures simulator settings (control gains, flight conditions, etc).
	% Inputs
	%	geom = AircraftGeometry object
	%	maxLaps = num laps to fly around the course
	%	simParams.CRUISE_ALT = [m] cruising altitude
	%	simParams.CRUISE_V_INF = [m/s] estimate used to calculate phi_max
	%	simparams.RHO = [kg/m^3] air density
	%	simParams.P_alt = proportional altitude control gain
	%	simparams.D_alt = derivative altitude control gain
	%	simParams.P_hdg = proportional heading control gain
	%	simParams.D_hdg = derivative heading control gain
	%	simParams.timeStep = dt for linear sim
	%	verbose = true: output plots and dialogue false: run silently
	% Returns
	%	courseResults = [totalTime[s], minLapTime[s], maxLapTime[s], capacity[mAh]]
		units = loadUnits();

		PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line
		COURSE_WIDTH = 100 / units.M_2_FT; % [m] 360 turn distance from start

		state = AircraftState();
		state.rho = simParams.RHO;
		state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

		controller = AircraftController(simParams.P_alt, simParams.D_alt, simParams.P_hdg, simParams.D_hdg, simParams.timeStep);
		controller.PHI_MAX = geom.calcphi_max(0.5 * simParams.RHO * simParams.CRUISE_V_INF^2);

		sim = AircraftSim(state, geom, controller, simParams.timeStep);
		sim.commandAlt = simParams.CRUISE_ALT;
		sim.commandHdg = pi/2;

		maxLapTime = 0;
		minLapTime = 9999999999999999;
		TAKEOFF_TRIGGER_ALT = 0.2; % [m] altitude where "takeoff" is recorded
		MAX_FLIGHT_TIME = 600; % [s] 10 min flight window

		% fly the course
		battCapacity_reserve = sim.geom.battCapacity * 0.3; % fly to 70% capacity
		numLaps = 0;
		while (numLaps < maxLaps)
			startTime = sim.time;
			sim = sim.navToPos([0, PYLON_DIST, simParams.CRUISE_ALT]);
			fprintf('p1 ')
			sim = sim.navToPos([COURSE_WIDTH, 0, simParams.CRUISE_ALT]);
			fprintf('p2 ')
			sim = sim.turnCircle(1);
			sim = sim.navToPos([COURSE_WIDTH, -PYLON_DIST, simParams.CRUISE_ALT]);
			fprintf('p3 ')
			sim = sim.navToPos([0, 0, simParams.CRUISE_ALT]);
			endTime = sim.time;
			lapTime = endTime - startTime;
			if (lapTime > maxLapTime)
				maxLapTime = lapTime;
			elseif (lapTime < minLapTime)
				minLapTime = lapTime;
			end
			if (sim.geom.battCapacity < battCapacity_reserve);
				fprintf('lap %d FAILED (out of battery)\n', numLaps);
				break
			elseif (sim.time > MAX_FLIGHT_TIME)
				fprintf('lap %d FAILED (out of time)\n', numLaps);
				break
			else
				fprintf('lap %d complete time=%.2f capacity=%.2f\n', numLaps, sim.time, sim.geom.battCapacity);
				numLaps = numLaps + 1;
			end
		end

		% parse data
		startPos = sim.data.state(1).pos;
		takeoffLength = -1;
		for i=1:length(sim.data.state)
			if (sim.data.state(i).pos(3) > TAKEOFF_TRIGGER_ALT)
				takeoffLength = sim.data.state(i).calcDistToPos(startPos);
				break;
			end
		end

		if (verbose)
			fprintf('==========COURSE FINISHED==========\n');
			fprintf('NUM_LAPS: %d    CRUISE_ALT: %.2f\n', numLaps, simParams.CRUISE_ALT);
			fprintf('Total Time: %.2fsec    Min Lap Time: %.2f    Max Lap Time: %.2f\n', sim.time, minLapTime, maxLapTime);
			fprintf('Capacity: %.2fmAh      TakeoffLength: %.2f\n', sim.data.battCapacity(end), takeoffLength);
			plotData(sim.data);
		end

		courseResults.time = sim.time;
		courseResults.numLaps = numLaps;
		courseResults.minLapTime = minLapTime;
		courseResults.maxLapTime = maxLapTime;
		courseResults.battCapacity = sim.data.battCapacity(end);
	end
