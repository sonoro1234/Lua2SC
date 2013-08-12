#ifndef __OscLua__
#define __OscLua__
extern "C"//noexternc
{
#include "lua.h"
#include "lauxlib.h"
#include <lualib.h>
}
#include "osc/OscReceivedElements.h"
#include "osc/OscPacketListener.h"
#include "osc/OscOutboundPacketStream.h"

int pushValuesLua(lua_State *state, osc::OutboundPacketStream &p);
int toOSCMessage(lua_State *state, osc::OutboundPacketStream &p);
void fromOSCMessage(lua_State *state, osc::ReceivedPacket &p, int fulltype);
void parseOSCMessage(lua_State *state, osc::ReceivedMessage &m,  int fulltype);
void fromOSCMessage(lua_State *state, const osc::ReceivedBundleElement &p, int fulltype);
void fromOSCParseArgs(lua_State *state, osc::ReceivedBundle b, int fulltype);
int toOSCLua(lua_State *state);
int fromOSCLua(lua_State *state);
#endif
