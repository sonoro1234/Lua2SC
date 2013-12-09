
--callback wrappers


initCbCallbacks={}
function _initCb()
	print("_initCb\n")
	
	--guiSizesDelayed=guiGetSize()
	for i,v in ipairs(initCbCallbacks) do v() end
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
  
	for i=#resetCbCallbacks,1,-1 do
		print("resetcallback: ",i)
		resetCbCallbacks[i]()
	end
    if resetCb then
        resetCb()
    end

end

function _onFrameCb() end