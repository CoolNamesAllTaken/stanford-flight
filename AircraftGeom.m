classdef AircraftGeom
	properties
		name = '';

		wing.b = 0; % wing span
		wing.S = 0; % wing reference area
		wing.C_L = 0; % wing coefficient of lift
		wing.e = 0.85; % wing efficiency factor (1 for an ellipse, 0.8-0.9 for a normal wing)

		tail.b = 0; % tail span
		tail.S = 0; % tail reference area
		tail.C_L = 0; % tail coefficient of lift
		wing.e = 1; % wing efficiency factor
	end
	methods
		function AircraftGeom(nameIn)
			name = nameIn;
		end
		function L = calcLift(q_inf)
			% wing lift
			L_wing = q_inf .* wing.S .* wing.C_L;

			% tail lift
			L_tail = q_inf .* tail.S .* tail.C_L;

			L = (2 .* L_wing) + (2 .* L_tail); % full span lift
		end
		function D = calcDrag(q_inf)
			D_wing = q_inf .* wing.S .* wing.C_D;

			D_tail = q_inf .* tail.S .* tail.C_D;
		end
		function C_D = calcC_D(C_L, AR, e)
		% Calculates the finite wing coefficient of drag
		% Inputs
		%	C_L = lift coefficient
		%	AR = aspect ratio
		%	e = efficiency factor (e = 1 for an ellipse, in general e < 1)
			C_D = C_L.^2 ./ (pi .* AR .* e);
		end
		function AR = calcAR(b, S)
		% Calculates aspect ratio
		% Inputs
		%	b = span (fuselage centerline to wingtip)
		%	S = reference area
			AR = b.^2 ./ s;
		end
	end
end