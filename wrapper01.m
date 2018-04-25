tic;
filePath = 'C:\Users\baptiste\Documents\MATLAB\foraging\dragoiexp\';

sessionName = 'Mo_noPert_April24';
load([filePath sessionName '.mat']);
eventStruct = parseNEVDigitalIO(NEV);
toc

timeStamp = readVideoTimeStamp([filePath sessionName]);

% load ([filePath 'data\' sessionName 'TimeStamp.mat'],'timeStampOCR')
%% array of task events

taskSignal.resp = zeros(1,length(eventStruct.resp1TimeStamps)+length(eventStruct.resp2TimeStamps));
taskSignal.rew = zeros(1,length(eventStruct.resp1TimeStamps)+length(eventStruct.resp2TimeStamps));
taskSignal.timeStamps = sort([eventStruct.resp1TimeStamps;eventStruct.resp2TimeStamps])';
[t,indSorted] = sort([eventStruct.resp1TimeStamps;eventStruct.resp2TimeStamps]);
taskSignal.resp(find(indSorted<=length(eventStruct.resp1TimeStamps))) = 1;
taskSignal.resp(find(indSorted>length(eventStruct.resp1TimeStamps))) = 2;

for i = 1:length(eventStruct.rew1TimeStamps),
    [m,ind] = min(abs(taskSignal.timeStamps-eventStruct.rew1TimeStamps(i))); 
    taskSignal.rew(ind) = 1;
end

for i = 1:length(eventStruct.rew2TimeStamps),
    [m,ind] = min(abs(taskSignal.timeStamps-eventStruct.rew2TimeStamps(i))); 
    taskSignal.rew(ind) = 2;
end

%% pre-processing eye data
figure
plot(eventStruct.eyeX, '.')
hold on
plot(eventStruct.eyeY, 'r.')
plot(eventStruct.pupilSize, 'k.')

eyeX = eventStruct.eyeX;
eyeY = eventStruct.eyeY;
pupilSize = eventStruct.pupilSize;


indInvalid = find(eventStruct.eyeX==0 & eventStruct.eyeX==0 & eventStruct.pupilSize==1);

eyeX(indInvalid) = nan;
eyeY(indInvalid) = nan;
pupilSize(indInvalid) = nan;

indOutlier  = find(abs(eyeX-nanmean(eyeX))>3*nanstd(eyeX)); 
indOutlier2  = find(abs(eyeY-nanmean(eyeY))>3*nanstd(eyeY)); 
indOutlier3  = find(abs(pupilSize-nanmean(pupilSize))>3*nanstd(pupilSize)); 

eyeX(indOutlier) = nan;
eyeY(indOutlier2) = nan;
pupilSize(indOutlier3) = nan;
% eventStruct.pupilSize(indInvalid) = nan;


figure
plot(eyeX, '.')
hold on
plot(eyeY, 'r.')
plot(pupilSize, 'k.')

res = 0.1; % temporal resolution (sec) 
mx = ceil(eventStruct.eyetrackerEventTimeStamps(end)/res);
eyeSignal.eyeX = nan(1, mx); 
eyeSignal.eyeY = nan(1, mx); 
eyeSignal.pupilSize = nan(1, mx); 
eyeSignal.eyeX(round(eventStruct.eyetrackerEventTimeStamps/res)) = eyeX;
eyeSignal.eyeY(round(eventStruct.eyetrackerEventTimeStamps/res)) = eyeY;
eyeSignal.pupilSize(round(eventStruct.eyetrackerEventTimeStamps/res)) = pupilSize;


%% eye position and pupil size per event

clear eye*resp* pupilSizeResp*
preDur = 3;
trialLength = 5;

for j = 1:length(taskSignal.timeStamps)
    st = ceil((taskSignal.timeStamps(j)-preDur)/res);
    eyeSignal.eyeXresp(j,:) = eyeSignal.eyeX(st+(1:trialLength/res));
    eyeSignal.eyeYresp(j,:) = eyeSignal.eyeY(st+(1:trialLength/res));
    eyeSignal.pupilSizeResp(j,:) = eyeSignal.pupilSize(st+(1:trialLength/res));
end


[mX1,eX1] = mWe(eyeSignal.eyeXresp(taskSignal.resp==1,:),1);
[mY1,eY1] = mWe(eyeSignal.eyeYresp(taskSignal.resp==1,:),1);
[mPupil1,ePupil1] = mWe(eyeSignal.pupilSizeResp(taskSignal.resp==1,:),1);

[mX2,eX2] = mWe(eyeSignal.eyeXresp(taskSignal.resp==2,:),1);
[mY2,eY2] = mWe(eyeSignal.eyeYresp(taskSignal.resp==2,:),1);
[mPupil2,ePupil2] = mWe(eyeSignal.pupilSizeResp(taskSignal.resp==2,:),1);

figure
subplot(1,3,1)
hold on
errorbar(-preDur/res+(1:trialLength/res),mX1, eX1)
errorbar(-preDur/res+(1:trialLength/res),mX2, eX2)

subplot(1,3,2)
hold on
errorbar(-preDur/res+(1:trialLength/res),mY1, eY1)
errorbar(-preDur/res+(1:trialLength/res),mY2, eY2)

subplot(1,3,3)
hold on
errorbar(-preDur/res+(1:trialLength/res),mPupil1, ePupil1)
errorbar(-preDur/res+(1:trialLength/res),mPupil2, ePupil2)


[mX1,eX1] = mWe(eyeSignal.eyeXresp(taskSignal.rew==1,:),1);
[mY1,eY1] = mWe(eyeSignal.eyeYresp(taskSignal.rew==1,:),1);
[mPupil1,ePupil1] = mWe(eyeSignal.pupilSizeResp(taskSignal.rew==1,:),1);

[mX2,eX2] = mWe(eyeSignal.eyeXresp(taskSignal.rew==2,:),1);
[mY2,eY2] = mWe(eyeSignal.eyeYresp(taskSignal.rew==2,:),1);
[mPupil2,ePupil2] = mWe(eyeSignal.pupilSizeResp(taskSignal.rew==2,:),1);

figure
subplot(1,3,1)
hold on
errorbar(-preDur/res+(1:trialLength/res),mX1, eX1)
errorbar(-preDur/res+(1:trialLength/res),mX2, eX2)

subplot(1,3,2)
hold on
errorbar(-preDur/res+(1:trialLength/res),mY1, eY1)
errorbar(-preDur/res+(1:trialLength/res),mY2, eY2)

subplot(1,3,3)
hold on
errorbar(-preDur/res+(1:trialLength/res),mPupil1, ePupil1)
errorbar(-preDur/res+(1:trialLength/res),mPupil2, ePupil2)



[mX1,eX1] = mWe(eyeSignal.eyeXresp(taskSignal.rew==0,:),1);
[mY1,eY1] = mWe(eyeSignal.eyeYresp(taskSignal.rew==0,:),1);
[mPupil1,ePupil1] = mWe(eyeSignal.pupilSizeResp(taskSignal.rew==0,:),1);

[mX2,eX2] = mWe(eyeSignal.eyeXresp(taskSignal.rew>0,:),1);
[mY2,eY2] = mWe(eyeSignal.eyeYresp(taskSignal.rew>0,:),1);
[mPupil2,ePupil2] = mWe(eyeSignal.pupilSizeResp(taskSignal.rew>0,:),1);

figure
subplot(1,3,1)
hold on
errorbar(-preDur/res+(1:trialLength/res),mX1, eX1)
errorbar(-preDur/res+(1:trialLength/res),mX2, eX2)

subplot(1,3,2)
hold on
errorbar(-preDur/res+(1:trialLength/res),mY1, eY1)
errorbar(-preDur/res+(1:trialLength/res),mY2, eY2)

subplot(1,3,3)
hold on
errorbar(-preDur/res+(1:trialLength/res),mPupil1, ePupil1)
errorbar(-preDur/res+(1:trialLength/res),mPupil2, ePupil2)

%% correlation of pupil size and reward expectation

tslr1 = diff([0 taskSignal.timeStamps(taskSignal.resp==1)]); 
tslr2 = diff([0 taskSignal.timeStamps(taskSignal.resp==2)]);
tslr(taskSignal.resp==1) = tslr1;
tslr(taskSignal.resp==2) = tslr2;
tslr(1) = nan;

tslr(tslr<2) = nan;
tslr(tslr>30) = nan;
taskSignal.tslr = tslr;

figure
plot(log(taskSignal.tslr), nanmean(eyeSignal.pupilSizeResp(:,10:20),2),'r.')


winSize = 1;
for w = 1:trialLength/res-winSize,
    ind = find(~isnan(taskSignal.tslr)' & ~isnan(nanmean(eyeSignal.pupilSizeResp(:,w+(1:winSize)),2)));
    [R,P] = corrcoef(log(taskSignal.tslr(ind)),nanmean(eyeSignal.pupilSizeResp(ind,w+(1:winSize)),2));
    pupiSizeCorr(w) = R(1,2);
end

figure
plot(pupiSizeCorr)

%%





