%% Example 4 - Discriminative training with momentum
% Tries to reproduce discriminative result from table 1 in 
% "Learning algorithms for the classification Restricted boltzmann machine"
if ~ismac
    current_dir = pwd();
    cd('../..');
    addpath(genpath(pwd()));
    cd(current_dir)
end

%% setup training
rng('default');rng(101);

[train_x,val_x,test_x,train_y,val_y,test_y] = setupmnist();
f = fullfile(pwd,'example9.mat')

% Setup DBN
sizes = [500 ];   % hidden layer size
[opts, valid_fields] = dbncreateopts();
opts.early_stopping = 1;
opts.patience = 15;
opts.numepochs = 10000;
opts.traintype = 'CD';
opts.init_type = 'cRBM';
opts.test_interval = 1;

opts.classRBM = 1;
opts.y_train = train_y;
opts.x_val = val_x;
opts.y_val = val_y;
opts.train_func = @rbmdiscriminative;

%% Set learningrate and momentum
opts.learningrate = @(t,momentum) 0.05;

T = 5;       % momentum ramp up
p_f = 0.9;    % final momentum
p_i = 0.5;    % initial momentum
opts.momentum     = @(t) ifelse(t < T, p_i*(1-t/T)+(t/T)*p_f, p_f);

disp(opts)
dbncheckopts(opts,valid_fields);       %checks for validity of opts struct
dbn = dbnsetup(sizes, train_x, opts);  % train function 
dbn = dbntrain(dbn, train_x, opts);


class_vec = zeros(100,size(train_y,2));
for i = 1:size(train_y,2)
    class_vec((i-1)*10+1:i*10,i) = 1;
end
digits = dbnsample(dbn,100,10000,class_vec);




save(f,'dbn','opts','digits');
