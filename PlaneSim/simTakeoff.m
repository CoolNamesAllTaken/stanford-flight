aircraftName = 'LittlePuckerTakeoff';
rho = 1.1; % [kg/m^2] kansas-ish

units = loadUnits();
TIME_STEP = 0.5; % [s] time between updates

geom = defineAircraftGeometry(aircraftName);
state = AircraftState();

currTime = 0;
currVel = [0 0 0];
currL = 0;

time = [];
pos = [];
v_inf = [];
thrust = [];
L = [];

while (currL < geom.mass .* units.KG_2_N)
	currTime = currTime + TIME_STEP;
	currv_inf = state.calcv_inf();
	currq_inf = 0.5 .* rho .* currv_inf^2;
	currThrust = geom.calcThrust(currv_inf, 1);
	currL = geom.calcLift(currq_inf);
	currD = geom.calcDrag(currq_inf);
	acc = [0 ((currThrust - currD) ./ geom.mass) 0]; % runway is eastwards
	currVel = currVel + (acc .* TIME_STEP);

	state.pos = state.pos + (currVel .* TIME_STEP); 
	state.vel = currVel;

	time = vertcat(time, currTime);
	pos = vertcat(pos, state.pos);
	v_inf = vertcat(v_inf, currv_inf);
	thrust = vertcat(thrust, currThrust);
	L = vertcat(L, currL);
end

close all;

figure();
rectangle('Position', [-1 0 2 45.72]);
hold on;
plot3(pos(:, 1), pos(:, 2), pos(:, 3));
axis equal; % N and E axes are same scale [m]

xl = xlim;
yl = ylim;
zl = zlim;
zlim([0 max([xl(2) yl(2) zl(2)])]);
xlabel('Northing [m]');
ylabel('Easting [m]');
zlabel('Altitude AGL [m]');
grid on;

figure();
subplot(4, 1, 1);
plot(time, pos);
ylabel('Pos [m]')

subplot(4, 1, 2);
plot(time, v_inf);
ylabel('v_{inf} [m/s]');

subplot(4, 1, 3);
plot(time, thrust);
ylabel('Thrust [N]');

subplot(4, 1, 4);
plot(time, L);
ylabel('Lift [N]');

xlabel('Time [s]');