clear global
close all hidden
clear
rng(0)
env = snake_class;

% load('high_average.mat','saved_agent');
load('Agent3075.mat','saved_agent');

plot(env)

simOptions = rlSimulationOptions('MaxSteps',999999);
experience = sim(env,saved_agent,simOptions);


