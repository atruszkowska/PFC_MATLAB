% PFC/MATLAB Optimization driver 
% -------------------------------------------------------------------------
% fminsearch optimization to find parameters for modeling of anisotropic 
% elasticity of a given cubic material
% Finds the solution based on elastic constants in GPa
% Target material constant and deformation are hardcoded in FunctionF.m
% Uses polling procedure to communicate with PFC
% Used as a template for other automated procedures
% -------------------------------------------------------------------------
% To run - first change the flag in "hold_flag.txt" to 1, start 
% "while_function_PFC.p3dat, then run this program; no other inputs
% necessary
% -------------------------------------------------------------------------
% Functions used: FunctionF.m, get_spheres.m, and import_hist.m
% -------------------------------------------------------------------------
% Last modified: March 23 2016
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Optimization settings
options=optimset('Display','iter');
% Initial values - [an, as, kn, ks]
x0=[2.8926907e-02, 1.1204203e-01, 1.0000000e+13, 2.4699439e+11];
% Optimization
[x,fval]=fminsearch(@FunctionF, x0, options);
% Stop PFC by renaming flag file and causing an error
movefile('hold_flag.txt','hold_flag_final.txt')
