% Author: Fangchang Ma
%
% Email: fcma@mit.edu
%
% Last Updated: July 31, 2016
%
% Purpose: This is an example script for you to learn about a few things in
% MATLAB, including: add reference path, creating variables, use of other
% functions in a script, visualization of data


close all;  % close all windows in MATLAB
clear;      % clear the workspace (delete all variables)
clc;        % clear the command window

%% General settings (provided, no need to change)
addpath('lib')  % add reference path to functions in the library
addpath('dataset_1') % add path so that MATLAB knows where to find the data
addpath('dataset_2') % add path so that MATLAB knows where to find the data

% "settings" is a structure variable, containing many sub-fields
settings.path = 'dataset_2';     % specify the path to the data
settings.subSample = 0.5;   % downsample the data by 20% to speed up
settings.min_depth = 500;   % minimum valid distance in milimeters
settings.max_depth = 4500;   % maximum valid distance in milimeters

%% User settings (feel free to make any change)
doShowData = false;
doSURF = false;
do3DStitching = true;

%% Loading the data
[ depth_a, rgb_a, odom_a ] = load_and_process_data( settings, 20 );
[ depth_b, rgb_b, odom_b ] = load_and_process_data( settings, 30 );

%% SURF feature detection
if doSURF
    figure;
    subplot(221); imshow(rgb_a);
    subplot(222); imshow(rgb_b);
    subplot(223); imshow(depth_a);
    subplot(224); imshow(depth_b);
    
    num_strongest = 30;

    % feature extraction on gray scale images
    points_a = detectSURFFeatures(rgb2gray(rgb_a));
    points_b = detectSURFFeatures(rgb2gray(rgb_b));
    subplot(221); hold on; plot(points_a.selectStrongest(num_strongest));
    subplot(222); hold on; plot(points_b.selectStrongest(num_strongest));

    % feature extraction on depth
    points_a = detectSURFFeatures(depth_a);
    points_b = detectSURFFeatures(depth_b);
    subplot(223); hold on; plot(points_a.selectStrongest(num_strongest));
    subplot(224); hold on; plot(points_b.selectStrongest(num_strongest));
   
end

%% 3-D Point Cloud Registration and Stitching
if do3DStitching
    ptCloud_a = depth2pc(depth_a, rgb_a, odom_a, settings);
    ptCloud_b = depth2pc(depth_b, rgb_b, odom_b, settings);

    % Begin by finding the rigid transformation for aligning the second point 
    % cloud with the first point cloud.
    tform = pcregrigid(ptCloud_b, ptCloud_a, 'Metric','pointToPlane','Extrapolate', true);

    % Use it to transform the second point cloud to the reference coordinate 
    % system defined by the first point cloud.
    ptCloudAligned = pctransform(ptCloud_b, tform);

    % merge point cloud
    mergeSize = 0.015;
    ptCloudScene = pcmerge(ptCloud_a, ptCloudAligned, mergeSize);

    % visualizaiton
    figure
    subplot(2,2,1)
    imshow(rgb_a)
    title('First input image')
    drawnow

    subplot(2,2,3)
    imshow(rgb_b)
    title('Second input image')
    drawnow

    % Visualize the world scene.
    subplot(2,2,[2,4])
    pcshow(ptCloudScene, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
    title('Initial world scene')
    xlabel('X (m)')
    ylabel('Y (m)')
    zlabel('Z (m)')
    drawnow
end
accumTform = tform;

figure 
hAxes = pcshow(ptCloudScene, 'VerticalAxis', 'Y', 'VerticalAxisDir','Down');
title('Updated world scene')
hAxes.CameraViewAngleMode ='auto';
hScatter = hAxes. Children;

for i = 40 :5 : 200
   
    [depth_c, rgb_c, odom_c ] = load_and_process_data( settings, i );
    ptCloudCurrent = depth2pc(depth_c, rgb_c, odom_c, settings);
    ptCloud_a= ptCloud_b;
    gridSize = 0.1;
    ptCloud_b = pcdownsample(ptCloudCurrent,'gridAverage', gridSize);
    tform = pcregrigid(ptCloud_a, ptCloud_b, 'Metric', 'pointToPlane', 'Extrapolate', true);
    accumTform = affine3d(accumTform.T* tform.T);
    ptCloudAligned = pctransform (ptCloudCurrent, accumTform);
    ptCloudScene = pcmerge(ptCloudScene, ptCloudAligned, mergeSize);
    
end
    hScatter.XData = ptCloudScene.Location(:,1);
    hScatter.YData = ptCloudScene.Location(:,2);
    hScatter.ZData = ptCloudScene.Location(:,3);
    hScatter.CData = ptCloudScene.Color;
    drawnow('limitrate')










