close all;

h1 = openfig('activity_70091100056-4113.fig','reuse'); % open figure
ax1 = gca; % get handle to axes of figure
h2 = openfig('activity_70091100056-4213.fig','reuse');
ax2 = gca;
h3 = openfig('activity_70091100056-4313.fig','reuse'); % open figure
ax3 = gca; % get handle to axes of figure
h4 = openfig('activity_70091100056-4413.fig','reuse');
ax4 = gca;
h5 = openfig('activity_70091100056-4513.fig','reuse');
ax5 = gca;

h12 = openfig('rssi_70091100056-4113.fig','reuse'); % open figure
ax12 = gca; % get handle to axes of figure
h22 = openfig('rssi_70091100056-4213.fig','reuse');
ax22 = gca;
h32 = openfig('rssi_70091100056-4313.fig','reuse'); % open figure
ax32 = gca; % get handle to axes of figure
h42 = openfig('rssi_70091100056-4413.fig','reuse');
ax42 = gca;
h52 = openfig('rssi_70091100056-4513.fig','reuse');
ax52 = gca;


h6 = figure; %create new figure
s1 = subplot(5,2,1); %create and get handle to the subplot axes
title("activity 70091100056-4/1/13 67")
s2 = subplot(5,2,3);
title("activity 70091100056-4/2/13 67")
s3 = subplot(5,2,5);
title("activity 70091100056-4/3/13 67")
s4 = subplot(5,2,7);
title("activity 70091100056-4/4/13 67")
s5 = subplot(5,2,9);
title("activity 70091100056-4/5/13 67")

s12 = subplot(5,2,2); %create and get handle to the subplot axes
title("rssi 70091100056-4/1/13 67")
s22 = subplot(5,2,4);
title("rssi 70091100056-4/2/13 67")
s32 = subplot(5,2,6);
title("rssi 70091100056-4/3/13 67")
s42 = subplot(5,2,8);
title("rssi 70091100056-4/4/13 67")
s52 = subplot(5,2,10);
title("rssi 70091100056-4/5/13 67")

fig1 = get(ax1,'children'); %get handle to all the children in the figure
fig2 = get(ax2,'children');
fig3 = get(ax3,'children');
fig4 = get(ax4,'children');
fig5 = get(ax5,'children');
fig12 = get(ax12,'children'); %get handle to all the children in the figure
fig22 = get(ax22,'children');
fig32 = get(ax32,'children');
fig42 = get(ax42,'children');
fig52 = get(ax52,'children');

copyobj(fig1,s1); %copy children to new parent axes i.e. the subplot axes
copyobj(fig2,s2);
copyobj(fig3,s3);
copyobj(fig4,s4);
copyobj(fig5,s5);
copyobj(fig12,s12); %copy children to new parent axes i.e. the subplot axes
copyobj(fig22,s22);
copyobj(fig32,s32);
copyobj(fig42,s42);
copyobj(fig52,s52);



fprintf('start...\n');
fprintf('connecting to mongoDB...\n');
javaaddpath('C:\Users\Axel\Documents\MATLAB\JAR\mongo-java-driver-3.8.2.jar')
import com.mongodb.*;

mongoClient = MongoClient();
db = mongoClient.getDB( 'main' );
fprintf('find collections...\n');
colls = db.getCollectionNames().toArray();
disp(colls);

currColl = "_70091100056-4/5/13";
disp("currColl="+currColl);

coll = db.getCollection(currColl).findOne().toString().toCharArray;

fprintf('coll=\n');
disp(size(coll))

data = reshape(coll,[1,size(coll)]);

fprintf('json decode...\n');
json = jsondecode(data);
fprintf('json=\n');
disp(json);

fprintf('json ok\n');
fprintf('start parsing...\n');

A = 1;

if A == 2
    fprintf('v2 sensor plot...\n');
    acceleration(json)
end

if A == 1
    fprintf('v1 sensor plot...\n');
    animalArray = json.animals;
    rows = size(animalArray);
    r = rows(1);
    maxCols = 0;
    names = [];
        
        names = strings(1,r);
        figure('NumberTitle', 'off', 'Name', currColl+"  "+r); hold on
        for i = 1:size(animalArray)
            times = [];
            values = [];
            tagDataArray = animalArray(i).tagData;
            names(i) = tagDataArray(1).serial_number.x_numberLong;
              for j = 1:size(tagDataArray)
                    tag = tagDataArray(j);
                    TF = contains(tag.time,'PM')
                    if TF == 1
                        time = datenum(tag.time, 'HH:MM:SS PM');
                        fprintf("PM\n"+time);
                    end
                    if TF == 0
                        time = datenum(tag.time, 'HH:MM:SS AM');
                        fprintf("AM\n"+time)
                    end
                    value = tag.first_sensor_value;
                    %value = str2num(tag.signal_strength);
                    if value < 0
                        value = 0;
                    end
                    values = [values, value];
                    times = [times, time];
                    
                    if j > maxCols
                        maxCols = j;
                    end
              end
              
              
        %values = values(:,1:maxCols);
        
        N = size(animalArray);
        W = floor(sqrt(N));
        width = W(1)+1;
        height = ceil(N/W);
        
        %y = values(i,1:maxCols);
        plot(times, values);  
        datetick('x','HH:MM') 
        title(currColl+"  "+r); 
              
        end
        hold off

        
              %figure(); hold on
              %for m = 1:size(values,1)
                  %subplot(width,height,i);
                  %plot(times(m,:), values(m,:));              % plot the data,
                  %datetick('x','HH:MM')   % give the a xaxis time label ticks..
                  %title(names(m));
              %end
              %hold off
              
end

function acceleration(input)
    animalArray = input.animals;
    xmin = 0;
    ymin = 0;
    zmin = 0;
    xmax = 0;
    ymax = 0;
    zmax = 0;
    gravity = [0, 0, 0];
    linear_acceleration = [0, 0, 0];

    for i = 1:size(animalArray)
       tagDataArray = animalArray(i).tagData;
       x = [];
       y = [];
       z = [];
       time = [];
       name = "unknown";
       for j = 1:size(tagDataArray)
            tag = tagDataArray(j);
            raw = tag.second_sensor_values_xyz;
            name = tag.serial_number.x_numberLong;
            split = strsplit(raw,':');
            xmin = str2double(split(1));ymin = str2double(split(3));
            zmin = str2double(split(5));xmax = str2double(split(2));
            ymax = str2double(split(4));
            zmax = str2double(split(6));
            aplha = 0.8;
            gravity(1) = aplha * gravity(1) + (1 - aplha)*xmin;
            gravity(2) = alpha * gravity(2) + (1 - aplha)*ymin;
            gravity(3) = alpha * gravity(3) + (1 - aplha)*zmin;

            linear_acceleration(1) = xmin - gravity(1);
            linear_acceleration(2) = ymin - gravity(2);
            linear_acceleration(3) = zmin - gravity(3);

            x = [x, linear_acceleration(1)];
            y = [y, linear_acceleration(2)];
            z = [z, linear_acceleration(3)];
            time = [time, j];
       end
       disp(name);
       N = size(animalArray);
       W = floor(sqrt(N));
       width = W(1)+1;
       height = ceil(N/W);

       disp(i);
       subplot(width,height,i);
       plot(time,x,time,y,time,z);
       title(name); 
    end  
end
%scatter3(xmax,ymax,zmax,'filled')