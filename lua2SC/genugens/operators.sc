
////////////operators binary
(
~binops=['+','-','*','/','div','%','**','min','max','<','<=','>','>=','&','|','lcm','gcd',
'round','trunc','atan2','hypot','hypotApx','>>','+>>','fill','ring1','ring2','ring3',
'ring4','difsqr','sumsqr','sqrdif','absdif','amclip','scaleneg','clip2','excess',
'<!','rrand','exprand','rotate','dist','bitAnd','bitOr','bitXor','bitHammingDistance','@','=='];

///////////~binops.post;
~binops.do({arg item; ("[\""++item.asString++"\"]="++item.specialIndex++",").post;})

)

///operator special index table
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
/////unary ops/////////////////
neg, reciprocal, bitNot, abs, asFloat, asInt, ceil, floor, frac, sign, squared, cubed, sqrt
exp, midicps, cpsmidi, midiratio, ratiomidi, ampdb, dbamp, octcps, cpsoct, log, log2,
log10, sin, cos, tan, asin, acos, atan, sinh, cosh, tanh, rand, rand2, linrand, bilinrand,
sum3rand, distort, softclip, nyqring, coin, even, odd, isPositive, isNegative,
isStrictlyPositive, rho, theta
//////////////////////////////////
