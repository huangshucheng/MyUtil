#pragma once
#include <stdio.h>
#include <iostream>
#include <functional>

class Logger
{
public:
	void LOGMEMBER(const char* message)
	{
		printf("--  成员函数（LOGMEMBER）  %s\n", message);
	}

	virtual void LOGVIRTUAL(const char* message)
	{
		printf("--  虚成员函数（LOGVIRTUAL）  %s\n", message);
	}

	Logger()
	{
		printf("-- 构造函数（Logger()）  (%p)...\n", this);
	}

	virtual ~Logger()
	{
		printf("--  析构函数(~Logger)  (%p)...\n", this);
	}

	Logger(int n)
	{
		printf(" -- 构造函数（Logger(int)） [%d](%p)...\n", n, this);
	}
	Logger(Logger* logger)
	{
		printf(" -- 构造函数（Logger(Logger*)） [%p](%p)...\n", logger, this);
	}

	void setValue(int vl){
		printf(" -- 成员函数(setValue(int)...(%p)...\n", this);
		this->v = vl;
	}

	int getValue()
	{
		printf(" -- 成员函数（getValue()）...(%p)...\n", this);
		return v;
	}

	//bool callFunc(std::function<void(void)>func)		//不能注册回调函数到lua    
	bool callFunc(std::function<void(int num)>func)
	{
		printf(" -- 成员函数（callFunc()）...(%p)...\n", this);
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