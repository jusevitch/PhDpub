%-------------------------------------------------------------------------%
% W-MSR Gazebo Generator 1.0
% 
% This program generates velocity commands for a visual simulation of the
% W-MSR algorithm to be run in Gazebo.
%
% Assumptions: This simulation applies the W-MSR algorithm dynamics directly to
% quadrotors. It does not reflect the dynamics of quadrotors in real
% life, which will be the subject of future simulations. In addition, there
% is no collision avoidance algorithm implemented.
%
% Required functions: Dmatrix.m, kCirculant.m
%
% Outputs: Text file of velocity commands for each time step of the
% simulation. These velocity commands are used by the uav_controller.cpp
% file to run the simulation in Gazebo.
%
% ***THE OUTPUT FILE MUST BE IN THE FOLLOWING LOCATION: /home/james/catkin_ws/src/UAV_simulator/uav_ros_controller/src
%-------------------------------------------------------------------------%

clear all
clc

n = 10;
k = 5;
maxsteps = 50;

graph = 'dir';
% graph = 'undir';

% Determine max value of F
if strcmp(graph, 'dir')
    % Circulant digraphs:
    if mod(k,2) == 0
        F = floor((k+2)/4)-1;
    else
        F = floor((k+3)/4)-1;
    end
elseif strcmp(graph, 'undir')
    if mod(k,2) == 0
        F = floor((k+1)/2)-1;
    else
        F = floor(k/2); % Equivalent to floor((k+2)/2)-1
    end
end

L = kCirculant(n,k,graph);

leader = 1:1+F;

malicious = [];
while length(malicious) < F
    randNum = randi([1,n],1,1);
    if any(malicious == randNum) || any(leader == randNum) % Trusted leaders; leaders can't become malicious
%     if any(malicious == randNum) % Leaders can become malicious
    else
        malicious = [malicious randNum];
    end
end
% malicious = [];

% Index of behaving agents
behaving = 1:n;
behaving(malicious) = [];

% Initial state positions.
x = zeros(n,1);
rng('shuffle')
% rng(0); % Use if you want the same starting position each time
x = 100*rand(n,1)-50;

y = zeros(n,1);
rng('shuffle')
% rng(0); % Use if you want the same starting position each time
y = 100*rand(n,1)-50;

z = zeros(n,1);
rng('shuffle')
% rng(0); % Use if you want the same starting position each time
z = 100*rand(n,1);

% The path to the correct output launch file. In other words, this variable should
% contain both the filepath and name of the launch file you'll be using.
% It should be placed in the \launch folder in the uav_ros_controller package. 
%
% CHANGE THIS PATH IF YOU SWITCH COMPUTERS
file = '/home/james/catkin_ws/src/UAV_simulator/uav_ros_controller/launch/uav_wmsr.launch';

% Create the launch file
quadInit(x,y,z,file);

% W-MSR Loop

xfinal = WMSRfunc(x,L,F,malicious,maxsteps);
yfinal = WMSRfunc(y,L,F,malicious,maxsteps);
zfinal = WMSRfunc(z,L,F,malicious,maxsteps);

% To achieve a formation, let x = xp - del, where xp is physical position
% and del is relative formation position. Then xp = x + del.
%
% Only delx and dely are needed when final agent height is desired to be the same. 

pos = setCircle(n,10);

xpfinal = xfinal + pos(:,1);
ypfinal = yfinal + pos(:,2);

% Graph results to see if they are correct
% stepvec = 1:maxsteps+1;
% subplot(3,1,1)
% plot(stepvec,xfinal)
% ylabel('X')
% subplot(3,1,2)
% plot(stepvec,yfinal)
% ylabel('Y')
% subplot(3,1,3)
% plot(stepvec,zfinal)
% ylabel('Z')

% Duration of each time step
dt = 10;

% Calculate Velocity commands
% v[k] = (x[k+1] - x[k])/dt
% v[maxsteps+1] = 0
% M is the matrix that vectorizes this process
M = -diag(ones(maxsteps+1,1)) + diag(ones(maxsteps,1),1);
M(end,end) = 0;

vx = (1/dt)*M*xpfinal';
vy = (1/dt)*M*ypfinal';
vz = (1/dt)*M*zfinal';



[file,errmsg] = fopen('/home/james/catkin_ws/src/UAV_simulator/uav_ros_controller/src/data/vel_input.txt','w+');

% n  maxsteps  1/dt (Hz)
fprintf(file,[num2str(n) ' ' num2str(size(vx,1)) ' ' num2str(1/dt)]); fprintf(file,'\n');

% Since quadrotors start from the ground, these velocity commands will
% initialize their starting position
initTime = 3; % seconds. MAKE SURE dt EVENLY DIVIDES initTime!!!
% vxi = dt/initTime*xfinal(:,1);
% vyi = dt/initTime*yfinal(:,1);

vxi = zeros(length(xfinal(:,1)));
vyi = zeros(length(yfinal(:,1)));
vzi = dt/initTime*zfinal(:,1);
txt = '';
for j=1:1:n
    txt = strcat(txt,num2str(vxi(j)),{' '},num2str(vyi(j)),{' '},num2str(vzi(j)),{' '});
end

for i=1:1:initTime/dt
    fprintf(file,txt{1}); fprintf(file,'\n');
end

for t=1:1:size(vx,1)
    for j=1:1:n
        txt = strcat(num2str(vx(t,j)),{' '},num2str(vy(t,j)),{' '},num2str(vz(t,j)),{' '});
        fprintf(file,txt{1});
    end
    
    fprintf(file,'\n');
end

