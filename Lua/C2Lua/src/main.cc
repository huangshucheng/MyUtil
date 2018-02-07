#pragma once

#include <iostream>
#include <stdlib.h>
#include "LuaEngine.h"

using namespace std;




int main(int argc ,char** argv)
{
	LuaEngine::getInstance();
	system("pause");
	return 0;
}