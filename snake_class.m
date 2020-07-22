classdef snake_class < snake_env

    methods
        function this = snake_class()
            ActionInfo = rlFiniteSetSpec([1 2 3 4]);
            this = this@snake_env(ActionInfo);
            updateActionInfo(this);
        end        
    end
    
    methods (Access = protected)
        function force = getForce(this,action)
            if ~ismember(action,this.ActionInfo.Elements)
                error(message('bad direction'));
            end
            force = action;           
        end
        
        function updateActionInfo(this)
            this.ActionInfo.Elements = [1 2 3 4];
        end
    end
end