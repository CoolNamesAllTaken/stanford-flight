function aeroSurfaceTest
	a = AeroSurface(40, 100, 1.2, 0.3, 0.85)

	% dynamic pressure
	AIR_DENSITY = 1.043; % [kg/m^3] air density in wichita, ks, when it's 78 degrees, 
		% rel. humidity 52%, 30.01" Hg, 3315.61 ft density alt
	AIRSPEED = 22; % [m/s]
	q_inf = 0.5 * AIR_DENSITY * AIRSPEED^2 % dynamic pressure = 1/2 rho v^2

	a.calcDrag(q_inf)
	a.calcLift(q_inf)
	a.calcAR()
end