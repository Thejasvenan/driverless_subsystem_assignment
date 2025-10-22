load('manual_track.mat');  % contains midline
% Bicycle model parameters
wheelbase = 0.3;   % meters
dt = 0.1;          % time step
filename = 'pursuit_sim.gif'; 
figure; axis equal;

% Initial state [x, y, theta]
state = [midline(1,1), midline(1,2), 0];
controller = controllerPurePursuit;
controller.Waypoints = midline;       % follow midline
controller.LookaheadDistance = 0.5;   % tune this
controller.DesiredLinearVelocity = 1; % m/s
controller.MaxAngularVelocity = 2;    % rad/s

% Store trajectory
trajectory = [];

for i = 1:1000
    % Get control commands
    [v, omega] = controller(state);

    % Bicycle model update
    x = state(1); y = state(2); theta = state(3);
    x = x + v*cos(theta)*dt;
    y = y + v*sin(theta)*dt;
    theta = theta + omega*dt;

    state = [x, y, theta];
    trajectory = [trajectory; state];

    % Plot
    clf; hold on; axis equal;
    plot(midline(:,1), midline(:,2), 'k--','LineWidth',1.5);
    plot(trajectory(:,1), trajectory(:,2), 'r-','LineWidth',2);
    plot(x, y, 'ro','MarkerFaceColor','r');
    title('Pure Pursuit Following Midline');
    drawnow;
    
    % --- capture frame ---
    frame = getframe(gcf);
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);

    % --- write to GIF ---
    if i == 1
        imwrite(A,map,filename,"gif","LoopCount",Inf,"DelayTime",0.1);
    else
        imwrite(A,map,filename,"gif","WriteMode","append","DelayTime",0.1);
    end

end

