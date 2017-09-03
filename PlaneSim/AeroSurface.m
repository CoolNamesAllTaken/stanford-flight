classdef AeroSurface
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
		function as = AeroSurface(b, S, C_L, C_D0, e)
		% as = AeroSurface(b, S, C_L, C_D0, e) creates a new AeroSurface object as, which represents a wing
		% or horizontal stabilizer on an aircraft.
		%	b = [m] span
		%	S = [m^2] reference area
		%	C_L = coefficient of lift
		%	C_D0 = coefficient of drag at 0 lift
		%	e = efficiency factor (1 for an ellipse, 0.8-0.9 for most aircraft)
			as.b = b;
			as.S = S;
			as.C_L = C_L;
			as.C_D0 = C_D0;
			as.e = e;
		end

		function AR = get.AR(as)
		% as.AR calculates and returns the dependent variable for Aspect Ratio; AR updates with as.b and as.S
			AR = as.b.^2 ./ as.S; % calculate and store aspect ratio
		end

		function D = calcDrag(as, q_inf)
		% as.calcDrag(q_inf) calculates the total drag produced by and AeroSurface as at the dunamic pressure q_inf
			D = q_inf .* as.S .* as.calcC_D(q_inf);
		end
		function L = calcLift(as, q_inf)
		% as.calcLift(q_inf) calculates the total lift produced by an AeroSurface as at the dynamic pressure q_inf
			L = q_inf .* as.S .* as.C_L;
		end

		function C_D = calcC_D(as, q_inf)
		% as.calcC_D(q_inf) calculates the total drag coefficient of an AeroSurface at the dynamic pressure q_inf
			% C_D = C_D0 + C_Di + C_Dwave, ignore wave drag for model aircraft speeds
			C_D = as.C_D0 + as.calcC_Di(q_inf);
		end

		function C_Di = calcC_Di(as, q_inf)
		% as.calcC_Di(q_inf) calculates the induced drag coefficient of an AeroSurface as at the dynamic pressure q_inf
			C_Di = as.C_L.^2 ./ (pi .* as.e * as.AR);
		end
	end
end