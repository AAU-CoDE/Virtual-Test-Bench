%%% Generalize node list of mosfet

function nodeListGeneral = generalizeNodeList(mosfetNodeList)

    % 
    % List of mosfet model connections:
    
    drain = {' d ',' D ',' drain ',' DRAIN ',' drainin ',' DRAININ '};
    source = {' s ',' S ',' s1 ',' S1 ',' source ',' SOURCE ',' sourcein ',' SOURCEIN '};
    kelvinSource = {' s2 ',' S2 ',' SOURCESENSE ',' sourcesence '};
    gate = {' g ',' G ',' gate ',' GATE ',' gatein ',' GATEIN '};
    junctionTemp = {' tj ',' TJ ', 'Tj '};
    caseTemp = {' tc ',' TC ',' tcase ',' TCASE ',' Tcase '};
    %%
        validIdxCnt = 1;
     mosfetNodeList_space = append(mosfetNodeList,' ');
    for drainMatch = 1:numel(drain)
        if contains(mosfetNodeList_space,drain{drainMatch})
            lastValidIdx(validIdxCnt) = strfind(mosfetNodeList_space,drain{drainMatch}) + strlength(drain{drainMatch});
            validIdxCnt = validIdxCnt + 1;
            break
        end
    end
    
    for sourceMatch = 1:numel(source)
        if contains(mosfetNodeList_space,source{sourceMatch})
            lastValidIdx(validIdxCnt) = strfind(mosfetNodeList_space,source{sourceMatch}) + strlength(source{sourceMatch});
            validIdxCnt = validIdxCnt + 1;
            break
        end
    end
    
    for kelvinSourceMatch = 1:numel(kelvinSource)
        if contains(mosfetNodeList_space,kelvinSource{kelvinSourceMatch})
           lastValidIdx(validIdxCnt) = strfind(mosfetNodeList_space,kelvinSource{kelvinSourceMatch}) + strlength(kelvinSource{kelvinSourceMatch});
            validIdxCnt = validIdxCnt + 1;
            break
        end
    end
    
    for gateMatch = 1:numel(gate)
        if contains(mosfetNodeList_space,gate{gateMatch})
            lastValidIdx(validIdxCnt) = strfind(mosfetNodeList_space,gate{gateMatch}) + strlength(gate{gateMatch});
            validIdxCnt = validIdxCnt + 1;
            break
        end
    end
    
    for tjMatch = 1:numel(junctionTemp)
        if contains(mosfetNodeList_space,junctionTemp{tjMatch})
            lastValidIdx(validIdxCnt) = strfind(mosfetNodeList_space,junctionTemp{tjMatch}) + strlength(junctionTemp{tjMatch});
            validIdxCnt = validIdxCnt + 1;
            break
        end
    end
    
    for tcMatch = 1:numel(caseTemp)
        if contains(mosfetNodeList_space,caseTemp{tcMatch})
            lastValidIdx(validIdxCnt) = strfind(mosfetNodeList_space,caseTemp{tcMatch}) + strlength(caseTemp{tcMatch});
            
            break
        end
    end
    lastValidIdx = max(lastValidIdx);
    
    mosfetNodeList_space(lastValidIdx:end) = []; 

    nodeListGeneral = replace(mosfetNodeList_space,drain(drainMatch),' drain ');
    nodeListGeneral = replace(nodeListGeneral,source(sourceMatch),' source ');
    nodeListGeneral = replace(nodeListGeneral,kelvinSource(kelvinSourceMatch),' ksource ');
    nodeListGeneral = replace(nodeListGeneral,gate(gateMatch),' gate ');
    nodeListGeneral = replace(nodeListGeneral,junctionTemp(tjMatch),' tj ');
    nodeListGeneral = replace(nodeListGeneral,caseTemp(tcMatch),' tc ');
end
