#pragma once

#include "cocos2d.h"
#include "ODSocket/ODSocket.h"
#include "CCPlatformConfig.h"

using namespace cocos2d;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#include <Winsock2.h>
#include <Wininet.h>

#else

#include <pthread.h>
#include <unistd.h>

#endif

class SocketTest : public Layer
{
public:

	SocketTest();
	~SocketTest();

	virtual bool init();
	CREATE_FUNC(SocketTest);

public:

	void connectServer();
	void receiveData();

private:

	ODSocket socket;
};

