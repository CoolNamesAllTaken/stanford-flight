numPassengers = 70;
passengerConfiguration = [32 32 49 49]; %passengers in the row
numBats = 112;
inchToMiliConversion = 25.4;
areaDensityFoam = 110/(20*29.5*(inchToMiliConversion^2)); % g/mm^2  20x29.5in 110g 
areaDensity = areaDensityFoam*1.5; %reinforced
[emptyFuselageWeight, passengerLoadedWeight, fuselageLength, fuselageWidth, fuselageHeight] = ballparkEstimate(numPassengers, passengerConfiguration, numBats, areaDensity)