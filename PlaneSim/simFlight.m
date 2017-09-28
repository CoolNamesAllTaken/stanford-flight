aircraftName = 'LittlePucker'

units = loadUnits();

TIME_STEP = 0.1; % [s] time between updates
NUM_STEPS = 500;

geom = defineAircraftGeometry(aircraftName);

CRUISE_ALT = 20; % [m]
CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
RHO = 1.1; % [kg/m^3], kansas-ish

PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line
PHI_MAX = geom.calcphi_max(0.5 * RHO * CRUISE_V_INF^2); % [rad], limit to 60 degree bank

% control loop gains
P_alt = 0.1;
D_alt = 0.3;
P_hdg = 0.5;
D_hdg = 0.5;

state = AircraftState();
state.rho = RHO;
state.vel = [0 10 0]; % start aircraft rolling down runway (heading established)

sim = AircraftSim(state, geom);

currStage = 0; % 0 = takeoff; 1 = pylon #1a; 1.5 = pylon #1b; 2, 2.5 = 360 turn; 3 = pylon #2a; 3.5 = pylon #2b

commandAlt = CRUISE_ALT;
commandHdg = pi/2;
oldHdg = commandHdg;

for (i=1:NUM_STEPS)
	config = [];

	% command loop
	if (currStage == 0)
		commandHdg = pi/2;
		currStage = 1;
	elseif (currStage == 1 && sim.state.pos(2) > PYLON_DIST)
		commandHdg = 0;
		currStage = 1.5;
	elseif (currStage == 1.5)
		commandHdg = 3 * pi/2;
		currStage = 2;
	elseif (currStage == 2 && sim.state.pos(2) < 0)
		commandHdg = 0;
		currStage = 2.25;
	elseif (currStage == 2.25)
		commandHdg = pi/2;
		currStage == 2.5;
	elseif (currStage == 2.5)
		commandHdg = pi;
		currStage == 2.75
	elseif (currStage == 2.75)
		commandHdg = 3 * pi/2;
		currStage == 2.9;
	elseif (currStage == 2.9)
		commandHdg = 0;
		currStage = 3;
	elseif (currStage == 3 && sim.state.pos(2) < -PYLON_DIST)
		commandHdg = pi;
		currStage = 2.5;
	elseif (currStage == 3.5)
		commandHdg = pi/2
	end
	% if (sim.state.pos(2) > PYLON_DIST)
	% 	commandHdg = 3 * pi/2;
	% end

	% PD altitude control loop
	altErr = sim.state.pos(3) - commandAlt;
	dAltErr = sim.state.vel(3);
	response = altErr * P_alt + dAltErr * D_alt;

	liftMult = sim.geom.liftMult - response;
	if (liftMult > 1) liftMult = 1;
	elseif (liftMult < 0) liftMult = 0; end
	sim.geom.liftMult = liftMult;

	% PD heading control loop
	hdgErr = sim.state.calcHdgDiff(commandHdg)
	dHdgErr = sim.state.calcHdgDiff(oldHdg) / TIME_STEP;
	oldHdg = sim.state.hdg;
	response = hdgErr * P_hdg + dHdgErr * D_hdg;

	phi = sim.state.phi + response;
	if (phi > PHI_MAX) phi = PHI_MAX;
	elseif (phi < -PHI_MAX) phi = -PHI_MAX; end
	sim.state.phi = phi;

	sim = sim.update(TIME_STEP);
end

plotData(sim.data);
