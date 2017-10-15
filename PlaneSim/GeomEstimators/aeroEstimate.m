function [b, S] = aeroEstimate(mass, v)
	CL_0 = 0.5; %assumed cruise at aoa=0
	AR = 5; %Aspect Ratio - selected at 5
	g=9.81; rho=1.225; %density and gravity

	S = 2*mass*g/(rho*v^2) / CL_0; %in meters
	b = sqrt(AR*S); %in meters
end