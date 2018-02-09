#pragma once
#include <iostream>
#include "../3rd/luaplus/LuaPlus.h"
using namespace LuaPlus;

class LuaPlusEngine
{
public:
	LuaPlusEngine();
	~LuaPlusEngine();
	static LuaPlusEngine getInstance();

	void LuaCallCFunc();
	void CCallLuaFunc();

	void RegModule();
	void RegClass();
	void RegLogger();

public:
	void doFile();

private:
	LuaState* m_state;

};