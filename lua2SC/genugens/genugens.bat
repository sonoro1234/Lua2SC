"%CD%/../../SuperCollider/sclang" -d "%CD%" -a -l sclang.cfg genugens.scd  > dumpedugens.lua
"%CD%/../../luajit.exe" cleandumpedugens.lua
cmd /k