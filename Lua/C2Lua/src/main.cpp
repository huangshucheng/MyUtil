#pragma once
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include "LuaEngine.h"
#include "LuaPlusEngine.h"
#include "luaDump.h"
#include "LuaClassReg.h"
#include "logger.h"

using namespace std;

void cfk(int num)
{
	std::cout << "callfunc----------------->" << num << std::endl;
}

int main(int argc, char** argv) {
	//LuaEngine::getInstance();
	//LuaEngine::getInstance()->testCallLua();
	//LuaEngine::getInstance()->c_getLuaNum();

	//LuaPlusEngine::getInstance().LuaCallCFunc();
	//LuaPlusEngine::getInstance().CCallLuaFunc();
	//LuaPlusEngine::getInstance().RegModule();
	//LuaPlusEngine::getInstance().RegClass();
	//LuaPlusEngine::getInstance().RegLogger();

	LuaClassReg::getInstance().regClass1();
	//LuaClassReg::getInstance().regClass2();

	system("pause");
	return 0;
}


