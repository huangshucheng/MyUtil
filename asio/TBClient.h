#pragma once

#include <iostream>
#include "cocos2d.h"
#include "boost/system/error_code.hpp"
//ͬ���ͻ���

using namespace boost;
using namespace cocos2d;

void asyc_echo(std::string &msg);

void startTBConnect();