%
% Syntax:
% [measure dt] = getMeasures(format)
% 
% In:
%   format  - indicate the data format (optional,default 2)
%           - 0: .txt file format [time range radian velosity]
%           - 1: .xls file format [...]
%           - 2: no file available,use the simualted data
% 
% Out:   
%   measure - the measure matrix 4xD
%   dt      - time difference between two measures
%
% Author:
%           - laishaofa@gmail.com

function [ raIn, xyIn, time, n ] = getMeasures( format )
    if nargin < 1
        format = 0;
    end
    
%%%%%%%%%%%% .txt format
    if 0 == format                    
         raw = dlmread('./data/filter_in.txt')';
        n = size(raw, 2);
        raIn = zeros(3, n);
        time = raw(1, :);
        raIn(1, :) = raw(2,:);
        raIn(2, :) = (90-raw(3,:)) .* pi ./ 180.0;
        raIn(3, :) = raw(4,:);
        xyIn(1, :) = raIn(1, :) .* cos(raIn(2, :));
        xyIn(2, :) = raIn(3, :) .* cos(raIn(2, :));
        xyIn(3, :) = 0;
        xyIn(4, :) = raIn(1, :) .* sin(raIn(2, :));
        xyIn(5, :) = raIn(3, :) .* sin(raIn(2, :));
        xyIn(6, :) = 0;
        
%%%%%%%%%%%% .xls format
    elseif 1==format
        raw = xlsread('2015-01-08-11-27-51-1294');
        n = size(raw, 1);
        raIn = zeros(3, n);
        time = raw(:,3) ./ 10000;
        raIn(1, :) = raw(:, 4) ./ 100;
        raIn(2, :) = raw(:, 5) ./ 10 ./ 180 .* pi;
        raIn(3, :) = raw(:, 6) ./ 100;
        time = time;
        for i = 2 : n
            time(i) = time(i) - time(i-1);
        end
        time(1) = 10;
        
%%%%%%%%%%%% simulation format
    elseif 2==format
        dT = 0.05;
        n = 200;
        state = zeros(6, n);
        state(:, 1) = [10, 10, 0.1, 1, 0, 0.1]';
        for i = 2 : n
            state(:, i) = ukf_track_f(state(:, i-1), dT);
        end
        raIn = ukf_track_h(state);
        raIn(1, :) = raIn(1, :) + normrnd(0, 1, 1, n);
        raIn(2, :) = raIn(2, :) + normrnd(0, 0.01, 1, n);
        raIn(3, :) = raIn(3, :) + normrnd(0, 0.01, 1, n);
        time = zeros(1, n);
        for i = 1 : n
            time(i) = dT;
        end
    end
end

