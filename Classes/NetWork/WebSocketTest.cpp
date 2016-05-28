#include "WebSocketTest.h"

bool WebSocketTest::init()
{
	if (!Layer::init())
	{
		return false;
	}
	log("websocket");

	//Application::getInstance()->openURL("http://www.cocos2d-x.org/");

	_wsiClient = new cocos2d::network::WebSocket();
	_wsiClient->init(*this, "ws://echo.websocket.org");
	/*
	在init之后，我们就可以调用send接口，往服务器发送数据请求。send有文本和二进制两中模式。

	发送文本

	_wsiClient->send("Hello WebSocket, I'm a text message."); 

	发送二进制数据(多了一个len参数)

	_wsiClient->send((unsigned char*)buf, sizeof(buf)); 

	主动关闭WebSocket

	这是让整个流程变得完整的关键步骤, 当某个WebSocket的通讯不再使用的时候，我们必须手动关闭这个WebSocket与服务器的连接。close会触发onClose消息，而后onClose里面，我们释放内存。

	_wsiClient->close(); 
	*/

	_wsiClient->send("Hello WebSocket, I'm a text message.");

	//_wsiClient->send((unsigned char*)buf, sizeof(buf));
	_wsiClient->close();
	return true;
}

WebSocketTest::WebSocketTest():
_wsiClient(nullptr)
{

}

WebSocketTest::~WebSocketTest()
{

}
//init会触发WebSocket链接服务器，如果成功，WebSocket就会调用onOpen
//告诉调用者，客户端到服务器的通讯链路已经成功建立，可以收发消息了。
void WebSocketTest::onOpen(cocos2d::network::WebSocket* ws)
{

	if (ws == _wsiClient)

	{
		CCLOG("OnOpen");
	}
}
/*
network::WebSocket::Data对象存储客户端接收到的数据， 
isBinary属性用来判断数据是二进制还是文本，len说明数据长度，bytes指向数据。
*/
void WebSocketTest::onMessage(cocos2d::network::WebSocket* ws, const cocos2d::network::WebSocket::Data& data)
{
	std::string textStr = data.bytes;
	textStr.c_str();
	CCLOG("%s",textStr.c_str());
}
/*
不管是服务器主动还是被动关闭了WebSocket，客户端将收到这个请求后，
需要释放WebSocket内存，并养成良好的习惯：置空指针。
*/
void WebSocketTest::onClose(cocos2d::network::WebSocket* ws)
{
	if (ws == _wsiClient)
	{
		_wsiClient = nullptr;
	}
	CC_SAFE_DELETE(ws);
	CCLOG("onClose");
}
/*
客户端发送的请求，如果发生错误，就会收到onError消息，游戏针对不同的错误码，做出相应的处理。
*/
void WebSocketTest::onError(cocos2d::network::WebSocket* ws, const cocos2d::network::WebSocket::ErrorCode& error)
{
	if (ws == _wsiClient)
	{
		char buf[100] = { 0 };
		sprintf(buf, "an error was fired, code: %d", error);
	}
	CCLOG("Error was fired, error code: %d", error);
}