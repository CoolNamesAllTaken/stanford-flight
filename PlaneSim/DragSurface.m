classdef DragSurface
	properties
		S % [m^2] reference area
		C_D0 % zero-lift coefficient of drag
	end
	methods
		function dsurf = DragSurface(C_D0)
			dsurf.C_D0 = C_D0;
		end
		function D = calcDrag(dsurf, q_inf)
			D = q_inf .* dsurf.S .* dsurf.C_D0;
		end
	end
end