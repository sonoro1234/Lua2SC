


local function resample_lin(data,pos)
	local posi = math.floor(pos)
	local frac = pos - posi
	local pos1 = (posi > 0) and posi or 1
	local a = data[pos1] --or 0
	local pos2 = ((posi + 1) <= #data) and (posi + 1) or #data
	local b = data[pos2] --or 0
	return a + (b-a)*frac
end
--pos is from 1 to #data
local function section_area(data,pos1,pos2)
	--print("sarea",pos1,pos2)
	local points = {}
	
	--local pos1c = math.floor(pos1+1)
	local pos1c = math.ceil(pos1)
	local pos2f = math.floor(pos2)
	points[#points+1] = {pos1c-pos1,resample_lin(data,pos1)}
	for i=pos1c,pos2f,1 do
		if data[i]==0 then return 0 end
		points[#points+1] = {1,data[i]}--{1,resample_lin(data,i)}
	end
	points[#points][1] = pos2-pos2f
	points[#points+1] = {pos2-pos2f,resample_lin(data,pos2)}
	local sum = 0
	local sumW = 0
	for i=1,#points-1 do
		sum = sum + (points[i][2] + points[i+1][2])*points[i][1]*0.5
		sumW = sumW + points[i][1]
	end
	return sum/sumW
end


local areas = {}
local fixed = {}
areas.I={0.36,0.50,0.82,1.00,1.45,3.90,3.33,2.84,2.75,3.84,4.30,4.38,4.16,3.22,2.50,2.25,2.19,2.27,1.78,1.25,0.74,0.28,0.18,0.14,0.19,0.28,0.48,0.75,0.51,0.71,1.00,0.74,1.24,1.51,1.65,1.59}
--areas.I={0.3375,0.635,3.06,2.94,3.85125,4.4475,4.38125,3.51,1.79875, 0.9375, 0.32375, 0.13, 0.2575, 0.822, 2.3838, 1.1508}
areas.I1={0.21,0.14,0.40,0.51,0.82,0.72,0.88,1.01,0.91,1.55,1.70,1.86,1.36,1.14,1.67,1.93,1.79,1.57,1.46,1.22,1.28,1.22,1.31,1.23,1.13,1.20,0.98,1.47,1.70,0.97,0.86,1.20,1.18,1.34}
areas.E={0.18,0.15,0.55,0.92,0.49,0.53,0.50,0.46,1.35,1.16,1.54,1.31,1.03,1.38,1.67,1.45,1.26,1.22,1.29,1.27,1.28,1.45,1.83,1.46,1.26,1.25,1.77,1.60,1.52,1.80,2.14,1.59}
areas.Ae={0.26,0.19,0.70,1.23,1.14,1.03,1.10,1.27,1.78,1.94,1.80,2.16,2.78,3.01,3.00,2.98,2.92,3.27,3.80,3.79,4.03,3.46,3.06,2.75,3.89,2.91,3.22,3.82,3.90,3.43}
areas.A={0.18,0.29,0.51,0.94,0.43,0.37,0.42,0.27,0.51,0.60,1.00,0.48,0.21,0.28,0.62,0.84,0.92,1.15,1.47,2.00,2.32,2.71,2.64,2.74,2.26,2.14,1.96,2.02,1.83,1.25,1.35,1.90,1.70,1.69}
areas.A1 ={0.20,0.42,0.46,1.17,1.55,0.99,0.38,0.18,0.97,1.17,1.24,1.32,1.08,1.18,1.38,2.04,2.06,2.36,2.78,2.86,3.50,3.54,3.84,4.31,5.16,5.19,4.39,3.20,2.89,2.13,1.95,1.38,1.29,2.81}
areas.Lorig={0.55,0.63,0.75,1.80,2.98,3.56,3.45,3.22,3.20,2.67,3.02,3.55,3.76,3.53,2.62,2.40,2.32,2.43,2.13,2.27,2.28,2.26,2.33,2.43,2.44,2.54,2.64,2.67,3.16,3.68,4.30,5.14,5.83,6.44,6.54,6.91,6.72,5.61,4.08,2.73,0.45,0.90,3.92,4.99,4.57,3.70}
areas.Lmalo={0.55,0.63,0.75,1.80,2.98,3.56,3.45,3.22,3.20,2.67,3.02,3.55,3.76,3.53,2.62,2.40,2.32,2.43,2.13,2.27,2.28,2.26,2.33,2.43,2.44,2.54,2.64,2.67,3.16,3.68,4.30,5.14,5.83,6.44,6.54,6.91,6.72,5.61,4.08,1.8,0.1,0.30,3.92,4.99,4.57,3.70}
areas.L={0.33,0.30,0.36,0.34,0.68,0.50,2.43,3.15,2.66,2.49,3.39,3.80,3.78,4.35,4.50,4.43,4.68,4.52,4.15,4.09,3.51,2.26,2.33,2.43,2.44,2.54,2.64,2.67,3.16,3.68,4.30,5.14,5.83,6.44,6.54,6.91,6.72,5.61,4.08,2.73,0.10,0.20,3.92,4.99,4.57,3.70}
fixed.L = {41,42}
areas.R={0.33,0.30,0.36,0.34,0.68,0.50,2.43,3.15,2.66,2.49,3.39,3.80,3.78,4.35,4.50,4.43,4.68,4.52,4.15,4.09,3.51,2.26,2.33,2.43,2.44,2.54,2.64,2.67,3.16,3.68,4.30,5.14,5.83,6.44,6.54,6.91,6.72,5.61,4.08,2.73,0.01,0.01,3.92,4.99,4.57,3.70}
areas.M = {0.57,0.57,0.21,0.58,2.18,3.15,2.96,2.89,3.70,4.21,3.57,3.59,2.97,3.17,3.25,2.58,2.74,2.77,2.49,2.93,3.33,2.27,2.57,2.17,1.84,1.98,1.73,1.43,1.73,2.08,2.32,2.84,3.51,4.25,4.79,4.61,4.07,3.64,2.84,1.42,0.0,0.00,0.00,0.7}

areas.N={0.26,0.24,0.17,0.21,0.15,0.36,1.37,1.66,1.35,0.90,0.71,0.93,1.41,2.07,2.12,2.04,2.16,2.36,2.52,2.88,2.30,1.93,1.77,0.96,0.89,1.22,1.30,1.30,1.14,0.77,0.34,0.15,0.22,0.21,0.00,0.00,0.00,0.00,0.00,0.00,1.59,1.60,1.69,1.17}
areas.O2={0.17,0.18,0.81,0.65,0.61,0.46,0.44,0.61,0.67,0.97,1.19,0.66,0.37,0.46,1.33,2.00,1.81,1.77,2.24,2.43,2.87,4.24,4.63,4.95,4.92,4.76,5.34,5.43,4.75,4.26,2.97,1.99,1.33,1.45,1.60,1.39}
areas.O1={0.18,0.17,0.23,0.28,0.59,1.46,1.60,1.11,0.82,1.01,2.72,2.71,1.96,1.92,1.70,1.66,1.52,1.28,1.44,1.28,0.89,1.25,1.38,1.09,0.71,0.46,0.39,0.32,0.57,1.06,1.38,2.29,2.99,3.74,4.39,5.38,7.25,7.00,4.57,2.75,1.48,0.68,0.39,0.14}--copied from male
areas.O={
0.17571428571428574,0.33904761904761915,1.5,0.99952380952380948,1.8242857142857145,2.2814285714285716,1.7733333333333334,1.5533333333333332,1.4171428571428573, 0.90857142857142859, 1.3661904761904762, 0.67428571428571438, 0.37333333333333341, 0.98640000000000017, 2.5482, 4.1916000000000002, 5.6718000000000002, 5.0136000000000003, 3.2052, 0.57540000000000002, 0.32879999999999998
} --a mano desde male
areas.Oc2 = {0.17714285714285713,0.74142857142857155,0.58857142857142852,0.44285714285714289,0.64428571428571424,1.0328571428571429,0.66000000000000003,0.43428571428571422,1.6171428571428574, 1.8042857142857143, 2.1728571428571435, 2.6814285714285724, 4.3514285714285714, 4.9500000000000002, 5.5890000000000004, 4.8491999999999997, 4.1916000000000002, 3.5340000000000007, 2.3016000000000001, 0.24660000000000004, 1.1508} --a mano desde female
areas.Oc1={0.137,0.28,1.46,1.11,1.01,1.781,1.92,1.66,1.28, 1.28, 1.25, 0.685, 0.137, 0.137, 1.06, 2.29, 3.74, 5.38, 7, 5.75, 3.68, 0.548}
areas.Oc2 ={0.1513,0.516,1.355,1.07,1.3955,1.8644,1.738,1.356,1.28, 1.25, 0.6302, 0.1644, 3.123, 4.767, 5.5068, 5.4246, 6.514, 6, 3.887, 0.548}
areas.Uo={0.07,0.10,0.07,0.05,0.18,0.43,0.75,0.47,0.29,0.11,0.32,0.58,1.11,0.84,0.17,0.39,0.81,1.03,1.02,1.04,1.42,1.93,2.10,2.21,2.53,2.82,2.80,2.46,2.32,2.46,2.09,2.57,1.76,1.37,1.09,1.16}
areas.U={0.22,0.48,0.81,0.90,1.20,3.13,2.71,1.75,2.01,2.20,2.16,2.56,2.61,2.34,2.05,1.21,0.80,0.74,1.36,1.18,1.05,0.78,0.78,1.17,1.47,2.00,2.50,2.92,3.10,2.98,3.40,3.61,2.97,2.74,1.79,0.87,0.44,0.18}

areas.P = {0.31,0.39,0.42,0.71,1.28,1.80,1.70,1.43,1.25,0.90,2.06,2.77,2.19,2.35,2.67,2.17,1.77,2.09,2.16,2.26,2.26,2.29,2.17,2.13,2.64,2.65,2.30,2.12,1.67,1.44,1.16,1.51,1.76,1.93,1.98,2.21,2.35,2.45,2.37,2.47,1.75,1.09,0.70,0.00}
--areas.T={0.38,0.50,0.40,1.07,1.38,1.65,1.29,1.01,0.92,0.86,1.03,1.60,2.46,2.24,2.47,2.86,2.74,3.32,3.83,3.97,4.16,4.41,4.11,3.95,3.64,3.37,2.89,2.61,2.69,2.32,2.04,1.64,1.39,1.26,0.87,0.60,0.10,0.00,0.00,0.13,0.18,1.48,1.60,1.43}
areas.T={0.38,0.50,0.40,1.07,1.38,1.65,1.29,1.01,0.92,0.86,1.03,1.60,2.46,2.24,2.47,2.86,2.74,3.32,3.83,3.97,4.16,4.41,4.11,3.95,3.64,3.37,2.89,2.61,2.69,2.32,2.04,1.64,1.39,1.26,0.87,0.60,0.0,0.00,0.00,0.13,0.18,1.48,1.60,1.43}
areas.K={0.34,0.35,0.49,0.78,1.31,1.34,1.19,0.94,0.69,0.92,1.45,1.73,1.67,2.13,1.61,1.56,1.54,1.18,1.44,1.12,0.76,0.96,1.09,0.79,0.25,0.00,0.00,0.03,0.09,0.10,0.06,0.03,0.48,1.27,2.28,2.35,2.40,2.41,4.21,3.37,2.46,2.46,2.14,1.50}
------------
tenor_areas = {}
tenor_areas.I = {}
tenor_areas.I[1] = 1
tenor_areas.I[2] = 1.1576089870161
tenor_areas.I[3] = 6.4316706003408
tenor_areas.I[4] = 0.91158888470934
tenor_areas.I[5] = 1.3196993974341
tenor_areas.I[6] = 0.26759943209992
tenor_areas.I[7] = 0.7086225652888
tenor_areas.I[8] = 0.23455707278156
tenor_areas.I[9] = 0.9476051853814
tenor_areas.I[10] = 0.96635078929917
tenor_areas.I[11] = 7.2585761644867
tenor_areas.O = {}
tenor_areas.O[1] = 1
tenor_areas.O[2] = 0.26889619030935
tenor_areas.O[3] = 0.53388191369012
tenor_areas.O[4] = 0.042133096501404
tenor_areas.O[5] = 0.70090402010355
tenor_areas.O[6] = 0.44308549172117
tenor_areas.O[7] = 2.4667249084471
tenor_areas.O[8] = 0.23444529023805
tenor_areas.O[9] = 0.97178114643663
tenor_areas.O[10] = 0.6277270966062
tenor_areas.O[11] = 4.8163618382412
tenor_areas.U = {}
tenor_areas.U[1] = 1
tenor_areas.U[2] = 0.039193849953601
tenor_areas.U[3] = 0.084214693821866
tenor_areas.U[4] = 0.033693892802856
tenor_areas.U[5] = 1.4161232357091
tenor_areas.U[6] = 0.72731031905778
tenor_areas.U[7] = 1.4170710838673
tenor_areas.U[8] = 0.13887886013003
tenor_areas.U[9] = 0.47210540313702
tenor_areas.U[10] = 0.37235669556612
tenor_areas.U[11] = 2.9854003878669
tenor_areas.A = {}
tenor_areas.A[1] = 1
tenor_areas.A[2] = 0.52049142873833
tenor_areas.A[3] = 1.7548900156723
tenor_areas.A[4] = 0.24758903518933
tenor_areas.A[5] = 2.6750975184055
tenor_areas.A[6] = 1.8978953008264
tenor_areas.A[7] = 9.3616643339252
tenor_areas.A[8] = 1.7218086380404
tenor_areas.A[9] = 5.7875776846001
tenor_areas.A[10] = 3.9741243932766
tenor_areas.A[11] = 25.115777823472
tenor_areas.E = {}
tenor_areas.E[1] = 1
tenor_areas.E[2] = 0.78525426197846
tenor_areas.E[3] = 3.1517436428599
tenor_areas.E[4] = 0.78920677092643
tenor_areas.E[5] = 1.7718492093422
tenor_areas.E[6] = 0.46647527134182
tenor_areas.E[7] = 1.1359056651119
tenor_areas.E[8] = 0.34603715733702
tenor_areas.E[9] = 1.0192893464237
tenor_areas.E[10] = 0.87410649502352
tenor_areas.E[11] = 6.3009566123863
for k,v in pairs(tenor_areas) do
	areas[k.."te"]=v
end
-----------------------------------------
areas.S = deepcopy(areas.N)
local Tract = {}
Tract.areas = areas


Tract.nasal = {["M"]=true,["N"]=true}

Tract.noise = {}
Tract.noise.F = {pos=22,freqs={1800,4000},bw={0.5,0.15}} 
Tract.noise.S = {pos=22,freqs={2500,7500},bw={0.15,0.1}}--{pos=21,freqs={3500,7500},bw={0.5,0.15}} 
Tract.noise.Z = {pos=22,freqs={4000,4500},bw={0.15,0.15}} --,bw={1,0.5}}


Tract.len = {}
Tract.len.I = 14.29
Tract.len.I2 = 13.49
Tract.len.E = 12.70
Tract.len.Ae = 11.9
Tract.len.A = 13.49
Tract.len.A1 = 13.49
Tract.len.Oorig = 17.46
Tract.len.O = 14.29
Tract.len.Uo = 14.29
Tract.len.U = 15.08
Tract.len.Lorig = 18.25
Tract.len.L = 14.29
Tract.len.M = 14.29
Tract.len.N = 14.29
Tract.len.K = 14.29
Tract.deflen = 14.29
--------------gains
Tract["gains"] = {}
Tract.gains.Ate = db2amp(6)
Tract.gains.Ete = db2amp(0)
Tract.gains.Ite = db2amp(5)
Tract.gains.Ote = db2amp(0)
Tract.gains.Ute = db2amp(0)

Tract.gains.A = db2amp(2)
Tract.gains.B = db2amp(-25)-- -61)
Tract.gains.P = db2amp(-25)
Tract.gains.D = db2amp(-15)
Tract.gains.T = db2amp(-20)
Tract.gains.R = db2amp(-5) --db2amp(-5)
Tract.gains.K = db2amp(0)
Tract.gains.G = db2amp(-20)
Tract["gains"]["O"] = db2amp(-10)
Tract["gains"]["O1"] = db2amp(0)
Tract.gains.L = db2amp(-5)
Tract.gains.E = db2amp(2)
Tract.gains.I = db2amp(0)
Tract.gains.I1 = db2amp(0)
Tract.gains.M = db2amp(-12)
Tract["gains"]["Ui"] = 0.50118723362727
Tract["gains"]["U1"] = db2amp(-18)
Tract.gains.U = db2amp(-18)
Tract.gains.N = db2amp(-3)
Tract.gains.S = db2amp(0)
Tract.gains.F = db2amp(-3)
Tract.gains.Z = db2amp(10)
-----------------

--[=[
local data = areas.A
--data = {1,0.5,3,0} 
--data = {3,1,2}
local NNres = #data+5 --18
local function XX(x) 
	local i = math.floor(linearmap(0,1,1,NNres,x));
	local bin1 = linearmap(1,NNres,1,#data,i)
	local bin2 = linearmap(1,NNres,1,#data,i+1)
	bin1 = math.min(bin1,#data)
	bin2 = math.min(bin2,#data)
	return section_area(data,bin1,bin2) 
end
graph = addControl{typex="funcgraph3",minx=0,maxx=1,miny=0,maxy=7,width=500,height=500}
---[[
graph:val{funcs={--function(i) return resample(data,i) end,
				function(i) return resample_lin(data,linearmap(0,1,1,#data,i)) end,
				--function(i) return resample_lin(data,math.floor(i*NNres)*#data/NNres) end,
--				function(x) local i = math.floor(linearmap(0,1,1,NNres,x)+0.5);
--					local bin = linearmap(1,NNres,1,#data,i)
--					return resample_lin(data,bin) end,
				XX,
				--function(i) return resample_lin(data,math.floor(linearmap(0,1,1,#data,i)+0.5)) end,
				
				--function(i) return resample(data,i*#data/NNres) end
}}
--]]
guiUpdate()
--section_area(data,44,45)
for x=0,1,1/500 do
	--print(x,XX(x))
end
--]=]

local AreaNoseI = {1.35,1.7,1.7,1.3,0.9}
local rNose = {1,1.35,1.5,1.7,1.7,1.7,1.5,1.3,0.9}
rNose = {0.25,1.35,1.5,2.5,3,2.5,1.5,1.3,0.5}
rNose = {1,2,4,4,5,6,6,6,4,2,1}
AreaNoseI = TA(rNose)--:Do(function(v) return v*v*math.pi end)
local AreaNoseC = deepcopy(AreaNoseI)
AreaNoseC[1]=0

local AreaNose = {4.2,3.6,4.4,4.8,4.1,5,5,7,6.2,6.2,5.2,4.6,3.2,2.4,2.2}
local lennose ={0.8,1.6,3.2,3.8,4.4,4.9,5.1,6.6,6.9,7.8,8.9,9.7,10.5,11.5,12.9}
for i,v in ipairs(lennose) do
	lennose[i] = v/12.9
end
local function NoseArea(x)
	local sec
	for i=1,#lennose do
		if x <= lennose[i] then sec=i;break end
	end
	return linearmap(lennose[sec-1] or 0,lennose[sec] or 1,AreaNose[sec-1] or AreaNose[1],AreaNose[sec] ,x)
end
---------------------------------------------------------

local function GetData(NN,resamp)

	local minlen1 = 12.70/NN
	local samp = 44100*minlen1/(35000)
	print("samp",samp,NN)
	if resamp then
		assert(samp>=0.5)
	else
		assert(samp>=1)
	end
	local ar = {}
	for k,v in pairs(areas) do
		ar[k] = {}
		for i=1,NN do
			ar[k][i] = resample_lin(v,i*#v/NN)
--			local bin1 = linearmap(1,NN+1,1,#v,i)
--			local bin2 = linearmap(1,NN+1,1,#v,i+1)
--			bin2 = math.min(bin2,#v)
--			ar[k][i] = section_area(v,bin1,bin2) 
		end
	end
	for k,v in pairs(fixed) do
		Tract.fixed = Tract.fixed or {}
		Tract.fixed[k] = {}
		local tt = Tract.fixed[k]
		local lenars = #areas[k]
		for i_sec,fsec in ipairs(v) do
			local tfsec = NN*fsec/lenars
			tt[#tt + 1] = math.floor(tfsec + 0.5)
		end

	end
	-------------noise pos
	local noiseloc = NN-1 --math.floor(NN*0.95)
	Tract.noise.S.pos = noiseloc --NN-1
	Tract.noise.F.pos = noiseloc --NN-1
	Tract.noise.Z.pos = noiseloc --NN-1

	--local NNnose = math.floor(0.5 + NN/22*#AreaNose)
	--local NNnose = math.floor(0.5 + 12/17.5*#AreaNose)
	local len1 = 17/NN
	local NNnose = math.floor( (14*12/17)/len1)
	local res1,res2 = {},{}
	for i=1,NNnose do
		--res1[i] = resample_lin(AreaNoseI,i*#AreaNoseI/NNnose)
		res1[i] = NoseArea(i/NNnose)
		res2[i] = res1[i]
	end

	res2[1]=0
	Tract.area1len = 0.47*NN
	Tract.areas = ar
	Tract.AreaNose = res1
	Tract.AreaNoseC = res2

	return Tract
end

--prtable(GetData(10))

return GetData


