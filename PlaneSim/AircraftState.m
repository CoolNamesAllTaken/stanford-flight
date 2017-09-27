classdef AircraftState
	properties
		pos = [0 0 0]; % [m m m] northing pos, easting pos, altitude AGL
		vel = [0 0 0]; % [m/s m/s m/s] northing vel, easting vel, vertical speed
		acc = [0 0 0]; % [m/s^2 m/s^2 m/s^2] northing, easting, vertical accelerations

		rho = 1.1; % [kg/m^3] air density, default value is kansas-ish
		% TODO: add battery capacity
	end
	methods  
		function as = AircraftState(pos, vel, acc, rho)
			if (nargin == 4)
				as.pos = pos;
				as.vel = vel;
				as.acc = acc;
				as.rho = rho;
			end
		end
		function v_inf = calcv_inf(as)
			% TODO: account for wind
			v_inf = sqrt(sum(as.vel .^ 2));
		end
		function q_inf = calcq_inf(as)
			v_inf = as.calcv_inf();
			q_inf = 0.5 .* as.rho .* (v_inf .^ 2);
		end
		function gamma = calcgamma(as)
		% gamma = calcgamma(as) calculates the flight path angle of the aircraft relative to the inertial frame, in radians
			vel_x = sqrt(as.vel(1) .^ 2 + as.vel(2) .^ 2);
			vel_z = as.vel(3);

			if (vel_x > 0)
				% avoid dividing by 0 when aircraft is at rest
				gamma =  atan(vel_z ./ vel_x);
			else
				% assume flight path angle is 0 radians if aircraft is not translating horizontally
				gamma = 0;
			end
		end
		function as = update(as, timeStep)
			as.pos = as.pos + (as.vel .* timeStep);
			as.vel = as.vel + (as.acc .* timeStep);
		end
	end
end