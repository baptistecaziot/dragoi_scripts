function eventStruct = parseNEVDigitalIO(NEV)



tmp1 = NEV.Data.SerialDigitalIO.UnparsedData;
%make sure it looks like a string
tmp1 = char(tmp1);
%make sure the data is a row
if iscolumn(tmp1)
    tmp1 = tmp1';
end

tmp2 = NEV.Data.SerialDigitalIO.TimeStampSec;
if isrow(tmp2)
    tmp2 = tmp2';
end

eyeTrackerEvents = find(NEV.Data.SerialDigitalIO.InsertionReason == 129);
character_array = tmp1(eyeTrackerEvents);
time_array = tmp2(eyeTrackerEvents);

taskEvents = find(NEV.Data.SerialDigitalIO.InsertionReason == 1);
characterArray = tmp1(taskEvents);
timeArray = tmp2(taskEvents);

%find all newlines
all_cr_locations = find(character_array == 10);
%find all tabs
all_tab_locations = find(character_array == 9);

%check that row lengths are all the same
tabs_between_cr = zeros(length(all_cr_locations) - 1, 1);
for i = 1:length(all_cr_locations) - 1
    tabs_between_cr(i,1) = length(find(all_tab_locations > all_cr_locations(i) & all_tab_locations < all_cr_locations(i+1)));
end
assert(length(unique(tabs_between_cr)) == 1, 'row length varies, error\n');
columns = unique(tabs_between_cr);


%build matrix (first, between all of the returns)
matrix = zeros(length(all_cr_locations) - 1, columns + 1);
for i = 1:length(all_cr_locations) - 1
    fprintf('\nProcessing..%i%%', round(i*100/length(all_cr_locations)));
    tabs_for_line = all_tab_locations(all_tab_locations > all_cr_locations(i) & all_tab_locations < all_cr_locations(i+1));
    
    matrix(i,columns + 1) = time_array(all_cr_locations(i)+1);
    for j = 1:columns
        if j == 1
            start_i = all_cr_locations(i) + 1;
        else
            start_i = tabs_for_line(j - 1) + 1;
        end
        
        
        end_i = tabs_for_line(j) - 1;
        
        matrix(i,j) = str2num(character_array(start_i:end_i)); %#ok<ST2NM>
    end
end

%% specific to setting on the eye tracker software
eventStruct.eyeX = matrix(:,1);
eventStruct.eyeY = matrix(:,2);
eventStruct.pupilSize = matrix(:,3);
eventStruct.min = matrix(:,4);
eventStruct.sec = matrix(:,5);
eventStruct.frameNum = matrix(:,6);
eventStruct.eyetrackerEventTimeStamps = matrix(:,7);
%% specific to the task

% st = find(characterArray=='s',1);
% eventStruct.sch1 = str2num(characterArray(st+(6:7))); 
% eventStruct.sch2 = str2num(characterArray(st+(16:17))); 
% eventStruct.sch1 = str2num(characterArray(st+(6:7))); 
 
eventStruct.resp1TimeStamps = timeArray(characterArray == 131);
eventStruct.resp2TimeStamps = timeArray(characterArray == 132);
eventStruct.rew1TimeStamps = timeArray(characterArray == 141);
eventStruct.rew2TimeStamps = timeArray(characterArray == 142);


end

