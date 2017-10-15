classdef AircraftController
	properties
		P_alt
		D_alt
		P_hdg
		D_hdg
		timeStep % [s] dt

		LIFTMULT_MAX = 1; % maximum lift multiplier (1: 100% of C_Lmax)
		LIFTMULT_MIN = 0; % minimum lift multiplier (0: C_L = 0)
		PHI_MAX = pi/4; % [rad] maximum +/- bank angle
	end
	methods  
		function ac = AircraftController(P_alt, D_alt, P_hdg, D_hdg, timeStep)
			ac.P_alt = P_alt;
			ac.D_alt = D_alt;
			ac.P_hdg = P_hdg;
			ac.D_hdg = D_hdg;
			ac.timeStep = timeStep
		end

		function liftMult = controlAlt(ac, altErr, dAltErr, liftMult)
			% PD altitude control
			response = altErr * ac.P_alt + dAltErr * ac.D_alt;

			liftMult = liftMult - response;
			if (liftMult > ac.LIFTMULT_MAX) liftMult = ac.LIFTMULT_MAX;
			elseif (liftMult < ac.LIFTMULT_MIN) liftMult = ac.LIFTMULT_MIN; end
		end

		function phi = controlHdg(ac, hdgErr, dHdgErr, phi)
			% PD heading control
			response = hdgErr * ac.P_hdg + dHdgErr * ac.D_hdg;

			phi = phi + response;
			if (phi > ac.PHI_MAX) phi = ac.PHI_MAX;
			elseif (phi < -ac.PHI_MAX) phi = -ac.PHI_MAX; end
		end
	end
end