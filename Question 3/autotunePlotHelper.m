function stop = plotHelperAutotune(x,optimValues,state)

stop = false;

h_bar = findobj('Tag','optimplotx');
if isempty(h_bar)
    return
end
h_bar_ax = h_bar.Parent;
xticklabels(h_bar_ax,{'\sigma_{gb}','\sigma_{ob}','P_{is}','P_{pl}','P_{null}'})
h_bar_fig = h_bar_ax.Parent;
set(findall(h_bar_fig,'-property','FontSize'),'FontSize',12)

