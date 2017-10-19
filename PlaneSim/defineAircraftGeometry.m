function geom = defineAircraftGeometry(aircraftName)
	units = loadUnits();

	if (strcmpi(aircraftName, 'LittlePucker'))
		mass = 1.97; % [kg]

		% cruise conditions
		v_inf = 13.06; % [m/s]
		rho = 1.1; % [kg/m^2] kansas-ish
		q_inf = 0.5 .* rho .* v_inf^2;

		wing1_b = 1.27;
		wing1_S = 0.18;
		wing1_C_Lmax = 1.15; % max C_L
		wing1_C_D0 = 0.02; % zero lift C_D
		wing1_e = 0.7; % rectangular wing efficiency factor
		wing1 = LiftSurface(wing1_b, wing1_S, wing1_C_Lmax, wing1_C_D0, wing1_e);
		wing2 = LiftSurface(wing1_b, wing1_S, wing1_C_Lmax, wing1_C_D0, wing1_e);
		liftSurfaces = {wing1, wing2};

		fuse_C_D = 2.1; % rectangular box
		fuse_A = 0.0075; %[m^2] frontal area
		fuse = DragSurface(fuse_A, fuse_C_D);
		dragSurfaces = {fuse};

		motor_v_inf = [0.0 21.03 26.11]; % [m/s] static, cruise
		motor_T = [1.204 0.239 0]; % [kg] static, cruise
		motor_e_prop = [0.0048 0.00307 0]; % [kg/W] static, cruise
		motor_e_motor = 0.795; % static and cruise
		battVoltage = 14; % [V] loaded voltage
		motor = Motor(motor_v_inf, motor_T, motor_e_prop, motor_e_motor, battVoltage);

		geom = AircraftGeom('Little Pucker', mass, liftSurfaces, dragSurfaces, {motor});
	elseif(strcmpi(aircraftName, 'LittlePucker-Empty'))
		mass = 1.00; % [kg]

		% cruise conditions
		v_inf = 13.06; % [m/s]
		rho = 1.1; % [kg/m^2] kansas-ish
		q_inf = 0.5 .* rho .* v_inf^2;

		wing1_b = 1.27;
		wing1_S = 0.18;
		wing1_C_Lmax = 1.15; % max C_L
		wing1_C_D0 = 0.02; % zero lift C_D
		wing1_e = 0.7; % rectangular wing efficiency factor
		wing1 = LiftSurface(wing1_b, wing1_S, wing1_C_Lmax, wing1_C_D0, wing1_e);
		wing2 = LiftSurface(wing1_b, wing1_S, wing1_C_Lmax, wing1_C_D0, wing1_e);
		liftSurfaces = {wing1, wing2};

		fuse_C_D = 2.1; % rectangular box
		fuse_A = 0.0075; %[m^2] frontal area
		fuse = DragSurface(fuse_A, fuse_C_D);
		dragSurfaces = {fuse};

		motor_v_inf = [0.0 21.03 26.11]; % [m/s] static, cruise
		motor_T = [1.204 0.239 0]; % [kg] static, cruise
		motor_e_prop = [0.0048 0.00307 0]; % [kg/W] static, cruise
		motor_e_motor = 0.795; % static and cruise
		battVoltage = 14; % [V] loaded voltage
		motor = Motor(motor_v_inf, motor_T, motor_e_prop, motor_e_motor, battVoltage);

		geom = AircraftGeom('Little Pucker Empty', mass, liftSurfaces, dragSurfaces, {motor});
	elseif(~isempty(strfind(aircraftName, 'DBF18')))
		% 'DBF18-5-empty' is 5 passenger aircraft, empty
		dashIndices = strfind(aircraftName, '-');
		numPax = str2num(aircraftName(dashIndices(1)+1:dashIndices(2)-1));
		loadedStr = aircraftName(dashIndices(2)+1:end);
		loaded = strcmpi(loadedStr, 'full');

		% estimate fuselage structural weight
		passengerConfiguration = [32 32 49 49]; %passengers in the row
		numBatts = round(1.6 * numPax); % approximated from 116 batts : 70 pax estimate
		inchToMiliConversion = 25.4;
		areaDensityFoam = 110/(20*29.5*(inchToMiliConversion^2)); % g/mm^2  20x29.5in 110g 
		areaDensity = areaDensityFoam*1.5; %reinforced
		[emptyFuselageMass, passengerLoadedMass, fuselageLength, fuselageWidth, fuselageHeight] = ...
		ballParkEstimate(numPax, passengerConfiguration, numBatts, areaDensity);
    
		% propulsion system estimate
		propEst = propulsionEstimate(passengerLoadedMass * units.G_2_KG);
		maxMass = propEst.propulsionMass + passengerLoadedMass * units.G_2_KG;
		motor = Motor(propEst.motor_v_inf, propEst.motor_T, propEst.motor_e_prop, propEst.motor_e_motor, propEst.battVoltage);
		
		motors = cell(propEst.numMotors, 1);
		motors(:) = {motor};

		% cruise conditions
		v_inf = 25; % [m/s]
		rho = 1.1; % [kg/m^2] kansas-ish
		q_inf = 0.5 .* rho .* v_inf^2;

		[wing_b, wing_S] = aeroEstimate(maxMass, v_inf);
		wing_C_Lmax = 1.8; % max C_L
		wing_C_D0 = 0.02; % zero lift C_D TODO: get from XFLR5?
		wing_e = 0.9; % oswald efficiency factor TODO: get from XFLR5?
		wing = LiftSurface(wing_b, wing_S, wing_C_Lmax, wing_C_D0, wing_e);
		liftSurfaces = {wing};

		fuse_C_D = 2.1; % rectangular box
		fuse_A = fuselageHeight * units.MM_2_M * fuselageWidth * units.MM_2_M; %[m^2] frontal area
		fuse = DragSurface(fuse_A, fuse_C_D);
		dragSurfaces = {fuse};

		if (loaded)
            mass = maxMass;
        else
			mass = (emptyFuselageMass * units.G_2_KG) + propEst.propulsionMass;
        end
        fprintf('Max Mass: %.2f Current Mass: %.2f', maxMass, mass);
		geom = AircraftGeom(['DBF18 ' num2str(numPax) ' ' loadedStr], mass, liftSurfaces, dragSurfaces, motors)
	end
end
