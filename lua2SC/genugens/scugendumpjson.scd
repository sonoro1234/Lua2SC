(
var ugens_db = Dictionary.new();
var failedclasses=List.new();
var find_rate_from_new = {arg class;var ret;try {ret=class.new().rate; }{ret=\fail};ret};
var ignoring = [
    /* abstract */
    'AbstractIn','AbstractOut','AudioControl','BasicOpUGen','BEQSuite','BufInfoUGenBase','ChaosGen','DUGen','Filter','ListDUGen','MultiOutUGen','OutputProxy','PureMultiOutUGen','PureUGen','WidthFirstUGen',
    /* deprecated */
    'SharedIn','SharedOut',
    /* composite & derived */
    'Changed','DynKlang','DynKlank','HilbertFIR','InBus','LagControl','Splay','SplayAz','Tap',
    /* non-user & implicit */
    'Control',
    /* text label */
    'SendPeakRMS','SendReply',
    'FFTTrigger','PackFFT','Unpack1FFT','UnpackFFT',
    'MulAdd',
    /* implicit length input */
    'ClearBuf','SetBuf',
    /* count input */
    'MaxLocalBufs'
];
var excluded=["Out","MultiOutUGen","OutputProxy","BinaryOpUGen","UnaryOpUGen","MulAdd"];


var losmetodos=['ir','kr','ar'];

/* PV_ operates at kr but message is \new.  Demand operates at \dr but message is \new. */
var is_demand = {
    arg o;
    [Dibrown,Diwhite,Dswitch,Dunique].includes(o) || [ListDUGen,DUGen].includes(o.superclass);
};

/* PV_ operates at kr but message is \new. */
var is_PV = {arg o; var nm = o.asString; (nm == "FFT") || (nm.find("PV_") == 0)};

var to_upper = {arg o; o.asString.toUpper.asSymbol};

var find_method_r = {
    arg o, n;
    var m = o.findMethod(n);
    var p = o.superclass;
    if(m.notNil, {m}, {if(p.notNil, {find_method_r.(p,n)}, {nil})});
};

var supports_rate = {arg o, r; find_method_r.(o.class,r) != nil};

var supported_rates = {
    arg o;
    var d = if(is_demand.(o), {[\dr]}, {[]});
    var pv = if(is_PV.(o), {[\kr]}, {[]});
    [\ar,\kr,\dr,\ir].select({arg r; supports_rate.(o,r)}) ++ d ++ pv;
};

var input_names = {
    arg nm, o, r;
    var n = find_method_r.(o.class,r).argNames;
    var x = [
        'this','mul','add',
        'selector', // uop & binop
    ];
    var f = {arg e; x.includes(e)};
    n.reject(f);
};

var input_default = {
    arg o, r ,nm;
    var m = find_method_r.(o.class,r);
    var n = m.argNames;
    var i = n.detectIndex({arg e; e == nm});
    m.prototypeFrame[i];
};

var number_of_outputs = {
    arg o, r;
    try {var u = o.perform(r); if(u.isArray,{u.size},{if(u.isFloat,{0},{1})})} {arg err; 1};
};


var ugen_dump = {
    arg o;
    var nm = o.name.asString;
    var rt_all = supported_rates.(o);
    var rt_def = if(rt_all.isEmpty, {\ir}, {rt_all[0]});
    var rt_cons = if(is_demand.(o) || is_PV.(o) || rt_all.isEmpty, {\new}, {rt_def});
    var n_a = input_names.(nm,o,rt_cons);
    var n = n_a;
    var nn = n.collect({arg e; [e.asString, input_default.(o,rt_cons,e)]});
    var no = number_of_outputs.(o, rt_cons);
    var h_m = SCDoc.documents.at("Classes/"++nm);
    var h = if(h_m==nil, {"No summary"}, {h_m.summary});
    /*var rng = signal_range.(o,rt_cons);*/
    [nm,rt_all,rt_def,nn,no,h,rt_cons];
};
/*
var one_ugen = Dwrand;
ugen_dump.(one_ugen).postln;
//find_method_r.(Dwrand.class,\new);
find_method_r.(one_ugen.class,\new).postln;
one_ugen.class.findRespondingMethodFor(\new).postln;
find_rate_from_new.value(one_ugen).postln;
//one_ugen.new().postln;
)*/

var ugens;
//get all sorted ugens except excluded
ignoring.do({arg a; excluded=excluded.add(a.asString);});
//excluded.postln;
//ignoring.postln;
ugens = UGen.allSubclasses.select({|ugen| excluded.detect({arg itexcl;itexcl==ugen.name.asString}).isNil});
//var ugens = UGen.allSubclasses.select({|ugen| excluded.includes(ugen.name.asString).not;});
ugens.sort({|a, b| a.name < b.name});

ugens.do({arg it;
	var armet,nameclass,defaultval,argnames;
	var methodfound,dump,res;

	nameclass=it.name.asString;
	ugens_db.put(nameclass,Dictionary.new());
	ugens_db.at(nameclass).put("methods",Dictionary.new());
	if(it.isOutputUGen,
		{ugens_db.at(nameclass).put("isOut",true);},
		{var supcl=it.superclasses.detect({arg it2;it2.name.asString=="MultiOutUGen";});
		if(supcl.notNil,{ugens_db.at(nameclass).put("isMultiOut",true);});}
	);
	ugens_db.at(nameclass).put("parent",it.superclass.name.asString.asCompileString;);
	dump = ugen_dump.(it);
	ugens_db.at(nameclass).put("nOuts",dump[4]);
	ugens_db.at(nameclass).put("description",dump[5].asCompileString;);
	methodfound=false;


	//try {res=it.perform(dump[6]); }{res=\fail};
	//if(res!=\fail && res.isKindOf(it).not && ugens_db.at(nameclass).at("isMultiOut").isNil,{ugens_db.at(nameclass).put("pseudo",true);});

	losmetodos.do({arg metod,indmetod;
	armet=it.class.findRespondingMethodFor(metod);
	if (armet.notNil,
		{
			ugens_db.at(nameclass).at("methods").put(metod,List.new());
			methodfound=true;
			argnames=armet.argNames.copyRange(1,armet.argNames.size);

			if((argnames.size >0),{

			defaultval = armet.prototypeFrame.copyRange(1,armet.prototypeFrame.size);
			defaultval = defaultval.replace([inf],["inf"]);
			defaultval = defaultval.collect({arg i; if(i.isKindOf(Symbol),{i=i.asString}); i});
			defaultval = defaultval.collect({arg i;if(i.isString,{i=i.asCompileString});i});
			defaultval = defaultval.replace([nil],["null"]);
			});


			argnames.do({arg varname,ind;
			if( (varname!='mul') && (varname!='add'),
			{
			ugens_db.at(nameclass).at("methods").at(metod).add([varname,defaultval.at(ind)]);
			});
		});

		}
	);//armet.notnil
	});//losmetodos.do

	if(methodfound,{},
	{
		var metodo=it.class.findRespondingMethodFor(\new);
		var larate=find_rate_from_new.value(it);

		if(metodo.isNil.not,{
		var argnames=metodo.argNames.copyRange(1,metodo.argNames.size);
		var ratenum=switch (larate,
    			\scalar,   { 0 },
    			\control, { 1 },
    			\audio, { 2},
				\demand,{3}
		);
		if(ratenum.isNil,{
			ratenum=switch(dump[2],
						\ir,   { 0 },
						\kr, { 1 },
						\ar, { 2},
						\dr,{3}
			);
		});
				if(ratenum.isNil,{failedclasses.add(it.name);});
		ugens_db.at(nameclass).put("ratenew",ratenum);
		ugens_db.at(nameclass).at("methods").put("new",List.new());
		if((argnames.size >0),{

			//argnames.asString.replace("SymbolArray[",' ').replace("]",' ').post;
			//argnames.asCompileString.replace("SymbolArray[","{").tr($],$}).post;
			defaultval = metodo.prototypeFrame.copyRange(1,metodo.prototypeFrame.size);
			defaultval = defaultval.replace([inf],["inf"]);
			defaultval = defaultval.collect({arg i; if(i.isKindOf(Symbol),{i=i.asString}); i});
			defaultval = defaultval.collect({arg i;if(i.isString,{i=i.asCompileString});i});
			defaultval = defaultval.replace([nil],["null"]);
			//defaultval.asCompileString.tr($[,${).tr($],$}).post;

		});
		argnames.do({arg varname,ind;
			if( (varname!='mul') && (varname!='add'),
			{
				ugens_db.at(nameclass).at("methods").at("new").add([varname,defaultval.at(ind)]);
			});
		});


		},{failedclasses.add(it.name);});//la rate not nil no testfail
	});//not methodfound

});


//json printing
"{".postln;
ugens.do{arg it,itnum;
	var ugen,uname,comma;
	uname = it.name.asString;
	ugen = ugens_db.at(uname);

	postln('"'++uname++'"' ++": {");
	ugen.keysValuesDo{|key,val,ind0|
	switch( key,
		"methods", {'    "methods":{'.postln;
			val.keysValuesDo{|met,l,ind|
			('        "'++met++'" :[').postln;
			l.do{|argu,ind2| '          '.post;
			if(((ind2+1)<l.size),{comma=","},{comma=""});
			('["'++argu[0]++'",'++argu[1]++']'++comma).postln;};
			if(((ind+1)<val.size),{comma=","},{comma=""});
			('        ]'++comma).postln;};
			if(((ind0+1)<ugen.size),{comma=","},{comma=""});
			("    }"++comma).postln;
			},
			{
				if(((ind0+1)<ugen.size),{comma=","},{comma=""});
				('    "'++key++'" :').post;val.post;comma.postln;}
	);
	};
	if(((itnum+1)<ugens.size),{comma=","},{comma=""});
	("}"++comma).postln;
};
"}".postln;
"failed classes are".postln;
failedclasses.do({arg it; it.postln;});

)
(
var col = [nil,1,2,3];
col = col.replace([nil,3],["null",5]);
col.postln;
\pepe.isKindOf(Symbol).postln;
nil.asCompileString.isNil.postln;
nil.asCompileString.postln;
\pepe.asCompileString.postln;
)

(
var find_method_r = {
    arg o, n;
    var m = o.findMethod(n);
    var p = o.superclass;
    if(m.notNil, {m}, {if(p.notNil, {find_method_r.(p,n)}, {nil})});
};
Dwrand.findMethod(\new);
find_method_r.(Dwrand,\new).postln;
)Onsets