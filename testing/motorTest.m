v_inf = [0 27];
T = [0 1204];
prop_e = [0.2 0.7];
motor_e = 0.85;
m = Motor(v_inf, T, prop_e, motor_e)

m.calcThrust(0)
m.calcThrust(27)
m.calcThrust(13.5)