local nowt = lanes:now_secs()
win = nil --addWindow{width=400,height=400}
local panelflexi=addPanel{type="flexi",cols=12,parent=nil,window=win}
for i=1,100 do
	 local newcontrol = {
					name="pan.",
					window=win,
					panel=panelflexi, --i,
					--value= 0,
					variable={"pan"},
					--width = 40,
					--height = 30,
					typex = "button",
					label="label",
					Gui2Value=function(val) return val end,
					Value2Gui=function(val) return val end,
					FormatLabel=function(val) return string.format("%.2f",val) end,
					callback=function(value,str,c) 
							--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
							--player.channel.params.level = value
							--player.channel:SendParam("level")
						end
						--,notify={player.channel}
				}
				addControl(newcontrol)
end
guiUpdate()
print("bbbbbbbbbbbbbbbbbb",lanes:now_secs()-nowt)
