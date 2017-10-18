classdef Motor
	properties
		v_inf % [m/s] freestream velocity for other properties [idle, cruise]
		T % [kg] motor max thrust [idle, cruise]
		e_prop % propeller efficiency factor [idle, cruise]
		e_motor % motor efficiency factor

		battVoltage % [V] battery voltage under load
	end
	methods
		function m = Motor(v_inf, T, e_prop, e_motor, battVoltage)
		% m = Motor(e_prop, e_motor, T, v_inf) creates a motor object.  NOTE: v_inf, T, e_prop are variable
		% arrays used to interpret motor properties for all phases of flight.  Recommend at least two values
		% per input, in the form [idle, cruise]
		%	v_inf = [m/s] freestream velocity for other properties
		%	T = [kg] motor max thrust
		%	e_prop = [kg/W] propeller specific thrust
		%	e_motor = [unitless] motor efficiency factor at cruise (shaft power / electric power)
			% motor produces 0 thrust at infinite speed (avoid issues when flying faster than pitch speed)
			m.v_inf = [v_inf, 999999999];
			m.T = [T, 0];
			m.e_prop = [e_prop, 0];
			m.e_motor = e_motor;
			m.battVoltage = battVoltage;
		end

		function ret = calcPropulsion(m, v_inf, throttle)
			thrust = m.calcThrust(v_inf, throttle);
			motorPower = m.calcMotorPower(v_inf, thrust);
			battPower = m.calcBattPower(motorPower);
			ret = [thrust battPower]; % [kg, W]
		end

		function thrust = calcThrust(m, v_inf, throttle)
		% thrust = m.calcThrust(v_inf) calculates the thrust produced by the motor m at a given speed v_inf,
		% assuming thrust scales linearly with throttle (interpolates between static thrust and cruise thrust values)
		% Inputs:
		%	v_inf = [m/s] cruise speed
		%	throttle = throttle value between 0 and 1
			thrust = interp1(m.v_inf, m.T, v_inf) .* throttle;
		end

		function motorPower = calcMotorPower(m, v_inf, T)
		% motorPower = m.calcMotorPower(v_inf, T) calculates the shaft power of the motor m motorPower,
		% required to create thrust force T at cruise speed v_inf
		%	v_inf = [m/s] cruise speed
		%	T = [kg] thrust force
			e_prop = interp1(m.v_inf, m.e_prop, v_inf);
			motorPower = T ./ e_prop;
		end

		function battPower = calcBattPower(m, motorPower)
		% battPower = m.calcBattPower(motorPower) calculates the electrical power provided provided by the
		% batteries to a motor m producing motorPower watts of shaft power
		%	motorPower = [W] motor shaft power
			battPower = motorPower ./ m.e_motor;
		end
	end
end