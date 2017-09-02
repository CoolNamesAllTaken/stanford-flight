classdef AeroSurface
	properties
		b = 0; % [m] span
		S = 0; % [m^2] reference area
		C_L = 0; % coefficient of lift
		C_D = 0; % coefficient of drag
		e = 0.7; % efficiency factor (1 for an ellipse, 0.8-0.9 for a normal 
	end
	methods
		function as = AeroSurface(b, S, C_L, C_D, e)
		% as = AeroSurface(b, S, C_L, C_D, e) creates a new AeroSurface object as, which represents a wing
		% or horizontal stabilizer on an aircraft.
		%	b = [m] span
		%	S = [m^2] reference area
		%	C_L = coefficient of lift
		%	C_D = coefficient of drag
		%	e = efficiency factor (1 for an ellipse, 0.8-0.9 for a normal
			as.b = b;
			as.S = S;
			as.C_L = C_L;
			as.C_D = C_D;
			as.e = e;
		end
		function D = calcDrag(as, q_inf)
			D = q_inf .* as.S .* as.C_D;
		end
		function L = calcLift(as, q_inf)
			L = q_inf .* as.S .* as.C_L;
		end
		function AR = calcAR(as)
		% Calculates aspect ratio
			AR = as.b.^2 ./ as.S;
		end
	end
end