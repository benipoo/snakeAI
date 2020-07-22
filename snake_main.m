close all hidden
clear global
clear
rng(0)
env = snake_class;
clc

obsInfo = getObservationInfo(env);
numObservations = obsInfo.Dimension(1);
actInfo = getActionInfo(env);
numActions = numel(actInfo.Elements);
learnrate = 5e-4;

criticNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(32,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(32,'Name','CriticStateFC2')
    reluLayer('Name','CriticRelu2')
    fullyConnectedLayer(32,'Name','CriticStateFC3')
    reluLayer('Name','CriticRelu3')
    fullyConnectedLayer(1, 'Name', 'CriticFC')];

criticOpts = rlRepresentationOptions('LearnRate',learnrate,'GradientThreshold',1);

critic = rlRepresentation(criticNetwork,obsInfo,'Observation',{'state'},criticOpts);

actorNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(32, 'Name','ActorStateFC1')
    reluLayer('Name','ActorRelu1')
    fullyConnectedLayer(32, 'Name','ActorStateFC2')
    reluLayer('Name','ActorRelu2')
    fullyConnectedLayer(32, 'Name','ActorStateFC3')
    reluLayer('Name','ActorRelu3')
    fullyConnectedLayer(numActions,'Name','action')];

actorOpts = rlRepresentationOptions('LearnRate',learnrate,'GradientThreshold',1);

actor = rlRepresentation(actorNetwork,obsInfo,actInfo,...
    'Observation',{'state'},'Action',{'action'},actorOpts);

agentOpts = rlACAgentOptions(...
    'NumStepsToLookAhead',100,...
    'EntropyLossWeight',0.01,...
    'DiscountFactor',0.99);

agent = rlACAgent(actor,critic,agentOpts);

trainOpts = rlTrainingOptions(...
    'MaxEpisodes',10000000,...
    'MaxStepsPerEpisode',999999999,...
    'Verbose',false,...
    'SaveAgentCriteria',"EpisodeReward",...
    'SaveAgentValue',300,...
    'SaveAgentDirectory', pwd + "test4batch1\Agents",... % refresh the batch! %%%%%%%%%%%%%
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',2000,...
    'ScoreAveragingWindowLength',100); 

% plot(env)

% trainOpts.UseParallel = true;
% trainOpts.ParallelizationOptions.Mode = "async";
% trainOpts.ParallelizationOptions.DataToSendFromWorkers = "gradients";
% trainOpts.ParallelizationOptions.StepsUntilDataIsSent = 32;

doTraining = true;
if doTraining    
% 	load('Agent3317.mat','saved_agent');
    trainingStats = train(agent,env,trainOpts);
else
    % load('SCORE_OF_16000','saved_agent');
end
% 
% plot(env)
% simOptions = rlSimulationOptions('MaxSteps',99999);
% experience = sim(env,agent,simOptions);

% close all hidden
