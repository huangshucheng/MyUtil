#pragma once
#include <stdio.h>
#include <iostream>
#include <functional>

class Logger
{
public:
	void LOGMEMBER(const char* message)
	{
		printf("--  ��Ա������LOGMEMBER��  %s\n", message);
	}

	virtual void LOGVIRTUAL(const char* message)
	{
		printf("--  ���Ա������LOGVIRTUAL��  %s\n", message);
	}

	Logger()
	{
		printf("-- ���캯����Logger()��  (%p)...\n", this);
	}

	virtual ~Logger()
	{
		printf("--  ��������(~Logger)  (%p)...\n", this);
	}

	Logger(int n)
	{
		printf(" -- ���캯����Logger(int)�� [%d](%p)...\n", n, this);
	}
	Logger(Logger* logger)
	{
		printf(" -- ���캯����Logger(Logger*)�� [%p](%p)...\n", logger, this);
	}

	void setValue(int vl){
		printf(" -- ��Ա����(setValue(int)...(%p)...\n", this);
		this->v = vl;
	}

	int getValue()
	{
		printf(" -- ��Ա������getValue()��...(%p)...\n", this);
		return v;
	}

	//bool callFunc(std::function<void(void)>func)		//����ע��ص�������lua    
	bool callFunc(std::function<void(int num)>func)
	{
		printf(" -- ��Ա������callFunc()��...(%p)...\n", this);
		if (func)
		{
			func(100);
			return true;
		}
		return false;
	}

	static int cCallBack(lua_State*L)
	{
		LuaStack args(L);
		printf("In member cCallBack.  Message: %s\n", args[1].GetString());
		return 0;
	}
public:
	int v = 0;
};