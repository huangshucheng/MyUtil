#include "SocketTest.h"

#define MAX_LEN 512

SocketTest::SocketTest()
{

}

SocketTest::~SocketTest()
{

}

bool SocketTest::init()
{
	if (!Layer::init())
	{
		return false;
	}

	connectServer();
	return true;
}

void SocketTest::connectServer()
{
	// 初始化
	// ODSocket socket;
	socket.Init();
	socket.Create(AF_INET, SOCK_STREAM, 0);

	// 设置服务器的IP地址，端口号
	// 并连接服务器 Connect
	const char* ip = "127.0.0.1";
	int port = 12345;
	bool result = socket.Connect(ip, port);

	int retryTimes = 0;

	while (result == false && retryTimes < 7)
	{
		log("retry connecting...");

		result = socket.Connect(ip, port);
		retryTimes++;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		Sleep(500);
#else
		usleep(500);
#endif

	}
	// 发送数据 Send
	socket.Send("login", 5);

	if (result)
	{
		CCLOG("connect to server success!");
		// 开启新线程，在子线程中，接收数据
		std::thread recvThread = std::thread(&SocketTest::receiveData, this);
		recvThread.detach(); // 从主线程分离
	}
	else
	{
		CCLOG("can not connect to server");
		return;
	}
}

void SocketTest::receiveData()
{
	// 因为是强联网
	// 所以可以一直检测服务端是否有数据传来
	while (true)
	{
		// 接收数据 Recv
		char data[MAX_LEN] = "";

		int result = socket.Recv(data, MAX_LEN, 0);

		// 与服务器的连接断开了
		if (result <= 0)
			break;

		CCLOG("result=%d", result);

		CCLOG("revData=%s", data);
	}
	// 关闭连接
	socket.Close();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	Sleep(20);
#else
	usleep(20);
#endif
}