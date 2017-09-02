classdef AircraftGeom
	properties
		name = '';

		aeroSurfaces = {};
	end
	methods  
		function ag = AircraftGeom(name, aeroSurfaces)
			ag.name = name;
			ag.aeroSurfaces = aeroSurfaces;
		end
		function L = calcLift(ag, q_inf)
			L = sum(aeroSurfaces.calcLift);
		end
		function D = calcDrag(ag, q_inf)
			D = sum(aeroSurfaces.calcDrag);
		end	
	end
end