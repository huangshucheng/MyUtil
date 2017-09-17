#pragma once

#include <iostream>
#include "cocos2d.h"
#include "boost/system/error_code.hpp"
//同步客户端

using namespace boost;
using namespace cocos2d;

void asyc_echo(std::string &msg);

void startTBConnect();