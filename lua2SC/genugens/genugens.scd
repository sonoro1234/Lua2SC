
var failedclasses=List.new();
var find_rate_from_new = {arg class;var ret;try {ret=class.new().rate; }{ret=\fail};ret};
var excluded=["Out","MultiOutUGen","OutputProxy","BinaryOpUGen","UnaryOpUGen","MulAdd"];
var losmetodos=['ir','kr','ar'];

var ugens;
//get all sorted ugens except excluded
ugens = UGen.allSubclasses.select({|ugen| excluded.detect({arg itexcl;itexcl==ugen.name.asString}).isNil});
ugens.sort({|a, b| a.name < b.name});

ugens.do({arg it;
	var armet,nameclass,mulind,defaultval,argnames,supcl;
	var methodfound,isexcl;


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
			argnames=armet.argNames.copyRange(1,armet.argNames.size);
			//argnames.postln;
			//argnames=argnames.replace([\end],[\endp]).replace('in','inp');
			argnames.do({arg varname,ind;
				if((varname==\end) || (varname==\in),
					{
						argnames.put(ind,(varname.asString++"p").asSymbol);
					}
				);
			});
			("function "++nameclass++"."++metod.asString++"(...)").postln;


			"\t".post;
			defaultval = armet.prototypeFrame.copyRange(1,armet.prototypeFrame.size).replace([inf],["math.huge"]);
					if((argnames.size >0),{
			"local ".post;
			//argnames.asString.replace("SymbolArray[",' ').replace("]",' ').post;
			argnames.asCompileString.replace("SymbolArray["," ").tr($],$ ).replace("'","").post;
			" = assign(".post;
			argnames.asCompileString.replace("SymbolArray[","{").tr($],$}).post;
			",".post;
			defaultval = armet.prototypeFrame.copyRange(1,armet.prototypeFrame.size).replace([inf],["math.huge"]);
			/*defaultval.do({arg item,ind;
				if((item.class.name.asString=="Symbol"),
								{item=item.asString});
						});*/
			defaultval.asCompileString.tr($[,${).tr($],$}).post;
			",...)".postln;
					});

			///////////////////////
			if(it.isOutputUGen,
				{("\treturn "++nameclass++":donew(").post;},
				{("\treturn "++nameclass++":MultiNew{").post;}
			);
			(indmetod.asString).post;

			argnames.do({arg varname,ind;
				if( (varname!='mul') && (varname!='add'),
					{
						",".post;
						varname.asString.post;
					}
				);
			});
			if(it.isOutputUGen,
				{(")").post;},
				{("}").post;}
			);
			if(argnames.notNil,{
				mulind=argnames.detectIndex({arg it2;it2=='mul';});
				if(mulind.notNil,{":madd(mul,add)".post});
			});
			"".postln;
			"end".postln;
		}
	);//armet.notnil
	});//losmetodos.do

	if(methodfound,{},
	{
		var larate=find_rate_from_new.value(it);
		if(larate!=\fail,{
		var mulind;
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
		var metodo=it.class.findRespondingMethodFor(\new);
		//metodo.argumentString.postln;
		var argnames=metodo.argNames.copyRange(1,metodo.argNames.size);
			//argnames.postln;
			argnames.do({arg varname,ind;
				if((varname==\end) || (varname==\in),
					{
						argnames.put(ind,(varname.asString++"p").asSymbol);
					}
				);
			});
		//"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx".postln;
		//("function "++it.name++"."++ratefunc++"\(").post;
		("function "++it.name++".create"++"\(...)").postln;

			"\t".post;
			if((argnames.size >0),{
			"local ".post;
			//argnames.asString.replace("SymbolArray[",' ').replace("]",' ').post;
			argnames.asCompileString.replace("SymbolArray["," ").tr($],$ ).replace("'","").post;
			" = assign(".post;
			argnames.asCompileString.replace("SymbolArray[","{").tr($],$}).post;
			",".post;
			defaultval = metodo.prototypeFrame.copyRange(1,metodo.prototypeFrame.size).replace([inf],["math.huge"]);
			/*defaultval.do({arg item,ind;
				if((item.class.name.asString=="Symbol"),
								{item=item.asString});
						});*/
			defaultval.asCompileString.tr($[,${).tr($],$}).post;
			",...)".postln;
					});
		if(it.isOutputUGen,
				{("\treturn "++it.name++":donew(").post;},
				{("\treturn "++it.name++":MultiNew{").post;}
		);
			(ratenum.asString).post;

			argnames.do({arg varname,ind;
				if( (varname!='mul') && (varname!='add'),
					{
						",".post;
						varname.asString.post;
					}
				);
			});
			if(it.isOutputUGen,
				{(")").post;},
				{("}").post;}
			);
			if(argnames.notNil,{
				mulind=argnames.detectIndex({arg it2;it2=='mul';});
				if(mulind.notNil,{":madd(mul,add)".post});
			});
			"".postln;
			"end".postln;
		},{"--there was fail in".postln;failedclasses.add(it.name);});//la rate not nil no testfail
	});//not methodfound

	}); //not out or multi
});
"--[[failed classes are".postln;
failedclasses.do({arg it; it.postln;});
"--]]".postln;

0.exit;