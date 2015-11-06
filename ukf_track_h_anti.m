function [ x ] = ukf_track_h_anti__(y)
%跟踪滤波的测量过程的反过程（采用UKF），用于验证 ukf_track_h是否正确
%输入： 测量值
%输出： 倒退出来的实际值
x = zeros(6,size(y,2));
x(1,:) = y(1,:) .* cos(y(2,:));
x(4,:) = y(1,:) .* sin(y(2,:));
x(2,:) = y(3,:) .* cos(y(2,:));
x(5,:) = y(3,:) .* sin(y(2,:));
end