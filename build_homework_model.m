function modelName = build_homework_model(modelName)
% build_homework_model 自动搭建一个可提交作业的 Simulink 基础模型。
% 用法：
%   modelName = build_homework_model();
%   modelName = build_homework_model('hw_model');
%
% 说明：
% README 只有图片没有文字任务，因此这里先创建一个“可替换参数/方程”的通用闭环结构：
% Step -> Sum(e=r-y) -> PID -> Plant(Transfer Fcn) -> Scope
%                              ^----------------------|
%
% 你只需要把 PID、Plant 参数替换成题目要求，即可快速完成作业。

if nargin < 1 || strlength(string(modelName)) == 0
    modelName = 'hw_autobuild_model';
end
modelName = char(modelName);

% 若模型已存在则关闭重建，避免重复块冲突
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

new_system(modelName);
open_system(modelName);

% 统一布局参数
x0 = 60;  y0 = 80;  dx = 140;  dy = 70;

% ---- 添加模块 ----
add_block('simulink/Sources/Step', [modelName '/Step'], ...
    'Position', [x0 y0 x0+40 y0+30], ...
    'Time', '0', 'Before', '0', 'After', '1');

add_block('simulink/Math Operations/Sum', [modelName '/Sum'], ...
    'Position', [x0+dx y0 x0+dx+40 y0+30], ...
    'Inputs', '+-');

add_block('simulink/Continuous/PID Controller', [modelName '/PID'], ...
    'Position', [x0+2*dx y0-10 x0+2*dx+80 y0+40], ...
    'P', '1', 'I', '0', 'D', '0');

add_block('simulink/Continuous/Transfer Fcn', [modelName '/Plant'], ...
    'Position', [x0+3*dx y0 x0+3*dx+90 y0+30], ...
    'Numerator', '[1]', ...
    'Denominator', '[1 2 1]');

add_block('simulink/Sinks/Scope', [modelName '/Scope'], ...
    'Position', [x0+4*dx y0 x0+4*dx+40 y0+30]);

add_block('simulink/Sinks/To Workspace', [modelName '/y_out'], ...
    'Position', [x0+4*dx y0+dy x0+4*dx+90 y0+dy+30], ...
    'VariableName', 'y_out', 'SaveFormat', 'StructureWithTime');

% ---- 连线 ----
add_line(modelName, 'Step/1', 'Sum/1', 'autorouting', 'on');
add_line(modelName, 'Sum/1', 'PID/1', 'autorouting', 'on');
add_line(modelName, 'PID/1', 'Plant/1', 'autorouting', 'on');
add_line(modelName, 'Plant/1', 'Scope/1', 'autorouting', 'on');
add_line(modelName, 'Plant/1', 'y_out/1', 'autorouting', 'on');
add_line(modelName, 'Plant/1', 'Sum/2', 'autorouting', 'on');

% 仿真设置（可按作业要求修改）
set_param(modelName, 'StopTime', '10', 'Solver', 'ode45');

save_system(modelName);
fprintf('模型已创建: %s.slx\n', modelName);
end
