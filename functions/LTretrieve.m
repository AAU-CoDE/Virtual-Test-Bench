function var = LTretrieve(input,data)
%%% Find variable "input" in data set "data". To be used with
%%% LTspice2Matlab fuction
%%% Example: find voltage of node q1drain in raw_data = LTspice2Matlab(xxx.raw):
%%%  Vd1 = LTretrieve("V(q1drain)",raw_data);

    if isstring(input) == 0 & ischar(input) == 0
        input = num2str(input);
    end
   var = data.variable_mat(find(contains(data.variable_name_list,input)),:);
    
end