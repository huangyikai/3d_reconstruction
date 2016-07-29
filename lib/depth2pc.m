function ptCloud = depth2pc(depth, rgb, odom, settings)
% DEPTH2PC Converts data from depth and rgb images to colored point cloud
%   The transformations by order is:
%       image plane -> camera frame
%       camera frame -> vehicle frame (calibration for tilting of Kinect camera, if any)
%       vehicle frame -> world frame (using odometry information)
%
% Following conventions in ROS, the axes in a coordinate frame is defined
% as follows:
%   x: pointing forward
%   z: pointing upward
%   y: pointing to the left


%% Load intrinsic parameters of the camera
load intrinsic_parameters.mat
height = ceil(H * settings.subSample);
width = ceil(W * settings.subSample);
fu = fu * settings.subSample; 
fv = fv * settings.subSample; 
center_u = center_u * settings.subSample;
center_v = center_v * settings.subSample;

%% Vectorize all computation
% U and V are columns and rows in the image plane
% U is from left to right, and V is from top to bottom
[U,V] = meshgrid(1:width, 1:height);
u = reshape(U, [], 1);
v = reshape(V, [], 1);

% reshape each channel into columns
if numel(rgb) > 0
    colors = reshape(rgb, [], 3);
end


if ~exist('tilting', 'var') 
    tilting = 0;
end

%% image plane -> camera frame
x_cam = double(reshape(depth, [], 1));

% remove invalid depth data
valid_mask = find ( (x_cam > settings.min_depth) & (x_cam < settings.max_depth) ); 
x_cam = x_cam(valid_mask, :);
u = u(valid_mask, :);
v = v(valid_mask, :);
colors = colors(valid_mask, :);

% compute y and z in camera frame
y_cam = (center_u - u) / fu .* x_cam; 
z_cam = (center_v - v) / fv .* x_cam;

%% camera frame -> vehicle frame (calibrate for the tilting angle)
% tilting angle is positive when the camera looks down
% TODO: tilting has no effect?
y_vehicle = y_cam;
x_vehicle = z_cam * sin(tilting) + x_cam * cos(tilting);
z_vehicle = z_cam * cos(tilting) - x_cam * sin(tilting);

%% vehicle frame -> world frame
t_x = odom.Position.X;
t_y = odom.Position.Y;
Theta = odom.Theta * pi / 180;  % convert from degree to radian
z = z_vehicle;
[x, y] = transform2d_body2world( x_vehicle, y_vehicle, t_x, t_y, Theta );
xyzPoints = [x y z];

%% add color to the point cloud
% pcshow(xyzPoints, colors)
if numel(rgb) > 0
    ptCloud = pointCloud(xyzPoints, 'Color', colors);
else
    ptCloud = pointCloud(xyzPoints);
end