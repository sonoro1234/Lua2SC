require"sc.routines"

notisink = {}
function notisink:notify(cont)
	print("notisink",cont.value)
end

win = addWindow{width=400,height=400}
local panelflexi=addPanel{type="flexi",cols=12,parent=nil,window=win}
local newcontrol = {
					name="pan.",
					window=win,
					radio = 10,
					panel=panelflexi, --i,
					value= 0,
					width = 40,
					height = 30,
					typex = "knob",
					label="label",
					Gui2Value=function(val) return 2*val end,
					Value2Gui=function(val) return 0.5*val end,
					FormatLabel=function(val) return string.format("%.2f",val) end,
					callback=function(value,str,c) 
						print(value,str,c)
							--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
							--player.channel.params.level = value
							--player.channel:SendParam("level")
						end
						,notify={notisink}
				}
control = addControl(newcontrol)
local newcontrol = {
					name="pan.",
					window=win,
					panel=panelflexi, --i,
					value= 0,
					width = 40,
					height = 130,
					typex = "vslider",
					label="label",
					Gui2Value=function(val) return 2*val end,
					Value2Gui=function(val) return 0.5*val end,
					FormatLabel=function(val) return string.format("%.2f",val) end,
					callback=function(value,str,c) 
						print(value,str,c)
						control:val(value)
							--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
							--player.channel.params.level = value
							--player.channel:SendParam("level")
						end
						--,notify={notisink}
				}
control2 = addControl(newcontrol)
guiUpdate()

rut = Routine(function() 
		for i=0,2,0.0999 do
			control:val(i,false)
			coroutine.yield(1)
		end
	end)
theMetro:start() 