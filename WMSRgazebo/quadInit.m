function quadInit(x0,y0,z0,filePath)

% This function generates a ROS .launch file for the WMSRGazebo_1_0
% simulation.

[file,errmsg] = fopen(filePath,'w+');
n = length(x0); % x0, y0, z0 must be the same length

% This initializes the quads to be on the ground. Remove if you don't want
% them to start on ground.
z0 = zeros(size(z0));

if file ~= -1
    
    fprintf(file,'<?xml version="1.0"?>\n\n<launch>\n\n<include file="$(find uav_ros_controller)/launch/empty_world.launch"/>\n\n');
    fprintf(file,'<arg name="model" default="$(find hector_quadrotor_description)/urdf/quadrotor_hokuyo_utm30lx.gazebo.xacro"/>\n\n');
    
    for i=0:1:n-1
        name = ['"quad' num2str(i) '"'];
        fprintf(file,['<group ns=' name '>']); fprintf(file,'\n');
        fprintf(file, '<include file="$(find uav_ros_controller)/launch/spawn_quadrotor.launch">\n');
        fprintf(file, ['<arg name="name" value=' name ' />']); fprintf(file,'\n');
        fprintf(file, ['<arg name="tf_prefix" value=' name '/>']); fprintf(file,'\n');
        fprintf(file, '<arg name="model" value="$(arg model)" />\n');
        fprintf(file, ['<arg name="x" value="' num2str(x0(i+1)) '"/>']); fprintf(file,'\n');
        fprintf(file, ['<arg name="y" value="' num2str(y0(i+1)) '"/>']); fprintf(file,'\n');
        fprintf(file, ['<arg name="z" value="' num2str(z0(i+1)) '"/>']); fprintf(file,'\n');
        fprintf(file, '</include>\n</group>\n\n');         
    end
    
    fprintf(file,'</launch>');
    fclose(file);
else
    fprintf(2,errmsg);
end


end