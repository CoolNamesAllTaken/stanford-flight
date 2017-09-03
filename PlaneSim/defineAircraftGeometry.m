function geom = defineAircraftGeometry(aircraftName)
	if (strcmpi(aircraftName, 'dbf16'))
		wing_b = 2;
		wing_S = 0.26;
		wing_C_L = 0.4; % cruise C_L
		wing_C_D0 = 0.01; % zero lift C_D
		wing_e = 0.7; % rectangular wing efficiency factor
		wing = AeroSurface(wing_b, wing_S, wing_C_L, wing_C_D0, wing_e);

		ag = AircraftGeom('hallo');
	end
end