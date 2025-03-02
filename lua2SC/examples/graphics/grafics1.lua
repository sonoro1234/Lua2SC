
grafic = addControl{ typex="funcgraph",width=300,height=300,miny=0,maxy=1}

function createpoly(val1)
	local t = {}
	local steps = 80
	for i=0,steps do
		local x = linearmap(0,steps,0,1,i)
		t[#t+1] = math.pow(x,val1)
	end
	grafic:val(t)
end

panel = addPanel{type="vbox"}
curr_panel = panel
slider = Slider("val",0,4,1,function(v) print(v);createpoly(v) end)
Button("but",function() createpoly(slider.value)end)
Toggle("Tog",function(val) print(val) end)
