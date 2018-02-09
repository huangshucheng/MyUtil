#pragma once
#include <iostream>
#include "LuaPlus.h"
using namespace  LuaPlus;

const char* lua_dump_path = "../script/luadump.lua";

class LuaDump
{
public:
	LuaDump();
	~LuaDump();

	bool doFile();
	void saveTable();
	void showTable();

private:
	LuaState* m_state;
};

LuaDump::LuaDump()
{
	m_state = LuaState::Create();
	m_state->OpenLibs();
	int dfrst = m_state->LoadFile(lua_dump_path);		//加载文件
	if (dfrst != 0){
		std::cout << "load file error..." << std::endl;
	}
	//this->doFile();
}

LuaDump::~LuaDump()
{
	LuaState::Destroy(m_state);
	m_state = nullptr;
}

//执行文件
bool LuaDump::doFile()
{
	if (m_state == nullptr){
		return false;
	}
	int df = m_state->DoFile(lua_dump_path);
	if (df != 0)
	{
		std::cout << "do file error..." << std::endl;
		return false;
	}
	return true;
}

int my_lua_Writer(lua_State *L, const void *p, size_t sz, void *ud)
{
	return 0;
}

void LuaDump::saveTable()
{
	/*
	LuaObject myTable = m_state->GetGlobals().CreateTable("Window");
	myTable.SetInteger("width", 640);
	myTable.SetInteger("height", 480);
	myTable.SetString("title", "My First Window");
	myTable.SetBoolean("enabled", true);
	myTable.SetInteger("alpha", 128);
	myTable.SetString("backgroundimage", "bg.jpg");
	
	//m_state->DumpObject("FirstWindow.lua", "Window", state->GetGlobals()["Window"], 0);
	m_state->Dump(my_lua_Writer,"hellolua",0);
	*/
}

void LuaDump::showTable()
{

}