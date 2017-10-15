classdef DragSurface
	properties
		S % [m^2] reference area
		C_D % coefficient of drag
	end
	methods
		function dsurf = DragSurface(S, C_D)
			dsurf.S = S;
			dsurf.C_D = C_D;
		end
		function D = calcDrag(dsurf, q_inf)
			D = q_inf .* dsurf.S .* dsurf.C_D;
		end
	end
end