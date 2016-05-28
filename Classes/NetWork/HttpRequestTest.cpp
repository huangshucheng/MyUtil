#include "HttpRequestTest.h"

HttpRequestTest::HttpRequestTest()
{

}

HttpRequestTest::~HttpRequestTest()
{

}

bool HttpRequestTest::init()
{
	if (!Layer::init())
	{
		return false;
	}

	log("httpreq");

	//testHttpGet();

	//testHttpPost();

	downloadImage();

	return true;
}
//Get请求(从服务器上获取数据)
void HttpRequestTest::testHttpGet()
{
	HttpRequest* requst = new HttpRequest();

	requst->setUrl("http://www.httpbin.org/get");
	requst->setRequestType(HttpRequest::Type::GET);

	requst->setResponseCallback(CC_CALLBACK_2(HttpRequestTest::requestResponseFunc, this));
	requst->setTag("get");

	HttpClient::getInstance()->send(requst);

	//设置等待时间
	HttpClient::getInstance()->setTimeoutForConnect(20);

	HttpClient::getInstance()->setTimeoutForRead(20);

	requst->release();
}
//Post请求(向服务器传送数据)(登录注册)
void HttpRequestTest::testHttpPost()
{
	//http://132.56.111.165:8050/userRegister
	//{"email":"123@qq.com","password":"123456","phonIdentity":"555555555"}

	//    std::string name = StringUtils::format("name");
	//   std::string pwd= StringUtils::format("pwd");
	//    //////修改请求格式///////////
	//    std::string text = StringUtils::format("{\"email\":%s,\"password\":%s,\"phonIdentity\":\"5555555\" }",name.c_str(),pwd.c_str());

	char data[50];

	sprintf(data, "user_name=test12&user_password=123456");

	log("data=%ld", strlen(data));

	HttpRequest* requst = new HttpRequest();

	requst->setUrl("http://42.96.151.161:83/service/userligin");

	requst->setRequestType(HttpRequest::Type::POST);

	requst->setRequestData(data, strlen(data));

	requst->setResponseCallback(CC_CALLBACK_2(HttpRequestTest::requestResponseFunc, this));

	requst->setTag("post");

	HttpClient::getInstance()->send(requst);

	requst->release();
}
//下载图片
void HttpRequestTest::downloadImage()
{
	HttpRequest* request = new HttpRequest();
	//设置请求的url：网站上面的图片地址
	request->setUrl("http://f.hiphotos.baidu.com/image/pic/item/77094b36acaf2eddb6542135881001e938019340.jpg");
	//请求格式
	request->setRequestType(HttpRequest::Type::GET);
	//回掉
	request->setResponseCallback(CC_CALLBACK_2(HttpRequestTest::onHttpRequestImageCompleted, this));
	//发送请求
	HttpClient::getInstance()->send(request);
	//释放请求
	request->setTag("downloadImage");
	request->release();
}

void HttpRequestTest::onHttpRequestImageCompleted(HttpClient* sender, HttpResponse* response)
{
	if (response->isSucceed())
	{
		const char* tag = response->getHttpRequest()->getTag();

		if (0 != strlen(tag)) 
		{
			log("tag= %s", response->getHttpRequest()->getTag());
		}

		//返回数据存到Buffer容器
		std::vector<char>*buffer = response->getResponseData();

		std::string wrPath = FileUtils::getInstance()->getWritablePath();

		wrPath += "a.jpg";

		log("wrpath = %s", wrPath.c_str());

		Image* image = new Image;
		//把buffer容器的图片数据给image
		image->initWithImageData((unsigned char*)buffer->data(), buffer->size());
		//image保存到沙盒
		image->saveToFile(wrPath);

		//判断image是否有
		Texture2D* texture = new Texture2D();

		bool isImage = texture->initWithImage(image);

		if (isImage) 
		{
			log("Texture2D init success");
		}

		//    image->release();
		//    //创建容器
		std::vector<std::string>path;

		//把沙盒里面的东西放到容器
		path.push_back(wrPath.c_str());

		//设置搜索路径为容器
		FileUtils::getInstance()->setSearchPaths(path);

		//图片显示在屏幕上
		auto size = Director::getInstance()->getVisibleSize();

		auto s = Sprite::createWithTexture(texture);

		s->setPosition(Vec2(size.width / 2, size.height / 2));
		this->addChild(s);
	}
	else
	{
		log("error:%d", response->getErrorBuffer());
	}
}

void HttpRequestTest::requestResponseFunc(HttpClient* sender, HttpResponse* response)
{
	if (response->isSucceed()) 
	{
		//200算请求成功，其他失败
		log("ResponseCode =  %ld", response->getResponseCode());

		log(" tag = %s", response->getHttpRequest()->getTag());

		std::vector<char> *buffer = response->getResponseData();

		std::stringstream oss;	//数据流

		for (unsigned int i = 0; i< buffer->size(); i++)
		{
			oss << (*buffer)[i];	//写入数据流
		}
		std::string str = oss.str();

		log("response data= %s", str.c_str());
	}
	else
	{
		log("error:%d", response->getErrorBuffer());
	}
}