#include "LuaEngine.h"

LuaEngine::LuaEngine()
{
	//获取工作路径
	char buf[100] = { 0 };
	_getcwd(buf, sizeof(buf));
	cout << "path:" << buf << endl;
}

LuaEngine::~LuaEngine()
{

	if (m_state)
	{
		lua_close(m_state);
		m_state = nullptr;
	}
}
LuaEngine* LuaEngine::instance;
LuaEngine* LuaEngine::getInstance()
{
	if (!instance)
	{
		instance = new LuaEngine();
		instance->init();
	}
	return instance;
}

bool LuaEngine::init()
{
	m_state = luaL_newstate();
	luaL_openlibs(m_state);
	register_my_functions();
	register_my_libs();
	char* path = "../../script/main.lua";
	luaL_dofile(m_state, path);
	lua_pcall(m_state, 0, 0, -1);
	return true;
}

//有一个返回值
static int l_getName(lua_State* L)
{
	cout << "l_getName...." << endl;
	lua_pushstring(L, "haungshucheng");	//返回值传到栈顶
	return 1;							//一个返回值
}

//没有返回值
static int l_show_return_0(lua_State* L)
{
	cout << "l_show_return_0" << endl;
	return 0;
}
//一个返回值
static int l_show_return_1(lua_State* L)
{
	cout << "l_show_return_1" << endl;
	lua_pushstring(L, "I am l_show_return_1");
	return 1;
}

//两个返回值
static int l_show_return_2(lua_State* L)
{
	cout << "l_show_return_2" << endl;
	lua_pushstring(L, "I am l_show_return_2 111");
	lua_pushstring(L, "I am l_show_return_2 222");
	return 2;
}
//返回值是table
static int l_getTable(lua_State* L)
{
	lua_newtable(L);
	char buf[20] = {0};
	for (int i = 1; i <= 10; i++){
		lua_pushnumber(L, i);
		sprintf_s(buf, "num is %d", i);
		lua_pushstring(L, buf);
		lua_settable(L, -3);
	}
	return 1;
}

void LuaEngine::register_my_functions()
{
	lua_pushcfunction(m_state, l_getName);
	lua_setglobal(m_state, "getName");

	lua_pushcfunction(m_state, l_show_return_0);
	lua_setglobal(m_state, "showZero");

	lua_pushcfunction(m_state, l_show_return_1);
	lua_setglobal(m_state, "showOne");

	lua_pushcfunction(m_state, l_show_return_2);
	lua_setglobal(m_state, "showTwo");

	lua_pushcfunction(m_state, l_getTable);
	lua_setglobal(m_state, "getTable");
}
//注册自己的lua包(有错误)
void LuaEngine::register_my_libs()
{
	luaL_Reg * lib = luax_my_libs;
	lua_getglobal(m_state, "package");
	lua_getfield(m_state, -1, "preload");
	for (; lib->func;lib++){
		lua_pushcfunction(m_state,lib->func);
		lua_setfield(m_state, -2, lib->name);
	}
	lua_pop(m_state,2);
}