function results = propulsionEstimate(dryMassIn)
% Inputs:
%	dryMass = [kg] weight of aircraft before propulsion system

% Project name = [2500g__4156g]
% 	motor_v_inf   :  [0, 25.0, 25.27777777777778]
% 	motor_T       :  [1.743, 0.016, 0]
% 	motor_e_prop  :  [0.005340073529411765, 0.00534, 0]
% 	motor_e_motor :  0.816

% Project name = [4000g__6240g]
% 	motor_v_inf   :  [0, 25.0, 26.666666666666668]
% 	motor_T       :  [1.943, 0.12, 0]
% 	motor_e_prop  :  [0.005028467908902692, 0.005030000000000001, 0]
% 	motor_e_motor :  0.812

% Project name = [7500g_10500g_plane]
% 	motor_v_inf   :  [0, 25.0, 33.05555555555556]
% 	motor_T       :  [2.987, 0.726, 0]
% 	motor_e_prop  :  [0.004034850736188032, 0.004030000000000001, 0]
% 	motor_e_motor :  0.804
dryMass = [2.5, 4, 7.5];
totalMass = [4.156, 6.240, 10.500];

motor_v_inf.static = 0;
motor_v_inf.cruise = [25.0, 25.0, 25.0];
motor_v_inf.pitch = [25.278, 26.667, 33.056];

motor_T.static = [1.743, 1.943, 2.987];
motor_T.cruise = [0.016, 0.12, 0.726];
motor_T.pitch = 0;

motor_e_prop.static = [0.005340073529411765, 0.005028467908902692, 0.004034850736188032];
motor_e_prop.cruise = [0.00534, 0.005030000000000001, 0.004030000000000001];
motor_e_prop.pitch = 0;
motor_e_motor = [0.816, 0.812, 0.804];

battVoltage = [9, 10, 16]; % [V] assume 1V per cell under load
battCapacity = [14000, 17500, 17500]
numMotors = 2;

figure()
plot(dryMass, motor_v_inf.static)

results.totalMass = interp1(dryMass, totalMass, dryMassIn)
results.motor_v_inf = [motor_v_inf.static, interp1(dryMass, motor_v_inf.cruise, dryMassIn), interp1(dryMass, motor_v_inf.pitch, dryMassIn)];
results.motor_T = [interp1(dryMass, motor_T.static, dryMassIn), interp1(dryMass, motor_T.cruise, dryMassIn), motor_T.pitch];
results.motor_e_prop = [interp1(dryMass, motor_e_prop.static, dryMassIn), interp1(dryMass, motor_e_prop.cruise, dryMassIn), motor_e_prop.pitch];
results.motor_e_motor = interp1(dryMass, motor_e_motor, dryMassIn);
results.battVoltage = round(interp1(dryMass, battVoltage, dryMassIn));
results.battCapacity = round(interp1(dryMass, battCapacity, dryMassIn));
results.numMotors = numMotors;

results.propulsionMass = results.totalMass - dryMassIn;
results
% results.propulsionMass = dryMass * 0.4;
% totalMass = dryMass + results.propulsionMass;

% results.motor_v_inf = [0.0, 25.0, 26.666];
% results.motor_T = [totalMass * 0.7, totalMass * 0.2, 0];
% results.motor_e_prop = [0.005, 0.004, 0];
% results.motor_e_motor = 0.804;
% results.batt_voltage = 14; % [V] assume a 14V power system
end
