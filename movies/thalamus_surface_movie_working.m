figure; 
addbrain('thalamus');
view(135, 30);
set(gca, 'ZLim', [-60 30]);
lightRestoreSingle;
drawnow

addbrain('brainstem'); set(gca, 'ZLim', [-60 30]); drawnow
addbrain('lgn'); set(gca, 'ZLim', [-60 30]); drawnow
addbrain('mgn'); set(gca, 'ZLim', [-60 30]); drawnow

for regname = {'VPthal', 'VPLthal', 'VPL', 'intralaminar_thal'}
    
    addbrain(regname{1})
    set(gca, 'ZLim', [-60 30]); drawnow
    
end

% rotate, add habenula


% remove brainstem
