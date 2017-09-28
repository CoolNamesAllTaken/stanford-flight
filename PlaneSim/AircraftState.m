classdef AircraftState
	properties
		pos = [0 0 0]; % [m m m] northing pos, easting pos, altitude AGL
		vel = [0 0 0]; % [m/s m/s m/s] northing vel, easting vel, vertical speed
		acc = [0 0 0]; % [m/s^2 m/s^2 m/s^2] northing, easting, vertical accelerations

		phi = 0; % [rad] roll angle

		rho = 1.1; % [kg/m^3] air density, default value is kansas-ish
		% TODO: add battery capacity
	end
	properties (Dependent)
		v_inf % [m/s] freestream velocity
		q_inf % [kg / m * s^2]
		gamma % [rad] flight path angle
		hdg % [rad] compass heading
	end
	methods  
		function as = AircraftState(pos, vel, acc)
			if (nargin == 3)
				as.pos = pos;
				as.vel = vel;
				as.acc = acc;
			end
		end

		function v_inf = get.v_inf(as)
			% TODO: account for wind
			v_inf = sqrt(sum(as.vel .^ 2));
		end
		function q_inf = get.q_inf(as)
			v_inf = as.v_inf;
			q_inf = 0.5 * as.rho * (v_inf^2);
		end
		function gamma = get.gamma(as)
		% gamma = as.gamma calculates the flight path angle of the aircraft relative to the inertial frame, in radians
			vel_x = sqrt(as.vel(1)^2 + as.vel(2)^2);
			vel_z = as.vel(3);

			if (vel_x > 0)
				% avoid dividing by 0 when aircraft is at rest
				gamma =  atan(vel_z / vel_x);
			else
				% assume flight path angle is 0 radians if aircraft is not translating horizontally
				gamma = 0;
			end
		end
		function hdg = get.hdg(as)
			hdg = 3 * pi / 2;
			if (as.vel(2) == 0)
				% moving directly north or south
				if (as.vel(1) > 0)
					hdg = 0; % north
				else
					hdg = pi; % south
				end
			elseif (as.vel(2) > 0)
				% moving east-ish, pi-2pi
				hdg = 3*pi/2 + atan(as.vel(1) / as.vel(2));
			else
				% moving west-ish, 0-pi
				hdg = pi/2 + atan(as.vel(1) / as.vel(2));
			end
		end

		function as = update(as, timeStep)
			as.pos = as.pos + (as.vel .* timeStep);
			as.vel = as.vel + (as.acc .* timeStep);
		end
		function hdgDiff = calcHdgDiff(as, hdg)
			if (hdg < 0 || hdg > 2 * pi)
				error(['Heading ' num2str(hdg) ' is out of range.']);
			end
			hdgDiff = hdg - as.hdg;
			if (hdgDiff > pi)
				hdgDiff = (2 * pi) - hdgDiff;
			elseif (hdgDiff < -pi)
				hdgDiff = (-2 * pi) - hdgDiff;
			end
		end
	end
end