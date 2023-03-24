function [bestFit,R2max] = fitThisCurve(x,y,R2_goal) 
% FITTTHISCURVE Iterates through fit methods with increasing complexity (i.e. nr. of
% parameters). Stop when R is above e.g. 0.95.
%
% Input variables:
%
% x:    x values (1 x n or 1 x n)
% y:    y valyes (same dimensions as x)
%
% Optional: 
%       R2_goal: Desired R-squared value (Default is 0.95)
%
% Output is fit & R2
%
%% Library of fit options:
% 2 Parameters:
%     poly1	Y = p1*x+p2
%     power1  Y = a*x^b
%     rat01   Y = p1/(x + q1)
%     weibull	Y = a*b*x^(b-1)*exp(-a*x^b)
%     exp1	Y = a*exp(b*x)

% 3 Parameters 
%     poly2	Y = p1*x^2+p2*x+p3
%     power2	Y = a*x^b+c
%     rat11   Y = (p1*x + p2)/(x + q1)
%     rat02	Y = (p1)/(x^2+q1*x+q2)
%     exp2	Y = a*exp(b*x)+c*exp(d*x)
%     sin1	Y = a1*sin(b1*x+c1)

% 4 Parameters
%     poly3	Y = p1*x^3+p2*x^2+...+p4
%     exp2	Y = a*exp(b*x)+c*exp(d*x)
%     fourier1	Y = a0+a1*cos(x*p)+b1*sin(x*p)
%     rat21	Y = (p1*x^2+p2*x+p3)/(x+q1)
% 
% 5+ Parameters
%     poly4	Y = p1*x^4+p2*x^3+...+p5
%     fourier2	Y = a0+a1*cos(x*p)+b1*sin(x*p)+a2*cos(2*x*p)+b2*sin(2*x*p)
%     sin2	Y = a1*sin(b1*x+c1)+a2*sin(b2*x+c2)
%     ...
%% Input Parse
 if ~exist('R2_goal','var')
     % third parameter does not exist, so default it to something
      R2_goal = 0.95;
 end
    
 % Ensure that X & Y are row vecotrs
 [rowX, ~] = size(x);
 [rowY, ~] = size(y);

 if rowX <= 1 % Only 1 row means X is column --> Transpose
     x = x';
 end
 if rowY <= 1 % Only 1 row means Y is column --> Transpose
     y = y';
 end


%% Fit Library
fitName = ["poly1","power1","rat01","weibull","exp1","poly2","power2","rat11","rat02","exp2","sin1",...
            "poly3","exp2","fourier1","rat21","poly4","fourier2","sin2","poly5","fourier3","sin3",...
            "poly6","fourier4","sin4","poly7","fourier5","sin5","poly8","fourier6","sin6",...
            "poly9","fourier7","sin7","fourier8","sin8"];

%% Loop:
for n = 1:numel(fitName)
    % Exclude Power and Weibull fit if x contains negative values
    if sum(x < 0) > 0 && (contains(fitName(n),"power")||contains(fitName(n),"weibull"))
        R2(n) = 0;
        F(n).fit = nan;       
    % EXCLUDE METHODS   
%     elseif (contains(fitName(n),"fourier")||contains(fitName(n),"rat"))
%                 R2(n) = 0;
%         F(n).fit = nan;  
    else
        [f, gof] = fit(x,y,fitName(n));
        R2(n) = gof.rsquare;
        F(n).fit = f;
        
        % Check whether R2 is high enough
        if R2(n) >= R2_goal
            break
        end
    end
end
[R2max, R2MaxIdx] = max(R2);
bestFit = F(R2MaxIdx).fit;

