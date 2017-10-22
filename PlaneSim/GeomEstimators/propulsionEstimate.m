function results = propulsionEstimate(dryMassIn)
% Inputs:
%	dryMass = [kg] weight of aircraft before propulsion system

dryMass = [0.371, 0.897, 1.612, 2.5, 4.0, 7.0];
totalMass = [1.708, 2.600, 2.947, 4.726, 6.869, 11.737];

motor_v_inf.static = 0;
motor_v_inf.cruise = [25.0, 25.0, 25.0, 25.0, 25.0, 25.0];
motor_v_inf.pitch = [25.556, 26.667, 25.278, 25.278, 26.11, 33.056];

motor_T.static = [1.180, 1.245, 1.111, 1.757, 1.869, 2.972];
motor_T.cruise = [0.021, 0.078, 0.009, 0.023, 0.081, 0.717];
motor_T.pitch = 0;

motor_battPower = [213.9, 244.1, 214.8, 333.8, 397.7, 742.4];

battVoltage = [15, 14, 15, 9, 10, 16]; % [V] assume 1V per cell under load
battCapacity = [4500, 6000, 6000, 14000, 17500, 17500]; % [mAh]
numMotors = 2;

figure()
plot(dryMass, motor_v_inf.static)

results.totalMass = interp1(dryMass, totalMass, dryMassIn);
results.motor_v_inf = [motor_v_inf.static, interp1(dryMass, motor_v_inf.cruise, dryMassIn), interp1(dryMass, motor_v_inf.pitch, dryMassIn)];
results.motor_T = [interp1(dryMass, motor_T.static, dryMassIn), interp1(dryMass, motor_T.cruise, dryMassIn), motor_T.pitch];
results.motor_battPower = interp1(dryMass, motor_battPower, dryMassIn);
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
