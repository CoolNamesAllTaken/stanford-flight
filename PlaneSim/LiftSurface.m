classdef LiftSurface
	properties
		b % [m] span
		S % [m^2] reference area
		C_L % coefficient of lift
		C_D0 % coefficient of drag at zero lift
		e % efficiency factor (1 for an ellipse, 0.8-0.9 for most aircraft)
	end
	properties (Dependent)
		AR % aspect ratio, dependent on b and S
	end
	methods
		function lsurf = LiftSurface(b, S, C_L, C_D0, e)
		% lsurf = LiftSurface(b, S, C_L, C_D0, e) creates a new LiftSurface object lsurf, which represents a wing
		% or lift-generating horizontal stabilizer on an aircraft.
		%	b = [m] span
		%	S = [m^2] reference area
		%	C_L = coefficient of lift
		%	C_D0 = coefficient of drag at 0 lift
		%	e = efficiency factor (1 for an ellipse, 0.8-0.9 for most aircraft)
			lsurf.b = b;
			lsurf.S = S;
			lsurf.C_L = C_L;
			lsurf.C_D0 = C_D0;
			lsurf.e = e;
		end

		function AR = get.AR(lsurf)
		% lsurf.AR calculates and returns the dependent variable for Aspect Ratio; AR updates with lsurf.b and lsurf.S
			AR = lsurf.b.^2 ./ lsurf.S; % calculate and store aspect ratio
		end

		function D = calcDrag(lsurf, q_inf)
		% lsurf.calcDrag(q_inf) calculates the total drag produced by and LiftSurface lsurf at the dunamic pressure q_inf
			D = q_inf .* lsurf.S .* lsurf.calcC_D(q_inf);
		end
		function L = calcLift(lsurf, q_inf)
		% lsurf.calcLift(q_inf) calculates the total lift produced by an LiftSurface lsurf at the dynamic pressure q_inf
			L = q_inf .* lsurf.S .* lsurf.C_L;
		end
		function C_D = calcC_D(lsurf, q_inf)
		% lsurf.calcC_D(q_inf) calculates the total drag coefficient of an LiftSurface at the dynamic pressure q_inf
			% C_D = C_D0 + C_Di + C_Dwave, ignore wave drag for model aircraft speeds
			C_D = lsurf.C_D0 + lsurf.calcC_Di(q_inf);
		end
		function C_Di = calcC_Di(lsurf, q_inf)
		% lsurf.calcC_Di(q_inf) calculates the induced drag coefficient of an LiftSurface lsurf at the dynamic pressure q_inf
			C_Di = lsurf.C_L.^2 ./ (pi .* lsurf.e * lsurf.AR);
		end
	end
end