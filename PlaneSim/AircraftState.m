classdef AircraftState
	properties
		pos = [0 0 0] % [m m m] northing pos, easting pos, altitude AGL
		vel = [0 0 0] % [m/s m/s m/s] northing vel, easting vel, vertical speed
		
		% TODO: add battery capacity
	end
	methods  
		function as = AircraftState(pos, vel)
			if (nargin == 2)
				as.pos = pos;
				as.vel = vel;
			end
		end
		function v_inf = calcv_inf(as)
			% TODO: account for wind
			v_inf = sqrt(sum(as.vel .^ 2)); % freestream velocity in combines XY vel with ascent rate
		end
		function as = update(as, timeStep)
			as.pos = as.pos + (as.vel .* timeStep);
		end
	end
end