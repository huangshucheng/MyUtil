#pragma once

#include "cocos2d.h"
#include "network/WebSocket.h"

using namespace cocos2d;

using namespace cocos2d::network;

class WebSocketTest : public cocos2d::Layer, public cocos2d::network::WebSocket::Delegate
{
public:

	virtual bool init();
	CREATE_FUNC(WebSocketTest);

public:
	WebSocketTest();
	virtual~WebSocketTest();
	/*
	WebSocket.org 提供了一个专门用来测试WebSocket的服务器"ws://echo.websocket.org"。
	测试代码以链接这个服务器为例，展示如何在Cocos2d-x中使用WebSocket。
	*/
	virtual void onOpen(cocos2d::network::WebSocket* ws);
	virtual void onMessage(cocos2d::network::WebSocket* ws, const cocos2d::network::WebSocket::Data& data);
	virtual void onClose(cocos2d::network::WebSocket* ws);
	virtual void onError(cocos2d::network::WebSocket* ws, const cocos2d::network::WebSocket::ErrorCode& error);

private:
	cocos2d::network::WebSocket* _wsiClient;
};

