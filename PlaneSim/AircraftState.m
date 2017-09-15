classdef AircraftState
	properties
		pos = [0 0 0] % [m m m] northing pos, easting pos, altitude AGL
		vel = [0 0 0] % [m/s m/s m/s] northing vel, easting vel, vertical speed
		
		% TODO: add battery capacity
	end
	methods  
		function as = AircraftState(pos, vel)
			as.pos = pos;
			as.vel = vel;
		end
		function v_inf = calcv_inf(as)
			% TODO: account for wind
			v_inf = sum(as.vel .* [1 1 0] .^ 2); % freestream velocity in XY (NE) plane
		end
		function as = update(as, timeStep)
			as.pos = as.pos + (as.vel .* timeStep);
		end
	end
end