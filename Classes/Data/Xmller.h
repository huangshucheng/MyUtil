#pragma once

#include <iostream>
#include "cocos2d.h"

#include "tinyxml2/tinyxml2.h"

using namespace cocos2d;

using namespace tinyxml2;
using namespace std;

class  Xmller
{
public:
    void createwithxmlfile(std::string xmlfile);
    //解析
    void XmlParse(std::string xmlfile);
    //修改节点
    void changeName(std::string name);
    void changeNumber(std::string number);
    void changeLock(std::string lock);
    
    std:: string getName();
    std:: string getNumber();
    std:: string getLock();
    
private:
	//拷贝到沙盒
	void copyFileToPath(std::string xmlfile);

	//生成xml文档
	void giveBirthTo(std::string xmlfile);

private:
    
    std::string name;
    std::string num;
    std::string lock;
    
    std::string wpath;
    
    XMLElement *parentelement;
	tinyxml2::XMLDocument *myDocument;
    
    XMLNode *nameNode;
    XMLNode *numberNode;
    XMLNode *lockNode;
};
