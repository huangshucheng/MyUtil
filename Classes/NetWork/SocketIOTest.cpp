#include "SocketIOTest.h"

bool SocketIOTest::init()
{
	if (!Layer::init())
	{
		return false;
	}
	log("socketIO");

	return true;
}

void SocketIOTest::onClose(SIOClient* client)
{

}

void SocketIOTest::onError(SIOClient* client, const std::string& data)
{

}