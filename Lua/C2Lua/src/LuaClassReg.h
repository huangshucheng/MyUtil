#pragma once
#include <iostream>
#include "../3rd/luaplus/LuaPlus.h"
using namespace LuaPlus;

//////////////////////////// test class
class VECTOR
{
public:
	double x, y, z;
};

class ENTITY {
public:
	virtual ~ENTITY() {
	}

	void printName() {
		printf("ENTITY name: %s\n", name.c_str());
	}

	std::string name;
};

class POSITION_ENTITY : public ENTITY {
public:
	VECTOR position;
};

class HUMAN : public ENTITY {
public:
	int alive;

	void printMe() {
		printf("HUMAN printMe - alive:%d\n", alive);
	}
};

class MONSTER : public POSITION_ENTITY {
public:
	int alive;
	VECTOR attackPosition;

	void printMe() {
		printf("MONSTER printMe - alive:%d\n", alive);
	}
};

//////////////////////////// end

class MultiObject
{
public:
	MultiObject(int num) :
		m_num(num)
	{
	}

	int Print(LuaState* state)
	{
		printf("m_num: %d\n", m_num);
		return 0;
	}

	void Print2(int num)
	{
		printf("m_num: %d , num: %d\n", m_num, num);
	}

protected:
	int m_num;
};
//////////////////////////// end

class LuaClassReg
{
public:
	LuaClassReg();
	~LuaClassReg();
	static LuaClassReg getInstance();

	bool doFile();

public:
	void regClass1();
	void regClass2();

private:
	LuaState* m_state;
};