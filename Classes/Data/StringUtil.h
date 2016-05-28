#pragma once
#include "cocos2d.h"

USING_NS_CC;

class StringUtil:public Ref
{


public:
   static StringUtil* getInstance();
   virtual bool init();
   /*
   用分隔符分割 字符串，结果放到一个列表中，列表中的对象为Value
   */
   ValueVector split(const char* srcStr,const char* sSep);	

private:
	static StringUtil* instance;
	StringUtil();
	~StringUtil();
};

/*-------------------------------CsvData类----------------------------------------------*/

class CsvData:public Ref
{
public:

	CsvData();
	~CsvData();
public:
	CREATE_FUNC(CsvData);
	virtual bool init();
	void addLineData(ValueVector lineData);		//添加一行的数据
	ValueVector getStringLineData(int iLine);	//获取某行的数据
	Size getRowColNum();						//获取行列的大小
private:
	ValueVector m_allLinesVec;
	int m_iColNum;
};

