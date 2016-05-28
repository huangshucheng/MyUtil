#pragma once

#include "cocos2d.h"
#include "network/SocketIO.h"

using namespace cocos2d;
using namespace cocos2d::network;

class SocketIOTest : public Layer, public cocos2d::network::SocketIO::SIODelegate
{
public:

	virtual bool init();
	CREATE_FUNC(SocketIOTest);

public:

	virtual void onConnect(SIOClient* client) { CC_UNUSED_PARAM(client); CCLOG("SIODelegate onConnect fired"); };

	virtual void onMessage(SIOClient* client, const std::string& data) { CC_UNUSED_PARAM(client); CCLOG("SIODelegate onMessage fired with data: %s", data.c_str()); };

	virtual void onClose(SIOClient* client);

	virtual void onError(SIOClient* client, const std::string& data);

private:

};

