#include "LuaPlusEngine.h"
#include "../3rd/luaplushelper/LuaModule.h"
#include "../3rd/luaplushelper/LuaClass.h"
#include "logger.h"

const char* lua_plus_file_path = "../script/luaplus.lua";

LuaPlusEngine::LuaPlusEngine()
{
	m_state = LuaState::Create();
	m_state->OpenLibs();
	int dfrst = m_state->LoadFile(lua_plus_file_path);		//加载文件
	if (dfrst != 0){
		std::cout << "load file error..." << std::endl;
	}
}
LuaPlusEngine::~LuaPlusEngine()
{
	LuaState::Destroy(m_state);
	m_state = nullptr;
}

static LuaPlusEngine ins;
LuaPlusEngine LuaPlusEngine::getInstance()
{
	return ins;
}
//执行文件
void LuaPlusEngine::doFile()
{
	if (m_state)
	{
		int df = m_state->DoFile(lua_plus_file_path);		
		if (df != 0)
		{
			std::cout << "do file error..." << std::endl;
		}
	}
}

/*c function*/
int addFunc(int a, int b){ return a + b; }

class Test
{
public:
	int add(int a, int b){ return a + b; }
};
//lua调用C
void LuaPlusEngine::LuaCallCFunc()
{
	std::cout << std::endl;

	//执行命令
	int reslt;
	m_state->DoString("print('c_print-----')");

	// 为Lua脚本设置变量
	m_state->GetGlobals().SetNumber("myvalue", 100);
	int number = m_state->GetGlobal("myvalue").GetInteger();
	std::cout << "number: " << number << std::endl;

	//获取lua函数
	LuaFunction<int>luaprint = m_state->GetGlobal("print");
	luaprint("hello lua");
	
	// 让Lua调用C语言函数
	m_state->GetGlobals().RegisterDirect("addFunc", addFunc);
	m_state->DoString("print('addFunc: ' .. addFunc(3,4))");

	// 让Lua调用C++类成员函数
	Test _test;
	m_state->GetGlobals().RegisterDirect("cppAdd", _test, &Test::add);
	m_state->DoString("print('cppAdd: ' .. cppAdd(3,8))");

	//////////////////////////////////////////////////////////////////////////

	//table 操作
	LuaObject tb = m_state->GetGlobals().CreateTable("hcctb");
	tb.SetInteger("m", 10);
	tb.SetNumber("f", 1.99);
	tb.SetString("s", "Hello World");
	tb.SetString(1, "What");

	LuaObject tb2 = m_state->GetGlobal("hcctb");
	int m = tb2.GetByName("m").GetInteger();

	///// 
	m_state->DoString("MyTable = { Hi = 5, Hello = 10, Yo = 6 }");

	std::cout << "//////////////////////" << std::endl;
	LuaObject obj = m_state->GetGlobal("MyTable");
	for (LuaTableIterator it(obj); it ; it.Next()){
		const char* key = it.GetKey().GetString();
		int num = it.GetValue().GetInteger();
		std::cout << "key: " << key << "  ,value: " << num << std::endl;
	}

	std::cout << std::endl;
	std::cout << "///////////lua print///////////" << std::endl;

	this->doFile();
}
//C 调用lua
void LuaPlusEngine::CCallLuaFunc()
{
	this->doFile();//先执行文件，载入lua栈
	//到lua栈获取数据
	LuaObject obj = m_state->GetGlobal("num");
	printf("num: %d\n", obj.GetInteger());
	//到栈获取table
	LuaObject obj1 = m_state->GetGlobal("mytb");
	bool istable = obj1.IsTable();
	char* istb = istable ? "true" : "false";
	printf("istable: %s\n", istb);
	//遍历table
	LuaTableIterator it(obj1);
	/*for (;it;it.Next()){
		int key = it.GetKey().GetInteger();
		int num = it.GetValue().GetInteger();
		std::cout << "key: " << key << "  ,value: " << num << std::endl;
		}*/
	while (it.Next())
	{
		int key = it.GetKey().GetInteger();
		int num = it.GetValue().GetInteger();
		std::cout << "key: " << key << "  ,value: " << num << std::endl;
	}
}

void LuaPlusEngine::RegModule()
{
	Test _test;
	CLuaModule md = CLuaModule(m_state,"mymodule");
	md.def("add1", addFunc);		//注册函数
	md.def("add2", _test,&Test::add);				//注册类函数

	//m_state->DoString("print(mymodule.add1(3,4));print(mymodule.add2(3,4));");
	//m_state->DoString("print(mymodule.add1(3,4));");
	this->doFile();//先执行文件，载入lua栈
}
//注册类到Lua   TODO
void LuaPlusEngine::RegClass()
{
	//http://blog.csdn.net/kenkao/article/details/8138510
	//Logger _log;
	//_log.LOGMEMBER("loghcc...");
	//LuaClass<Logger> cls = LuaClass<Logger>(m_state);
	//cls.create("logger");
	//cls.def()

	LuaClass<Logger>(m_state)
		.create("Logger")
		.create<int>("Logger2")
		.create<Logger*>("Logger3")
		.destroy("Free")
		.destroy("__gc")
		.def("lm", &Logger::LOGMEMBER)
		.def("lv", &Logger::LOGVIRTUAL);
	/*
	m_state->DoString(
		"print('=========');"
		"print(Logger, _G['MetaClass_.?AVLogger@@']);"
		"l = Logger();"
		"print(Logger2(250));"
		);
	*/
	//m_state->DoString(
	//	"print('=====2222222====');"
	//	"print(mylog());"
	//	);

	//this->doFile();//先执行文件，载入lua栈
}