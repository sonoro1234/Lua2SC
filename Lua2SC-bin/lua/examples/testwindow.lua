require"sc.routines"
win = addWindow{}
print(win)
panel=addPanel{window=win,type="hbox"}
glcanvas=addControl{window=win,panel=panel,typex="glcanvas",
	DrawCb = function(self) 
		local mx = self.mx or 0
		local my = self.my or 0
		--thread_print(mx,my)
		gl.ClearColor(self.r or 0, self.g or 0, mx/self.width, 0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		gl.Begin('TRIANGLES')
		gl.Vertex( 0,  my/self.height, 0)
		gl.Vertex(-0.75, -0.75, 0)
		gl.Vertex( 0.75, -0.75, 0)
		gl.End()

	end,
	mouseLD = function(x,y,Ob) 
		Ob.mx=x;Ob.my = y 
		--thread_print(x,y)
	end}
addControl{window=win,panel=panel,typex="vslider",
	name="slid",
	label = 0,
	FormatLabel=function(val) return val end,
	callback=function(value,str,c)
							glcanvas:val({g=value})
						end}
arut=Routine(function()
	while true do
	for i=1,100 do
		glcanvas:val({r=i/100})
		coroutine.yield(1/8)
	end
	end
end)
--guiUpdate()
theMetro:start()