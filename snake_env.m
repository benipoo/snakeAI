classdef (Abstract) snake_env < rl.env.MATLABEnvironment
    
    properties
        State = zeros(24,1)
        CarryOver = zeros(8,1)
        Extradata = {1,[8 8]}
    end
    properties(Access = protected)
        % Internal flag to store stale env that is finished
        isdone = false
    end
    properties (Transient,Access = private)
        Visualizer = []
    end
    methods (Abstract,Access = protected)
        Force = getForce(this,action)
        updateActionInfo(this)
    end 
    
    methods
        function this = snake_env(ActionInfo)
            ObservationInfo = rlNumericSpec([24 1]);
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo); 
        end
        function set.State(this,state)
            validateattributes(state,{'numeric'},{'finite','real','vector','numel',24},'','State');
            this.State = double(state(:));
            notifyEnvUpdated(this);
        end
        function set.CarryOver(this,state)
            validateattributes(state,{'numeric'},{'finite','real','vector','numel',8},'','State');
            this.CarryOver = double(state(:));
            notifyEnvUpdated(this);
        end
        
        function set.Extradata(this,state) % needed to put extra_data into the output of reset
%             validateattributes(state,{'numeric'},'State');
            this.Extradata = state(:,:);
            notifyEnvUpdated(this);
        end
        
        function [NextObs,reward,isdone,loggedSignals] = step(this,action)
            
            if ~ismember(action,[1 2 3 4])
                error('Action must be %g for up, %g for down, %g for right, %g for left.',...
                    1,2,3,4);
            end
            
            loggedSignals = [];
            
            force = getForce(this,action);
            
            reused_data = this.CarryOver;
            x = reused_data(1);
            y = reused_data(2);
            a = reused_data(3);
            b = reused_data(4);
            
            closest_to_food = reused_data(5);
%             flag = reused_data(6);
            previous_action = reused_data(7);
            ate = reused_data(8);
            axis_limit= 15;
            
            isdone = 0;
            proximity = 0;
            food_reward = 0;
            food=[a b];
            snake(1,1:2) = [x y];
%             self_penalty = 0;
            
%%%%%%%%%%%%%%%%%%% EXTEND SNAKE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            extra_data = this.Extradata;
            size_snake = size(extra_data);
            size_snake = size_snake(1);
            
            snake(1,1:2) = [x y]; % preallocate
            for k = 1:size_snake % is there a +ate here?
                snake(k,1:2) = extra_data{k,2}; % unpack the snake from storage cell
            end
%             flag
%             if flag == 0
%                 for l=size_snake+ate:-1:2
%                     snake(l,:)=snake(l-1,:);
%                 end
%             end
%%%%%%%%%%%%%%%%%%% WHAT DIRECTION? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             disp('start')
            flag = 0;
%             snake
%             previous_action
            if force == 1 %up
                if previous_action ~= 2
                    for l=size_snake+ate:-1:2
                    snake(l,:)=snake(l-1,:);
                    end
                    snake(1,2)=snake(1,2)+1;
                    previous_action = 1;
%                     self_penalty = self_penalty + 1;
                else
%                     self_penalty = self_penalty - 10;
                    snake(1,2)=snake(1,2)+1;
%                     snake(2,:) = snake(1,:);
%                     isdone = 1;
                    flag = 1;
                    disp('cant go up')
                end
            elseif force == 2
                if previous_action ~= 1
                    for l=size_snake+ate:-1:2
                    snake(l,:)=snake(l-1,:);
                    end
                    snake(1,2)=snake(1,2)-1;
                    previous_action = 2;
%                     self_penalty = self_penalty + 1;
                else
%                     self_penalty = self_penalty - 10;
                    snake(1,2)=snake(1,2)-1;
%                     snake(2,:) = snake(1,:);
%                     isdone = 1;
                    flag = 2;
                    disp('cant go down')
                end
            elseif force == 3
                if previous_action ~= 4
                    for l=size_snake+ate:-1:2
                    snake(l,:)=snake(l-1,:);
                    end
                    snake(1,1)=snake(1,1)+1;
                    previous_action = 3;
%                     self_penalty = self_penalty + 1;
                else
%                     self_penalty = self_penalty - 10;
                    snake(1,1)=snake(1,1)+1;
%                     snake(2,:) = snake(1,:);
%                     isdone = 1;
                    flag = 3;
                    disp('cant go right')
                end
            elseif force == 4
                if previous_action ~= 3
                    for l=size_snake+ate:-1:2
                    snake(l,:)=snake(l-1,:);
                    end
                    snake(1,1)=snake(1,1)-1;
                    previous_action = 4;
%                     self_penalty = self_penalty + 1;
                else
%                     self_penalty = self_penalty - 10;
                    snake(1,1)=snake(1,1)-1;
%                     snake(2,:) = snake(1,:);
%                     isdone = 1;
                    flag = 4;
                    disp('cant go left')
                end
            else
            disp('You cant go this way!')
            end
            
            if flag == 0
                for k = 1:size_snake+ate
                    extra_data{k,2} = snake(k,1:2); % pack snake back into storage cell
                end
            end
            this.Extradata = extra_data;
            
%%%%%%%%%%%%%%%%%%% PROXIMITY CALCULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            after_moving = [snake(1,1),snake(1,2);food(1),food(2)];
            d1 = pdist(after_moving,'euclidean');
            
            if d1 < closest_to_food
                closest_to_food = d1;
%                 proximity = proximity + 0.05;
            else
%                 proximity = proximity - 0.05;
            end
            
%%%%%%%%%%%%%%%%%%% DID SNAKE EAT FOOD? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if snake(1,1)==food(1) && snake(1,2)==food(2)
              food(1) = randi([1 axis_limit-1]);
              food(2) = randi([1 axis_limit-1]);
              food_reward = 10;
              closest_to_food = pdist([snake(1,1),snake(1,2);food(1),food(2)],'euclidean');
              ate = 1;
            else
                ate = 0;
            end
            
%%%%%%%%%%%%%%%%%%% DID SNAKE HIT WALL? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if snake(1,1)==0 
                isdone=1;
            elseif snake(1,2)==0
                isdone=1;
            elseif snake(1,1)==axis_limit
                isdone=1;
            elseif snake(1,2)==axis_limit
                isdone=1;
            end
            
            if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                 food_reward = food_reward - 10;
                disp('hit self')
%                 NextObs(3*n)
                isdone = 1;
            end
            
%%%%%%%%%%%%%%%%%%% REWARD SYSTEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            reused_data(1) = snake(1,1);
            reused_data(2) = snake(1,2);
            reused_data(3) = food(1);
            reused_data(4) = food(2);
            reused_data(5) = closest_to_food;
            reused_data(6) = flag;
            reused_data(7) = previous_action;
            reused_data(8) = ate;
%             reward
            state = this.State;
%             food
%             snake
            NextObs = state;

%%%%%%%%%%%%%%%%% NEXT OBSERVATION CALCULATION %%%%%%%%
            
            for n = 1:8
                [NextObs((3*n)-2),NextObs((3*n)-1),NextObs(3*n)] = distances(n,snake,food,axis_limit);
            end

            if flag ~= 0
                if flag == 1
                    NextObs(3) = 0;
                elseif flag == 2
                    NextObs(15) = 0;
                elseif flag == 3
                    NextObs(9) = 0;
                elseif flag == 4
                    NextObs(21) = 0;
                end
            end
            
%%%%%%%%%%%%%%%%% REWARD SYSTEM USING OBSERVATIONS %%%%%%%%
            
            % what to do with self distances
            for n = 1:8
                if (NextObs(3*n) > 1) % if segment is in sight (up,right,down,left)
                    proximity = proximity - 0.25/(NextObs(3*n)); % give  higher penalty if closer
                end
            end
            
            % what to do with food distances
            for n = 1:8
                if (NextObs((3*n)-2) > 0) % if the food is in sight
                    proximity = proximity + 1/(NextObs((3*n)-2)); % give higher reward if closer
                end
%                 if NextObs((3*n)-2) == 0 % if snake eats food
%                     proximity = proximity + 10; % give reward of 10
%                 end
            end
            
            % what to do with wall distances
%             for n = 1:8
%                 if (NextObs((3*n)-1) > 0) && (NextObs((3*n)-1)) < 15 % if within bounds of walls
%                     if NextObs((3*n)-1) < 3
%                         proximity = proximity - 1/(NextObs((3*n)-1)); % give higher penalty if closer than 3 units
%                     end
%                 end
%             end

            if ~isdone
%                 reward = food_reward + self_penalty;
                reward = proximity+food_reward;
            else
                disp('dead')
                reward = -10 + proximity + food_reward;
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isdone
                disp(NextObs)
            end
%             snake
%             disp(NextObs)
            this.State = NextObs;
            this.CarryOver = reused_data;
            this.isdone = isdone;
            
        function [food_distance,wall_distance,Self_distance] = distances(direction,snake,food,axis_limit)

            closest_to_wall = min([axis_limit-snake(1,1) axis_limit-snake(1,2)]);
            
            switch direction
                
                case 1
                    wall_distance = axis_limit - snake(1,2);
                    Self_distance = self_distance(1,snake,axis_limit);
                    if snake(1,1) == food(1) && food(2) > snake(1,2)
                    food_distance = round(pdist([snake(1,1:2);food],'euclidean'));
                    else
                    food_distance = -1;
                    end

                case 2
                    wall_distance = diagonal_distance(2,snake,axis_limit);
                    Self_distance = self_distance(2,snake,axis_limit);
                    true = 0;
                    for i =1:closest_to_wall
                        if snake(1,1)+i == food(1) && snake(1,2)+i == food(2)
                        food_distance = norm(snake(1,1:2)-food);
                        true = 1;
                        end
                    end
                    if true == 0
                    food_distance = -1;
                    end

                 case 3
                    wall_distance = axis_limit - snake(1,1);
                    Self_distance = self_distance(3,snake,axis_limit);
                    if snake(1,2) == food(2) && food(1) > snake(1,1)
                    food_distance = round(pdist([snake(1,1:2);food],'euclidean'));
                    else
                    food_distance = -1;
                    end

                 case 4
                    wall_distance = diagonal_distance(4,snake,axis_limit);
                    Self_distance = self_distance(4,snake,axis_limit);
                    true = 0;
                    for i =1:closest_to_wall
                        if snake(1,1)+i == food(1) && snake(1,2)-i == food(2)
                        food_distance = norm(snake(1,1:2)-food);
                        true = 1;
                        end
                    end
                    if true == 0
                    food_distance = -1;
                    end

                 case 5
                    wall_distance = snake(1,2);
                    Self_distance = self_distance(5,snake,axis_limit);
                    if snake(1,1) == food(1) && food(2) < snake(1,2)
                    food_distance = round(pdist([snake(1,1:2);food],'euclidean'));
                    else
                    food_distance = -1;
                    end

                 case 6
                    wall_distance = diagonal_distance(6,snake,axis_limit);
                    Self_distance = self_distance(6,snake,axis_limit);
                    true = 0;
                    for i =1:closest_to_wall
                        if snake(1,1)-i == food(1) && snake(1,2)-i == food(2)
                        food_distance = norm(snake(1,1:2)-food);
                        true = 1;
                        end
                    end
                    if true == 0
                    food_distance = -1;
                    end

                 case 7
                    wall_distance = snake(1,1);
                    Self_distance = self_distance(7,snake,axis_limit);
                    if snake(1,2) == food(2) && food(1) < snake(1,1)
                    food_distance = round(pdist([snake(1,1:2);food],'euclidean'));
                    else
                    food_distance = -1;
                    end

                 case 8
                    wall_distance = diagonal_distance(8,snake,axis_limit);
                    Self_distance = self_distance(8,snake,axis_limit);
                    true = 0;
                    for i =1:closest_to_wall
                        if snake(1,1)-i == food(1) && snake(1,2)+i == food(2)
                        food_distance = norm(snake(1,1:2)-food);
                        true = 1;
                        end
                    end
                    if true == 0
                    food_distance = -1;
                    end

                 otherwise
                     warning('Unexpected action in switch statement')
                     food_distance = -1;
                     Self_distance = -1;
                     wall_distance = -1;
            end
        end
        
        function [wall_distance] = diagonal_distance(direction,snake,axis_limit)
%                 snake
                switch direction
                
                case 2
                    x_distance_to_wall = axis_limit - snake(1,1);
                    y_distance_to_wall = axis_limit - snake(1,2);
                    
                    if x_distance_to_wall < y_distance_to_wall
                        wall_distance = sqrt(2)*x_distance_to_wall;
                    else
                        wall_distance = sqrt(2)*y_distance_to_wall;
                    end
                    
                case 4
                    x_distance_to_wall = axis_limit - snake(1,1);
                    y_distance_to_wall = snake(1,2);
                    
                    if x_distance_to_wall < y_distance_to_wall
                        wall_distance = sqrt(2)*x_distance_to_wall;
                    else
                        wall_distance = sqrt(2)*y_distance_to_wall;
                    end
                    
                case 6
                    x_distance_to_wall = snake(1,1);
                    y_distance_to_wall = snake(1,2);
                    
                    if x_distance_to_wall < y_distance_to_wall
                        wall_distance = sqrt(2)*x_distance_to_wall;
                    else
                        wall_distance = sqrt(2)*y_distance_to_wall;
                    end
                    
                case 8
                    x_distance_to_wall = snake(1,1);
                    y_distance_to_wall = axis_limit - snake(1,2);
                    
                    if x_distance_to_wall < y_distance_to_wall
                        wall_distance = sqrt(2)*x_distance_to_wall;
                    else
                        wall_distance = sqrt(2)*y_distance_to_wall;
                    end
                otherwise
                    disp('Bad direction!')
                end
                
        end
        
        function [self_distance] = self_distance(direction,snake,axis_limit)

            size_array=size(snake);
            size_array=size_array(1); % get number of snake segments
            eligible_segments = snake(2:size_array,:); % this excludes the head of the snake, makes calculating this a lot easier
%             eligible_segments = snake;
            switch direction
                
                case 1
                    % calculate the distance to closest snake segment above
                    % snake head
                    closest = Inf; % infinity
                    for i = 1:((axis_limit - snake(1,2))-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,1) == eligible_segments(j,1) && snake(1,2)+i == eligible_segments(j,2) % if there is a valid segment
                                distance = (eligible_segments(j,2)-snake(1,2)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
%                             self_distance = -1; % if there was no segment found, return -1
%                         end
                        self_distance = -1; % if there was no segment found, return -1
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end  

                case 2
                    % calculate the distance to closest snake segment at 45
                    % degree angle from head of snake
                    closest_to_wall = min([axis_limit-snake(1,1) axis_limit-snake(1,2)]);
                    closest = Inf; % infinity
                    for i = 1:(closest_to_wall-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,1)+i == eligible_segments(j,1) && snake(1,2)+i == eligible_segments(j,2) % if there is a valid segment
                                distance = sqrt(2)*(eligible_segments(j,1)-snake(1,1)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf 
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end
                    
                 case 3
                    % calculate the distance to closest snake segment above
                    % snake head
                    closest = Inf; % infinity
                    for i = 1:((axis_limit - snake(1,1))-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,2) == eligible_segments(j,2) && snake(1,1)+i == eligible_segments(j,1) % if there is a valid segment
                                distance = (eligible_segments(j,1)-snake(1,1)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end 

                 case 4
                    % calculate the distance to closest snake segment at
                    % 135 degree angle from head of snake
                    closest_to_wall = min([axis_limit-snake(1,1) snake(1,2)]);
                    closest = Inf; % infinity
                    for i = 1:(closest_to_wall-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,1)+i == eligible_segments(j,1) && snake(1,2)-i == eligible_segments(j,2) % if there is a valid segment
                                distance = sqrt(2)*(eligible_segments(j,1)-snake(1,1)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf 
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end
                    
                 case 5
                    % calculate the distance to closest snake segment above
                    % snake head
                    closest = Inf; % infinity
                    for i = 1:(snake(1,2)-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,1) == eligible_segments(j,1) && snake(1,2)-i == eligible_segments(j,2) % if there is a valid segment
                                distance = (snake(1,2) - eligible_segments(j,2)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end 

                 case 6
                    % calculate the distance to closest snake segment at
                    % 225 degree angle from head of snake
                    closest_to_wall = min([snake(1,1) snake(1,2)]);
                    closest = Inf; % infinity
                    for i = 1:(closest_to_wall-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,1)-i == eligible_segments(j,1) && snake(1,2)-i == eligible_segments(j,2) % if there is a valid segment
                                distance = sqrt(2)*(snake(1,1) - eligible_segments(j,1)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf 
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end

                 case 7
                    % calculate the distance to closest snake segment above
                    % snake head
                    closest = Inf; % infinity
                    for i = 1:((snake(1,2))-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,2) == eligible_segments(j,2) && snake(1,1)-i == eligible_segments(j,1) % if there is a valid segment
                                distance = (snake(1,1) - eligible_segments(j,1)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end 

                 case 8
                    % calculate the distance to closest snake segment at
                    % 315 degree angle from head of snake
                    closest_to_wall = min([snake(1,1) (axis_limit-snake(1,2))]);
                    closest = Inf; % infinity
                    for i = 1:(closest_to_wall-1) % iterate the value of snake coorinates by one
                        for j = 1:(size_array-1) % search the segments for one that fits the correct criteria
                            if snake(1,1)-i == eligible_segments(j,1) && snake(1,2)+i == eligible_segments(j,2) % if there is a valid segment
                                distance = sqrt(2)*(snake(1,1)-eligible_segments(j,1)); % get its distance from the snake
                                if distance < closest % if coordinates of current segment are closer to snake than the closest segment so far
                                    closest = distance; % set this segment as new closest segment to the snake
                                end
                            end
                        end
                    end
                    if closest == Inf 
%                         if (sum(snake(:, 1) ==snake(1, 1)   & snake(:, 2) == snake(1, 2) )>1) %if snake hits itself
%                             self_distance = 0;
%                         else
                            self_distance = -1; % if there was no segment found, return -1
%                         end
                    else
                        self_distance = closest; % if there was a segment found, then return its distance from the snake
                    end

                 otherwise
                     warning('Unexpected action in switch statement')
                     self_distance = -1;
            end
        end
            
        end
        
        function [initialState, reusable_data, extra_data] = reset(this)
            
            % Reset function to place snake environment into a random initial state
            axis_limit= 15;
            x =round(axis_limit/2); %starting point
            y =round(axis_limit/2); %starting point
            a =randi([1 axis_limit-1],1); % generates random x coordinate for food
            b =randi([1 axis_limit-1],1); % generates random y coordinate for food
            before_moving = [x,y;a,b];
            closest_to_food = pdist(before_moving,'euclidean');
            flag = 0;
            previous_action = -1; 
            ate = 1;
            
            initialState = [-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1];
            reusable_data = [x;y;a;b;closest_to_food;flag;previous_action;ate];
            extra_data = {1,[x y]};
            this.Extradata = extra_data;
            this.State = initialState;
            this.CarryOver = reusable_data;
        end
        
        function varargout = plot(this)
            % Visualizes the environment
            if isempty(this.Visualizer) || ~isvalid(this.Visualizer)
                this.Visualizer = snakeVisualizer(this);
            else
                bringToFront(this.Visualizer);
            end
            if nargout
                varargout{1} = this.Visualizer;
            end
        end
    end
end