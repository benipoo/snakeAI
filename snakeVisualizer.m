classdef snakeVisualizer < rl.env.viz.AbstractFigureVisualizer
    
    methods
        function this = snakeVisualizer(env)
            this = this@rl.env.viz.AbstractFigureVisualizer(env);
        end
    end
    
    methods (Access = protected)
        function f = buildFigure(this)
            
            f = figure(...
                'Toolbar','none',...
                'Visible','on',...
                'HandleVisibility','off', ...
                'NumberTitle','off',...
                'MenuBar','none',...
                'CloseRequestFcn',@(~,~)delete(this));
%                             'Name',getString(message('SNAKE')),... 
            
            if ~strcmp(f.WindowStyle,'docked')
                f.Position(3:4) = [500 500];
            end
            ha = gca(f);
            
            ha.XLimMode = 'manual';
            ha.YLimMode = 'manual';
            ha.ZLimMode = 'manual';
            ha.DataAspectRatioMode = 'manual';
            ha.PlotBoxAspectRatioMode = 'manual';
            ha.YTick = [];
            
            ha.XLim = [0 15];
            ha.YLim = [0 15];
            hold(ha,'on');
        end
        
        function updatePlot(this)

            env = this.Environment;
            f = this.Figure;
            ha = gca(f);
            reused_data = env.CarryOver;
            x = reused_data(1);
            y = reused_data(2);
            
            extra_data = env.Extradata;
            
            size_snake = size(extra_data);
            size_snake = size_snake(1);
            snake(1,1:2) = [x y];
            
            for k = 1:size_snake % is there a +ate here?
                snake(k,1:2) = extra_data{k,2}; % unpack the snake from storage cell
            end

            a = reused_data(3);
            b = reused_data(4);
            food=[a b];

            width = 1;
            boundary1 = [-width/2,-width/2,width/2,width/2];
            boundary2 = [-width/2,width/2,width/2,-width/2];
            poly1 = polyshape(boundary1,boundary2);
%             object = polyshape(boundary1,boundary2); % preallocate?
            
            for p = 1:size_snake
                object(p).poly = translate(poly1,[snake(p,1),snake(p,2)]);
                object(p).name = sprintf('s%d',p);
                object(p).find = findobj(ha,'Tag',object(p).name);
                delete(object(p).find);
                object(p).find = plot(ha,object(p).poly,'FaceColor','red');
                object(p).find.Tag = object(p).name;
                object(p).find.Shape = object(p).poly;
            end

            food_box = polyshape([-width/2,-width/2,width/2,width/2]+food(1),[-width/2,width/2,width/2,-width/2]+food(2));
            foodplot = findobj(ha,'Tag','food');
            delete(foodplot);
            foodplot = plot(ha,food_box,'FaceColor','blue');
            foodplot.Tag = 'food';
            foodplot.Shape = food_box;
            
%             pause(0.3)
            
            drawnow()
        end
    end
end
