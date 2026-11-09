
local gllib = require"gl"
--gllib.set_loader(W.sdl)
local gl, glc, glu, glext = gllib.libraries()
local ig = require"imgui.GLFW"
local ffi = require"ffi"



local function newImGuiCanvas(parent)
local panel
local context
local ww,hh = 450,450
local function keepsize(event)
	ww,hh = panel:GetClientSizeWH()
	panel:Refresh(false)
	panel:Update()
end

local function OnMouseWheel(event)
	--if (event:GetWheelAxis() == wx.wxMOUSE_WHEEL_VERTICAL) then
	--if event: == wx.wxEVT_MOUSEWHEEL then
	local io = ig.GetIO();
		local wheel_y = event:GetWheelDelta() * event:GetWheelRotation()
		io:AddMouseWheelEvent(0, (wheel_y>0 and 1) or (wheel_y<0 and -1) or 0);
	--	g_MouseWheel += event.GetWheelDelta() * event.GetWheelRotation();
	--end
end
local function OnMouseEvent(event)
	local mouse_button = -1
	local io = ig.GetIO();
	--local mb = event:GetButton()
	-- if (event:LeftDown()) then
		-- g_MousePressed[0] = event:LeftIsDown();
	-- end
	-- if (event:MiddleDown()) then
		-- g_MousePressed[1] = event:MiddleIsDown();
	-- end
	-- if (event:RightDown()) then
		-- g_MousePressed[2] = event:RightIsDown();
	-- end
	if event:Button( wx.wxMOUSE_BTN_LEFT) then
		mouse_button = 0
	elseif event:Button( wx.wxMOUSE_BTN_RIGHT) then
		mouse_button = 1
	elseif event:Button( wx.wxMOUSE_BTN_MIDDLE) then
		mouse_button = 2
	end
	if mouse_button~=-1 then
	io:AddMouseButtonEvent(mouse_button, event:ButtonDown());
	end
	

	-- g_MousePos[0] = event:GetX();
	-- g_MousePos[1] = event:GetY();
	io:AddMousePosEvent(event:GetX(), event:GetY());
	event:Skip();
end


local keytab = {
		[wx.WXK_TAB] = ig.lib.ImGuiKey_Tab,
		[wx.WXK_LEFT] = ig.lib.ImGuiKey_LeftArrow,
		[wx.WXK_RIGHT] = ig.lib.ImGuiKey_RightArrow,
		[wx.WXK_UP] = ig.lib.ImGuiKey_UpArrow,
		[wx.WXK_DOWN] = ig.lib.ImGuiKey_DownArrow,
		[wx.WXK_PAGEUP] = ig.lib.ImGuiKey_PageUp,
		[wx.WXK_PAGEDOWN] = ig.lib.ImGuiKey_PageDown,
		[wx.WXK_HOME] = ig.lib.ImGuiKey_Home,
		[wx.WXK_END] = ig.lib.ImGuiKey_End,
		[wx.WXK_DELETE] = ig.lib.ImGuiKey_Delete,
		[wx.WXK_BACK] = ig.lib.ImGuiKey_Backspace,
		[wx.WXK_RETURN] = ig.lib.ImGuiKey_Enter,
		[wx.WXK_ESCAPE] = ig.lib.ImGuiKey_Escape,
	}
--print("key--------------------",wx.WXK_TAB , ig.lib.ImGuiKey_Tab)
local function WxKeyCodeToImgui(kc)
	--print("kc is:",kc,"ImGuiKey_Tab",ig.lib.ImGuiKey_Tab)
	if kc >=65 and kc <=90 then
		return kc - 65 + ig.lib.ImGuiKey_A
	end
	return keytab[kc] or ig.lib.ImGuiKey_None
end
local function OnKeyEvent(event)
	local io = ig.GetIO();
    io:AddKeyEvent(ig.lib.ImGuiMod_Ctrl, event:ControlDown());
    io:AddKeyEvent(ig.lib.ImGuiMod_Shift, event:ShiftDown());
    io:AddKeyEvent(ig.lib.ImGuiMod_Alt, event:AltDown());
    --io:AddKeyEvent(ig.lib.ImGuiKey_ModSuper, (sdl_key_mods & KMOD_GUI) != 0);
	io:AddKeyEvent(WxKeyCodeToImgui(event:GetKeyCode()),event:GetEventType() == wx.wxEVT_KEY_DOWN)
	event:Skip();
end

local function OnCharEvent(event)
	local uc = event:GetUnicodeKey();
	
	if (uc ~= wx.WXK_NONE) then
		ig.GetIO():AddInputCharacter(uc);
	end
	-- else // No Unicode equivalent.
	-- {
		-- unsigned int c = event.GetRawKeyCode();
		-- if (c > 0 && c < 1000)
			-- ImGui::GetIO().AddInputCharacter(c);
	-- }

	--event:DoAllowNextEvent();

	event:Skip();
end

-- Create a function to encapulate the code, not necessary, but it makes it
--  easier to debug in some cases.
local function ImGui_ImplWx_NewFrame(window)
	--cAssert(window != 0, "Erreur : window = 0");

	--if (!g_FontTexture)
	--	ImGui_ImplWx_CreateDeviceObjects();

	local io = ig.GetIO();

	--// Setup display size (every frame to accommodate for window resizing)
	local w, h;
	local display_w, display_h;
	local rc = window:GetClientRect();
	w = rc.width;
	display_w = w;
	h = rc.height;
	display_h = h;
	io.DisplaySize.x, io.DisplaySize.y = w,h
	io.DisplayFramebufferScale.x, io.DisplayFramebufferScale.x = 1,1
--[[
	// Setup time step
	double time = g_Time.get() / 1000.0f;
	io.DeltaTime = time > 0.0 ? (float)(time) : (float)(1.0f / wxIMGUI_FPS);
	g_Time.Fix();
--]]

	-- if (window:HasFocus()) then
		-- io.MousePos = ig.ImVec2(g_MousePos[0], g_MousePos[1]);
	-- else
		-- io.MousePos = ig.ImVec2(-1, -1);
	-- end
	
	--io.AddMousePosEvent((float)mouse_x, (float)mouse_y);
--[[
	local mouseStat = wx.wxGetMouseState();
	io.MouseDown[0] = g_MousePressed[0] or mouseStat:LeftIsDown();
	io.MouseDown[1] = g_MousePressed[1] or mouseStat:RightIsDown();
	io.MouseDown[2] = g_MousePressed[2] or mouseStat:MiddleIsDown();
	g_MousePressed[0] ,g_MousePressed[1], g_MousePressed[2] = false, false,false;
--]]
	--io.MouseWheel = g_MouseWheel;
	--g_MouseWheel = 0.0;
--[[
	io.KeyCtrl = (GetKeyState(VK_CONTROL) & 0x8000) != 0;
	io.KeyShift = (GetKeyState(VK_SHIFT) & 0x8000) != 0;
	io.KeyAlt = (GetKeyState(VK_MENU) & 0x8000) != 0;
	io.KeySuper = false;

	-- Hide OS mouse cursor if ImGui is drawing it
	ShowCursor(io.MouseDrawCursor ? 0 : 1);

	-- Start the frame
	ImGui::NewFrame();
--]]
end


local imgui_func = function() end
local function glrender()

	local res = panel:SetCurrent(context) or print("bad current")
	gl.glViewport(0, 0, ww, hh);
	gl.glClearColor(1,0,0,0)
	gl.glClear(bit.bor(glc.GL_COLOR_BUFFER_BIT,glc.GL_DEPTH_BUFFER_BIT))
	 gl.glBegin(glc.GL_POLYGON);
        gl.glColor3f(1.0, 1.0, 1.0);
        gl.glVertex2f(-0.5, -0.5);
        gl.glVertex2f(-0.5, 0.5);
        gl.glVertex2f(0.5, 0.5);
        gl.glVertex2f(0.5, -0.5);
        gl.glColor3f(0.4, 0.5, 0.4);
        gl.glVertex2f(0.0, -0.8);
    gl.glEnd();

    gl.glBegin(glc.GL_POLYGON);
        gl.glColor3f(1.0, 0.0, 0.0);
        gl.glVertex2f(0.1, 0.1);
        gl.glVertex2f(-0.1, 0.1);
        gl.glVertex2f(-0.1, -0.1);
        gl.glVertex2f(0.1, -0.1);
    gl.glEnd();
	
	ig.lib.ImGui_ImplOpenGL3_NewFrame();
    --lib.ImGui_ImplSDL2_NewFrame();
	ImGui_ImplWx_NewFrame(panel)
    ig.lib.igNewFrame();
	
	imgui_func(ig)
	
	ig.lib.igRender()
    ig.lib.ImGui_ImplOpenGL2_RenderDrawData(ig.lib.igGetDrawData());
	--[[
	--viewport branch
        if W.has_imgui_viewport then
            local igio = ig.GetIO()
            if bit.band(igio.ConfigFlags , ig.lib.ImGuiConfigFlags_ViewportsEnable) ~= 0 then
                local backup_current_context = W.lj_glfw.getCurrentContext();
                ig.UpdatePlatformWindows();
                ig.RenderPlatformWindowsDefault();
                window.makeContextCurrent(backup_current_context)
                --window:makeContextCurrent()
            end
        end
		
		        --viewport branch
        if W.has_imgui_viewport then
            local igio = ig.GetIO()
            if bit.band(igio.ConfigFlags , ig.lib.ImGuiConfigFlags_ViewportsEnable) ~= 0 then
                ig.UpdatePlatformWindows();
                ig.RenderPlatformWindowsDefault();
                sdl.gL_MakeCurrent(window, gl_context)
            end
        end
	
	--]]
	panel:SwapBuffers() 

end

-- paint event handler for the frame that's called by wxEVT_PAINT
local function OnPaint(event)
    -- must always create a wxPaintDC in a wxEVT_PAINT handler
	print"paint"
	--local res = panel:SetCurrent(context) or print("bad current")
	
    local dc = wx.wxPaintDC(panel)
	---[[
	glrender()
	--]]
	--[[
    -- call some drawing functions
    dc:DrawRectangle(10, 10, 300, 300);
    dc:DrawRoundedRectangle(20, 20, 280, 280, 20);
    dc:DrawEllipse(30, 30, 260, 260);
    dc:DrawText("A test string", 50, 150);
    -- the paint DC will be automatically destroyed by the garbage collector,
    -- however on Windows 9x/Me this may be too late (DC's are precious resource)
    -- so delete it here
--]]
	
    dc:delete() -- ALWAYS delete() any wxDCs created when done
end



	local imguictx = ig.lib.igCreateContext(nil)

	
	local glargs = {wx.WX_GL_RGBA, wx.WX_GL_DOUBLEBUFFER, 
	wx.WX_GL_DEPTH_SIZE, 16,
	--wx.WX_GL_MAJOR_VERSION,3,
	--wx.WX_GL_MINOR_VERSION, 2,
	0}
	print(wx.WX_GL_RGBA, wx.WX_GL_DOUBLEBUFFER, wx.WX_GL_DEPTH_SIZE, 16, 0)
	--print(wx.wxGLCanvas:IsDisplaySupported(glargs))
	panel = wx.wxGLCanvas(parent, wx.wxID_ANY,glargs, wx.wxDefaultPosition, wx.wxSize(450, 450), wx.wxEXPAND)
		--ig.lib.ImGui_ImplOpenGL3_Init("#version 130")
		--ig.lib.ImGui_ImplOpenGL2_Init()
	context = wx.wxGLContext(panel)

	local aares = panel:SetCurrent(context) or print("bad current 1")
	--print("gl.VERSION ",ffi.string(gl.glGetString(glc.GL_VERSION) or ""))
	--print("gl.VERSION ",gl.glGetString(glc.GL_VERSION)) 	
	--ig.lib.ImGui_ImplOpenGL2_Init()--"#version 130")
	ig.lib.ImGui_ImplOpenGL3_Init("#version 130")
	
    -- connect the paint event handler function with the paint event
    panel:Connect(wx.wxEVT_PAINT, OnPaint)
	panel:Connect(wx.wxEVT_SIZE, keepsize)
	local mouse_evts = {
    wx.wxEVT_ENTER_WINDOW
    ,wx.wxEVT_LEAVE_WINDOW
    ,wx.wxEVT_LEFT_DOWN
    ,wx.wxEVT_LEFT_UP
    ,wx.wxEVT_LEFT_DCLICK
    ,wx.wxEVT_MIDDLE_DOWN
    ,wx.wxEVT_MIDDLE_UP
    ,wx.wxEVT_MIDDLE_DCLICK
    ,wx.wxEVT_RIGHT_DOWN
    ,wx.wxEVT_RIGHT_UP
    ,wx.wxEVT_RIGHT_DCLICK
    -- ,wx.wxEVT_AUX1_DOWN
    -- ,wx.wxEVT_AUX1_UP
    -- ,wx.wxEVT_AUX1_DCLICK
    -- ,wx.wxEVT_AUX2_DOWN
    -- ,wx.wxEVT_AUX2_UP
    -- ,wx.wxEVT_AUX2_DCLICK
    ,wx.wxEVT_MOTION
    --,wx.wxEVT_MOUSEWHEEL
}
	for i,ev in ipairs(mouse_evts) do
		panel:Connect(ev, OnMouseEvent)
	end
	panel:Connect(wx.wxEVT_MOUSEWHEEL, OnMouseWheel)
	--[[
	panel:Connect(wx.wxEVT_MOTION, OnMouseEvent)
	panel:Connect(wx.wxEVT_LEFT_DOWN, OnMouseEvent)
	panel:Connect(wx.wxEVT_LEFT_UP, OnMouseEvent)
	panel:Connect(wx.wxEVT_RIGHT_UP, OnMouseEvent)
	panel:Connect(wx.wxEVT_ENTER_WINDOW, OnMouseEvent)
	panel:Connect(wx.wxEVT_LEAVE_WINDOW, OnMouseEvent)
	--]]
	panel:Connect(wx.wxEVT_KEY_DOWN, OnKeyEvent)
	panel:Connect(wx.wxEVT_KEY_UP, OnKeyEvent)
	panel:Connect(wx.wxEVT_CHAR, OnCharEvent)
	


	panel:Refresh()
	
	function panel:set_imgui_func(func)
		imgui_func = func
	end
	panel.onpaint = glrender
    return panel
end

return newImGuiCanvas


