aircraftName = 'LittlePucker'

units = loadUnits();
TIME_STEP = 0.1; % [s] time between updates
NUM_STEPS = 500;

geom = defineAircraftGeometry(aircraftName);

CRUISE_ALT = 20; % [m]
ALT_ERR = 5; % [m]

COURSE_EDGE = 100; % [m] first pylon distance, fudged
MAX_BANK = pi/4 % [rad], limit to 45 degree bank

% control loop gains
P_alt = 0.003;
D_alt = 0.04;
P_hdg = 0.5;
D_hdg = 0.5;

state = AircraftState();
state.rho = 1.1; % [kg/m^2] kansas-ish
state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

currTime = 0;

data.time = [];
data.pos = [];
data.vel = [];
data.gamma = [];
data.phi = [];
data.hdg = [];
data.hdgDiff = [];
data.v_inf = [];
data.thrust = [];
data.L = [];
data.F_xyz = [];

commandAlt = CRUISE_ALT;
commandHdg = 3 * pi/2;
oldHdg = commandHdg;

% while (currL < geom.mass .* units.KG_2_N)
for (i=1:NUM_STEPS)
	config = [];

	% command loop
	if (state.pos(2) > COURSE_EDGE)
		commandHdg = pi/2;
	end
	if (state.pos(2) < -COURSE_EDGE)
		commandHdg = 3 * pi/2;
	end

	% PD altitude control loop
	altErr = state.pos(3) - commandAlt;
	dAltErr = state.vel(3);
	response = altErr * P_alt + dAltErr * D_alt;

	liftMult = geom.liftMult - response;
	if (liftMult > 1) liftMult = 1;
	elseif (liftMult < 0) liftMult = 0; end
	geom.liftMult = liftMult;

	% PD heading control loop
	hdgErr = state.calcHdgDiff(commandHdg);
	dHdgErr = -state.calcHdgDiff(oldHdg) / TIME_STEP;
	oldHdg = state.hdg;
	response = hdgErr * P_hdg - dHdgErr * D_hdg;

	phi = state.phi - response;
	if (phi > MAX_BANK) phi = MAX_BANK;
	elseif (phi < -MAX_BANK) phi = -MAX_BANK; end
	state.phi = phi;

	% update current state variables
	currTime = currTime + TIME_STEP;

	% transforms longitudinal forces (ie. thrust, drag) from XYZ coords to NEU coords
	TRANSFORM_LONG = [cos(state.gamma), (sin(state.gamma) * sin(state.phi)), (sin(state.gamma) * cos(state.phi))];
	% transforms vertical forces (ie. lift) from XYZ coords to NEU coords
	TRANSFORM_VERT = [-sin(state.gamma), (cos(state.gamma) * sin(state.phi)), (cos(state.gamma) * cos(state.phi))];

	currT = geom.calcThrust(state.v_inf, 1) .* TRANSFORM_LONG % [T_x T_y T_z]
	currL = geom.calcLift(state.q_inf) .* TRANSFORM_VERT; % [L_x L_y L_z]
	currD = -geom.calcDrag(state.q_inf) .* TRANSFORM_LONG; % [D_x D_y D_z]
	currW = [0, 0, -(geom.mass * units.KG_2_N)]; % [W_x W_y W_z]

	currF_xyz = currT + currL + currD + currW;
	currF_neu = currF_xyz * [cos(state.hdg), -sin(state.hdg), 0; sin(state.hdg), cos(state.hdg), 0; 0, 0, 1];

	state.acc = currF_neu ./ geom.mass;
	state = state.update(TIME_STEP);

	if (state.pos(3) <= 0 && state.vel(3) < 0)
		% aircraft sinking into ground
		state.pos(3) = 0;
		state.vel(3) = 0;
		state.acc(3) = 0;
	end 

	% record data
	data.time = vertcat(data.time, currTime);
	data.pos = vertcat(data.pos, state.pos);
	data.vel = vertcat(data.vel, state.vel);
	data.gamma = vertcat(data.gamma, state.gamma);
	data.phi = vertcat(data.phi, state.phi);
	data.hdg = vertcat(data.hdg, state.hdg);
	data.hdgDiff = vertcat(data.hdgDiff, hdgErr);
	data.v_inf = vertcat(data.v_inf, state.v_inf);
	data.thrust = vertcat(data.thrust, sqrt(sum(currT.^2)));
	data.L = vertcat(data.L, sqrt(sum(currL.^2)));
	data.F_xyz = vertcat(data.F_xyz, currF_xyz);
end

plotData(data);
