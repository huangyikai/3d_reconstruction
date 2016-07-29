function [ depth, rgb, odom ] = load_and_process_data( settings, id )
%LOAD_AND_PROCESS_DATA Load .mat files that contain rgb and depth images, as welll as odometry information
%   Detailed explanation goes here

filename = sprintf([settings.path, '/%03d.mat'], id);
load(filename)

%% Chopping for Kinect data
% the rgb images have two empty strips on the top and bottom
bottom_row = 400;
top_row = 40;
depth(bottom_row:end,:) = zeros(size(depth(bottom_row:end,:)));
depth(1:top_row,:) = zeros(size(depth(1:top_row,:)));

%% Downsampling the images
depth = imresize(depth, settings.subSample, 'nearest');
rgb = imresize(rgb, settings.subSample, 'nearest');

%% Odometry
odom.Position = Position;  
% convert from meters to milimeters
odom.Position.X = 1000 * odom.Position.X;
odom.Position.Y = 1000 * odom.Position.Y;
odom.Position.Z = 1000 * odom.Position.Z;

% odom.Orientation = Orientation; % in quaternion representation
odom.Theta = Theta; % note that this theta is extracted from Orientation for simplicity

end

