classdef Motor
	properties
		v_inf % [m/s] freestream velocity for other properties [idle, cruise]
		T % [kg] motor max thrust [idle, cruise]
		battPower % motor maximum battery power
	end
	methods
		function m = Motor(v_inf, T, battPower)
		% m = Motor(e_prop, e_motor, T, v_inf) creates a motor object.  NOTE: v_inf, T, are variable
		% arrays used to interpret motor properties for all phases of flight.  Recommend at least two values
		% per input, in the form [idle, cruise]
		%	v_inf = [m/s] freestream velocity for other properties
		%	T = [kg] motor max thrust
		%	power = [W] motor power at max throttle
			% motor produces 0 thrust at infinite speed (avoid issues when flying faster than pitch speed)
			m.v_inf = [v_inf, 999999999];
			m.T = [T, 0];
			m.battPower = battPower; % 0 power at 0 throttle
		end

		function ret = calcPropulsion(m, v_inf, throttle)
			thrust = m.calcThrust(v_inf, throttle);
			battPower = m.calcBattPower(throttle);
			ret = [thrust battPower]; % [kg, W]
		end

		function thrust = calcThrust(m, v_inf, throttle)
		% thrust = m.calcThrust(v_inf) calculates the thrust produced by the motor m at a given speed v_inf,
		% assuming thrust scales linearly with throttle (interpolates between static thrust and cruise thrust values)
		% Inputs:
		%	v_inf = [m/s] cruise speed
		%	throttle = throttle value between 0 and 1
			thrust = interp1(m.v_inf, m.T, v_inf) * throttle;
		end

		function battPower = calcBattPower(m, throttle)
		% battPower = m.calcBattPower(motorPower) calculates the electrical power provided provided by the
		% batteries to a motor m running at throttle setting throttle
		% Inputs:
		%	throttle = throttle value between 0 and 1
			battPower = m.battPower * throttle;
		end
	end
end