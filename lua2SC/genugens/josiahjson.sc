(
var ugens;
"ugens = {".postln;
ugens = UGen.allSubclasses.collect({|ugen| ugen});
ugens.sort({|a, b| a.name < b.name});
ugens.do({ | ugen |
    var methods;
    ('    "' ++ ugen.name ++ '": {').postln;
    ('        "parent": "' ++ ugen.superclass.name ++ '",').postln;
    methods = ugen.class.methods;
    if (methods.size > 0, {
        '        "methods": {'.postln;
        methods.do({ |method|
            ('            "' ++ method.name ++ '": [').postln;
            method.keyValuePairsFromArgs.asAssociations.do({ | pair |
                ('                ["' ++ pair.key ++ '", ' ++ pair.value ++ '],').postln;
            });
            '                ],'.postln;
        });
        '            },'.postln;
    });
    "        },".postln;
});
"    }".postln;
)