#pragma once

#include "cocos2d.h"
#include "network/HttpRequest.h"
#include "network/HttpClient.h"
#include"network/HttpResponse.h"

using namespace cocos2d;
using namespace cocos2d::network;

class HttpRequestTest : public Layer
{
public:

	HttpRequestTest();
	~HttpRequestTest();

	virtual bool init();
	CREATE_FUNC(HttpRequestTest);

public:
	//网络请求
	void testHttpGet();
	void testHttpPost();

	//下载图片
	void downloadImage();
	void onHttpRequestImageCompleted(HttpClient* sender, HttpResponse* response);

	//get请求回调函数
	void requestResponseFunc(HttpClient* sender, HttpResponse* response);

private:

};

