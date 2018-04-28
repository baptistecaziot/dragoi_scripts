

clearvars
close all
clc

% These names have to be changed
dataPath = 'C:\Users\baptiste\Documents\MATLAB\foraging\dragoiexp\data\';
NEVfile = 'Mo_noPert_April24.mat';
AVIfile = 'CAM02_20180424154826_-2086358696.mp4';

% These are just plotting parameters
eyeXMin = 0;
eyeYMax = 600;
eyeAMin = 0;
eyeEMax = 960;

% This creates a "dataSession" object
fprintf('\nCreate data object');
sessionObj = dataSession(dataPath, NEVfile, AVIfile);

% This changes some protected parameters
fprintf('\nChange variables');
sessionObj.setVar('velocityThreshold',800,'eyeFilter',2);

% This gets eye position from the NEV file
fprintf('\nUnpack eye position');
sessionObj.unpackEye;

% This remove blinks from the eye position data and interpolate missing samples
fprintf('\nRemove blinks');
sessionObj.cleanBlinks; fprintf(' - %i%% data',round(sessionObj.blinksTrimmed*100/size(sessionObj.eyeT,1)));

% This filters eye pos with a gaussian kernal of std "eyeFilter"
fprintf('\nFilter eye position');
sessionObj.filterEye;

% This computes eye velicity
fprintf('\nCompute eye velocity');
sessionObj.processVelocity;

% This removes saccades with velocity higher than "velocityThreshold"
fprintf('\nRemove saccades');
sessionObj.cleanSaccades; fprintf(' - %i%% data',round(sessionObj.saccadesTrimmed*100/size(sessionObj.eyeT,1)));

% This launches the scene video for tagging treat locations
fprintf('\nTag treat locations');
sessionObj.tagTreats; fprintf(' - %i treats tagged',size(sessionObj.treatsLoc,1));

% This regresses scene position with pupil position and converts eye position to scene position
fprintf('\nConvert to angles');
sessionObj.angleConversion;

% This gets a window around eye position of "RFsize" pixels wide
fprintf('\nUnpack scene video');
sessionObj.unpackScene;


fprintf('\nAll done\n');



figure(1)
subplot(1,3,1)
hold on
plot(sessionObj.eyeTraw,sessionObj.eyeXraw,'Color',[1,0,0,0.2])
plot(sessionObj.eyeTraw,sessionObj.eyeYraw,'Color',[0,1,0,0.2])
plot(sessionObj.eyeTraw,sessionObj.eyePraw,'Color',[0,0,0,0.2])
plot(sessionObj.eyeT,sessionObj.eyeX,'Color',[1,0,0,1])
plot(sessionObj.eyeT,sessionObj.eyeY,'Color',[0,1,0,1])
plot(sessionObj.eyeT,sessionObj.eyeP,'Color',[0,0,0,1])
axis([min(sessionObj.eyeT),max(sessionObj.eyeT),eyeXMin,eyeYMax])
% legend({'$X$','$Y$','$P$'},'Interpreter','latex')

subplot(1,3,2)
hold on
plot(sessionObj.eyeT,sessionObj.eyeXdot,'Color',[1,0,0,1])
plot(sessionObj.eyeT,sessionObj.eyeYdot,'Color',[0,1,0,1])
plot(sessionObj.eyeT,sessionObj.eyePdot,'Color',[0,0,0,1])
plot([min(sessionObj.eyeT),max(sessionObj.eyeT)],sessionObj.velocityThreshold*[+1,-1;+1,-1],'k--')
axis([min(sessionObj.eyeT),max(sessionObj.eyeT),-2*sessionObj.velocityThreshold,+2*sessionObj.velocityThreshold])
% legend({'$\dot{X}$','$\dot{Y}$','$\dot{P}$','thres'},'Interpreter','latex')

subplot(1,3,3)
plot(sessionObj.eyeX,sessionObj.eyeY,'k')
axis([min(sessionObj.eyeX),max(sessionObj.eyeX),min(sessionObj.eyeY),max(sessionObj.eyeY)])


figure(2)
subplot(1,2,1)
hold on
plot(sessionObj.eyeT,sessionObj.eyeX,'Color',[1,0,0,1])
plot(sessionObj.eyeT,sessionObj.eyeY,'Color',[0,1,0,1])
axis([min(sessionObj.eyeT),max(sessionObj.eyeT),eyeXMin,eyeYMax])
% legend({'$X$','$Y$'},'Interpreter','latex')

subplot(1,2,2)
hold on
plot(sessionObj.eyeT,sessionObj.eyeE,'Color',[1,0,0,1])
plot(sessionObj.eyeT,sessionObj.eyeA,'Color',[0,1,0,1])
axis([min(sessionObj.eyeT),max(sessionObj.eyeT),eyeAMin,eyeEMax])
% legend({'$A$','$E$'},'Interpreter','latex')


vwriter = VideoWriter('demo.avi','Grayscale AVI');
vwriter.FrameRate = 30;
open(vwriter)
for ff=1:600
    fprintf('\nWriting video..%i%%',ceil(100*ff/600));
    writeVideo(vwriter,reshape(sessionObj.scene(:,ff),sessionObj.RFsize,sessionObj.RFsize)./255);
end
close(vwriter);



