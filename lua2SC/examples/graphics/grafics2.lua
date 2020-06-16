win = addWindow{width=400,height=500}
grafic = addControl{window=win, typex="funcgraph2",width=300,height=300,expand=true}

function createpoly(val1)
	local t = {}
	local steps = 200
	for i=0,steps do
		local x = linearmap(0,steps,0,2,i)
		t[#t+1] = {x,math.pow(x,val1)}
	end
	grafic:val(t)
end

panel = addPanel{type="vbox"}
curr_panel = panel
slider = Slider("val",0,4,1,function(v) print(v);createpoly(v) end)
Button("but",function() createpoly(slider.value)end)