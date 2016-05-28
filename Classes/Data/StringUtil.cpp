#include "StringUtil.h"

StringUtil::StringUtil()
{
}

StringUtil::~StringUtil()
{
}

StringUtil* StringUtil::instance = nullptr;

StringUtil*StringUtil::getInstance(){
	if (instance == nullptr)
	{
		instance = new StringUtil();
		if (instance && instance->init())
		{
			instance->autorelease();
			instance->retain();
		}
		else
		{
			CC_SAFE_DELETE(instance);
			instance = nullptr;
		}
	}
	return instance;
}
bool StringUtil::init(){

	return true;
}

/*
srcStr:字符串
sSep:分隔符
作用：将字符串 用分隔符分割成一个个Value对象 放到ValueVector中
*/
ValueVector StringUtil::split(const char* srcStr, const char* sSep){
	ValueVector stringList;
	int size = strlen(srcStr);
	Value str = Value(srcStr);
	int startIndex = 0;
	int endIndex = 0;
	endIndex = str.asString().find(sSep);
	std::string lineStr;
	while (endIndex > 0 )
	{
		lineStr = str.asString().substr(startIndex,endIndex);//截取一行字符串
		stringList.push_back(Value(lineStr));				//添加到列表

		str = Value(str.asString().substr(endIndex + 1,size));//截取剩下的字符串
		endIndex = str.asString().find(sSep);					//
	}

	//剩下的字符串也添加到列表
	if (str.asString().compare("")!= 0)
	{
		stringList.push_back(Value(str.asString()));
	}
	return stringList;
}

/*-------------------------------CsvData类----------------------------------------------------*/

CsvData::CsvData()
{
}

CsvData::~CsvData()
{
}
bool CsvData::init(){
	return true;

}
//添加一行的数据
void CsvData::addLineData(ValueVector lineData){

	m_allLinesVec.push_back(Value(lineData));
	m_iColNum = lineData.size();

}	
//获取某行的数据
ValueVector CsvData::getStringLineData(int iLine){
	return m_allLinesVec.at(iLine).asValueVector();

}	
//获取行列的大小
Size CsvData::getRowColNum(){
	Size size = Size();
	size.width = m_allLinesVec.size();
	if (size.width > 0)
	{
		size.height = m_allLinesVec.at(0).asValueVector().size();
	}
	return size;

}					