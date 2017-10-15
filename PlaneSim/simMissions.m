function scores = simMissions()
units = loadUnits();

simParams.CRUISE_ALT = 20; % [m]
simParams.CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
simParams.RHO = 1.1; % [kg/m^3], kansas-ish

% control loop gains
simParams.P_alt = 0.9;
simParams.D_alt = 2.0;
simParams.P_hdg = 1.8;
simParams.D_hdg = 1.5;
simParams.timeStep = 0.1; % [s]

close all; % clear all plots

% % BEGIN
% PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line
% COURSE_WIDTH = 100 / units.M_2_FT; % [m] 360 turn distance from start

% state = AircraftState();
% state.rho = simParams.RHO;
% state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

% geom = defineAircraftGeometry('DBF18-50-full')

% controller = AircraftController(simParams.P_alt, simParams.D_alt, simParams.P_hdg, simParams.D_hdg, simParams.timeStep);
% controller.PHI_MAX = geom.calcphi_max(0.5 * simParams.RHO * simParams.CRUISE_V_INF^2);

% sim = AircraftSim(state, geom, controller, simParams.timeStep);
% sim.commandAlt = simParams.CRUISE_ALT;
% sim.commandHdg = pi/2;

% sim = sim.navToPos([PYLON_DIST, PYLON_DIST, simParams.CRUISE_ALT]);
% plotData(sim.data);
% % END

% fly M1
fprintf('===== MISSION 1 =====')
geom = defineAircraftGeometry('DBF18-50-empty');
missionResults(1) = flyCourse(geom, 3, simParams, true)
missionScores(1) = 1.0
fprintf('Mission 1 Complete\nScore: %.2f\n', missionScores(1))

% fly M2
% m2Results = flyCourse(3)

% fly M3

end