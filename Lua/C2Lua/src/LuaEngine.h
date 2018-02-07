#pragma once
#include <iostream>
#include <direct.h>
#include "../3rd/lua/lua.hpp"
using namespace std;
class LuaEngine
{

public:
	static LuaEngine* getInstance();
	bool init();
	void register_my_functions();
	void register_my_libs();

public:

public:
	void testCallLua();
private:
	LuaEngine();
	~LuaEngine();
	static LuaEngine* instance;
	lua_State* m_state;
};