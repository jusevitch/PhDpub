function out = WMSRfunc(x,L,F,malicious,maxsteps)

n = length(x);

out(:,1) = x;

for t=1:1:maxsteps %timespan and steps
    for i=1:1:n % Iterate through all nodes for each time step
        if ismember(i,malicious) % Check to see if the node is malicious
            % Update state information arbitrarily

            %             if i==1
            %                 x1(i) = x(i) - 1;
            %             elseif i==7
            %                 x1(i) = x(i) - 6;
            %             else
            %                 x1(i) = x(i) - 3;
            %             end
            %
            %             if x1(i) <= 0
            %                 x1(i) = 0;
            %             end
            
            %             end
            % ORIGINAL
            x(i) = x(i) + 20*cos(t)+15*sin(.5*t)+30*cos(2*t+4);
            
            %             x1(i) = x(i) - 7;
            
            
            %             % Static, then moving scenario
            %             if t < 30
            %                 x1(i) = x(i);
            %                 y1(i) = y(i);
            %             else
            %                 if i == 5 || i == 2 || i == 9 || i == 10
            %                     x1(i) = x(i)-.5;
            %                     y1(i) = y(i)-.5;
            %                 else
            %                     x1(i) = x(i);
            %                     y1(i) = y(i);
            %                 end
            %             end
            
            
        elseif ~ismember(i,malicious)
            
            % Reset the lists
            listx = []; % List of x values actually used for update protocol
            upperx = []; % X values higher than node i's x value
            lowerx = []; % X values lower than node i's x value
            
            for j=1:1:n
                if i~=j % Prevents algorithm from looking at the diagonal of the Laplacian
                    if L(i,j) ~= 0 % Identifies whether node j is in node i's neighboring set
                        % Sort x values by whether they're greater than, equal to, or less
                        % than node i's value
                        if x(j)==x(i)
                            listx = [listx x(j)];
                        elseif x(j) > x(i)
                            upperx = [upperx x(j)];
                        else
                            lowerx = [lowerx x(j)];
                        end
                    end
                end
            end
            % Sort upper and lower lists.
            upperx = sort(upperx, 'descend'); % Descending order so the highest entries are first
            lowerx = sort(lowerx); % Ascending order, so lowest entries are first.
            
            % If more than F entries present in each list,
            % remove the first F entries from each list. Otherwise,
            % remove all entries.
            if length(upperx) > F
                upperx = upperx(F+1:end);
            else
                upperx = [];
            end
            
            if length(lowerx) > F
                lowerx = lowerx(F+1:end);
            else
                lowerx = [];
            end
            
            % Add remaining values to listx, along
            % with the value of node i itself
            listx = [listx upperx lowerx x(i)];
            
            % Calculate weights according to footnote 3 of
            % LeBlanc 2013
            wx = 1/length(listx);
            
            x(i) = sum(wx*listx); % THIS ASSUMES WEIGHTS ARE EQUAL
            
        end
    end
    
    out(:,t+1) = x;
    
end

end