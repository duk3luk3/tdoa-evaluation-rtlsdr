%  Experimental Evaluation Script for RTL-SDR based TDOA
%  DC9ST, 2017-2019
% =========================================================================

clear;
clc;
close all;

% adds subfolder with functions to PATH
[p,n,e] = fileparts(mfilename('fullpath'));
addpath([p '/functions']);
addpath([p '/test']); % only required for the test setups


%% Read Parameters from config file, that specifies all parameters
%---------------------------------------------
%config;

%---------------------------------------------
% Test modes:
% for testing, generate html with configs below and compare output with
% reference html in /test
%config_test;
%config_test_fm;
%config_test_other;
% --------------------------------------------

config_mystery2;

% calculate geodetic reference point as mean center of all RX positions
geo_ref_lat  = mean([rx1_lat, rx2_lat, rx3_lat]);
geo_ref_long = mean([rx1_long, rx2_long, rx3_long]);
disp(['geodetic reference point (mean of RX positions): lat=' num2str(geo_ref_lat, 8) ', long=' num2str(geo_ref_long, 8) ])

% distance between two RXes in meters
rx_distance12 = dist_latlong(rx1_lat, rx1_long, rx2_lat, rx2_long, geo_ref_lat, geo_ref_long);
rx_distance13 = dist_latlong(rx1_lat, rx1_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);
rx_distance23 = dist_latlong(rx2_lat, rx2_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);


doa_meters12 = (rx1_ts - rx2_ts) * 3e8;
doa_meters13 = (rx1_ts - rx3_ts) * 3e8;
doa_meters23 = (rx2_ts - rx3_ts) * 3e8;

disp(['doa_meters12 = ' num2str(doa_meters12)]);
disp(['doa_meters13 = ' num2str(doa_meters13)]);
disp(['doa_meters23 = ' num2str(doa_meters23)]);

%% Generate html map
disp(' ');
disp('______________________________________________________________________________________________');
disp('GENERATE HYPERBOLAS');

[points_lat1, points_long1] = gen_hyperbola(doa_meters12, rx1_lat, rx1_long, rx2_lat, rx2_long, geo_ref_lat, geo_ref_long);
[points_lat2, points_long2] = gen_hyperbola(doa_meters13, rx1_lat, rx1_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);
[points_lat3, points_long3] = gen_hyperbola(doa_meters23, rx2_lat, rx2_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);

disp(' ');
disp('______________________________________________________________________________________________');
disp('GENERATE HTML');
rx_lat_positions  = [rx1_lat   rx2_lat   rx3_lat ];
rx_long_positions = [rx1_long  rx2_long  rx3_long];

hyperbola_lat_cell  = {points_lat1,  points_lat2, points_lat3};
hyperbola_long_cell = {points_long1, points_long2, points_long3};

[heatmap_long, heatmap_lat, heatmap_mag] = create_heatmap(doa_meters12, doa_meters13, doa_meters23, rx1_lat, rx1_long, rx2_lat, rx2_long, rx3_lat, rx3_long, heatmap_resolution, geo_ref_lat, geo_ref_long); % generate heatmap
heatmap_cell = {heatmap_long, heatmap_lat, heatmap_mag};

if strcmp(map_mode, 'google_maps')
    % for google maps
    create_html_file_gm( ['ergebnisse/map_' file_identifier '_' corr_type '_interp' num2str(interpol_factor) '_bw' int2str(signal_bandwidth_khz) '_smooth' int2str(smoothing_factor) '_gm.html'], rx_lat_positions, rx_long_positions, hyperbola_lat_cell, hyperbola_long_cell, heatmap_cell, heatmap_threshold);
else
    % for open street map
    create_html_file_osm( ['ergebnisse/map_' file_identifier '_' corr_type '_interp' num2str(interpol_factor) '_bw' int2str(signal_bandwidth_khz) '_smooth' int2str(smoothing_factor) '_osm.html'], rx_lat_positions, rx_long_positions, hyperbola_lat_cell, hyperbola_long_cell, heatmap_cell, heatmap_threshold);
end
disp('______________________________________________________________________________________________');

