aircraftName = 'LittlePucker'

TIME_STEP = 0.1; % [s] time between updates
NUM_STEPS = 500;

geom = defineAircraftGeometry(aircraftName);

CRUISE_ALT = 20; % [m]
CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
RHO = 1.1; % [kg/m^3], kansas-ish

COURSE_EDGE = 100; % [m] first pylon distance, fudged
PHI_MAX = geom.calcphi_max(0.5 * RHO * CRUISE_V_INF^2); % [rad], limit to 60 degree bank

% control loop gains
P_alt = 0.05;
D_alt = 0.1;
P_hdg = 0.5;
D_hdg = 0.5;

state = AircraftState();
state.rho = RHO;
state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

sim = AircraftSim(state, geom);

commandAlt = CRUISE_ALT;
commandHdg = 3 * pi/2;
oldHdg = commandHdg;

for (i=1:NUM_STEPS)
	config = [];

	% command loop
	if (sim.state.pos(2) > COURSE_EDGE)
		commandHdg = pi/2;
	end
	if (sim.state.pos(2) < -COURSE_EDGE)
		commandHdg = 3 * pi/2;
	end

	% PD altitude control loop
	altErr = sim.state.pos(3) - commandAlt;
	dAltErr = sim.state.vel(3);
	response = altErr * P_alt + dAltErr * D_alt;

	liftMult = sim.geom.liftMult - response;
	if (liftMult > 1) liftMult = 1;
	elseif (liftMult < 0) liftMult = 0; end
	sim.geom.liftMult = liftMult;

	% PD heading control loop
	hdgErr = sim.state.calcHdgDiff(commandHdg);
	dHdgErr = sim.state.calcHdgDiff(oldHdg) / TIME_STEP;
	oldHdg = sim.state.hdg;
	response = hdgErr * P_hdg + dHdgErr * D_hdg;

	phi = sim.state.phi - response;
	if (phi > PHI_MAX) phi = PHI_MAX;
	elseif (phi < -PHI_MAX) phi = -PHI_MAX; end
	sim.state.phi = phi;

	sim = sim.update(TIME_STEP);
end

plotData2(sim.data);
