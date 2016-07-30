% Author: Fangchang Ma
%
% Email: fcma@mit.edu
%
% Last Updated: July 28, 2016
%
% Purpose: This is an example script for you to learn about a few things in
% MATLAB, including: add reference path, creating variables, use of other
% functions in a script, visualization of data
%
% TODO: learn to merge point clouds. More specifically,
%   0. Understand this example.
%   1. Learn about the MATLAB function "pcmerge" and use it to merge two
%   point clouds
%   2. Once you learn to use "pcmerge", write a for-loop to merge all
%   point clouds in a dataset


close all;  % close all windows in MATLAB
clear;      % clear the workspace (delete all variables)
clc;        % clear the command window

%% General settings (provided, no need to change)
addpath('lib')  % add reference path to functions in the library
addpath('dataset_1') % add path so that MATLAB knows where to find the data
% addpath('dataset_2') % add path so that MATLAB knows where to find the data

% "settings" is a structure variable, containing many sub-fields
settings1.path = 'dataset_1';     % specify the path to the data
settings1.subSample = 1;   % downsample the data by 20% to speed up
settings1.min_depth = 500;   % minimum valid distance in milimeters
settings1.max_depth = 4500;   % maximum valid distance in milimeters



%% User settings (feel free to make any change)
doShow = true;
%%

%% Load data
% "load_and_process_data" is a function provided in the library to load
% data of particular format
  [ depth, rgb, odom ] = load_and_process_data( settings1, 1 );
% "depth2pc" is a function provided in the library to convert a depth image
% to a point cloud
  ptCloud1 = depth2pc(depth, rgb, odom, settings1);
%Another ptcloud
  [ depth, rgb, odom ] = load_and_process_data( settings1, 2 );
  ptCloud2 = depth2pc(depth, rgb, odom, settings1);
% merging tow ptcloud
  ptCloud1 = pcmerge(ptCloud1,ptCloud2,1);
  for a = 3 : 5 : 500;
       [ depth, rgb, odom ] = load_and_process_data( settings1, a );
       ptCloud2 = depth2pc(depth, rgb, odom, settings1);
       ptCloud1 = pcmerge(ptCloud2, ptCloud1,2);
  end
%% Visualize 3d point cloud
if doShow
    figure; 
    markersize = 1;
    pcshow(ptCloud1, 'MarkerSize', markersize);
    title('Yikai');

end



