#pragma once
#include <stdio.h>

class Logger
{
public:
	void LOGMEMBER(const char* message)
	{
		printf("��Ա����  %s\n", message);
	}

	virtual void LOGVIRTUAL(const char* message)
	{
		printf("�鹹����  %s\n", message);
	}

	Logger()
	{
		printf("���캯��  (%p)...\n", this);
		v = 10;
	}
	virtual ~Logger()
	{
		printf("��������  (%p)...\n", this);
	}

	Logger(int n)
	{
		printf(" -- ���캯����һ���Σ� [%d](%p)...\n", n, this);
	}
	Logger(Logger* logger)
	{
		printf(" -- ���캯����һ���Σ� [%p](%p)...\n", logger, this);
		logger->LOGMEMBER("-- 0000---0000\n");
	}

	void mylog(int){
		printf("my print ...\n");
	}
public:
	int v = 0;
};