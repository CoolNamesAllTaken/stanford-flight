aircraftName_climb = 'LittlePuckerClimb';
aircraftName_cruise = 'LittlePuckerCruise';
aircraftName_descend = 'LittlePuckerDescend';

units = loadUnits();
TIME_STEP = 0.1; % [s] time between updates
NUM_STEPS = 200;

geom_climb = defineAircraftGeometry(aircraftName_climb);
geom_cruise = defineAircraftGeometry(aircraftName_cruise);
geom_descend = defineAircraftGeometry(aircraftName_descend);

CRUISE_ALT = 20; % [m]
ALT_ERR = 5; % [m]

state = AircraftState();
state.rho = 1.1; % [kg/m^2] kansas-ish

currTime = 0;

time = [];
pos = [];
vel = [];
gamma = [];
v_inf = [];
thrust = [];
L = [];
Fz = [];
Fx = [];

commandAlt = CRUISE_ALT;

% while (currL < geom.mass .* units.KG_2_N)
for (i=1:NUM_STEPS)
	config = [];
	if (state.pos(3) < commandAlt - ALT_ERR)
		% climb to cruise alt
		config = 'climb'
	elseif(state.pos(3) > commandAlt + ALT_ERR)
		% descend to cruise alt
		config = 'descend'
	else
		config = 'cruise'
	end

	geom = [];
	if (strcmpi(config, 'climb'))
		geom = geom_climb;
	elseif (strcmpi(config, 'cruise'))
		geom = geom_descend;
	elseif(strcmpi(config, 'descend'))
		geom = geom_descend;
	end

	% update current state variables
	currTime = currTime + TIME_STEP;
	currv_inf = state.calcv_inf()
	currq_inf = state.calcq_inf();
	currT = geom.calcThrust(currv_inf, 1)
	currL = geom.calcLift(currq_inf);
	currD = geom.calcDrag(currq_inf);
	currgamma = state.calcgamma();
	currFx = ((currT - currD) .* cos(currgamma)) - (currL .* sin(currgamma));
	currFz = (currL .* cos(currgamma)) + ((currT - currD) .* sin(currgamma)) - (geom.mass .* units.KG_2_N);

	state.acc = [0, (currFx ./ geom.mass), (currFz ./ geom.mass)] % runway is eastwards
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
	gamma = vertcat(gamma, currgamma);
	v_inf = vertcat(v_inf, currv_inf);
	thrust = vertcat(thrust, currT);
	L = vertcat(L, currL);
	Fz = vertcat(Fz, currFz);
	Fx = vertcat(Fx, currFx);
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

a = vertcat(a, subplot(2, 1, 1));
plot(time, Fz(:, 1));
grid on;
ylabel('Fz [N]');

a = vertcat(a, subplot(2, 1, 2));
plot(time, Fx(:, 1));
grid on;
ylabel('Fx [N]');

linkaxes(a, 'x');
xlabel('Time [s]');