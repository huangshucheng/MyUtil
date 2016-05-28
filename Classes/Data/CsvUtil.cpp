#include "CsvUtil.h"

CsvUtil* CsvUtil::instance = nullptr;
CsvUtil::CsvUtil()
{

}

CsvUtil::~CsvUtil()
{

}

CsvUtil* CsvUtil::getInstance()
{
	if (instance == nullptr)
	{
		if (instance&& instance->init())
		{
			instance->autorelease();
			instance->retain();
		}
		else{
			CC_SAFE_DELETE(instance);
			instance = nullptr;
		}

		instance = new CsvUtil();
	}
	return instance;
}

bool CsvUtil::init()
{
	return true;
}
//加载配置文件
void CsvUtil::loadFile(const char* sPath){
	//存放一个Csv文件的对象
	CsvData* csvData = CsvData::create();
	std::string str = FileUtils::getInstance()->getStringFromFile(sPath);//读取数据 保存到列表中
	ValueVector linesList = StringUtil::getInstance()->split(str.c_str(),"\n");	//按每行分割
	for (auto value: linesList)
	{
		ValueVector tArr = StringUtil::getInstance()->split(value.asString().c_str(),",");//每行的字符串按逗号分隔 放到列表中
										
		csvData->addLineData(tArr);	//放到csvDat对象中
	}
	mCscMap.insert(sPath,csvData);//添加列表到字典
}
//获取某行某列的值
Value CsvUtil::getValue(int iRow, int iCol, const char* csvFilePath){
	auto csvData = mCscMap.at(csvFilePath);
	if (csvData == nullptr)
	{
		loadFile(csvFilePath);
		csvData = mCscMap.at(csvFilePath);
	}

	ValueVector rowVector = csvData->getStringLineData(iRow);

	Value colValue = rowVector.at(iCol);
	return colValue;
}
//获取值并转化为字符串
const std::string CsvUtil::getString(int iRow, int iCol, const char* csvFilePath){
	Value colValue = getValue(iRow, iCol, csvFilePath);
	return colValue.asString();
}
//获取值并转化为整型
const int CsvUtil::getInt(int iRow, int iCol, const char* csvFilePath){
	Value colValue = getValue(iRow, iCol, csvFilePath);
	return colValue.asInt();
}

const float CsvUtil::getFloat(int iRow, int iCol, const char* csvFilePath){
	Value colValue = getValue(iRow, iCol, csvFilePath);
	return colValue.asFloat();

}

const bool CsvUtil::getBool(int iRow, int iCol, const char* csvFilePath){
	Value colValue = getValue(iRow, iCol, csvFilePath);
	return colValue.asBool();
}
//获取文件的行和列数量
const Size CsvUtil::getFileRowColNum(const char* csvFilePath){
	auto csvData = mCscMap.at(csvFilePath);
	if (csvData == nullptr)	//文件不存在 重新加载
	{
		loadFile(csvFilePath);
		csvData = mCscMap.at(csvFilePath);
	}
	Size size = csvData->getRowColNum();
	return size;
}				
//获取某个列的值 查找该值所在的行
const int CsvUtil::findValueInWithLine(const char* chValue, int iValueCol, const char* csvFilePath){

	return 0;
}