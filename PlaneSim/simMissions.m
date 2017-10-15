function scores = simMissions()
units = loadUnits();

simParams.CRUISE_ALT = 20; % [m]
simParams.CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
simParams.RHO = 1.1; % [kg/m^3], kansas-ish

% control loop gains
simParams.P_alt = 0.1;
simParams.D_alt = 0.3;
simParams.P_hdg = 0.5;
simParams.D_hdg = 0.5;
simParams.timeStep = 0.1; % [s]

close all; % clear all plots

% fly M1
fprintf('===== MISSION 1 =====')
geom = defineAircraftGeometry('LittlePucker-Empty');
missionResults(1) = flyCourse(geom, 3, simParams, true)
missionScores(1) = 1.0
fprintf('Mission 1 Complete\nScore: %.2f\n', missionScores(1))

% fly M2
% m2Results = flyCourse(3)

% fly M3

end