(
var failedclasses=[];
var testclass = {arg class;try {class.new().rate; }{nil;}};
UGen.allSubclasses.do({arg it;
	var armet,nameclass,mulind,comas,losmetodos,defaultval,therearedefaults,argnames,supcl;
	var methodfound,excluded,isexcl;
	losmetodos=['ir','kr','ar'];
	excluded=["Out","MultiOutUGen","OutputProxy","BinaryOpUGen","UnaryOpUGen"];//,"LocalBuf","PackFFT"];
	nameclass=it.name.asString;
	isexcl = excluded.detect({arg itexcl;itexcl==nameclass});
	if(isexcl.isNil,{
	nameclass.post;
	if(it.isOutputUGen,
		{"=Out:new{name='".post;},
		{supcl=it.superclasses.detect({arg it2;it2.name.asString=="MultiOutUGen";});
		if(supcl.notNil,
			{"=MultiOutUGen:new{name='".post;},
			{"=UGen:new{name='".post;}
		);}
	);
	nameclass.post;
	"'\}".postln;
	methodfound=false;
	losmetodos.do({arg metod,indmetod;
	armet=it.class.findRespondingMethodFor(metod);
	if (armet.notNil,
		{
			methodfound=true;
			//("--"+armet.argumentString).postln;
			argnames=armet.argNames;
			//argnames.postln;
			argnames.do({arg varname,ind;
				if((varname==\end) || (varname==\in),
					{
						//"cambio varname".postln;
						argnames.put(ind,(varname.asString++"_a").asSymbol);
					}
				);
			});
			("function "++nameclass++"."++metod.asString++"(").post;
			argnames.do({arg varname,ind;
				if(ind!=0,{varname.asString.post;});
				if((ind>0) && (ind<(argnames.size-1)),{",".post;});
			});
			")".postln;
			therearedefaults=false;
			"\t".post;
			argnames.do({arg varname,ind;
				defaultval=armet.prototypeFrame.at(ind);
				if((ind>0) && (defaultval.notNil),{
					therearedefaults=true;
					(varname.asString++"="++varname.asString++" or ").post;
					if((defaultval.isString) || (defaultval.class.name.asString=="Symbol"),
						{("'"++defaultval.asString++"';").post;},
						{(defaultval.asString++";").post;}
					);
				});
			});
			if(therearedefaults,{"".postln});
			if(it.isOutputUGen,
				{("\treturn "++nameclass++":donew{").post;},
				{("\treturn "++nameclass++":MultiNew{").post;}
			);
			(indmetod.asString).post;
			mulind=argnames.detectIndex({arg it2;it2=='mul';});
			//mulind=mulind??{armet.argNames.size};
			//comas=false;
			argnames.do({arg varname,ind;
				if((ind>0) && (varname!='mul') && (varname!='add'),
					{
						//if(comas,{",".post;},{comas=true});
						",".post;
						varname.asString.post;
					}
				);
			});
			if(mulind.notNil,{"\}:madd(mul,add)".postln},{"}".postln;});
			"end".postln;
		}
	);//armet.notnil
	});//losmetodos.do
	if(methodfound,{},
	{
		var larate=testclass(it);
		if(larate.notNil,{
		var therearedefaults,mulind;
		var ratefunc=switch (larate,
    			\scalar,   { "ir" },
    			\control, { "kr" },
    			\audio, { "ar"},
				\demand,{"dm"}
		);
		var ratenum=switch (larate,
    			\scalar,   { 0 },
    			\control, { 1 },
    			\audio, { 2},
				\demand,{3}
		);
		var metodo=it.class.findMethod(\new);
		//metodo.argumentString.postln;
		var argnames=metodo.argNames;
			//argnames.postln;
			argnames.do({arg varname,ind;
				if((varname==\end) || (varname==\in),
					{
						argnames.put(ind,(varname.asString++"_a").asSymbol);
					}
				);
			});
		//"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx".postln;
		("function "++it.name++"."++ratefunc++"(").post;
		argnames.do({arg varname,ind;
				if(ind!=0,{varname.asString.post;});
				if((ind>0) && (ind<(argnames.size-1)),{",".post;});
			});
			")".postln;
			therearedefaults=false;
			"\t".post;
			argnames.do({arg varname,ind;
				var defaultval=metodo.prototypeFrame.at(ind);
				if((ind>0) && (defaultval.notNil),{
					therearedefaults=true;
					(varname.asString++"="++varname.asString++" or ").post;
					if((defaultval.isString) || (defaultval.class.name.asString=="Symbol"),
						{("'"++defaultval.asString++"';").post;},
						{(defaultval.asString++";").post;}
					);
				});
			});
		if(therearedefaults,{"".postln});
		if(it.isOutputUGen,
				{("\treturn "++it.name++":donew{").post;},
				{("\treturn "++it.name++":MultiNew{").post;}
			);
			(ratenum.asString).post;
			//mulind=mulind??{armet.argNames.size};
			//comas=false;
			argnames.do({arg varname,ind;
				if((ind>0) && (varname!='mul') && (varname!='add'),
					{
						//if(comas,{",".post;},{comas=true});
						",".post;
						varname.asString.post;
					}
				);
			});
			"}".postln;
			if(argnames.notNil,{
				mulind=argnames.detectIndex({arg it2;it2=='mul';});
				if(mulind.notNil,{":madd(mul,add)".postln});
			});
			"end".postln;
		});//la rate not nil no testfail
	});//not methodfound
	}); //not out or multi
});
"failed classes are".postln;
failedclasses.do({arg it; it.postln;});
)
////////////operators binary
+, -, *, /, div, %, **, min, max, <, <=, >, >=, &, |, lcm, gcd, round, trunc, atan2,
hypot, hypotApx, >>, +>>, fill, ring1, ring2, ring3, ring4, difsqr, sumsqr, sqrdif, absdif, amclip,
scaleneg, clip2, excess, <!, rrand, exprand, rotate, dist, bitAnd, bitOr, bitXor, bitHammingDistance, @

//////////////
**
////////////operators binary
(
~binops=['==','+','-','*','/','div','%','**','min','max','<','<=','>','>=','&','|','lcm','gcd',
'round','trunc','atan2','hypot','hypotApx','>>','+>>','fill','ring1','ring2','ring3',
'ring4','difsqr','sumsqr','sqrdif','absdif','amclip','scaleneg','clip2','excess',
'<!','rrand','exprand','rotate','dist','bitAnd','bitOr','bitXor','bitHammingDistance','@'];
//~binops.post;
~binops.do({arg item; ("[\""++item.asString++"\"]="++item.specialIndex++",").post;})
//String
)
(
SynthDef("plukaa2",{

		var signal;
		Out.ar(0, WhiteNoise.ar());

}).store;
)
(
SynthDef("help-Control", { arg out=0,i_freq;
	var klank, n, harm, amp, ring,harm2,harm3,xxx;
	// harmonics
	harm = Control.names([\harm]).ir(Array.series(4,1,1));
	// amplitudes
	//harm.post;
	xxx = Control.names([\harm2]).kr([1,[2,3,4]]);
	//harm2 = NamedControl.kr(\freq, 440);
	// amplitudes
	xxx.do({arg it;
	//it.dump;
	//it.source.dump;
	it.source.values.dump;
	});
	amp = Control.names([\amp]).ir(Array.fill(4,0.05));
	// ring times
	ring = Control.names([\ring]).ir(Array.fill(4,1));
	klank = Klank.ar(`[harm,amp,ring], {ClipNoise.ar(0.003)}.dup, i_freq);
	Out.ar(out, klank);
}).send(s);
)
SimpleNumber
///operato special index table
(
"{".post;
AbstractFunction.methods.do({arg it;
	if(it.name.specialIndex!= -1,
		{
			("[\""++it.name++"\"]="++it.name.specialIndex++",").post;
			//it.name.specialIndex.post;
		}
	)
	});
"}".postln;
)
//////////////
absdif
addition
amclip
atan2
clip2
difsqr
division
excess
exponentiation
fold2
greaterorequalthan
greaterthan
hypot
hypotApx
lessorequalthan
lessthan
max
min
modulo
multiplication
pow
ring1
ring2
ring3
ring4
round
scaleneg
sqrdif
sqrsum
subtraction
sumsqr
thresh
trunc
wrap2
/////unary ops/////////////////
neg, reciprocal, bitNot, abs, asFloat, asInt, ceil, floor, frac, sign, squared, cubed, sqrt
exp, midicps, cpsmidi, midiratio, ratiomidi, ampdb, dbamp, octcps, cpsoct, log, log2,
log10, sin, cos, tan, asin, acos, atan, sinh, cosh, tanh, rand, rand2, linrand, bilinrand,
sum3rand, distort, softclip, nyqring, coin, even, odd, isPositive, isNegative,
isStrictlyPositive, rho, theta
//////////////////////////////////
abs
acos
ampdb
asin
atan
ceil
convertRhythm
cos
cosh
cpsmidi
cpsoct
cubed
dbamp
distort
exp
floor
frac
isNegative
isPositive
isStrictlyPositive
log
log10
log2
midicps
neg
octcps
reciprocal
sign
sin
sinh
softclip
sqrt
squared
tan
tanh
           