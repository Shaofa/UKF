clc
clear all;

%% get mesurements
FORMAT_SIM  = 2;
FORMAT_XLS  = 1;
FORMAT_TXT  = 0;
FORMAT      = FORMAT_TXT;
PI_RD = 180./pi;

Q = diag([0.2, 0.02, 0.002, 0.2, 0.02, 0.002]);
R = diag([0.5, 0.00087, 0.05]);

P = diag([0.6, 0.9, 0.1, 0.4, 0.3, 0.07]);
alpha = 0.1;
beta = 2;
kappa = 0; 
mat = 1;
f_func = @ukf_track_f;
h_func = @ukf_track_h;
%% UKF filtering
[raIn, xyIn, time, n] = getMeasures(FORMAT);
raOut = zeros(size(raIn));
xyOut = xyIn;
X = xyIn(:,1);
errorCnt = 0;
hasError = 0;
error_idx=zeros(size(raIn,2),1);
for i = 2 : n
    [Xpre, Ppre] = ukf_predict1(X, P, f_func, Q, time(i)-time(i-1), alpha, beta, kappa, mat);
    Zpre = ukf_track_h(X);
    if abs(Zpre(2) - raIn(2,i)) > (3./180*pi) || abs(Zpre(1) - raIn(1,i))>2.
        errorCnt = errorCnt + 1;
        hasError = 1;
    else
        errorCnt = 0;
        hasError = 0;
    end
    if errorCnt > 4
        errorCnt = 0;
        X = xyIn(:,i);
    end
    if ~hasError
        [X, P] = ukf_update1(Xpre, Ppre, raIn(:,i), h_func, R, [], alpha, beta, kappa, mat);
    end
    xyOut(:,i) = X;
end
raOut = ukf_track_h(xyOut);

%% errors------------------------------------------------------------------
xyErr = xyOut - xyIn;
raErr = raOut - raIn;

%% plot---------------------------------------------------------------------
figure(1);
clf;
plot(xyIn(1,:), xyIn(4,:), '*b');
hold on;
plot(xyOut(1,:), xyOut(4,:), 'r', 'LineWidth', 2);
legend('Measurement', 'Smoothed')
xlabel('x/m');
ylabel('y/m');
title('UKF');
set(gca,'XGrid','on');
set(gca,'YGrid','on');

figure(2);
clf;
subplot(2,1,1);
plot(raIn(1,:),'b');
hold on;
plot(raOut(1,:), 'r', 'linewidth', 1.5);
set(gca,'XGrid','on');
set(gca,'YGrid','on');
legend('Measurement', 'Smoothed')
ylabel('Range/m');
title('UKF');

subplot(2,1,2);
plot(90-raIn(2,:).*180./pi, 'b');
hold on;
plot(90-raOut(2,:).*180./pi, 'r', 'linewidth', 1.5);
set(gca,'XGrid','on');
set(gca,'YGrid','on');
legend('Measurement', 'Smoothed')
xlabel('time/0.048 sec');
ylabel('Angle/degree');


% figure;
% subplot(2,1,1);
% plot(1:n, error_xy(1,:), 'b', 'LineWidth', 1);
% ylabel('xƫ��/��');
% title('x������� �˲�ֵ-����ֵƫ��');
% set(gca,'XGrid','on');
% set(gca,'YGrid','on');
% 
% subplot(2,1,2);
% plot(1:n, error_xy(4,:), 'r', 'LineWidth', 1);
% ylabel('yƫ��/��');
% title('y������� �˲�ֵ-����ֵƫ��');
% set(gca,'XGrid','on');
% set(gca,'YGrid','on');

% 
% if(READ_MODE == READ_NULL)
% figure;plot(x,y,'b','LineWidth',1);
% hold on;
% plot(stata_m(1,:),stata_m(4,:),'r','LineWidth',1);
% legend('��ʵ�켣','�˲�ֵ�켣')
% xlabel('x������루�ף�');
% ylabel('y������루�ף�');
% title('�˲�Ч��ͼ');
% set(gca,'FontSize',15);
% set(get(gca,'YLabel'),'Fontsize',20)
% set(get(gca,'XLabel'),'Fontsize',20)
% set(get(gca,'title'),'Fontsize',20)
% 
%     figure;plot(1:n,offset_measX,'r',1:n,offset_filtX,'b');
%     title('x����������');
%     legend('����ֵ���','�˲�ֵ���');
%     ylabel('x����������ף�');
%     set(gca,'FontSize',15);
%     set(get(gca,'YLabel'),'Fontsize',20)
%     set(get(gca,'XLabel'),'Fontsize',20)
%     set(get(gca,'title'),'Fontsize',20)
%     
%     figure;plot(1:n,offset_measY,'r',1:n,offset_filtY,'b');
%     title('y����������');
%     legend('����ֵ���','�˲�ֵ���');
%     ylabel('y����������ף�');
%     set(gca,'FontSize',15);
%     set(get(gca,'YLabel'),'Fontsize',20)
%     set(get(gca,'XLabel'),'Fontsize',20)
%     set(get(gca,'title'),'Fontsize',20)
% end;
