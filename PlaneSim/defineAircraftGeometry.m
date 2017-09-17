function geom = defineAircraftGeometry(aircraftName)
	units = loadUnits();

	if (strcmpi(aircraftName, 'LittlePuckerCruise'))
		mass = 1.97; % [kg]

		% cruise conditions
		v_inf = 13.06; % [m/s]
		rho = 1.1; % [kg/m^2] kansas-ish
		q_inf = 0.5 .* rho .* v_inf^2;

		wing1_b = 1.27;
		wing1_S = 0.18;
		wing1_C_Lc = mass .* units.KG_2_N ./ q_inf ./ wing1_S ./ 2; % cruise C_L, assume weight dist. between fwd and aft wing
		wing1_C_D0 = 0.02; % zero lift C_D
		wing1_e = 0.7; % rectangular wing efficiency factor
		wing1 = LiftSurface(wing1_b, wing1_S, wing1_C_Lc, wing1_C_D0, wing1_e);
		wing2 = LiftSurface(wing1_b, wing1_S, wing1_C_Lc, wing1_C_D0, wing1_e);
		liftSurfaces = {wing1, wing2};

		dragSurfaces = {};

		motor_v_inf = [0 13.06]; % [m/s] static, cruise
		motor_T = [1.204 0.239]; % [N] static, cruise
		motor_e_prop = [0.0048 0.00307]; % [kg/W] static, cruise
		motor_e_motor = 0.795; % static and cruise
		motor = Motor(motor_v_inf, motor_T, motor_e_prop, motor_e_motor);

		geom = AircraftGeom('Little Pucker', mass, liftSurfaces, dragSurfaces, {motor});
	elseif (strcmpi(aircraftName, 'LittlePuckerTakeoff'))
		mass = 1.97; % [kg]

		wing1_b = 1.27;
		wing1_S = 0.18;
		wing1_C_Lmax = 1.15; % takeoff condition; wing C_Lmax
		wing1_C_D0 = 0.02; % zero lift C_D
		wing1_e = 0.7; % rectangular wing efficiency factor
		wing1 = LiftSurface(wing1_b, wing1_S, wing1_C_Lmax, wing1_C_D0, wing1_e);
		wing2 = LiftSurface(wing1_b, wing1_S, wing1_C_Lmax, wing1_C_D0, wing1_e);
		liftSurfaces = {wing1, wing2};

		dragSurfaces = {};

		motor_v_inf = [0 13.06]; % [m/s] static, cruise
		motor_T = [1.204 0.239]; % [N] static, cruise
		motor_e_prop = [0.0048 0.00307]; % [kg/W] static, cruise
		motor_e_motor = 0.795; % static and cruise
		motor = Motor(motor_v_inf, motor_T, motor_e_prop, motor_e_motor);

		geom = AircraftGeom('Little Pucker', mass, liftSurfaces, dragSurfaces, {motor});
	end
end