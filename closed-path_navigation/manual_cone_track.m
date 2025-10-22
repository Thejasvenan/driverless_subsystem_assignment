function manual_cone_track()
    % Manual closed-loop cone track builder
    % Steps:
    % 1) Click to place BLUE cones (left boundary). Press Enter when done.
    % 2) Click to place YELLOW cones (right boundary). Press Enter when done.
    % 3) Script fits splines, computes midline, and plots all.
    %
    % Tip: Place points in clockwise or counterclockwise order around your loop.

    close all; clc;

    % --- Plot setup ---
    figure('Name','Manual Cone Track','Color','w'); axis equal; hold on;
    xlim([-20 20]); ylim([-20 20]);
    grid on; box on;
    title('Click to place BLUE cones (left). Press Enter when done.');

    % --- Collect BLUE cones via clicks ---
    [bx, by] = ginput;  % Press Enter to finish
    blue = [bx by];
    if size(blue,1) < 3
        error('Place at least 3 blue cones for a closed loop.');
    end
    plot(blue(:,1), blue(:,2), 'bo', 'MarkerFaceColor','b', 'DisplayName','Blue cones');

    % --- Collect YELLOW cones ---
    title('Click to place YELLOW cones (right). Press Enter when done.');
    [yx, yy] = ginput;
    yellow = [yx yy];
    if size(yellow,1) < 3
        error('Place at least 3 yellow cones for a closed loop.');
    end
    plot(yellow(:,1), yellow(:,2), 'yo', 'MarkerFaceColor','y', 'DisplayName','Yellow cones');
    legend('Location','best');

    % --- Ensure closed loops: connect end to start for parametric fitting ---
    blueLoop   = ensureClosedLoop(blue);
    yellowLoop = ensureClosedLoop(yellow);

    % --- Order points to avoid crossing (optional nearest-neighbor ordering) ---
    blueLoop   = orderPointsNN(blueLoop);
    yellowLoop = orderPointsNN(yellowLoop);

    % --- Fit periodic splines to boundaries ---
    nSamples = 400;                 % resolution along the loop
    [bluePts, tBlue]   = fitPeriodicSpline(blueLoop, nSamples);
    [yellowPts, tYel]  = fitPeriodicSpline(yellowLoop, nSamples);

    % --- Compute midline (pointwise midpoint) ---
    % We align samples by arc-length using indices; assumes roughly corresponding order
    midline = (bluePts + yellowPts) / 2;

    % --- Plot boundaries and midline ---
    hBlue   = plot(bluePts(:,1),   bluePts(:,2),   'b-', 'LineWidth',1.5, 'DisplayName','Blue boundary');
    hYellow = plot(yellowPts(:,1), yellowPts(:,2), 'y-', 'LineWidth',1.5, 'DisplayName','Yellow boundary');
    hCenter = plot(midline(:,1),   midline(:,2),   'k--','LineWidth',2.0, 'DisplayName','Midline');
    uistack(hCenter, 'top');
    legend([hBlue hYellow hCenter], {'Blue boundary','Yellow boundary','Midline'});

    % --- Save results for later use (planning/control) ---
    save('manual_track.mat', 'blue', 'yellow', 'bluePts', 'yellowPts', 'midline');

    % --- Optional: visualize normals from midline to boundaries ---
    % drawCorrespondenceNormals(midline, bluePts, yellowPts, 25);

    title('Track generated. You can now use midline for planning/control.');
end

% ===== Helpers =====

function loopPts = ensureClosedLoop(pts)
    % Append first point if last != first to close loop
    if ~isequal(pts(1,:), pts(end,:))
        loopPts = [pts; pts(1,:)];
    else
        loopPts = pts;
    end
end

function ordered = orderPointsNN(pts)
    % Nearest-neighbor ordering to reduce crossing for manual clicks
    % Start at first point, iteratively pick nearest unvisited.
    N = size(pts,1);
    ordered = zeros(N,2);
    visited = false(N,1);
    idx = 1;
    ordered(1,:) = pts(1,:);
    visited(1) = true;
    for k = 2:N
        last = ordered(k-1,:);
        d = sqrt(sum((pts - last).^2, 2));
        d(visited) = inf;
        [~, j] = min(d);
        ordered(k,:) = pts(j,:);
        visited(j) = true;
    end
end

function [curvePts, t] = fitPeriodicSpline(pts, nSamples)
    % Fit a periodic cubic spline to a closed-loop point set
    % 1) parameterize by cumulative arc-length
    % 2) wrap to enforce periodicity
    % 3) sample uniformly along t

    % Remove exact duplicates to avoid singularities
    [~, uniqueIdx] = unique(pts, 'rows', 'stable');
    pts = pts(uniqueIdx, :);

    % Arc-length parameter
    seg = diff(pts);
    segLen = sqrt(sum(seg.^2, 2));
    s = [0; cumsum(segLen)];
    if s(end) == 0
        error('Degenerate loop: zero length.');
    end

    % Ensure periodic by appending first point at end (already closed above)
    x = pts(:,1); y = pts(:,2);

    % Fit splines over s
    sx = spline(s, x); sy = spline(s, y);

    % Sample uniformly along s
    t = linspace(0, s(end), nSamples).';
    xs = ppval(sx, t);
    ys = ppval(sy, t);
    curvePts = [xs ys];

    % Close sampled curve for consistency
    curvePts(end+1,:) = curvePts(1,:);
end

function drawCorrespondenceNormals(center, left, right, step)
    % Draw lines from midline to boundaries for quick visual sanity check
    hold on;
    for k = 1:step:size(center,1)
        plot([center(k,1) left(k,1)],  [center(k,2) left(k,2)],  'b:');
        plot([center(k,1) right(k,1)], [center(k,2) right(k,2)], 'y:');
    end
end