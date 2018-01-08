function pos = setCircle(n,r)
% SETCIRCLE Create xi values to keep a swarm of agents in a circle
% formation.
%   n : Number of agents
%   r : Radius of the circle
%   pos(i,:) = [x,y]

% Divide 2*pi by n; this will place the agents equally around the perimeter
% of a circle.
theta = 0:2*pi/n:2*pi;

% Create the position vector of each agent.
for i=1:1:length(theta)-1
    pos(i,1) = r*cos(theta(i)); % X value
    pos(i,2) = r*sin(theta(i)); % Y value
end

end