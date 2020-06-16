win = addWindow{width=400,height=500}
grafic = addControl{window=win, typex="funcgraph3",width=200,height=200,minx=0,maxx=1,expand=true}

function createpoly(val1)
	grafic:val{funcs={function(i) 
					return math.pow(i,val1)
				end,function(i) 
					return math.pow(i,1/val1)
				end}}

end

panel = addPanel{type="vbox"}
curr_panel = panel
slider = Slider("val",0,4,1,function(v) print(v);createpoly(v) end)
Button("but",function() createpoly(slider.value)end)