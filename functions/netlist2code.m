function code = netlist2code(netlistname,path)
% NETLIST2CODE saves the specified LTSpice netlist as "matnetlist.txt"
ntlst = textread(append(path, "/", netlistname), '%q', 'delimiter','\n');

for n = 1:length(ntlst)
    ntlst2(n) = [append(ntlst(n),'\r\n')];
end
netlist = char(ntlst2);
   filename = append(path,'\matnetlist.txt');
   fileID = fopen(filename,'w');
   fprintf(fileID, "'%s' ...\n",string(netlist));
   fclose(fileID);
   code = 1;
end