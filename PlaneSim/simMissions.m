function scores = simMissions()
units = loadUnits();

simParams.CRUISE_ALT = 40; % [m]
simParams.CRUISE_V_INF = 20; % [m/s], estimate used to calculate phi_max
simParams.RHO = 1.1; % [kg/m^3], kansas-ish

% control loop gains
simParams.P_alt = 0.9;
simParams.D_alt = 2.0;
simParams.P_hdg = 1.8;
simParams.D_hdg = 1.5;
simParams.timeStep = 0.1; % [s]

% competitor best guesses
MAX_PAX_TIME = 80 / 180; % [80 pax / 3 mins] best M2 combo of any team
MAX_PAX_PAYLOAD_LAPS = 40 * 40 / 6; % [40 pax * 40oz payload / 6 laps]

close all; % clear all plots

% % BEGIN
% PYLON_DIST = 500 / units.M_2_FT; % [m] pylon distance from start line
% COURSE_WIDTH = 100 / units.M_2_FT; % [m] 360 turn distance from start
% 
% state = AircraftState();
% state.rho = simParams.RHO;
% state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)
% 
% geom = defineAircraftGeometry('DBF18-80-full')
% 
% controller = AircraftController(simParams.P_alt, simParams.D_alt, simParams.P_hdg, simParams.D_hdg, simParams.timeStep);
% controller.PHI_MAX = geom.calcphi_max(0.5 * simParams.RHO * simParams.CRUISE_V_INF^2);
% 
% sim = AircraftSim(state, geom, controller, simParams.timeStep);
% sim.commandAlt = simParams.CRUISE_ALT;
% sim.commandHdg = pi/2;
% 
% sim = sim.navToPos([PYLON_DIST, PYLON_DIST, simParams.CRUISE_ALT]);
% plotData(sim.data);
% % END

paxList = [64, 80, 100, 140, 160]; % list of passenger configurations to try

for i = 1:length(paxList)
	pax = paxList(i);

	% fly M1
	fprintf('===== MISSION 1 =====\n')
	geom = defineAircraftGeometry(['DBF18-' num2str(pax) '-empty']);
	mission1Results(i) = flyCourse(geom, 3, simParams, true)
	mission1Scores(i) = 1.0;
	fprintf('Mission 1 Complete\nScore: %.2f\n', mission1Scores(i))
    
    rac(i) = geom.mass * geom.liftSurfaces{1}.b;
	% fly M2
	fprintf('===== MISSION 2 =====\n')
	geom = defineAircraftGeometry(['DBF18-' num2str(pax) '-full']);
	mission2Results(i) = flyCourse(geom, 3, simParams, true);
	mission2Scores(i) = 2 * pax / mission2Results(i).time / MAX_PAX_TIME;
	fprintf('Mission 2 Complete\nScore: %.2f\n', mission2Scores(i));

	% fly M3
    fprintf('===== MISSION 3 =====\n')
	geom = defineAircraftGeometry(['DBF18-' num2str(pax) '-full']);
	mission3Results(i) = flyCourse(geom, 99999, simParams, true);
	m3Pax = pax / 2; % assume 50% pax, the rest as payload
	m3Payload = pax * 1.12; % avg. weight 1.12 oz/passenger
	mission3Scores(i) = 4 * m3Pax * m3Payload * mission3Results(i).numLaps / MAX_PAX_PAYLOAD_LAPS;
	fprintf('Mission 2 Complete\nScore: %.2f\n', mission2Scores(i));
end

totalMissionScores = mission1Scores + mission2Scores + mission3Scores;
competitionScoreMult = totalMissionScores ./ rac;

figure();
subplot(5, 1, 1);
plot(paxList, mission2Scores);
ylabel('M2')

subplot(5, 1, 2);
plot(paxList, mission3Scores);
ylabel('M3')

subplot(5, 1, 3);
plot(paxList, rac);
ylabel('RAC');

subplot(5, 1, 4);
plot(paxList, totalMissionScores);
ylabel('Total Mission Score');

subplot(5, 1, 5);
plot(paxList, competitionScoreMult);
ylabel('Competition Score Multiplier');
xlabel('Num Passengers')
end
