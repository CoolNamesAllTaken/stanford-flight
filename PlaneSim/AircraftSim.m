classdef AircraftSim
	properties
		state % AircraftState
		geom % AircraftGeom
		controller % AircraftController

		commandAlt = 0; % [m] commanded altitude
		commandHdg = 0; % [rad] commanded heading

		time = 0; % [s]

		data % contains states, etc of past simulation times

		TIME_STEP = 0.1; % [s] time step for linear simulation
		TIMEOUT_NUM_STEPS = 500; % max number of time steps before timeout
		WAYPOINT_HIT_RADIUS = 10; % [m] how close the aircraft gets to a waypoint before it's been "hit"
		TURN_HDG_STEP = pi/2;
	end
	methods  
		function as = AircraftSim(state, geom, controller)
			as.state = state;
			as.geom = geom;
			as.controller = controller;

			% initialize data (used as controller inputs for first time step)
			as.data.time = 0;
			as.data.state = state;
			as.data.v_inf = state.v_inf;
			as.data.thrust = 0;
			as.data.L = 0;
			as.data.F_xyz = [0 0 0];
		end

		function as = navToPos(as, pos)
			numSteps = 0;
			while (numSteps < as.TIMEOUT_NUM_STEPS && as.state.calcDistToPos(pos) > as.WAYPOINT_HIT_RADIUS)
				as.commandHdg = as.state.calcHdgToPos(pos);
				as.commandAlt = pos(3);
				as = as.update();
				numSteps = numSteps + 1;
			end
		end

		function as = turnCircle(as, rot)
		% turn a full circle with rotation direction rot
		% Inputs:
		%	rot [+/- 1] rotation direction (+: turn to right, -: turn to left)
			origHdg = as.state.hdg;
			lastHdg = origHdg;
			hdgStep = rot * as.TURN_HDG_STEP;
			totHdgChange = 0;
			numSteps = 0;
			while (numSteps < as.TIMEOUT_NUM_STEPS && abs(totHdgChange) < 2*pi)
				if (as.state.hdg + hdgStep >= 2*pi)
					% turning across north clockwise
					as.commandHdg = as.state.hdg + hdgStep - 2*pi;
				elseif (as.state.hdg + hdgStep < 0)
					% turning across north counterclockwise
					as.commandHdg = as.state.hdg + hdgStep + 2*pi;
				else
					% not crossing north
					as.commandHdg = as.state.hdg + hdgStep;
				end
				totHdgChange = totHdgChange + abs(as.state.calcHdgDiff(lastHdg));
				lastHdg = as.state.hdg;
				as = as.update();
				numSteps = numSteps + 1;
			end
		end

		function as = update(as)
			% units
			units = loadUnits();
			% transformation matrices
			AC_LONG_2_XYZ = [cos(as.state.gamma), (sin(as.state.gamma) * sin(as.state.phi)), (sin(as.state.gamma) * cos(as.state.phi))];
			AC_VERT_2_XYZ = [-sin(as.state.gamma), (cos(as.state.gamma) * sin(as.state.phi)), (cos(as.state.gamma) * cos(as.state.phi))];
			XYZ_2_NEU = [cos(as.state.hdg), sin(as.state.hdg), 0; -sin(as.state.hdg), cos(as.state.hdg), 0; 0, 0, 1];

			%% Fly the aircraft
			% update current state variables
			as.time = as.time + as.TIME_STEP;

			T_xyz = as.geom.calcThrust(as.state.v_inf, 1) .* AC_LONG_2_XYZ; % [T_x T_y T_z]
			L_xyz = as.geom.calcLift(as.state.q_inf) .* AC_VERT_2_XYZ; % [L_x L_y L_z]
			D_xyz = -as.geom.calcDrag(as.state.q_inf) .* AC_LONG_2_XYZ; % [D_x D_y D_z]
			W_xyz = [0, 0, -(as.geom.mass * units.KG_2_N)]; % [W_x W_y W_z]

			F_xyz = T_xyz + L_xyz + D_xyz + W_xyz;
			F_neu = F_xyz * XYZ_2_NEU;

			as.state.acc = F_neu ./ as.geom.mass;
			as.state = as.state.update(as.TIME_STEP);

			%% Control loops
			% PD altitude control (controls lift multiplier)
			altErr = as.state.pos(3) - as.commandAlt;
			dAltErr = as.state.vel(3);
			as.geom.liftMult = as.controller.controlAlt(altErr, dAltErr, as.geom.liftMult);

			% PD heading control (controls aircraft roll)
			hdgErr = as.state.calcHdgDiff(as.commandHdg);
			dHdgErr = as.state.calcHdgDiff(as.data.state(end).hdg) / as.TIME_STEP;
			as.state.phi = as.controller.controlHdg(hdgErr, dHdgErr, as.state.phi);

			% ground interactions: stop aircraft from sinking into ground
			if (as.state.pos(3) <= 0 && as.state.vel(3) < 0)
				as.state.pos(3) = 0;
				as.state.vel(3) = 0;
				as.state.acc(3) = 0;
			end 

			%% Record data
			as.data.time = vertcat(as.data.time, as.time);
			as.data.state = vertcat(as.data.state, as.state);
			as.data.v_inf = vertcat(as.data.v_inf, as.state.v_inf);
			as.data.thrust = vertcat(as.data.thrust, sqrt(sum(T_xyz.^2)));
			as.data.L = vertcat(as.data.L, sqrt(sum(L_xyz.^2)));
			as.data.F_xyz = vertcat(as.data.F_xyz, F_xyz);
		end
	end
end