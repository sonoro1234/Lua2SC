
--callback wrappers


initCbCallbacks={}
function _initCb()
	print("_initCb n callbacks",#initCbCallbacks)
	
	--guiSizesDelayed=guiGetSize()
	-- prtable(initCbCallbacks)
--	for i,v in ipairs(initCbCallbacks) do
--		print("prepared initCb",i, "from",#initCbCallbacks,debug.getinfo(v).short_src,debug.getinfo(v).linedefined)
--	end
	for i,v in ipairs(initCbCallbacks) do 
		print("initCb",i, "from",#initCbCallbacks,debug.getinfo(v).short_src,debug.getinfo(v).linedefined)
		--prtable(debug.getinfo(v))
		v() 
		--print("end initCb",i, "from",#initCbCallbacks)
	end
    if initCb then
        initCb()
    end	
    --make sure script is aware of current program status
	_initCbEnded=true
	print("end _initCb\n")
end    

resetCbCallbacks = resetCbCallbacks or {}
function _resetCb()
	print("_resetCb\n")
	if resetCb then
        resetCb()
    end

	for i=#resetCbCallbacks,1,-1 do
		print("resetcallback: ",i)
		resetCbCallbacks[i]()
	end
end

function _onFrameCb() end