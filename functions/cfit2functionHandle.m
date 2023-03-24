function fHandle = cfit2functionHandle(fitFunc)
% CFIT2FUNCTIONHANDLE returns a function handle from a cuve-fit function 

cNames = coeffnames(fitFunc); % Names of coefficients
cVals = coeffvalues(fitFunc); % Coefficient values
funcFormula = formula(fitFunc); % Formula of the fit

for n = 1:numel(cNames)
    funcFormula = replace(funcFormula,cNames{n},num2str(cVals(n))); % Replace the coefficients by the values
end

fHandle = eval(['@(x)',funcFormula]); % write as function handle
end