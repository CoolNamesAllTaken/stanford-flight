classdef Motor
	properties
		% TODO: change these to pairs
		e_prop % propeller efficiency factor at cruise
		e_motor % motor efficiency factor at cruise
		T_max_static % [N] motor max thrust when static
		T_max_cruise % [N] motor max thrust at cruise
		v_inf_cruise % [m/s] cruise velocity for T_max_cruise
	end
	methods
		function m = Motor(e_prop, e_motor)
		% m = Motor(e_prop, e_motor) creates a motor object with propeller efficiency e_prop and motor
		% efficiency e_motor
		%	e_prop = propeller efficiency factor at cruise (thrust power / shaft power)
		%	e_motor = motor efficiency factor at cruise (shaft power / electric power)
		%	TODO: finish this comment
			m.e_prop = e_prop;
			m.e_motor = e_motor;
			m.T_max_static = T_max_static;
			m.T_max_cruise = T_max_cruise;
			m.v_inf_cruise = v_inf_cruise;
		end

		function thrust = calcThrust(v_inf)
		% thrust = m.calcThrust(v_inf) calculates the thrust produced by the motor m at a given speed v_inf,
		% assuming throttle is at 100% (interpolates between static thrust and cruise thrust values)
			v_infBounds = [0, v_inf_cruise];
			thrustBounds = [T_max_static T_max_cruise];
			thrust = interp1(v_infBounds, thrustBounds, v_inf);
		end

		function motorPower = calcMotorPower(thrust, v_inf)
		% motorPower = m.calcMotorPower(thrust, v_inf) calculates the shaft power of the motor m motorPower,
		% required to create thrust force thrust at cruise speed v_inf
		%	thrust = [N] thrust force
		%	v_inf = [m/s] cruise speed
			motorPower = thrust .* v_inf ./ e_prop;
		end

		function battPower = calcBattPower(motorPower)
		% battPower = m.calcBattPower(motorPower) calculates the electrical power provided provided by the
		% batteries to a motor m producing motorPower watts of shaft power
		%	motorPower = [W] motor shaft power
			battPower = motorPower ./ e_motor;
		end
	end
end