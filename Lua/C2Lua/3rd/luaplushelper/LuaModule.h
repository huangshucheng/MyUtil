#ifndef _LUA_MODULE_H
#define _LUA_MODULE_H

#pragma once

#include "LuaPlus.h"

class CLuaModule
{
public:
	CLuaModule(LuaState* state)
	{
		luaModuleObj = state->GetGlobals();
	}

	CLuaModule(LuaState* state, const char* name)
	{
		luaModuleObj = state->GetGlobals().CreateTable(name);
	}

	template<typename Func>
		inline CLuaModule& def(const char* name, Func func)
	{
		luaModuleObj.RegisterDirect(name, func);
		return *this;
	}

	template<typename Object, typename Func>
		inline CLuaModule& def(const char* name, Object& o, Func func)
	{
		luaModuleObj.RegisterDirect(name, o, func);
		return *this;
	}

private:
	LuaObject luaModuleObj;
};

#endif