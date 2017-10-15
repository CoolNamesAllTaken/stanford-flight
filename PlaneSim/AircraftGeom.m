classdef AircraftGeom
	properties
		name = '';
		mass = 0; % [kg] mass of aircraft (AUW)

		liftMult = 1;
		liftSurfaces = {};
		dragSurfaces = {};
		motors = {};
	end
	methods  
		function ag = AircraftGeom(name, mass, liftSurfaces, dragSurfaces, motors)
			ag.name = name;
			ag.mass = mass;
			ag.liftSurfaces = liftSurfaces;
			ag.dragSurfaces = dragSurfaces;
			ag.motors = motors;
		end

		function ag = set.liftMult(ag, liftMult)
			for i = 1:length(ag.liftSurfaces)
				ag.liftSurfaces{i}.mult = liftMult;
			end
			ag.liftMult = liftMult;
		end

		function L = calcLift(ag, q_inf)
			L = 0;
			for i = 1:length(ag.liftSurfaces)
				L = L + ag.liftSurfaces{i}.calcLift(q_inf);
			end
		end
		function D = calcDrag(ag, q_inf)
			D = 0;
			for i = 1:length(ag.liftSurfaces)
				D = D + ag.liftSurfaces{i}.calcDrag(q_inf);
			end
			for i = 1:length(ag.dragSurfaces)
				D = D + ag.dragSurfaces{i}.calcDrag(q_inf);
			end
		end
		function T = calcThrust(ag, v_inf, throttle)
			units = loadUnits();
			T = 0;
			for i = 1:length(ag.motors)
				T = T + (ag.motors{i}.calcThrust(v_inf, throttle) .* units.KG_2_N);
			end
		end
		function ret = calcPropulsion(ag, v_inf, throttle)
			units = loadUnits();
			ret = [0 0]; % [T, battPower], measured in [N] and [W]
			for i = 1:length(ag.motors)
				ret = ret + (ag.motors{i}.calcPropulsion(v_inf, throttle) .* [units.KG_2_N 1]);
			end
			ret(end + 1) = ag.motors{1}.battVoltage; % [T, battPower, battVoltage]
		end
		function phi_max = calcphi_max(ag, q_inf)
			% returns the maximum bank angle [rad] that could result in level flight at q_inf (assuming C_Lmax)
			units = loadUnits();

			liftMult = ag.liftMult;
			ag.liftMult = 1; % set liftmult to 1 to calculate max lift (only modifies copy of ag)
			L_max = ag.calcLift(q_inf);
			W = ag.mass .* units.KG_2_N;
			phi_max = acos(W / L_max);
		end
	end
end