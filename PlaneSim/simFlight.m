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
P_alt = 0.008;
D_alt = 0.05;

state = AircraftState();
state.rho = 1.1; % [kg/m^2] kansas-ish
state.vel = [0 0.1 0]; % start aircraft rolling down runway (heading established)

currTime = 0;

time = [];
pos = [];
vel = [];
gamma = [];
phi = [];
hdg = [];
v_inf = [];
thrust = [];
L = [];
F_xyz = [];

commandAlt = CRUISE_ALT;

% while (currL < geom.mass .* units.KG_2_N)
for (i=1:NUM_STEPS)
	config = [];

	% proportional altitude control loop
	altErr = state.pos(3) - commandAlt;
	dAltErr = state.vel(3);
	response = altErr * P_alt + dAltErr * D_alt;

	liftMult = geom.liftMult - response;
	if (liftMult > 1)
		liftMult = 1;
	elseif (liftMult < 0)
		liftMult = 0;
	end
	geom.liftMult = liftMult;

	% crappy heading control loop
	if (state.pos(2) > COURSE_EDGE)
		state.phi = MAX_BANK;
	end

	% update current state variables
	currTime = currTime + TIME_STEP;

	% transforms longitudinal forces (ie. thrust, drag) from XYZ coords to NEU coords
	transform_long = [cos(state.gamma), (sin(state.gamma) * sin(state.phi)), (sin(state.gamma) * cos(state.phi))];
	% transforms vertical forces (ie. lift) from XYZ coords to NEU coords
	transform_vert = [-sin(state.gamma), (cos(state.gamma) * sin(state.phi)), (cos(state.gamma) * cos(state.phi))];

	currT = geom.calcThrust(state.v_inf, 1) .* transform_long % [T_x T_y T_z]
	currL = geom.calcLift(state.q_inf) .* transform_vert; % [L_x L_y L_z]
	currD = -geom.calcDrag(state.q_inf) .* transform_long; % [D_x D_y D_z]
	currW = [0, 0, -(geom.mass * units.KG_2_N)]; % [W_x W_y W_z]
	
	% currFx = ((currT - currD) .* cos(state.gamma)) - (currL .* sin(state.gamma));
	% currFz = (currL .* cos(state.gamma)) + ((currT - currD) .* sin(state.gamma)) - (geom.mass .* units.KG_2_N);

	currF_xyz = currT + currL + currD + currW;
	currF_neu = currF_xyz * [cos(state.hdg), -sin(state.hdg), 0; sin(state.hdg), cos(state.hdg), 0; 0, 0, 1];

	state.acc = currF_neu ./ geom.mass % runway is eastwards
	state = state.update(TIME_STEP);

	if (state.pos(3) <= 0 && state.vel(3) < 0)
		% aircraft sinking into ground
		state.pos(3) = 0;
		state.vel(3) = 0;
		state.acc(3) = 0;
	end 

	% record data
	time = vertcat(time, currTime);
	pos = vertcat(pos, state.pos);
	vel = vertcat(vel, state.vel);
	gamma = vertcat(gamma, state.gamma);
	phi = vertcat(phi, state.phi);
	hdg = vertcat(hdg, state.hdg);
	v_inf = vertcat(v_inf, state.v_inf);
	thrust = vertcat(thrust, sqrt(sum(currT.^2)));
	L = vertcat(L, sqrt(sum(currL.^2)));
	F_xyz = vertcat(F_xyz, currF_xyz);
end

close all;
set(0,'DefaultFigureWindowStyle','docked');

figure('name', '3D Position');
rectangle('Position', [-1 0 2 45.72]);
hold on;
plot3(pos(:, 1), pos(:, 2), pos(:, 3));
pbaspect([1 1 1]); % plot box aspect ratio is uniform
daspect([1 1 1]); % data aspect ratio is uniform

xl = xlim;
yl = ylim;
zl = zlim;
zlim([0 max([xl(2) yl(2) zl(2)])]); % start z at ground level

xlabel('Northing [m]');
ylabel('Easting [m]');
zlabel('Altitude AGL [m]');
grid on;
view(-30, 30);

figure('name', 'Data');
a = gobjects(0);

a = vertcat(a, subplot(5, 1, 1));
plot(time, pos(:, 2));
grid on;
ylabel('Pos [m]');

a = vertcat(a, subplot(5, 1, 2));
plot(time, pos(:, 3));
grid on;
ylabel('Alt [m]');

a = vertcat(a, subplot(5, 1, 3));
plot(time, v_inf);
grid on;
ylabel('v_{inf} [m/s]');

a = vertcat(a, subplot(5, 1, 4));
plot(time, thrust);
grid on;
ylabel('Thrust [N]');

a = vertcat(a, subplot(5, 1, 5));
plot(time, L);
grid on;
ylabel('Lift [N]');

linkaxes(a, 'x');
xlabel('Time [s]');

figure('name', 'Velocity Components');
a = gobjects(0);

a = vertcat(a, subplot(4, 1, 1));
plot(time, vel(:, 1));
grid on;
ylabel('N Vel [m/s]');

a = vertcat(a, subplot(4, 1, 2));
plot(time, vel(:, 2));
grid on;
ylabel('E Vel [m/s]');

a = vertcat(a, subplot(4, 1, 3));
plot(time, vel(:, 3));
grid on;
ylabel('Vert Speed [m/s]');

a = vertcat(a, subplot(4, 1, 4));
plot(time, gamma .* units.RAD_2_DEG);
grid on;
ylabel('Gamma [deg]');

linkaxes(a, 'x');
xlabel('Time [s]');

figure('name', 'Forces');
a = gobjects(0);

a = vertcat(a, subplot(3, 1, 1));
plot(time, F_xyz(:, 1));
grid on;
ylabel('F_x [N]');

a = vertcat(a, subplot(3, 1, 2));
plot(time, F_xyz(:, 2));
grid on;
ylabel('F_y [N]');

a = vertcat(a, subplot(3, 1, 3));
plot(time, F_xyz(:, 3));
grid on;
ylabel('F_z [N]');

linkaxes(a, 'x');
xlabel('Time [s]');

figure('name', 'Angles');
a = gobjects(0);

a = vertcat(a, subplot(3, 1, 1));
plot(time, gamma(:, 1));
grid on;
ylabel('gamma [rad]');

a = vertcat(a, subplot(3, 1, 2));
plot(time, phi(:, 1));
grid on;
ylabel('phi [rad]');

a = vertcat(a, subplot(3, 1, 3));
plot(time, hdg(:, 1));
grid on;
ylabel('heading [rad]');