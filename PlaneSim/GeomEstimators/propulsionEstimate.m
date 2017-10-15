function results = propulstionEstimate(dryMass)
% Inputs:
%	dryMass = [kg] weight of aircraft before propulsion system

% Project name = [2500g-plane__2400g-batteries__96kmph]
% 	motor_v_inf   :  [0, 25.0, 26.666666666666668]
% 	motor_T       :  [1.943, 0.12, 0]
% 	motor_e_prop  :  [0.005028467908902692, 0.005030000000000001, 0]
% 	motor_e_motor :  0.812

% Project name = [4000g-plane__2400g-batteries__96kmph]
% 	motor_v_inf   :  [0, 25.0, 26.666666666666668]
% 	motor_T       :  [1.943, 0.12, 0]
% 	motor_e_prop  :  [0.005028467908902692, 0.005030000000000001, 0]
% 	motor_e_motor :  0.812

% Project name = [4000g-plane__2400g-batteries__96kmph_v2]
% 	motor_v_inf   :  [0, 25.0, 26.666666666666668]
% 	motor_T       :  [1.943, 0.12, 0]
% 	motor_e_prop  :  [0.005028467908902692, 0.005030000000000001, 0]
% 	motor_e_motor :  0.812

% Project name = [super_heavy_4000g_plane]
% 	motor_v_inf   :  [0, 25.0, 33.05555555555556]
% 	motor_T       :  [2.987, 0.726, 0]
% 	motor_e_prop  :  [0.004034850736188032, 0.004030000000000001, 0]
% 	motor_e_motor :  0.804

results.propulsionMass = dryMass * 0.4;
totalMass = dryMass + results.propulsionMass;

results.motor_v_inf = [0.0, 25.0, 26.666];
results.motor_T = [totalMass * 0.7, totalMass * 0.2, 0];
results.motor_e_prop = [0.005, 0.004, 0];
results.motor_e_motor = 0.804;
results.batt_voltage = 14; % [V] assume a 14V power system
end