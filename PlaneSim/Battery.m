classdef Battery
	properties
		voltage % [V] battery voltage (under load, ~1V\cell for NiMh)
		capacity % [mAh] battery capacity remaining
	end
	methods
		function b = Battery(voltage, capacity)
			b.voltage = voltage;
			b.capacity = capacity;
		end

		function b = discharge(b, battPower, time)
			units = loadUnits();
			b.capacity = b.capacity - (battPower / b.voltage * time * units.AS_2_MAH);
		end
	end
end