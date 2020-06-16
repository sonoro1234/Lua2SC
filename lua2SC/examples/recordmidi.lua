
Effects={FX("gverb",db2amp(-9),nil,{revtime=5,roomsize=100})}
-- four beats count with four beat precount
Click(4,4)

---------------- instrument with GUI or without it
--instgui=InstrumentsGUI("help_clarinet")
instgui = {inst="help_clarinet",params={},oscfree=true}

-- this will allow midi to play instrument
MidiToOsc.AddChannel(0,instgui,{0.2})

-- this will allow recording a loop between beats 4 and 12
-- button dump will post the recorded sequence
MIDIRecord(instgui,4,12)


theMetro:tempo(120)
theMetro:start()
