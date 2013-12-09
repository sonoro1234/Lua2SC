-- idle1.wlua
require "iuplua"


canvas = iup.canvas{}
dlg = iup.dialog{canvas; title="Simple Dialog",size="200x200"}
dlg:showxy(iup.CENTER, iup.CENTER)

function canvas:button_cb(but, pressed, x, y, status)
	print(but, pressed, x, y, status)
end
function canvas:motion_cb(x, y, status)
	print(x, y, status)
end
function idle_cb()
	if not lanesloop() then return iup.ExitLoop() end
    return iup.DEFAULT
end
--iup.SetIdle(idle_cb)
print(iup.BUTTON1)


--_initCb()
--iup.MainLoop()