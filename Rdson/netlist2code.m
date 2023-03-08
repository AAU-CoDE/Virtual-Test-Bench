function code = netlist2code(netlistname,path)
% NETLIST2CODE saves the specified LTSpice netlist as "matnetlist.txt"
filepath = append(path, "/", netlistname);
if isfile(filepath) == 0
   filepath = append(cd,filepath);
   path = append(cd,path)
end 
ntlst = textread(filepath, '%q', 'delimiter','\n');
ntlst = replace(ntlst,'\','\\');
for n = 1:length(ntlst)
    ntlst2(n) = [append(ntlst(n),'\r\n')];
    %netlist(n,:) = append(a(n,:),'\r\n...')
end
netlist = char(ntlst2);
   filename = append(path,'\matnetlist.txt');
   fileID = fopen(filename,'w');
   fprintf(fileID, "'%s' ...\n",string(netlist));
   fclose(fileID);
   code = 1;
end