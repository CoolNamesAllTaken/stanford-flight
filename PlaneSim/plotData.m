function plotData(data)
	close all;
	set(0,'DefaultFigureWindowStyle','docked');

	figure('name', '3D Position');
	rectangle('Position', [-1 0 2 45.72]);
	hold on;
	plot3(pos(:, 1), pos(:, 2), pos(:, 3));
	% pbaspect([1 1 1]); % plot box aspect ratio is uniform
	daspect([1 1 1]); % data aspect ratio is uniform

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
	plot(data.time, data.pos(:, 2));
	grid on;
	ylabel('Pos [m]');

	a = vertcat(a, subplot(5, 1, 2));
	plot(data.time, data.pos(:, 3));
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

	figure('name', 'Velocity Components');
	a = gobjects(0);

	a = vertcat(a, subplot(4, 1, 1));
	plot(data.time, data.vel(:, 1));
	grid on;
	ylabel('N Vel [m/s]');

	a = vertcat(a, subplot(4, 1, 2));
	plot(data.time, data.vel(:, 2));
	grid on;
	ylabel('E Vel [m/s]');

	a = vertcat(a, subplot(4, 1, 3));
	plot(data.time, data.vel(:, 3));
	grid on;
	ylabel('Vert Speed [m/s]');

	a = vertcat(a, subplot(4, 1, 4));
	plot(data.time, data.gamma .* units.RAD_2_DEG);
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
	plot(data.time, data.gamma(:, 1));
	grid on;
	ylabel('gamma [rad]');

	a = vertcat(a, subplot(4, 1, 2));
	plot(data.time, data.phi(:, 1));
	grid on;
	ylabel('phi [rad]');

	a = vertcat(a, subplot(4, 1, 3));
	plot(data.time, data.hdg(:, 1));
	grid on;
	ylabel('heading [rad]');

	a = vertcat(a, subplot(4, 1, 4));
	plot(data.time, data.hdgDiff(:, 1));
	grid on;
	ylabel('heading Difference [rad]');
end