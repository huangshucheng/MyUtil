#include "LuaClassReg.h"

const char* lua_reg_path = "../script/luaclassreg.lua";

LuaClassReg::LuaClassReg()
{
	m_state = LuaState::Create();
	m_state->OpenLibs();
	int dfrst = m_state->LoadFile(lua_reg_path);		//加载文件
	if (dfrst != 0){
		std::cout << "load file error..." << std::endl;
	}
	//this->doFile();
}

LuaClassReg::~LuaClassReg()
{

}

static LuaClassReg instance;
LuaClassReg LuaClassReg::getInstance()
{
	return instance;
}

bool LuaClassReg::doFile()
{
	if (m_state == nullptr){
		return false;
	}
	int df = m_state->DoFile(lua_reg_path);
	if (df != 0)
	{
		std::cout << "do file error..." << std::endl;
		return false;
	}
	return true;
}

void LuaClassReg::regClass1()
{

	LPCD::Class(m_state->GetCState(), "VECTOR")
		.Property("x", &VECTOR::x)
		.Property("y", &VECTOR::y)
		.Property("z", &VECTOR::z);

	m_state->DoString("print('--------------------')");
	m_state->DoString("local vec = VECTOR() print(tostring(vec)");	//error


	//lua_register(L, "Vector", &new_VECTOR2);

	// ENTITY
	//LPCD::Class(m_state->GetCState(), "ENTITY")
		//.Property("name", &ENTITY::name)
		//.ObjectDirect("printName", (ENTITY*)0, &ENTITY::printName)
		//.MetatableFunction("__gc", &ENTITY___gc)
		;
	/*
	// POSITION_ENTITY
	LPCD::Class(L, "POSITION_ENTITY", "ENTITY")
		.Property("position", &POSITION_ENTITY::position)
		//.MetatableFunction("__gc", &POSITION_ENTITY___gc)
		;

	// MONSTER
	LPCD::Class(L, "MONSTER", "POSITION_ENTITY")
		.ObjectDirect("printMe", (MONSTER*)0, &MONSTER::printMe)
		.Property("alive", &MONSTER::alive)
		//.MetatableFunction("__gc", &MONSTER___gc)
		;
	*/


	///////////////////////////////////////////
	//lua_register(L, "Monster", &new_MONSTER2);
	/*
	luaL_dostring(L, "Monster1 = Monster()");
	lua_getglobal(L, "Monster1");
	luaL_dostring(L, "Monster1.alive = 1");
	luaL_dostring(L, "Monster1.position.x = 5");
	luaL_dostring(L, "Monster1.position.y = 10");
	luaL_dostring(L, "Monster1.position.z = 15");
	luaL_dostring(L, "Monster1.name = 'Joe'");
	luaL_dostring(L, "Monster1:printName()");
	luaL_dostring(L, "print(Monster1.position.x)");
	luaL_dostring(L, "Monster1:printMe()");
	luaL_dostring(L, "Monster1 = nil");
	lua_gc(L, LUA_GCCOLLECT, 0);

	luaL_dostring(L, "Monster2 = Monster()");
	lua_getglobal(L, "Monster2");
	MONSTER* monster2 = get_MONSTER2(L, -1);
	lua_pop(L, 1);
	luaL_dostring(L, "Monster2.alive = 0");
	luaL_dostring(L, "Monster2.position = Vector(25, 35, 45)");
	luaL_dostring(L, "Monster2.name = 'Jack'");
	luaL_dostring(L, "print(Monster2.position.x)");
	luaL_dostring(L, "Monster2:printMe()");

	lpcd_pushdirectclosure(L, &PassVector);
	lua_setglobal(L, "PassVector");

	luaL_dostring(L, "PassVector(Monster1.position)");

	*/
	/*
	// ENTITY_inplace
	LPCD::InPlaceClass(L, "ENTITY_inplace")
		.Property("position", &MONSTER::position)
		.Property("name", &MONSTER::name)
		.ObjectDirect("printName", (ENTITY*)0, &ENTITY::printName)
		.MetatableFunction("__gc", &ENTITY_inplace___gc)
		;

	// POSITION_ENTITY_inplace
	LPCD::InPlaceClass(L, "POSITION_ENTITY_inplace", "ENTITY_inplace")
		.Property("position", &MONSTER::position)
		.MetatableFunction("__gc", &ENTITY_inplace___gc)
		;

	// MONSTER_inplace
	LPCD::InPlaceClass(L, "MONSTER_inplace", "POSITION_ENTITY_inplace")
		.ObjectDirect("printMe", (MONSTER*)0, &MONSTER::printMe)
		.Property("alive", &MONSTER::alive)
		.MetatableFunction("__gc", &ENTITY_inplace___gc)
		;

	///////////////////////////////////////////
	lua_register(L, "MonsterInPlace", &new_MONSTER2_inplace);

	luaL_dostring(L, "Monster1InPlace = MonsterInPlace()");
	lua_getglobal(L, "Monster1InPlace");
	MONSTER* monsterInPlace = get_MONSTER2_inplace(L, -1);
	lua_pop(L, 1);
	lua_getglobal(L, "Monster1InPlace");
	lua_pushstring(L, "alive");
	lua_pushnumber(L, 0);
	lua_settable(L, -3);
	luaL_dostring(L, "Monster1InPlace.alive = 1");
	luaL_dostring(L, "Monster1InPlace.position.x = 5");
	luaL_dostring(L, "Monster1InPlace.position.y = 10");
	luaL_dostring(L, "Monster1InPlace.position.z = 15");
	luaL_dostring(L, "Monster1InPlace.name = 'JoeInPlace'");
	luaL_dostring(L, "Monster1InPlace:printName()");
	luaL_dostring(L, "print(Monster1InPlace.position.x)");
	luaL_dostring(L, "Monster1InPlace:printMe()");
	*/

	this->doFile();
}

void LuaClassReg::regClass2()
{
	// obj1 obj2 都继承MultiObject 
	LuaObject metaTableObj = m_state->GetGlobals().CreateTable("MultiObjectMetaTable");
	metaTableObj.SetObject("__index", metaTableObj);
	metaTableObj.RegisterObjectFunctor("Print", &MultiObject::Print);

	MultiObject obj1(10);
	LuaObject obj1Obj = m_state->BoxPointer(&obj1);
	obj1Obj.SetMetatable(metaTableObj);
	m_state->GetGlobals().SetObject("obj1", obj1Obj);

	MultiObject obj2(20);
	LuaObject obj2Obj = m_state->BoxPointer(&obj2);
	obj2Obj.SetMetatable(metaTableObj);
	m_state->GetGlobals().SetObject("obj2", obj2Obj);

	// test
	m_state->DoString("obj1:Print()");
	m_state->DoString("obj2:Print()");

	// table1 table2 都是obj1 , obj2的深拷贝
	LuaObject table1Obj = m_state->GetGlobals().CreateTable("table1");
	table1Obj.SetLightUserdata("__object", &obj1);
	table1Obj.SetMetatable(metaTableObj);

	LuaObject table2Obj = m_state->GetGlobals().CreateTable("table2");
	table2Obj.SetLightUserdata("__object", &obj2);
	table2Obj.SetMetatable(metaTableObj);

	// test
	m_state->DoString("table1:Print()");
	m_state->DoString("table2:Print()");
	this->doFile();
}