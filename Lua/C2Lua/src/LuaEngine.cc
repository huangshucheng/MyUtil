#include "LuaEngine.h"

const char* lua_file_path = "../../script/main.lua";

#define  _CRT_SECURE_NO_WARNINGS

typedef	struct NumArray
{
	int size;
	double values[1];
}NumArray;

LuaEngine::LuaEngine()
{
	//获取工作路径
	char buf[100] = { 0 };
	_getcwd(buf, sizeof(buf));
	cout << "workpath:" << buf << endl;
}

LuaEngine::~LuaEngine()
{
	if (m_state)
	{
		lua_close(m_state);
		m_state = nullptr;
	}
}
//打印栈信息
void stackDump(lua_State* L) {
	cout << "\nbegin dump lua stack" << endl;
	int i = 0;
	int top = lua_gettop(L);
	for (i = 1; i <= top; ++i) {
		int t = lua_type(L, i);
		switch (t) {
		case LUA_TSTRING: {
			printf("'%s' ", lua_tostring(L, i));
		}
						  break;
		case LUA_TBOOLEAN: {
			printf(lua_toboolean(L, i) ? "true " : "false ");
		}
						   break;
		case LUA_TNUMBER: {
			printf("%g ", lua_tonumber(L, i));
		}
						  break;
		default: {
			printf("%s ", lua_typename(L, t));
		}
				 break;
		}
	}
	cout << "\nend dump lua stack" << endl;
	cout << "\n" << endl;

}

LuaEngine* LuaEngine::instance;
LuaEngine* LuaEngine::getInstance()
{
	if (!instance)
	{
		instance = new LuaEngine();
		instance->init();
	}

	return instance;
}

bool LuaEngine::init()
{
	m_state = luaL_newstate();
	luaL_openlibs(m_state);								//打开链接库
	register_my_functions();
	register_my_libs();
	int fret = luaL_dofile(m_state, lua_file_path);		//执行脚本
	if (fret){
		std::cout << "read lua file error!" << std::endl;
		lua_pop(m_state, 1);
		return false;
	}
	return true;
}
//返回table给lua
int getCTable(lua_State* L)
{
	lua_newtable(L);	//创建table,放到栈顶
	char buf[10] = { 0 };

	for (int i = 1; i <= 10; i++){
		lua_pushnumber(L, i);
		sprintf_s(buf, "v-%d", i);
		lua_pushstring(L, buf);
		lua_settable(L, -3);
	}
	/*
	//将key,value分别入栈，再将带有k,v的table放到栈顶，供lua获取
	lua_pushnumber(L, 0);		//传入key 到table
	lua_pushstring(L, "v1");	//传入value 到table
	lua_settable(L, -3);		//弹出key,value，再将-3位置的table放到栈顶（此时table已经存放了key,value）
	*/
	//stackDump(L);
	return 1;						//返回参数，就是此table
}

/*
//例:将AddNum函数注册到lua,供lua使用
int addNum(int a,int b)
{
return a + b;
}
*/
int addNum(lua_State* L)
{
	//参数顺序和lua那边传入的是反序的 ,可以用正数的顺序，代表正向的第1,2,3个参数
	//int a = (int)luaL_checknumber(L, -1);
	//int b = (int)luaL_checknumber(L, -2);

	int a = (int)luaL_checknumber(L, 1);
	int b = (int)luaL_checknumber(L, 2);
	cout << "one: " << a << "  ,two: " << b << endl;
	//这么写也可以
	//int a = (int)lua_tonumber(L, -1);
	//int b = (int)lua_tonumber(L, -2);
	int sum = a + b;
	lua_pushnumber(L, sum);		//返回值传入栈顶，给lua使用
	return 1;					//一个返回值
}

//有一个返回值
static int l_getName(lua_State* L)
{
	lua_pushstring(L, "haungshucheng");	//返回值传到栈顶
	return 1;							//一个返回值
}

//没有返回值
static int l_show_return_0(lua_State* L)
{
	return 0;
}
//一个返回值
static int l_show_return_1(lua_State* L)
{
	lua_pushstring(L, "I am l_show_return_1");
	return 1;
}

//两个返回值
static int l_show_return_2(lua_State* L)
{
	lua_pushstring(L, "I am l_show_return_2 111");
	lua_pushstring(L, "I am l_show_return_2 222");
	return 2;
}
//返回值是table(lua调用C)
static int l_getTable(lua_State* L)
{
	lua_newtable(L);
	char buf[20] = { 0 };
	for (int i = 1; i <= 10; i++){
		lua_pushnumber(L, i);
		sprintf_s(buf, "num is %d", i);
		lua_pushstring(L, buf);
		lua_settable(L, -3);		//注意一下
	}
	return 1;
}

static int l_map(lua_State* L)
{
	int i, n;
	luaL_checktype(L, 1, LUA_TTABLE);
	luaL_checktype(L, 2, LUA_TUSERDATA);
	n = lua_rawlen(L, 1);
	for (i = 1; i <= n; i++)
	{
		lua_pushvalue(L, 2);
		lua_rawgeti(L, 1, i);
		lua_call(L, 1, i);
		lua_rawseti(L, 1, i);
	}
	return 0;
}
//将Lua第一个参数，根据第二个参数切割，用table形式返回给lua
static int l_split(lua_State* L)
{
	const char* s = luaL_checkstring(L, 1);
	const char* sep = luaL_checkstring(L, 2);
	const char* e;
	int i = 1;

	lua_newtable(L);

	while ((e = strchr(s, *sep)) != NULL)
	{
		lua_pushlstring(L, s, e - s);
		lua_rawseti(L, -2, i++);
		s = e + 1;
	}

	lua_pushstring(L, s);	//把cstr传入了table
	lua_rawseti(L, -2, i);	//把cstr弹出了栈（此时已经进入了table，table[i]=cstr）,再把-2位置的table放到栈顶，供Lua获取

	stackDump(L);
	return 1;
}

/* /////////////////// 自定义c模块/////////////////// */

//创建一个供userdata类型
static int newArray(lua_State* L){
	int n = (int)luaL_checkinteger(L, 1);
	size_t nbytes = sizeof(NumArray) + (n - 1)*sizeof(double);
	NumArray* a = (NumArray*)lua_newuserdata(L, nbytes);
	a->size = n;
	//stackDump(L);
	return 1;
}
//参数和那边是反的，所以用正向顺序,代表第一个，第二个参数
static int setArray(lua_State* L)
{
	cout << "setarray...." << endl;
	NumArray* na = (NumArray*)lua_touserdata(L, 1);
	int index = (int)luaL_checkinteger(L, 2);
	double value = luaL_checknumber(L, 3);
	luaL_argcheck(L, na != NULL, 1, "array expected!");
	luaL_argcheck(L, index >= 1 && index <= na->size, 2, "index out of range!");
	//cout <<"index: " << index << endl;
	na->values[index - 1] = value;
	stackDump(L);
	return 0;
}
//获取size
static int getSize(lua_State* L)
{
	cout << "getSize..." << endl;
	NumArray* na = (NumArray*)lua_touserdata(L, 1);
	luaL_argcheck(L, na != NULL, 1, "array expected!");
	lua_pushnumber(L, na->size);
	stackDump(L);
	return 1;
}
//用下标获取value,有错
static int getArray(lua_State* L)
{
	cout << "getArray...." << endl;
	NumArray* na = (NumArray*)lua_touserdata(L, 1);
	int index = (int)luaL_checkinteger(L, 2);
	luaL_argcheck(L, na != NULL, 1, "array expected!");
	luaL_argcheck(L, index >= 1 && index <= na->size, 2, "index out of range!");
	lua_pushnumber(L, na->values[index - 1]);
	stackDump(L);
	return 1;
}

static int showRes1(lua_State* L)	//一个返回值
{
	lua_pushstring(L, "I am res1");
	return 1;
}

static int showRes2(lua_State* L)//一个参数，一个返回值
{
	char buf[50] = { 0 };
	const char* val = luaL_checkstring(L, -1);
	sprintf_s(buf, "res2--->%s", val);
	lua_pushstring(L, buf);
	return 1;
}
//mylib c模块数组
static const struct luaL_Reg lua_my_lib[] = {
	{ "l_showRes1", showRes1 },
	{ "l_showRes2", showRes2 },
	{ NULL, NULL }
};
//myarray c模块数组
static const struct luaL_Reg lua_my_array[] = {
	{ "new", newArray },
	{ "set", setArray },
	{ "size", getSize },
	{ "get", getArray },
	{ NULL, NULL }
};
//array lib
int luaopen_array_lib(lua_State*L)
{
	luaL_newlib(L, lua_my_array);
	return 1;
}
//mylib
int luaopen_hcc_lib(lua_State*L)
{
	luaL_newlib(L, lua_my_lib);
	return 1;
}
//写入模块名称
static const struct luaL_Reg myLoadLibs[] = {
	{ "hcclib", luaopen_hcc_lib },
	{ "array", luaopen_array_lib },
	{ NULL, NULL }
};
/* /////////////////// 自定义c模块/////////////////// */

//将c函数注册到lua
void LuaEngine::register_my_functions()
{
	lua_register(m_state, "getName", l_getName);
	lua_register(m_state, "showZero", l_show_return_0);
	lua_register(m_state, "showOne", l_show_return_1);
	lua_register(m_state, "showTwo", l_show_return_2);
	lua_register(m_state, "getTable", l_getTable);
	lua_register(m_state, "addNum", addNum);
	lua_register(m_state, "mapFunc", l_map);
	lua_register(m_state, "getCtb", getCTable);
	lua_register(m_state, "l_split", l_split);
	lua_register(m_state, "newArray", newArray);
	//也可以这么写
	//lua_pushcfunction(m_state, addNum);
	//lua_setglobal(m_state, "addNum");
}
//注册自己的C模块
void LuaEngine::register_my_libs(){
	const luaL_Reg* lua_reg = myLoadLibs;
	for (; lua_reg->func; ++lua_reg){
		luaL_requiref(m_state, lua_reg->name, lua_reg->func, 1);
		lua_pop(m_state, 1);
	}
}
//C调用lua
void LuaEngine::testCallLua()
{
	lua_State* L = m_state;
	lua_settop(L, 0);
	/*
	//读取变量
	lua_getglobal(L, "name");   //string to be indexed
	std::cout << "name = " << lua_tostring(L, -1) << std::endl;

	//读取数字
	lua_getglobal(L, "version"); //number to be indexed
	std::cout << "version = " << lua_tonumber(L, -1) << std::endl;
	*/
	//读取表
	/*
	lua_getglobal(L, "me");  //table to be indexed
	if (!lua_istable(L, -1))
	{
	std::cout << "error:it is not a table" << std::endl;
	}

	//取表中元素
	lua_getfield(L, -1, "name");
	std::cout << "student name = " << lua_tostring(L, -1) << std::endl;
	lua_getfield(L, -2, "gender");
	std::cout << "student gender = " << lua_tostring(L, -1) << std::endl;
	stackDump(L);
	*/
	//修改表中元素
	/*lua_pushstring(L, "007");
	lua_setfield(L, -4, "name");
	lua_getfield(L, -3, "name");
	std::cout << "student newName = " << lua_tostring(L, -1) << std::endl;*/

	//取函数
	//lua_getglobal(L, "add");
	//lua_pushnumber(L, 15);
	//lua_pushnumber(L, 5);
	//lua_pcall(L, 2, 1, 0);//2-参数个数，1-返回值个数，//lua_pcall:调用函数，函数执行完，会将返回值压入栈顶
	//lua_pop(L,1);
	//std::cout << "5 + 15 = " << lua_tonumber(L, -1) << std::endl;

	//查看栈
	//stackDump(L);

	//stackDump(L);
	//lua_getglobal(L, "me"); //<= = push mytable
	/*
	lua_pushstring(L, "name"); //<= = push value 1 将name key入栈
	lua_gettable(L, -2); // <= = pop key name, push mytable[1]  讲键name出栈，将值弹到栈顶，方便获取
	*/
	/*
	lua_getfield(L, -1, "name"); //<= = push mytable["x"]，作用同上面两行调用
	std::cout << "student newName = " << lua_tostring(L, -1) << std::endl;
	lua_getfield(L, -2, "gender"); //<= = push mytable["x"]
	std::cout << "student gender = " << lua_tostring(L, -1) << std::endl;
	*/
	/*
	lua_getglobal(L, "mytb"); //<= = push mytable
	lua_rawgeti(L, -1, 1); //<= = push mytable[1]，作用同下面两行调用
	//lua_pushnumber(L, 1) <= = push key 1
	//lua_rawget(L, -2) <= = pop key 1, push mytable[1]
	std::cout << "student gender = " << lua_tostring(L, -1) << std::endl;
	*/
	/*
	lua_getglobal(L, "mytb"); //<= = push mytable
	lua_pushnumber(L, 1); //<= = push key 1
	lua_pushstring(L, "abc"); //<= = push value "abc"
	lua_settable(L, -3); //<= = mytable[1] = "abc", pop key & value
	*/
	/*
	lua_getglobal(L, "mytb"); //<= = push mytable
	lua_pushstring(L, "abc"); //<= = push value "abc"
	lua_rawseti(L, -2, 1); //<= = mytable[1] = "abc", pop value "abc"  ,set table to top
	std::cout << "stack top: " << lua_rawlen(L, -1) << std::endl;
	*/
	stackDump(L);
}
