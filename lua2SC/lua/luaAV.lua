-- this file is for using sclua
package.cpath = package.cpath .. package.cpath:gsub("%?","?"..table.concat{_VERSION:match("(%d).(%d)")})
function Window(title,x,y,w,h)
	require"iuplua"
	require( "iupluagl" )
	x = x or 200
	y = y or 200
	w = w or 200
	h = h or 200
	local size=tostring(w).."x"..tostring(h)
	local win = {dim={w,h}}
	local canvas = iup.glcanvas{buffer="DOUBLE", rastersize = size}--"640x480"}
	win.dlg = iup.dialog{canvas; title=title,size=size}
	win.dlg:showxy(x, y)
	function canvas:button_cb(but, pressed, x, y, status)
		--print(but, pressed, x, y, status)
		if win.mouse then
			local event = (pressed == 1) and "down" or "up"
			local btn = (but == iup.BUTTON1) and "left" or (but == iup.BUTTON2) and "middle" or (but == iup.BUTTON3) and "right"
			win.mouse(win,event,btn,x,y)
		end
	end
	function canvas:motion_cb(x, y, status)
		if win.mouse then
			local event = iup.isbutton1(status) and "drag" or false
			if event then
				win.mouse(win,event,"left",x,y)
			end
		end
	end
	function canvas:keypress_cb(c,press)
		if win.key then
			local ev = press==1 and "down" or "up"
			win.key(win,ev,c)
		end
	end
	function canvas:action(posx,posy)
		if win.draw then
			iup.GLMakeCurrent(canvas)
			win.draw(win)
			iup.GLSwapBuffers(canvas)
			gl.Flush()
		end
	end
	win.canvas = canvas
	--[[
	local winmt = {}
	wint.__newindex = function(t,k,v)
			if k == "mouse" and type(v)=="function" then
				t.mouse = v
			end
		end
	setmetatable(win,winmt)
	--]]
	return win
end

--require"osclua"

local oscout = {}
function oscout:send(...)
	--udp:send(toOSC({select(1, ...),{select(2, ...)}}))
	local addr = select(1, ...)
	local msg = {select(2, ...)}
	for i,v in ipairs(msg) do
		if type(v)=="number" then
			-- if not integer make it float osc
			if math.floor(v) ~= v then
				msg[i] = {"float",v}
			end
		end
	end
	udp:send(toOSC{addr,msg})
end
local M = {}
function M.Send()
	--initudp()
	return oscout
end
return M