///operato special index table
(
"{".post;
AbstractFunction.methods.do({arg it;
	if(it.name.specialIndex!= -1,
		{
			//("[\""++it.name++"\"]="++it.name.specialIndex++",").post;
			it.postln;
		}
	)
	});
"}".postln;
)
////////////////////////
//thanks to Fredrik Olofson
//and Lucas Samaruga for https://github.com/smrg-lm/sc3/blob/master/sc3/synth/_specialindex.py
(
var binary= List.new, unary= List.new;
var toString= {|name| "[%]=%,".format(name.asString.quote, name.specialIndex)};
AbstractFunction.methods.do({arg it;
	if(it.name.specialIndex >= 0, {  //match test in BasicOpUGen:operator_
		if(UGen().perform(it.name, UGen()).isKindOf(BinaryOpUGen), {
			binary.add(it.name);
		}, {
			unary.add(it.name);
		});
	});
});
binary.add("==".asSymbol);
binary.add("!=".asSymbol);
unary.add("isNil".asSymbol);
unary.add("notNil".asSymbol);
unary.add("digitValue".asSymbol);
unary.add("silence".asSymbol);
unary.add("thru".asSymbol);
"binary_ops={".postln;
binary.do{|x| toString.(x).post};
"}".postln;
"unary_ops={".postln;
unary.do{|x| toString.(x).post};
"}".postln;
)