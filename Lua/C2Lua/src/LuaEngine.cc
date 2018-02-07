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
	//��ȡ����·��
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
//��ӡջ��Ϣ
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
	luaL_openlibs(m_state);								//�����ӿ�
	register_my_functions();
	register_my_libs();
	int fret = luaL_dofile(m_state, lua_file_path);		//ִ�нű�
	if (fret){
		std::cout << "read lua file error!" << std::endl;
		lua_pop(m_state, 1);
		return false;
	}
	return true;
}
//����table��lua
int getCTable(lua_State* L)
{
	lua_newtable(L);	//����table,�ŵ�ջ��
	char buf[10] = { 0 };

	for (int i = 1; i <= 10; i++){
		lua_pushnumber(L, i);
		sprintf_s(buf, "v-%d", i);
		lua_pushstring(L, buf);
		lua_settable(L, -3);
	}
	/*
	//��key,value�ֱ���ջ���ٽ�����k,v��table�ŵ�ջ������lua��ȡ
	lua_pushnumber(L, 0);		//����key ��table
	lua_pushstring(L, "v1");	//����value ��table
	lua_settable(L, -3);		//����key,value���ٽ�-3λ�õ�table�ŵ�ջ������ʱtable�Ѿ������key,value��
	*/
	//stackDump(L);
	return 1;						//���ز��������Ǵ�table
}

/*
//��:��AddNum����ע�ᵽlua,��luaʹ��
int addNum(int a,int b)
{
return a + b;
}
*/
int addNum(lua_State* L)
{
	//����˳���lua�Ǳߴ�����Ƿ���� ,������������˳�򣬴�������ĵ�1,2,3������
	//int a = (int)luaL_checknumber(L, -1);
	//int b = (int)luaL_checknumber(L, -2);

	int a = (int)luaL_checknumber(L, 1);
	int b = (int)luaL_checknumber(L, 2);
	cout << "one: " << a << "  ,two: " << b << endl;
	//��ôдҲ����
	//int a = (int)lua_tonumber(L, -1);
	//int b = (int)lua_tonumber(L, -2);
	int sum = a + b;
	lua_pushnumber(L, sum);		//����ֵ����ջ������luaʹ��
	return 1;					//һ������ֵ
}

//��һ������ֵ
static int l_getName(lua_State* L)
{
	lua_pushstring(L, "haungshucheng");	//����ֵ����ջ��
	return 1;							//һ������ֵ
}

//û�з���ֵ
static int l_show_return_0(lua_State* L)
{
	return 0;
}
//һ������ֵ
static int l_show_return_1(lua_State* L)
{
	lua_pushstring(L, "I am l_show_return_1");
	return 1;
}

//��������ֵ
static int l_show_return_2(lua_State* L)
{
	lua_pushstring(L, "I am l_show_return_2 111");
	lua_pushstring(L, "I am l_show_return_2 222");
	return 2;
}
//����ֵ��table(lua����C)
static int l_getTable(lua_State* L)
{
	lua_newtable(L);
	char buf[20] = { 0 };
	for (int i = 1; i <= 10; i++){
		lua_pushnumber(L, i);
		sprintf_s(buf, "num is %d", i);
		lua_pushstring(L, buf);
		lua_settable(L, -3);		//ע��һ��
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
//��Lua��һ�����������ݵڶ��������и��table��ʽ���ظ�lua
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

	lua_pushstring(L, s);	//��cstr������table
	lua_rawseti(L, -2, i);	//��cstr������ջ����ʱ�Ѿ�������table��table[i]=cstr��,�ٰ�-2λ�õ�table�ŵ�ջ������Lua��ȡ

	stackDump(L);
	return 1;
}

/* /////////////////// �Զ���cģ��/////////////////// */

//����һ����userdata����
static int newArray(lua_State* L){
	int n = (int)luaL_checkinteger(L, 1);
	size_t nbytes = sizeof(NumArray) + (n - 1)*sizeof(double);
	NumArray* a = (NumArray*)lua_newuserdata(L, nbytes);
	a->size = n;
	//stackDump(L);
	return 1;
}
//�������Ǳ��Ƿ��ģ�����������˳��,�����һ�����ڶ�������
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
//��ȡsize
static int getSize(lua_State* L)
{
	cout << "getSize..." << endl;
	NumArray* na = (NumArray*)lua_touserdata(L, 1);
	luaL_argcheck(L, na != NULL, 1, "array expected!");
	lua_pushnumber(L, na->size);
	stackDump(L);
	return 1;
}
//���±��ȡvalue,�д�
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

static int showRes1(lua_State* L)	//һ������ֵ
{
	lua_pushstring(L, "I am res1");
	return 1;
}

static int showRes2(lua_State* L)//һ��������һ������ֵ
{
	char buf[50] = { 0 };
	const char* val = luaL_checkstring(L, -1);
	sprintf_s(buf, "res2--->%s", val);
	lua_pushstring(L, buf);
	return 1;
}
//mylib cģ������
static const struct luaL_Reg lua_my_lib[] = {
	{ "l_showRes1", showRes1 },
	{ "l_showRes2", showRes2 },
	{ NULL, NULL }
};
//myarray cģ������
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
//д��ģ������
static const struct luaL_Reg myLoadLibs[] = {
	{ "hcclib", luaopen_hcc_lib },
	{ "array", luaopen_array_lib },
	{ NULL, NULL }
};
/* /////////////////// �Զ���cģ��/////////////////// */

//��c����ע�ᵽlua
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
	//Ҳ������ôд
	//lua_pushcfunction(m_state, addNum);
	//lua_setglobal(m_state, "addNum");
}
//ע���Լ���Cģ��
void LuaEngine::register_my_libs(){
	const luaL_Reg* lua_reg = myLoadLibs;
	for (; lua_reg->func; ++lua_reg){
		luaL_requiref(m_state, lua_reg->name, lua_reg->func, 1);
		lua_pop(m_state, 1);
	}
}
//C����lua
void LuaEngine::testCallLua()
{
	lua_State* L = m_state;
	lua_settop(L, 0);
	/*
	//��ȡ����
	lua_getglobal(L, "name");   //string to be indexed
	std::cout << "name = " << lua_tostring(L, -1) << std::endl;

	//��ȡ����
	lua_getglobal(L, "version"); //number to be indexed
	std::cout << "version = " << lua_tonumber(L, -1) << std::endl;
	*/
	//��ȡ��
	/*
	lua_getglobal(L, "me");  //table to be indexed
	if (!lua_istable(L, -1))
	{
	std::cout << "error:it is not a table" << std::endl;
	}

	//ȡ����Ԫ��
	lua_getfield(L, -1, "name");
	std::cout << "student name = " << lua_tostring(L, -1) << std::endl;
	lua_getfield(L, -2, "gender");
	std::cout << "student gender = " << lua_tostring(L, -1) << std::endl;
	stackDump(L);
	*/
	//�޸ı���Ԫ��
	/*lua_pushstring(L, "007");
	lua_setfield(L, -4, "name");
	lua_getfield(L, -3, "name");
	std::cout << "student newName = " << lua_tostring(L, -1) << std::endl;*/

	//ȡ����
	//lua_getglobal(L, "add");
	//lua_pushnumber(L, 15);
	//lua_pushnumber(L, 5);
	//lua_pcall(L, 2, 1, 0);//2-����������1-����ֵ������//lua_pcall:���ú���������ִ���꣬�Ὣ����ֵѹ��ջ��
	//lua_pop(L,1);
	//std::cout << "5 + 15 = " << lua_tonumber(L, -1) << std::endl;

	//�鿴ջ
	//stackDump(L);

	//stackDump(L);
	//lua_getglobal(L, "me"); //<= = push mytable
	/*
	lua_pushstring(L, "name"); //<= = push value 1 ��name key��ջ
	lua_gettable(L, -2); // <= = pop key name, push mytable[1]  ����name��ջ����ֵ����ջ���������ȡ
	*/
	/*
	lua_getfield(L, -1, "name"); //<= = push mytable["x"]������ͬ�������е���
	std::cout << "student newName = " << lua_tostring(L, -1) << std::endl;
	lua_getfield(L, -2, "gender"); //<= = push mytable["x"]
	std::cout << "student gender = " << lua_tostring(L, -1) << std::endl;
	*/
	/*
	lua_getglobal(L, "mytb"); //<= = push mytable
	lua_rawgeti(L, -1, 1); //<= = push mytable[1]������ͬ�������е���
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
