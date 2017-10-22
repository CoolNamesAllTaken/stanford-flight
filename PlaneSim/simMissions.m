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
MAX_PAX_TIME = 160 / 180; % [160 pax / 3 mins] best M2 combo of any team
MAX_PAX_PAYLOAD_LAPS = 80 * 90 * 12; % [80 pax * 90oz payload * 12 laps]

close all; % clear all plots

paxList = [6, 20, 40, 60, 80, 100, 140, 160]; % list of passenger configurations to try

for i = 1:length(paxList)
	pax = paxList(i);

	% fly M1
	fprintf('===== MISSION 1 =====\n')
	geom = defineAircraftGeometry(['DBF18-' num2str(pax) '-empty']);
	mission1Results(i) = flyCourse(geom, 1, simParams, true)
	mission1Scores(i) = 1.0;
	fprintf('Mission 1 Complete\nScore: %.2f\n', mission1Scores(i))
    
    rac(i) = geom.mass * geom.liftSurfaces{1}.b; % calculate RAC with EWMax (includes batts, no payload), wingspan

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
	m3Payload = m3Pax * 1.12; % [oz] avg. weight 1.12 oz/passenger
	mission3Scores(i) = 4 * m3Pax * m3Payload * mission3Results(i).numLaps / MAX_PAX_PAYLOAD_LAPS;
	fprintf('Mission 3 Complete\nScore: %.2f\n', mission3Scores(i));
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
ylabel('Tot M Score');

subplot(5, 1, 5);
plot(paxList, competitionScoreMult);
ylabel('CS Mult');
xlabel('Num Passengers')
end
