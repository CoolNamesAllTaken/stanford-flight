classdef AircraftGeom
	properties
		name = '';
		mass = 0; % [kg] mass of aircraft (AUW)

		aeroSurfaces = {};
		motors = {};
	end
	methods  
		function ag = AircraftGeom(name, aeroSurfaces, motors)
			ag.name = name;
			ag.aeroSurfaces = aeroSurfaces;
			ag.motors = motors
		end
		function L = calcLift(ag, q_inf)
			L = 0;
			for i = 1:length(aeroSurfaces)
				L = L + aeroSurfaces{i}.calcLift(q_inf);
			end
		end
		function D = calcDrag(ag, q_inf)
			D = 0;
			for i = 1:length(aeroSurfaces)
				D = D + aeroSurfaces{i}.calcDrag(q_inf);
			end
		end
		function T = calcThrust(ag, v_inf, throttle)
			T = 0;
			for i = 1:length(motors)
				T = T + motors{i}.calcThrust(v_inf, throttle);
			end
		end
		function ret = calcPropulsion(ag, v_inf)
			ret = [0 0] % [T battPower], measured in [kg] and [W]
			for i = 1:length(motors)
				ret = ret + motors{i}.calcPropulsion(v_inf, throttle);
			end
		end
	end
end