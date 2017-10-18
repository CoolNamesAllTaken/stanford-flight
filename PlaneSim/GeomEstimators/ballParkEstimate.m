function[emptyFuselageWeight, passengerLoadedWeight, fuselageLength, fuselageWidth, fuselageHeight] = ...
	ballparkEstimate(numPassengers, passengerConfiguration, numBats, areaDensity)

	units = loadUnits();

	passengerWeightsDistribution = [0.40 0.67 1.12 1.85 2.39]; %oz
	pd = [ 27 0.15; 32 0.20; 38 0.30; 45 0.20; 49 0.15];

	% Then make it into a cumulative distribution
	D = cumsum(pd(:,2));

	for i = 1:numPassengers
	    R = rand;
	    if R < .15
	        passengerDiameters(i) = 27;
	        passengerWeights(i) = .4*units.OZ_2_G;
	    elseif R >= .15 && R < .35
	        passengerDiameters(i) = 32;
	        passengerWeights(i) = .67*units.OZ_2_G;
	    elseif R >= .35 && R < .65
	        passengerDiameters(i) = 38;
	        passengerWeights(i) = 1.12*units.OZ_2_G;
	    elseif R >= .65 && R < .85
	        passengerDiameters(i) = 45;
	        passengerWeights(i) = 1.85*units.OZ_2_G;
	    else
	        passengerDiameters(i) = 49;
	        passengerWeights(i) = 2.39*units.OZ_2_G;
	    end
	end

	figure();
	hist(passengerDiameters,[27 32 38 45 49]);

	%passengers added in groups of 4
	aisleWidth = 2*units.IN_2_MM;
	aisleHeight = 2*units.IN_2_MM;
	marginHeight = .25*units.IN_2_MM; 
	numRows = numPassengers/4;
	longitudinalSpacing = .25*units.IN_2_MM;
	edgeSpacing = 1*units.IN_2_MM;

	%empty fuselage - equally spaced rows that can accomade 2x49mm passenger
	%per row
	passengerCompartmentWidth = (sum(passengerConfiguration))+aisleWidth+edgeSpacing;
	passengerCompartmentLength = (numRows*49)+((numRows+1)*longitudinalSpacing);
	passengerCompartmentHeight = marginHeight + aisleHeight;
	passengerCompartmentVolume = passengerCompartmentWidth*passengerCompartmentLength*passengerCompartmentHeight;

	%histogram generated volume estimate

	passengerArea = 49*passengerDiameters;
	passengerArea = sum(passengerArea);
	marginArea = (aisleWidth+edgeSpacing+edgeSpacing)*(((numRows+1)*longitudinalSpacing) + (49*numRows));
	generatedPassengerVolume = (passengerArea+marginArea) *(passengerCompartmentHeight);
	totalPassengerWeight = sum(passengerWeights);

	batDiameter = 14.5;
	batsPerRow = numBats/16; %16 14.5mm batteries fit per row with given fuselage width
	electronicsBayLength = batsPerRow*batDiameter; %batteries/ESCs/storage/etc - add in once we calculate
	fuselageHeight = (3/2)*passengerCompartmentHeight; %assumes luggage compartment is half the area as passenger compartment
	fuselageLength = passengerCompartmentLength + electronicsBayLength;
	fuselageWidth = passengerCompartmentWidth;

	%in grams
	emptyFuselageWeight = areaDensity*(2*(fuselageHeight*fuselageWidth)+2*(fuselageLength*fuselageHeight) + 3*(fuselageLength*fuselageWidth));
	passengerLoadedWeight = emptyFuselageWeight + totalPassengerWeight;
end