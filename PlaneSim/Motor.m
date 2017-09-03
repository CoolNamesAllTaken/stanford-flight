classdef Motor
	properties
		prop_e % propeller efficiency factor at cruise
		motor_e % motor efficiency factor at cruise
	end
	methods
		function m = Motor(prop_e, motor_e)
		% m = Motor(prop_e, motor_e) creates a motor object with propeller efficiency prop_e and motor
		% efficiency motor_e
		%	prop_e = propeller efficiency factor at cruise (thrust power / shaft power)
		%	motor_e = motor efficiency factor at cruise (shaft power / electric power)
			m.prop_e = prop_e;
			m.motor_e = motor_e;
		end

		function thrust = calcThrust(throttle, v_inf)
			
		end

		function motorPower = calcMotorPower(thrust, v_inf)
		% motorPower = calcMotorPower(thrust, v_inf) calculates the shaft power of the motor motorPower,
		% required to create thrust force thrust at cruise speed v_inf
		%	thrust = [N] thrust force
		%	v_inf = [m/s] cruise speed
			motorPower = thrust .* v_inf ./ prop_e;
		end

		function battPower = calcBattPower(motorPower)
		% battPower = calcBattPower(motorPower) calculates the electrical power provided provided by the
		% batteries to a motor producing motorPower watts of shaft power
		%	motorPower = [W] motor shaft power
			battPower = motorPower ./ motor_e;
		end
	end
end