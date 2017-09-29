aircraftName = 'LittlePucker'

units = loadUnits();

TIME_STEP = 0.1; % [s] time between updates
NUM_STEPS = 500;

CRUISE_ALT = 20; % [m]
CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
RHO = 1.1; % [kg/m^3], kansas-ish

PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line

% control loop gains
P_alt = 0.1;
D_alt = 0.3;
P_hdg = 0.5;
D_hdg = 0.5;

geom = defineAircraftGeometry(aircraftName);

state = AircraftState();
state.rho = RHO;
state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

controller = AircraftController(P_alt, D_alt, P_hdg, D_hdg);
controller.PHI_MAX = geom.calcphi_max(0.5 * RHO * CRUISE_V_INF^2);

sim = AircraftSim(state, geom, controller);
sim.commandAlt = CRUISE_ALT;
sim.commandHdg = pi/2;

currStage = 0; % 0 = takeoff; 1 = pylon #1a; 1.5 = pylon #1b; 2, 2.5 = 360 turn; 3 = pylon #2a; 3.5 = pylon #2b

for (i=1:NUM_STEPS)
	config = [];

	% command loop
	sim.commandHdg = sim.state.calcHdgToPos([0, PYLON_DIST])
	% if (currStage == 0)
	% 	commandHdg = pi/2;
	% 	currStage = 1;
	% elseif (currStage == 1 && sim.state.pos(2) > PYLON_DIST)
	% 	commandHdg = 0;
	% 	currStage = 1.5;
	% elseif (currStage == 1.5)
	% 	commandHdg = 3 * pi/2;
	% 	currStage = 2;
	% elseif (currStage == 2 && sim.state.pos(2) < 0)
	% 	commandHdg = 0;
	% 	currStage = 2.25;
	% elseif (currStage == 2.25)
	% 	commandHdg = pi/2;
	% 	currStage == 2.5;
	% elseif (currStage == 2.5)
	% 	commandHdg = pi;
	% 	currStage == 2.75
	% elseif (currStage == 2.75)
	% 	commandHdg = 3 * pi/2;
	% 	currStage == 2.9;
	% elseif (currStage == 2.9)
	% 	commandHdg = 0;
	% 	currStage = 3;
	% elseif (currStage == 3 && sim.state.pos(2) < -PYLON_DIST)
	% 	commandHdg = pi;
	% 	currStage = 2.5;
	% elseif (currStage == 3.5)
	% 	commandHdg = pi/2
	% end
	% if (sim.state.pos(2) > PYLON_DIST)
	% 	commandHdg = 3 * pi/2;
	% end

	sim = sim.update(TIME_STEP);
end

plotData(sim.data);
