#include "LuaPlusEngine.h"
#include "../3rd/luaplushelper/LuaModule.h"
#include "../3rd/luaplushelper/LuaClass.h"
#include "logger.h"

const char* lua_plus_file_path = "../script/luaplus.lua";

LuaPlusEngine::LuaPlusEngine()
{
	m_state = LuaState::Create();
	m_state->OpenLibs();
	int dfrst = m_state->LoadFile(lua_plus_file_path);		//�����ļ�
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
//ִ���ļ�
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
//lua����C
void LuaPlusEngine::LuaCallCFunc()
{
	std::cout << std::endl;

	//ִ������
	int reslt;
	m_state->DoString("print('c_print-----')");

	// ΪLua�ű����ñ���
	m_state->GetGlobals().SetNumber("myvalue", 100);
	int number = m_state->GetGlobal("myvalue").GetInteger();
	std::cout << "number: " << number << std::endl;

	//��ȡlua����
	LuaFunction<int>luaprint = m_state->GetGlobal("print");
	luaprint("hello lua");
	
	// ��Lua����C���Ժ���
	m_state->GetGlobals().RegisterDirect("addFunc", addFunc);
	m_state->DoString("print('addFunc: ' .. addFunc(3,4))");

	// ��Lua����C++���Ա����
	Test _test;
	m_state->GetGlobals().RegisterDirect("cppAdd", _test, &Test::add);
	m_state->DoString("print('cppAdd: ' .. cppAdd(3,8))");

	//////////////////////////////////////////////////////////////////////////

	//table ����
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
//C ����lua
void LuaPlusEngine::CCallLuaFunc()
{
	this->doFile();//��ִ���ļ�������luaջ
	//��luaջ��ȡ����
	LuaObject obj = m_state->GetGlobal("num");
	printf("num: %d\n", obj.GetInteger());
	//��ջ��ȡtable
	LuaObject obj1 = m_state->GetGlobal("mytb");
	bool istable = obj1.IsTable();
	char* istb = istable ? "true" : "false";
	printf("istable: %s\n", istb);
	//����table
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
	md.def("add1", addFunc);		//ע�ắ��
	md.def("add2", _test,&Test::add);				//ע���ຯ��

	//m_state->DoString("print(mymodule.add1(3,4));print(mymodule.add2(3,4));");
	//m_state->DoString("print(mymodule.add1(3,4));");
	this->doFile();//��ִ���ļ�������luaջ
}
//ע���ൽLua   TODO
void LuaPlusEngine::RegClass()
{
	//http://blog.csdn.net/kenkao/article/details/8138510

	LuaClass<Logger>(m_state)
		.create("Logger")					// ���幹�캯�� Logger::Logger()			//local lg = Logger();
		.create<int>("Logger2")				// ���幹�캯�� Logger::Logger(int)		//local lg2 = Logger(250);
		.create<Logger*>("Logger3")			// ���幹�캯�� Logger::Logger(Logger*)	//local lg3 = Logger(lg);
		.destroy("Free")					// ������������ Logger::~Logger()			//lg:Free()		��ʾ������������
		.destroy("__gc")					// ������������ Logger::~Logger()			//�Զ�������������
		.def("LogMember", &Logger::LOGMEMBER)		// �����Ա���� Logger::LOGMEMBER(const char*)	//lg:LogMember()
		.def("LogVirtual", &Logger::LOGVIRTUAL)		// �����Ա����					//log:LogVirtual()
		.def("setValue", &Logger::setValue)			// �����Ա����					//log:setValue(123)
		.def("getValue", &Logger::getValue);		// �����Ա����					//log:getValue()
		//.def("callFunc", &Logger::callFunc);		//callback regist error

	///////////////////////////////////
	this->doFile();//ִ���ļ�������luaջ
}
//ע��logger��ĳ�Ա����
void LuaPlusEngine::RegLogger()
{
	LuaObject globalsObj = m_state->GetGlobals();
	Logger logger;
	globalsObj.RegisterDirect("LOGMEMBER", logger, &Logger::LOGMEMBER);
	globalsObj.RegisterDirect("LOGVIRTUAL", logger, &Logger::LOGVIRTUAL);

	// test
	m_state->DoString("LOGMEMBER('Hello')");
	m_state->DoString("LOGVIRTUAL('Hello')");
}