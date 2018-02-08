#pragma once
#include <stdio.h>

class Logger
{
public:
	void LOGMEMBER(const char* message)
	{
		printf("成员函数  %s\n", message);
	}

	virtual void LOGVIRTUAL(const char* message)
	{
		printf("虚构函数  %s\n", message);
	}

	Logger()
	{
		printf("构造函数  (%p)...\n", this);
		v = 10;
	}
	virtual ~Logger()
	{
		printf("析构函数  (%p)...\n", this);
	}

	Logger(int n)
	{
		printf(" -- 构造函数（一个参） [%d](%p)...\n", n, this);
	}
	Logger(Logger* logger)
	{
		printf(" -- 构造函数（一个参） [%p](%p)...\n", logger, this);
		logger->LOGMEMBER("-- 0000---0000\n");
	}

	void mylog(int){
		printf("my print ...\n");
	}
public:
	int v = 0;
};