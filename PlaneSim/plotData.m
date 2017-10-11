function plotData(data)
	units = loadUnits();

	close all;
	set(0,'DefaultFigureWindowStyle','docked');

	pos_n = [];
	pos_e = [];
	pos_u = [];
	for i = 1:length(data.state)
		pos_n = [pos_n, data.state(i).pos(1)];
		pos_e = [pos_e, data.state(i).pos(2)];
		pos_u = [pos_u, data.state(i).pos(3)];
	end
	figure('name', '3D Position');

	% draw the course
	RUNWAY_LENGTH = 150 / units.M_2_FT;
	rectangle('Position', [-1, 0, 2, RUNWAY_LENGTH]); % runway takeoff area
	PYLON_DIAM = 5;
	rectangle('Position', [0, 500/units.M_2_FT, PYLON_DIAM, PYLON_DIAM], 'Curvature', [1, 1]); % pylon 1
	rectangle('Position', [100/units.M_2_FT, 0, PYLON_DIAM, PYLON_DIAM], 'Curvature', [1, 1]); % pylon 2
	rectangle('Position', [0, -500/units.M_2_FT, PYLON_DIAM, PYLON_DIAM], 'Curvature', [1, 1]); % pylon 3
	hold on;
	plot3(pos_n, pos_e, pos_u);
	daspect([1 1 1]); % data aspect ratio is uniform
	set(gca, 'YDir', 'reverse'); % x axis increases from left to right

	xl = xlim;
	yl = ylim;
	zl = zlim;
	zlim([0 zl(2)]); % start z at ground level

	xlabel('Northing [m]');
	ylabel('Easting [m]');
	zlabel('Altitude AGL [m]');
	grid on;
	view(-30, 30);

	figure('name', 'Data');
	a = gobjects(0);

	a = vertcat(a, subplot(5, 1, 1));
	plot(data.time, pos_n);
	grid on;
	ylabel('Pos [m]');

	a = vertcat(a, subplot(5, 1, 2));
	plot(data.time, pos_u);
	grid on;
	ylabel('Alt [m]');

	a = vertcat(a, subplot(5, 1, 3));
	plot(data.time, data.v_inf);
	grid on;
	ylabel('v_{inf} [m/s]');

	a = vertcat(a, subplot(5, 1, 4));
	plot(data.time, data.thrust);
	grid on;
	ylabel('Thrust [N]');

	a = vertcat(a, subplot(5, 1, 5));
	plot(data.time, data.L);
	grid on;
	ylabel('Lift [N]');

	linkaxes(a, 'x');
	xlabel('Time [s]');

	vel_n = [];
	vel_e = [];
	vel_u = [];
	for i = 1:length(data.state)
		vel_n = [vel_n, data.state(i).vel(1)];
		vel_e = [vel_e, data.state(i).vel(2)];
		vel_u = [vel_u, data.state(i).vel(3)];
	end
	figure('name', 'Velocity Components');
	a = gobjects(0);

	a = vertcat(a, subplot(4, 1, 1));
	plot(data.time(:), vel_n);
	grid on;
	ylabel('N Vel [m/s]');

	a = vertcat(a, subplot(4, 1, 2));
	plot(data.time(:), vel_e);
	grid on;
	ylabel('E Vel [m/s]');

	a = vertcat(a, subplot(4, 1, 3));
	plot(data.time, vel_u);
	grid on;
	ylabel('Vert Speed [m/s]');

	a = vertcat(a, subplot(4, 1, 4));
	plot(data.time, [data.state(:).gamma] .* units.RAD_2_DEG);
	grid on;
	ylabel('Gamma [deg]');

	linkaxes(a, 'x');
	xlabel('Time [s]');

	figure('name', 'Forces');
	a = gobjects(0);

	a = vertcat(a, subplot(3, 1, 1));
	plot(data.time, data.F_xyz(:, 1));
	grid on;
	ylabel('F_x [N]');

	a = vertcat(a, subplot(3, 1, 2));
	plot(data.time, data.F_xyz(:, 2));
	grid on;
	ylabel('F_y [N]');

	a = vertcat(a, subplot(3, 1, 3));
	plot(data.time, data.F_xyz(:, 3));
	grid on;
	ylabel('F_z [N]');

	linkaxes(a, 'x');
	xlabel('Time [s]');

	figure('name', 'Angles');
	a = gobjects(0);

	a = vertcat(a, subplot(4, 1, 1));
	plot(data.time, [data.state(:).gamma]);
	grid on;
	ylabel('gamma [rad]');

	a = vertcat(a, subplot(4, 1, 2));
	plot(data.time, [data.state(:).phi]);
	grid on;
	ylabel('phi [rad]');

	a = vertcat(a, subplot(4, 1, 3));
	plot(data.time, [data.state(:).hdg]);
	grid on;
	ylabel('heading [rad]');

	% a = vertcat(a, subplot(4, 1, 4));
	% plot(data.time, data.hdgDiff(:, 1));
	% grid on;
	% ylabel('heading Difference [rad]');
end