aircraftName = 'LittlePucker'

units = loadUnits();

TIME_STEP = 0.1; % [s] time between updates
NUM_STEPS = 500;

CRUISE_ALT = 20; % [m]
CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
RHO = 1.1; % [kg/m^3], kansas-ish

PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line
COURSE_WIDTH = 100 / units.M_2_FT; % [m] 360 turn distance from start

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

% fly the course
% sim = sim.navToPos([0, PYLON_DIST, CRUISE_ALT])
sim = sim.navToPos([PYLON_DIST, PYLON_DIST, CRUISE_ALT])
% sim = sim.navToPos([COURSE_WIDTH, 0, CRUISE_ALT])
% sim = sim.turnCircle(1)

plotData(sim.data);
