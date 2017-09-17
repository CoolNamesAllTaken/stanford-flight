units = loadUnits();

v_inf = [0 13.06]; % [m/s] static, cruise
T = [1.204 0.239]; % [N] static, cruise
e_prop = [0.0048 0.00307]; % [kg/W] static, cruise
e_motor = 0.795; % static and cruise

m = Motor(v_inf, T, e_prop, e_motor)

m.calcPropulsion(13.06, 1) % thrust [kg], power [W]

m.calcThrust(13.06, 1) .* units.KG_2_N % thrust in [N]