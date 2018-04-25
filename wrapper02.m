

clearvars
close all
clc

dataPath = 'C:\Users\baptiste\Documents\MATLAB\foraging\dragoiexp\';
NEVfile = 'Mo_noPert_April24.mat';
AVIfile = 'CAM02_20180424160124_-2086292412.avi';

eyePosMin = 0;
eyePosMax = 600;
eyeVelMin = 0;
eyeVelMax = 1000;

fprintf('\nCreate data object');
sessionObj = dataSession(dataPath, NEVfile, AVIfile);

fprintf('\nChange variables');
sessionObj.setVar('cleanBlinks',1,'cleanSaccades',0,'velocityThreshold',1000);

fprintf('\nUnpack eye position');
sessionObj.unpackEye;

fprintf('\nCompute eye velocity');
sessionObj.processVelocity;

fprintf('\nRemove blinks and saccades');
sessionObj.cleanEye;

fprintf('\nUnpack scene video');
sessionObj.unpackScene;

% fprintf('\nTag treat locations');
% obj = dataSession(dataPath, sessionName, sessionName);

fprintf('\nAll done\n');


figure(1)
subplot(1,3,1)
plot(sessionObj.eyeT,sessionObj.eyeX,sessionObj.eyeT,sessionObj.eyeY,sessionObj.eyeT,sessionObj.eyeP)
axis([min(sessionObj.eyeT),max(sessionObj.eyeT),eyePosMin,eyePosMax])
legend({'$X$','$Y$','$P$'},'Interpreter','latex')

subplot(1,3,2)
hold on
plot(sessionObj.eyeT,sessionObj.eyeXdot,sessionObj.eyeT,sessionObj.eyeYdot,sessionObj.eyeT,sessionObj.eyePdot)
plot([min(sessionObj.eyeT),max(sessionObj.eyeT)],sessionObj.velocityThreshold*[1,1],'k--')
axis([min(sessionObj.eyeT),max(sessionObj.eyeT),eyeVelMin,eyeVelMax])
legend({'$\dot{X}$','$\dot{Y}$','$\dot{P}$'},'Interpreter','latex')

subplot(1,3,3)
plot(sessionObj.eyeX,sessionObj.eyeY,'k')
axis([eyePosMin,eyePosMax,eyePosMin,eyePosMax])



