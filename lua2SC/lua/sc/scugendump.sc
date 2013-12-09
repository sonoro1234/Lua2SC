(
var failedclasses=List.new();
var testclass = {arg class;var ret;try {ret=class.new().rate; }{ret=\fail};ret};
UGen.allSubclasses.do({arg it;
	var armet,nameclass,mulind,comas,losmetodos,defaultval,therearedefaults,argnames,supcl;
	var methodfound,excluded,isexcl;
	losmetodos=['ir','kr','ar'];
	excluded=["Out","MultiOutUGen","OutputProxy","BinaryOpUGen","UnaryOpUGen","MulAdd"];//,"LocalBuf","PackFFT"];
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
			argnames=armet.argNames.copy;
			//argnames.postln;
			argnames.do({arg varname,ind;
				if((varname==\end) || (varname==\in),
					{
						//"cambio varname".postln;
						argnames.put(ind,(varname.asString++"p").asSymbol);
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
						{if(defaultval==inf,{defaultval="math.huge"});
						(defaultval.asString++";").post;}
					);
				});
			});
			if(therearedefaults,{"".postln});
			if(it.isOutputUGen,
				{("\treturn "++nameclass++":donew(").post;},
				{("\treturn "++nameclass++":MultiNew{").post;}
			);
			(indmetod.asString).post;
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
		var larate=testclass.value(it);
		if(larate!=\fail,{
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
		var metodo=it.class.findRespondingMethodFor(\new);
		//metodo.argumentString.postln;
		var argnames=metodo.argNames.copy;
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
		("function "++it.name++".create"++"\(").post;
		argnames.do({arg varname,ind;
				if(ind!=0,{varname.asString.post;});
				if((ind>0) && (ind<(argnames.size-1)),{",".post;});
			});
			"\)".postln;
			therearedefaults=false;
			"\t".post;
			argnames.do({arg varname,ind;
				var defaultval=metodo.prototypeFrame.at(ind);
				if((ind>0) && (defaultval.notNil),{
					therearedefaults=true;
					(varname.asString++"="++varname.asString++" or ").post;
					if((defaultval.isString) || (defaultval.class.name.asString=="Symbol"),
						{("'"++defaultval.asString++"';").post;},
						{if(defaultval==inf,{defaultval="math.huge"});
						(defaultval.asString++";").post;}
					);
				});
			});
		if(therearedefaults,{"".postln});
		if(it.isOutputUGen,
				{("\treturn "++it.name++":donew(").post;},
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
"failed classes are".postln;
failedclasses.do({arg it; it.postln;});
)
/*
var therearedefaults;
var it=Dseries;
var metodo=it.class.findMethod(\new);

var argnames=metodo.argNames;
//metodo.argumentString.postln;
argnames.do({arg varname,ind;
				var defaultval=metodo.prototypeFrame.at(ind);
				if((ind>0) && (defaultval.notNil),{
					therearedefaults=true;
					(varname.asString++"="++varname.asString++" or ").post;
					if((defaultval.isString) || (defaultval.class.name.asString=="Symbol"),
						{("'"++defaultval.asString++"';").post;},
						{if(defaultval==inf,{defaultval="math.huge"});
						(defaultval.asString++";").post;}
					);
				});
			});
*/