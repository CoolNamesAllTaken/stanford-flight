classdef AircraftSim
	properties
		state % AircraftState
		geom % AircraftGeom
		controller % AircraftController

		commandAlt = 0; % [m] commanded altitude
		commandHdg = 0; % [rad] commanded heading

		time = 0; % [s]

		data % contains states, etc of past simulation times
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

		function as = update(as, timeStep)
			% units
			units = loadUnits();
			% transformation matrices
			AC_LONG_2_XYZ = [cos(as.state.gamma), (sin(as.state.gamma) * sin(as.state.phi)), (sin(as.state.gamma) * cos(as.state.phi))];
			AC_VERT_2_XYZ = [-sin(as.state.gamma), (cos(as.state.gamma) * sin(as.state.phi)), (cos(as.state.gamma) * cos(as.state.phi))];
			XYZ_2_NEU = [cos(as.state.hdg), sin(as.state.hdg), 0; -sin(as.state.hdg), cos(as.state.hdg), 0; 0, 0, 1];

			%% Control loops
			% PD altitude control (controls lift multiplier)
			altErr = as.state.pos(3) - as.commandAlt;
			dAltErr = as.state.vel(3);
			as.geom.liftMult = as.controller.controlAlt(altErr, dAltErr, as.geom.liftMult);

			% PD heading control (controls aircraft roll)
			hdgErr = as.state.calcHdgDiff(as.commandHdg);
			dHdgErr = as.state.calcHdgDiff(as.data.state(end).hdg) / timeStep;
			as.state.phi = as.controller.controlHdg(hdgErr, dHdgErr, as.state.phi);

			%% Fly the aircraft
			% update current state variables
			as.time = as.time + timeStep;

			T_xyz = as.geom.calcThrust(as.state.v_inf, 1) .* AC_LONG_2_XYZ; % [T_x T_y T_z]
			L_xyz = as.geom.calcLift(as.state.q_inf) .* AC_VERT_2_XYZ; % [L_x L_y L_z]
			D_xyz = -as.geom.calcDrag(as.state.q_inf) .* AC_LONG_2_XYZ; % [D_x D_y D_z]
			W_xyz = [0, 0, -(as.geom.mass * units.KG_2_N)]; % [W_x W_y W_z]

			F_xyz = T_xyz + L_xyz + D_xyz + W_xyz;
			F_neu = F_xyz * XYZ_2_NEU;

			as.state.acc = F_neu ./ as.geom.mass;
			as.state = as.state.update(timeStep);

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