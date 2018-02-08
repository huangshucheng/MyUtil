#pragma once
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include "LuaEngine.h"
#include "LuaPlusEngine.h"

using namespace std;

int main(int argc, char** argv) {
	//LuaEngine::getInstance();
	//LuaEngine::getInstance()->testCallLua();
	//LuaEngine::getInstance()->c_getLuaNum();

	//LuaPlusEngine::getInstance().LuaCallCFunc();
	//LuaPlusEngine::getInstance().CCallLuaFunc();
	//LuaPlusEngine::getInstance().RegModule();
	LuaPlusEngine::getInstance().RegClass();
	system("pause");
	return 0;
}


