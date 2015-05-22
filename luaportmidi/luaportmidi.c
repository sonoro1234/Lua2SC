#define LUA_LIB

#include "lua.h"
#include "lauxlib.h"

#include "portmidi.h"
#include "porttime.h"

#define INPUT_BUFFER_SIZE 256
#define OUTPUT_BUFFER_SIZE 0
#define DRIVER_INFO NULL
#define TIME_PROC NULL //((int32_t (*)(void *)) Pt_Time)
#define TIME_INFO NULL
#define TIME_START Pt_Start(1, 0, 0) /* timer started w/millisecond accuracy */
////////////////////////////////////////////////////////
#define MIDI_CODE_MASK  0xf0
#define MIDI_CHN_MASK   0x0f
/*#define MIDI_REALTIME   0xf8
  #define MIDI_CHAN_MODE  0xfa */
#define MIDI_OFF_NOTE   0x80
#define MIDI_ON_NOTE    0x90
#define MIDI_POLY_TOUCH 0xa0
#define MIDI_CTRL       0xb0
#define MIDI_CH_PROGRAM 0xc0
#define MIDI_TOUCH      0xd0
#define MIDI_BEND       0xe0

#define MIDI_SYSEX      0xf0
#define MIDI_Q_FRAME	0xf1
#define MIDI_SONG_POINTER 0xf2
#define MIDI_SONG_SELECT 0xf3
#define MIDI_TUNE_REQ	0xf6
#define MIDI_EOX        0xf7
#define MIDI_TIME_CLOCK 0xf8
#define MIDI_START      0xfa
#define MIDI_CONTINUE	0xfb
#define MIDI_STOP       0xfc
#define MIDI_ACTIVE_SENSING 0xfe
#define MIDI_SYS_RESET  0xff

#define MIDI_ALL_SOUND_OFF 0x78
#define MIDI_RESET_CONTROLLERS 0x79
#define MIDI_LOCAL	0x7a
#define MIDI_ALL_OFF	0x7b
#define MIDI_OMNI_OFF	0x7c
#define MIDI_OMNI_ON	0x7d
#define MIDI_MONO_ON	0x7e
#define MIDI_POLY_ON	0x7f
///////////////////////////////////////////////////////////
//Pm_Initialize();
typedef struct t_midi_ {
    int device;
    PmStream * stream;
} t_midi;
typedef t_midi *p_midi;



#define checkpmidi(L) \
(p_midi)luaL_checkudata(L, 1, "pmidimt")

const char * PtErrorMsg(PtError code){
	const char *msg;
	switch (code){
		case ptNoError :         
			msg="PtError: success ";
			break;
		case ptHostError:
			msg="PtError: a system-specific error occurred ";
			break;
		case ptAlreadyStarted:
			msg="PtError: cannot start timer because it is already started";
			break;
		case ptAlreadyStopped:
			msg="PtError: cannot stop timer because it is already stopped";
			break;
		case ptInsufficientMemory:
			msg="PtError: memory could not be allocated";
			break;
		default:
			msg="unknown PtError";
		
	}
	return msg;
}

 /* list device information */

int listDevices(lua_State *state)
{
    int i;
	lua_newtable(state);
	
	for (i = 0; i < Pm_CountDevices(); i++) {
        const PmDeviceInfo *info = Pm_GetDeviceInfo(i);
		lua_pushinteger(state,i);

		lua_newtable(state);

        lua_pushstring(state, "structVersion");
        lua_pushinteger(state, info->structVersion);
        lua_settable(state, -3);

		lua_pushstring(state, "interf");
        lua_pushstring(state, info->interf);
        lua_settable(state, -3);

		lua_pushstring(state, "name");
        lua_pushstring(state, info->name);
        lua_settable(state, -3); 

		lua_pushstring(state, "input");
        lua_pushinteger(state, info->input);
        lua_settable(state, -3);

		lua_pushstring(state, "output");
        lua_pushinteger(state, info->output);
        lua_settable(state, -3);

		lua_pushstring(state, "opened");
        lua_pushinteger(state, info->opened);
        lua_settable(state, -3);


		lua_settable(state, -3);
         
    }
	return 1;
}

void setfieldi (lua_State *state, const char *index, int value) {
      lua_pushstring(state, index);
      lua_pushnumber(state, value);
      lua_settable(state, -3);
}
int getfield (lua_State *state, const char *key, int def) {
      int result;
      lua_pushstring(state, key);
      lua_gettable(state, -2);  /* get background[key] */
      if (!lua_isnumber(state, -1))
      {        
        lua_pop(state, 1);  
        return def;
      }
      result = (int)lua_tonumber(state, -1);
      lua_pop(state, 1);  
      return result;
 }
static int writeShort(lua_State *L) {
	int delta, len, offset, data1, data2, data3, data4, detune, noteoff;
	int type, channel;
	PmError err;
	p_midi d= checkpmidi(L);

	type = getfield(L, "type", 0);
	channel = getfield(L, "channel", 0);
	data1 = ((type & 0xf) << 4) | (channel & 0xf);
	data2 = getfield(L, "byte2", 0);
	data3 = getfield(L, "byte3", 0);
	data4 = getfield(L, "byte4", 0);

	err=Pm_WriteShort(d->stream,0,Pm_Message(data1, data2, data3));
	if (err) {
        lua_pushfstring(L,"cannot write %d: for midi input %s", d->device, Pm_GetErrorText(err));
        return 1;
    }
	return 0;

}
static int read(lua_State *L) {

	PmEvent event;
	PmMessage data;
    int count;
	int channel, type;
	p_midi d= checkpmidi(L);
	count=Pm_Read(d->stream, &event, 1);
	if(count < 0){
		lua_pushnil(L);
		lua_pushfstring(L,"cannot read %d: for midi input %s", d->device, Pm_GetErrorText(count));
        return 2;
	}else if(count==0){
		lua_pushboolean(L,FALSE);
		return 1;
	}
	
    //type = (((unsigned char)data1 >> 4)& 0xf);
    //channel = ((unsigned char)data1 & 0xf); 
	data =event.message;
	//type = (((unsigned char)data1 >> 4)& 0xf);
    //channel = ((unsigned char)data1 & 0xf); 
	type = (Pm_MessageStatus(data)& MIDI_CODE_MASK) >> 4;
    channel = Pm_MessageStatus(data) & MIDI_CHN_MASK;
	Pm_MessageData1(data);

	lua_newtable(L);
	          

	setfieldi(L, "type", type);
	setfieldi(L, "channel", channel);
	//setfieldi(lua_state, "detune", detune);
	//setfieldi(lua_state, "noteOffVelocity", noteOff);
	setfieldi(L, "byte2", Pm_MessageData1(data));
	setfieldi(L, "byte3", Pm_MessageData2(data));
	setfieldi(L, "byte4", (data >> 24) & 0xFF);
    setfieldi(L, "delta", event.timestamp);
	return 1;

}
static int OpenInput (lua_State *L) {
	int device = luaL_checkinteger(L, 1);
	/////////////////////////
	PmStream * midiSt=NULL;
	PmError err;
	//PtError pterr;
    p_midi midi=NULL;
/*
	if(!Pt_Started()){
		pterr=Pt_Start(10,NULL, 0);
		if (pterr) {
			//luaL_error(L, "cannot open %d: for midi input %s", device, Pm_GetErrorText(err));
			lua_pushnil(L);
			lua_pushfstring(L,"Pt_Start: %s", PtErrorMsg(pterr));
			return 2;
		}
	}*/
    /* open input device */
    err=Pm_OpenInput(&midiSt, 
                 device,
                 DRIVER_INFO, 
                 INPUT_BUFFER_SIZE, 
                 TIME_PROC, 
                 TIME_INFO);
	if (err) {
		lua_pushnil(L);
        lua_pushfstring(L,"cannot open %d: for midi input %s", device, Pm_GetErrorText(err));
        return 2;
    }

	midi = (p_midi)lua_newuserdata(L, sizeof(t_midi));

	luaL_getmetatable(L, "pmidimt");
	lua_setmetatable(L, -2);
	
	midi->device=device;
	midi->stream=midiSt;
	return 1;
}
static int OpenOutput (lua_State *L) {
	int device = luaL_checkinteger(L, 1);
	/////////////////////////
	PmStream * midiSt=NULL;
	PmError err;
	//PtError pterr;
    p_midi midi=NULL;

    err=Pm_OpenOutput(&midiSt, 
                 device,
                 DRIVER_INFO, 
                 0,//INPUT_BUFFER_SIZE, 
                 TIME_PROC, 
                 TIME_INFO,
				 0 //latency
				 );
	if (err) {
		lua_pushnil(L);
        lua_pushfstring(L,"cannot open %d: for midi output %s", device, Pm_GetErrorText(err));
        return 2;
    }

	midi = (p_midi)lua_newuserdata(L, sizeof(t_midi));

	luaL_getmetatable(L, "pmidimt");
	lua_setmetatable(L, -2);
	
	midi->device=device;
	midi->stream=midiSt;
	return 1;
}
static int close(lua_State *L) {
	PmError err;
	//p_midi d = (p_midi)lua_touserdata(L, 1);
	p_midi d= checkpmidi(L);

		err=Pm_Close(d->stream);
		if (err) {
			luaL_error(L, "cannot close %d: for midi input %s", d->device, Pm_GetErrorText(err));
		//lua_pushnil(L);
        //lua_pushstring(L, Pm_GetErrorText(err));
        //return 2;
		}//else
	
	return 0;
}
static int poll(lua_State *L) {
	PmError status;
	p_midi d= checkpmidi(L);

		status=Pm_Poll(d->stream);
		if (status==TRUE) {
			lua_pushboolean(L,TRUE);
			return 1;
		}else{
			if(status==FALSE){
				lua_pushboolean(L,FALSE);
				return 1;
			}else{
				//luaL_error(L, "poll close %d: for midi input %s", d->device, Pm_GetErrorText(err));
				lua_pushnil(L);
				lua_pushfstring(L,"Error:poll device %d: %s", d->device, Pm_GetErrorText(status));
				return 2;
			}
	}

}

static const struct luaL_Reg thislib_f[] = {
  {"listDevices", listDevices},
  {"OpenInput", OpenInput},
  {"OpenOutput", OpenOutput},
  {NULL, NULL}
};
static const struct luaL_Reg thislib_m[] = {
  {"__gc", close},
  {"close", close},
  {"poll", poll},
  {"read", read},
  {"writeShort", writeShort},
  {NULL, NULL}
};

LUALIB_API int luaopen_pmidi_core (lua_State *L) {
  
	luaL_newmetatable(L, "pmidimt");
	/* metatable.__index = metatable */
	lua_pushvalue(L, -1); /* duplicates the metatable */
	lua_setfield(L, -2, "__index");

	luaL_register(L, NULL, thislib_m);
	lua_pop(L, 1); 
	luaL_register(L, "pmidi", thislib_f);
	return 1;
}