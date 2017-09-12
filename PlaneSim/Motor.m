classdef Motor
	properties
		v_inf % [m/s] freestream velocity for other properties [idle, cruise]
		T % [N] motor max thrust [idle, cruise]
		e_prop % propeller efficiency factor [idle, cruise]
		e_motor % motor efficiency factor
	end
	methods
		function m = Motor(v_inf, T, e_prop, e_motor)
		% m = Motor(e_prop, e_motor, T, v_inf) creates a motor object.  NOTE: v_inf, T, e_prop are variable
		% arrays used to interpret motor properties for all phases of flight.  Recommend at least two values
		% per input, in the form [idle, cruise]
		%	v_inf = [m/s] freestream velocity for other properties
		%	T = [N] motor max thrust
		%	e_prop = propeller efficiency factor at cruise (thrust power / shaft power)
		%	e_motor = motor efficiency factor at cruise (shaft power / electric power)
			m.v_inf = v_inf;
			m.T = T;
			m.e_prop = e_prop;
			m.e_motor = e_motor;
		end

		function thrust = calcThrust(m, v_inf)
		% thrust = m.calcThrust(v_inf) calculates the thrust produced by the motor m at a given speed v_inf,
		% assuming throttle is at 100% (interpolates between static thrust and cruise thrust values)
		%	v_inf = [m/s] cruise speed
			thrust = interp1(m.v_inf, m.T, v_inf);
		end

		function motorPower = calcMotorPower(m, v_inf, T)
		% motorPower = m.calcMotorPower(v_inf, T) calculates the shaft power of the motor m motorPower,
		% required to create thrust force T at cruise speed v_inf
		%	v_inf = [m/s] cruise speed
		%	T = [N] thrust force
			e_prop = interp1(m.v_inf, m.e_prop, v_inf);
			motorPower = T .* v_inf ./ e_prop;
		end

		function battPower = calcBattPower(m, motorPower)
		% battPower = m.calcBattPower(motorPower) calculates the electrical power provided provided by the
		% batteries to a motor m producing motorPower watts of shaft power
		%	motorPower = [W] motor shaft power
			battPower = motorPower ./ m.e_motor;
		end
	end
end