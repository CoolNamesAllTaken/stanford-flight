classdef AircraftSim
	properties
		state % AircraftState
		geom % AircraftGeom

		time = 0; % [s]

		data
	end
	methods  
		function as = AircraftSim(state, geom)
			as.state = state;
			as.geom = geom;

			as.data.time = [];
			as.data.state = [];
			as.data.v_inf = [];
			as.data.thrust = [];
			as.data.L = [];
			as.data.F_xyz = [];
		end

		function as = update(as, timeStep)
			% units
			units = loadUnits();

			% transformation matrices
			AC_LONG_2_XYZ = [cos(as.state.gamma), (sin(as.state.gamma) * sin(as.state.phi)), (sin(as.state.gamma) * cos(as.state.phi))];
			AC_VERT_2_XYZ = [-sin(as.state.gamma), (cos(as.state.gamma) * sin(as.state.phi)), (cos(as.state.gamma) * cos(as.state.phi))];
			XYZ_2_NEU = [cos(as.state.hdg), sin(as.state.hdg), 0; -sin(as.state.hdg), cos(as.state.hdg), 0; 0, 0, 1];

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

			% record data
			as.data.time = vertcat(as.data.time, as.time);
			as.data.state = vertcat(as.data.state, as.state);
			as.data.v_inf = vertcat(as.data.v_inf, as.state.v_inf);
			as.data.thrust = vertcat(as.data.thrust, sqrt(sum(T_xyz.^2)));
			as.data.L = vertcat(as.data.L, sqrt(sum(L_xyz.^2)));
			as.data.F_xyz = vertcat(as.data.F_xyz, F_xyz);
		end
	end
end