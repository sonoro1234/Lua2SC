/*
* osclua.cpp
* oscpack library for Lua 5.1, 5.2
* adapted by victor bombi from vstlua project by John Williamson
* This code is hereby placed in the public domain.
*/
extern "C" //noexternc
{
#include "lua.h"
#include "lauxlib.h"
#include <lualib.h>
LUALIB_API int luaopen_osclua (lua_State *L);
}
#include "string.h"
#include "math.h"
#include "osc/OscReceivedElements.h"
#include "osc/OscPacketListener.h"
#include "osc/OscOutboundPacketStream.h"
#include "osclua.h"
#define OUTPUT_BUFFER_SIZE 65535




//push a value with a special type tag. the format is a table, with the first element being the type, and the second the value.
void pushSpecial(lua_State *state, osc::OutboundPacketStream &p)
{
    //get the type tag
    lua_pushnumber(state, 1);
    lua_gettable(state, -2);
 
    //check it's a string
    if(!lua_isstring(state,-1))
    {        
        luaL_error(state, "Special tables must have a type tag as the first element\n");
        lua_pop(state,1);
        return;    
    }
    else
    {
        char typenam[512];
        strncpy(typenam, lua_tostring(state,-1), sizeof(typenam));
        int bad_type = 0; // bad type flag
    
        lua_pop(state,1); // pop the name
        
        //get the next value  
        lua_rawgeti(state,-1,2);   
        
        //now check how to format this...
        //we can explicitly specify types if we want...
        if(!strcmp(typenam, "float"))
        {
            if(lua_isnumber(state,-1))
            {
                float f = lua_tonumber(state,-1);
                p<<f;
            }
            else
                bad_type=1;            
        }
        
        else if(!strcmp(typenam, "double"))
        {
            if(lua_isnumber(state,-1))
            {
                double f = lua_tonumber(state,-1);
                p<<f;
            }
                else
                bad_type=1;
            
        }
        
        else if(!strcmp(typenam, "string"))
        {
            if(lua_isstring(state,-1))            
                p<<lua_tostring(state,-1);
            else
                bad_type=1;
            
        }
        
        else if(!strcmp(typenam, "symbol"))
        {
            if(lua_isstring(state,-1))
                p<<osc::Symbol(lua_tostring(state,-1));
            else
                bad_type=1;
            
        }
        
        
        else if(!strcmp(typenam, "blob"))
        {
            if(lua_isstring(state,-1))
                p<<osc::Blob(lua_tostring(state,-1), lua_strlen(state,-1));
            else
                bad_type=1;
            
        }        
        
        else if(!strcmp(typenam, "infinity"))
        {
            p<<osc::Infinitum;            
        }        
        
        else if(!strcmp(typenam, "nil"))
        {
            p<<osc::Nil;            
        }        
        
                                
        else if(!strcmp(typenam, "rgbacolor"))
        {
            if(lua_isnumber(state,-1))                
                p<< osc::RgbaColor((int)lua_tonumber(state,-1));
            else bad_type=1;
            
        }
        
        else if(!strcmp(typenam, "int32"))
        {
            if(lua_isnumber(state,-1))                            
                p<<(int)lua_tonumber(state,-1);
            else bad_type=1;
            
        }
        
        else if(!strcmp(typenam, "char"))
        {
            char str[2];
            //special exception for strings
            if(lua_isnumber(state,-1))                                            
                p<<(char)lua_tonumber(state,-1);
            else if(lua_isstring(state,-1))
            {   
                strncpy(str, lua_tostring(state,-1), 2);
                p<<str[0];
            }
            else bad_type = 1;                
            
        }
            
        
        else if(!strcmp(typenam, "int64"))
        {
            if(lua_isnumber(state,-1))                                                        
                p<<(osc::int64)lua_tonumber(state,-1);
            else bad_type=1;            
            
        }
        
        else if(!strcmp(typenam, "midi"))
        {
            if(lua_isnumber(state,-1))                                                        
                p<<osc::MidiMessage((int)(lua_tonumber(state,-1)));
            else bad_type=1;            
            
        }
        
        else if(!strcmp(typenam, "boolean"))
        {
            if(lua_isboolean(state,-1))                                                        
                p<< (bool)(lua_toboolean(state,-1));
            else bad_type=1;            
            
        }
        
        else if(!strcmp(typenam, "timetag"))
        {
            if(lua_isnumber(state,-1))                                                        
                p<<osc::TimeTag((osc::uint64)lua_tonumber(state,-1));
            else bad_type=1;
            
        }
		else if(!strcmp(typenam, "["))
        {                                                 
            osc::ArrayInitiator tag;
			p<<tag;
        }
		else if(!strcmp(typenam, "]"))
        {                                                 
            osc::ArrayTerminator tag;
			p<<tag;
        }
        else 
			luaL_error(state,"luaOsc Error: Unknown type %s\n", typenam); 
        lua_pop(state,1);
        
        //warn the user if a tag was invalid and therefore skipped
		if(bad_type){    
				luaL_error(state,"luaOsc Error: bad type for second element for OSC type %s\n", typenam); 
		}
    }        

}


int pushValuesLua(lua_State *state, osc::OutboundPacketStream &p)
{ 
    int index = 1;
    int going = 1;
    if (lua_type(state,-1)!= LUA_TTABLE){
        luaL_error(state,"Invalid entry in an OSC packet. Second item must be a table.\n");
        return 0;
    }
    while(going)
    {
    
        //lua_pushnumber(state, index);
        //lua_gettable(state, -2);
        lua_rawgeti(state,-1,index);
		
        //do the right thing with the type
        switch(lua_type(state, -1))
        {
            case LUA_TNIL:
                going  = 0;
                break;
                
            case LUA_TBOOLEAN:
                p << (bool)lua_toboolean(state, -1);
                break;
                
            case LUA_TNUMBER:
            {
                double val = lua_tonumber(state,-1);
                
                //push integers as integers
                if(val==floor(val))
                    p<<(int)val;
                else
                    p<<val;                               
                    
            }
                break;
                                
            case LUA_TSTRING:
                p<<lua_tostring(state,-1);
                break;       
                
            case LUA_TTABLE:
                pushSpecial(state, p);
                break;

            default:
				luaL_error(state,"Invalid entry in an OSC packet. Must be string, boolean, special table or number.\n");
                return 0;
                break;
        }
        index++;
        lua_pop(state, 1);    
    }
    
    
    return 1;
}

int toOSCBundle(lua_State *state, osc::OutboundPacketStream &p)
{
    int going = 1;
    int index = 2; // start _after_ the time tag
    
    //timetag is at top of stack    
    double tag = lua_tonumber(state, -1);
    lua_pop(state,1);
    
    p << osc::BeginBundle((osc::uint64)tag);
    while(going)
    {
        //get the next message
        lua_pushnumber(state, index);
        lua_gettable(state, -2);
        
        if(lua_istable(state, -1))
        {        
            //check if this is a nested bundle, or a packet                                              
           lua_pushnumber(state, 1);
           lua_gettable(state, -2);
           
           //message if it begins with a string
		   if(lua_isnumber(state,-1))
            toOSCBundle(state, p);
           else if(lua_isstring(state,-1))
            toOSCMessage(state, p);
          else
          {
			 luaL_error(state,"Start of a nested table must be an address (for messages) or a timetag (for bundles)\n");
            going = 0; 
           }
        }
        else
            going = 0;             
        lua_pop(state, 1);        
        index++;        
    }    
    p << osc::EndBundle;  
   
   
    
    return 1;
   
}


int toOSCMessage(lua_State *state, osc::OutboundPacketStream &p)
{
        char addr[512];

           if(lua_isstring(state, -1))
           {
                strncpy(addr, lua_tostring(state, -1), 512);
                lua_pop(state, 1);
                
   
                //begin the message
                p << osc::BeginMessage(addr);
                
                //get the values
                lua_pushnumber(state, 2);
                lua_gettable(state, -2);
                
                //push all the values; error if it returns 0;
                if(!pushValuesLua(state, p))
                {
					luaL_error(state,"Error in message components!\n");
                    return 0;                
                }                           
                lua_pop(state, 1);
                
                //end the message
                p << osc::EndMessage;
                return 1;
           }
           else
           {
		   luaL_error(state,"First element of an OSC message should be the address!");
            return 0;
           }                          
           
}

//take an osc structure, return the string all packed up
int toOSCLua(lua_State *state)
{
    char buffer[OUTPUT_BUFFER_SIZE];
    osc::OutboundPacketStream p(buffer, OUTPUT_BUFFER_SIZE);

    // got to have a table!    
	if(!lua_istable(state, -1)){
		luaL_error(state,"Non-table argument to toOSC!");
	}   
       
    //lua_pushnumber(state, 1);
    //lua_gettable(state,-2);
	lua_rawgeti(state,-1,1);
    
    //if this begins with a number, it's the time tag, and we're doing a bundle.
    if(lua_isnumber(state,-1))
    {                
        try{
			toOSCBundle(state, p);
		}catch(osc::Exception Ex){
			luaL_error(state,"osclua error: %s\n",Ex.what());
		}          
		//toOSCBundle(state, p);
    }
    //if it's a string it's the address and we're doing a message
    else if(lua_isstring(state,-1))
    {        
		try{
			toOSCMessage(state, p);
		}catch(osc::Exception Ex){
			luaL_error(state,"osclua error: %s\n",Ex.what());
		}                        
    }
    //otherwise we didn't call it right
    else
    {
        luaL_error(state,"first element of toOSC must be a time (for bundles) or an address (for messages)");
        return 0;
    }
    lua_pushlstring(state, p.Data(), p.Size());
    return 1;
}


void fromOSCBundle(lua_State *state, osc::ReceivedPacket &p, int fulltype)
{
    osc::ReceivedBundle b(p);    
    fromOSCParseArgs(state, b, fulltype)  ;
}


void fromOSCBundle(lua_State *state, const osc::ReceivedBundleElement &p, int fulltype)
{
    osc::ReceivedBundle b(p);    
    fromOSCParseArgs(state, b, fulltype);    
}


void fromOSCParseArgs(lua_State *state, osc::ReceivedBundle b, int fulltype)
{
    osc::ReceivedBundle::const_iterator arg = b.ElementsBegin();
        
    //first value is the time tag
    lua_pushnumber(state, 1);
    lua_pushnumber(state, b.TimeTag());
    lua_settable(state, -3);
            
    int index = 2;
    while(arg!=b.ElementsEnd())
    {            
        
        //second value is the table
        lua_pushnumber(state, index);
    
        lua_newtable(state);
        if(arg->IsBundle())
        {                
            //we probably don't ever need to do this...
            fromOSCBundle(state,  *arg, fulltype);
        }
        else
        {
    
            fromOSCMessage(state, *arg, fulltype);        
        }    
        arg++;
        index++;
        lua_settable(state, -3);
    }        
    
}


void fromOSCMessage(lua_State *state, const osc::ReceivedBundleElement &p, int fulltype)
{
    osc::ReceivedMessage m(p);
    parseOSCMessage(state, m, fulltype);
}

void fromOSCMessage(lua_State *state, osc::ReceivedPacket &p, int fulltype)
{
	try{
		osc::ReceivedMessage m(p);
		parseOSCMessage(state, m, fulltype);
	}catch(osc::MalformedMessageException Ex){
		
		luaL_error(state,"osclua error: %s\n",Ex.what());
	}                        
}



void parseOSCMessage(lua_State *state, osc::ReceivedMessage &m, int fulltype)
{

        char typestr[512];
   
        //element 1 = address
        lua_pushnumber(state, 1);
        lua_pushstring(state, m.AddressPattern());
        lua_settable(state, -3);        

        //element 2 = OSC table
        lua_pushnumber(state, 2);
        lua_newtable(state);
        
        osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
        
        int index = 1;
        
        while(arg!=m.ArgumentsEnd())
        {
            lua_pushnumber(state, index);
            
            //set the second element, if we're writing out full types
            if(fulltype)
            {
                lua_newtable(state);                
                lua_pushnumber(state,2);
            }                        

                //parse the tag
                switch(arg->TypeTag())
                {
                    case osc::INT64_TYPE_TAG:                                            
                        strncpy(typestr, "int64", sizeof(typestr));
                        lua_pushnumber(state, (double)arg->AsInt64());
                        break;
                    case osc::TRUE_TYPE_TAG:
                        strncpy(typestr, "boolean", sizeof(typestr));
                        lua_pushboolean(state, 1);
                        break;
                    case osc::FALSE_TYPE_TAG:    
                        strncpy(typestr, "boolean", sizeof(typestr));
                        lua_pushboolean(state, 0);
                        break;
                    case osc::NIL_TYPE_TAG:
                        strncpy(typestr, "nil", sizeof(typestr));
                        lua_pushstring(state, "nil");
                        break;
                    case osc::INFINITUM_TYPE_TAG:
                        strncpy(typestr, "infinity", sizeof(typestr));
						//lua_pushstring(state, "infinity");
						lua_pushnumber(state,INFINITY);
                        break;
                    case osc::INT32_TYPE_TAG:
                        strncpy(typestr, "int32", sizeof(typestr));
                        lua_pushnumber(state, arg->AsInt32());
                        break;
                    case osc::FLOAT_TYPE_TAG:
                        strncpy(typestr, "float", sizeof(typestr));
                        lua_pushnumber(state, arg->AsFloat());
                        break;
                        
                    case osc::DOUBLE_TYPE_TAG:
                        strncpy(typestr, "double", sizeof(typestr));
                        lua_pushnumber(state, arg->AsDouble());
                        break;
                        
                    case osc::CHAR_TYPE_TAG:
                        strncpy(typestr, "char", sizeof(typestr));
                        lua_pushnumber(state, arg->AsChar());
                        break;
                        
                     case osc::RGBA_COLOR_TYPE_TAG:
                        strncpy(typestr, "rgbacolor", sizeof(typestr));
                        lua_pushnumber(state, arg->AsRgbaColor());
                        break;
                     
                    case osc::MIDI_MESSAGE_TYPE_TAG:
                        strncpy(typestr, "midi", sizeof(typestr));
                        lua_pushnumber(state, arg->AsMidiMessage());
                        break;
                    
                    case osc::TIME_TAG_TYPE_TAG:
                        strncpy(typestr, "timetag", sizeof(typestr));
                        lua_pushnumber(state, arg->AsTimeTag());
                        break;
                                        
                    case osc::STRING_TYPE_TAG:
                        strncpy(typestr, "string", sizeof(typestr));
                        lua_pushstring(state, arg->AsString());
                        break;
                        
                    case osc::SYMBOL_TYPE_TAG:
                        strncpy(typestr, "symbol", sizeof(typestr));
                        lua_pushstring(state, arg->AsSymbol());
                        break;
                        
                    case osc::BLOB_TYPE_TAG:
                        strncpy(typestr, "blob", sizeof(typestr));
                        const void *ptr;
                        //long int len;
						osc::osc_bundle_element_size_t len;
                        arg->AsBlob(ptr,len);
                        lua_pushlstring(state, (char*)ptr, len);
                        break;
					case osc::ARRAY_BEGIN_TYPE_TAG:
						strncpy(typestr, "[", sizeof(typestr));
                        lua_pushstring(state, "[");
                        break;
					case osc::ARRAY_END_TYPE_TAG:
						strncpy(typestr, "]", sizeof(typestr));
                        lua_pushstring(state, "]");
                        break;
					default:
						luaL_error(state,"Invalid tag  in an fromOSC packet.\n");
						break;
                 }
                        
                if(fulltype) 
                {                 
                    //set the value
                    lua_settable(state,-3);
                    //set the name
                    lua_pushnumber(state,1); 
                    lua_pushstring(state, typestr); 
                    lua_settable(state, -3);                      
                }
        
            //set the value of this index
            lua_settable(state, -3);
            index ++;
            arg++;
        
        }        
    
    lua_settable(state, -3);
    
}


int fromOSCLua(lua_State *state)
{
    //push the address...
        if(!lua_isstring(state,1))
        {
            luaL_error(state,"fromOSC called without a string argument!");
            return 0;
        }
        
            int fulltype;
        /*
            //check if we need to use the full type form
            if(lua_gettop(state)==2 && lua_tonumber(state,2))
            {
                fulltype = 1;
                lua_pop(state,1); //make sure top of stack is the string again
            }
            else
                fulltype=0;
		*/

             //check if we need to use the full type form
            if(lua_gettop(state)==2 )//vicpuso && lua_tonumber(state,2))
            {
                if (lua_toboolean(state,2)==1)
					fulltype = 1;
				else
					fulltype = 0;
                lua_pop(state,1); //make sure top of stack is the string again
            }
            else
                fulltype=0;
            
            //get the string to be decoded
            const char *msg = lua_tostring(state, -1);
            int len = lua_strlen(state,-1);
            
            lua_pop(state,1);
            
            //Decode the packet
			try{
				osc::ReceivedPacket p(msg, len);
            
				lua_newtable(state);            
				if(p.IsBundle())
				{               
					fromOSCBundle(state,p,fulltype);
				}
				else
				{                
					fromOSCMessage(state,p,fulltype);
				}
			}catch(osc::MalformedPacketException Ex){
				luaL_error(state,"osclua error in ReceivedPacket: %s\n",Ex.what());
			}     
            //return two values, (1) is this message or a bundle (2) the table data
            return 1;                                                 
}

static const struct luaL_Reg thislib[] = {
  {"toOSC", toOSCLua},
  {"fromOSC", fromOSCLua},
  {NULL, NULL}
};


LUALIB_API int luaopen_osclua (lua_State *L) {
  luaL_register(L, "osclua", thislib);
  return 1;
}
