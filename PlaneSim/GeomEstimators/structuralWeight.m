units = loadUnits();
numPassengers = 60; %Choose number divisible by 4 if numPassengers >=20 and divisible by 2 if numPassengers < 20

if numPassengers < 20
    passengerConfiguration = [32 49];
else
    passengerConfiguration = [32 32 49 49];
end

numBats = 112;
inchToMiliConversion = 25.4;
areaDensityFoam = 110/(20*29.5*(inchToMiliConversion^2)); % g/mm^2  20x29.5in 110g 
areaDensity = areaDensityFoam*1.5; %reinforced
[emptyFuselageWeight, passengerLoadedWeight, fuselageLength, fuselageWidth, fuselageHeight] = ballParkEstimate(numPassengers, passengerConfiguration, numBats, areaDensity)