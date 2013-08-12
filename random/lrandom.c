/*
* lrandom.c
* random-number library for Lua 5.1 based on the Mersenne Twister
* Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
* 27 Jun 2007 23:52:15
* This code is hereby placed in the public domain.
*/

#include <math.h>
#include <stdio.h>

#include "lua.h"
#include "lauxlib.h"

#define MYNAME		"random"
#define MYVERSION	MYNAME " library for " LUA_VERSION " / Jun 2007"
#define MYTYPE		MYNAME " handle"

#define SEED		2007UL

#include "random.c"

static MT *Pget(lua_State *L, int i)
{
 return (MT *)luaL_checkudata(L,i,MYTYPE);
}

static MT *Pnew(lua_State *L)
{
 MT *c=(MT *)lua_newuserdata(L,sizeof(MT));
 luaL_getmetatable(L,MYTYPE);
 lua_setmetatable(L,-2);
 return c;
}

static int Lnew(lua_State *L)			/** new([seed]) */
{
 long seed=luaL_optlong(L,1,SEED);
 MT *c=Pnew(L);
 init_genrand(c,seed);
 return 1;
}

static int Lclone(lua_State *L)			/** clone(c) */
{
 MT *c=Pget(L,1);
 MT *d=Pnew(L);
 *d=*c;
 return 1;
}

static int Lseed(lua_State *L)			/** seed(c,[seed]) */
{
 MT *c=Pget(L,1);
 init_genrand(c,luaL_optlong(L,2,SEED));
 return 0;
}

static int Lvalue(lua_State *L)			/** value(c) */
{
 MT *c=Pget(L,1);
 lua_pushnumber(L,genrand_real1(c));
 return 1;
}

static int Lvaluei(lua_State *L)		/** valuei(c,a,[b]) */
{
 MT *c=Pget(L,1);
 int a,b;
 if (lua_gettop(L)==2)
 {
  a=1;
  b=luaL_checkint(L,2);
 }
 else
 {
  a=luaL_checkint(L,2);
  b=luaL_checkint(L,3);
 }
 lua_pushnumber(L,floor(a+genrand_real2(c)*(b-a+1)));
 return 1;
}

static int Lvaluex(lua_State *L)		/** valuex(c) */
{
 MT *c=Pget(L,1);
 lua_pushnumber(L,genrand_res53(c));
 return 1;
}

static int Ltostring(lua_State *L)		/** tostring(c) */
{
 MT *c=Pget(L,1);
 lua_pushfstring(L,"%s %p",MYTYPE,(void*)c);
 return 1;
}

static int LvalueN(lua_State *L)			/** vicpuso */
{
 MT *c=Pget(L,1);
 lua_pushnumber(L,genrand_normal(c));
 return 1;
}

static const luaL_Reg R[] =
{
	{ "__tostring",	Ltostring	},
	{ "clone",	Lclone		},
	{ "new",	Lnew		},
	{ "seed",	Lseed		},
	{ "tostring",	Ltostring	},
	{ "value",	Lvalue		},
	{ "valuei",	Lvaluei		},
	{ "valuex",	Lvaluex		},
	{ "valueN", LvalueN		}, 
	{ NULL,		NULL		}
};

LUALIB_API int luaopen_random(lua_State *L)
{
 luaL_newmetatable(L,MYTYPE);
 lua_pushvalue(L,-1);
 luaL_register(L,NULL,R);
 lua_pushliteral(L,"version");			/** version */
 lua_pushliteral(L,MYVERSION);
 lua_settable(L,-3);
 lua_pushliteral(L,"__index");
 lua_pushvalue(L,-2);
 lua_settable(L,-3);
 lua_setglobal(L,MYNAME);
 return 1;
}
