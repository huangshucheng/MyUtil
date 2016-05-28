#pragma once

#include "cocos2d.h"
#include "StringUtil.h"

USING_NS_CC;
using namespace std;

class CsvUtil:public Ref
{
public:
	static CsvUtil* getInstance();
	virtual bool init();
	void loadFile(const char* sPath);							//加载配置文件
	const Size getFileRowColNum(const char* csvFilePath);				//获取文件的行和列数量
	//获取某个列的值 查找该值所在的行
	const int findValueInWithLine(const char* chValue,int iValueCol,const char* csvFilePath);

public:
	Value getValue(int iRow, int iCol, const char* csvFilePath);	//获取某行某列的值
	const std::string getString(int iRow, int iCol, const char* csvFilePath);	//获取值并转化为字符串
	const int getInt(int iRow, int iCol, const char* csvFilePath);		//获取值并转化为整型
	const float getFloat(int iRow, int iCol, const char* csvFilePath);
	const bool getBool(int iRow, int iCol, const char* csvFilePath);
private:
	static CsvUtil* instance;
	Map<std::string, CsvData*>mCscMap;	//存放mCsvStrList-filePath的字典

private:
	CsvUtil();
	~CsvUtil();
};

