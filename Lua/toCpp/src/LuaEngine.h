#pragma once
#include <iostream>
#include <direct.h>
#include "../3rd/lua/lua.hpp"
using namespace std;

static int showRes1(lua_State* L)
{
	cout << "showRes1........" << endl;
	lua_pushstring(L, "I am res1");
	return 1;
}

static int showRes2(lua_State* L)
{
	cout << "showRes2........" << endl;
	char buf[20] = { 0 };
	const char* val = luaL_checkstring(L,-1);
	sprintf_s(buf, "res2--->%s", val);
	lua_pushstring(L, buf);
	return 1;
}

//注册lua包，lua中可以require
#ifdef __cplusplus
extern "C"{
#endif // __cplusplus
	static luaL_Reg luax_my_libs[] = {
		{ "mylib", showRes1 },
		//{ "showRes2", showRes2 },
		{NULL,NULL}
	};

#ifdef __cplusplus
}
#endif // __cplusplus

class LuaEngine
{

public:
	static LuaEngine* getInstance();
	bool init();
	void register_my_functions();
	void register_my_libs();
private:
	LuaEngine();
	~LuaEngine();
	static LuaEngine* instance;
	lua_State* m_state;
};

