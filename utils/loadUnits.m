function units = loadUnits()
	% SI to standard
	units.KG_2_N = 9.81;
	units.RAD_2_DEG = 180 / pi;
	units.M_2_FT = 3.2808399;

	% standard to SI
	units.IN_2_MM = 25.4; % inches to millimeters
	units.OZ_2_G = 28.3495; % oz to grams

	% SI to SI
	units.AS_2_MAH = 1000 / 3600; % Amp*s to mAh
	units.MM_2_M = 1.0 / 1000; % millimeters to meters
	units.G_2_KG = 1.0/1000; % grams to kilograms
end