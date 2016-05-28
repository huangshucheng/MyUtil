#include "Xmller.h"
/*
void Xmller::copyFileToPath(std::string xmlfile)
{
    FileUtils *fu=FileUtils::getInstance();
    std::string wrpath=fu->getWritablePath();
    log("沙盒路径==%s",wrpath.c_str());
    wrpath+=xmlfile;
    
    if(!fu->isFileExist(wrpath))
    {
        std::string dataPath = fu->fullPathForFilename(xmlfile.c_str());//获取App里面的路径
        std::string pFileContent = fu->getStringFromFile(dataPath);
        
        FILE *file=fopen(wrpath.c_str(), "w");
        
        if(file)
        {
            fputs(pFileContent.c_str(),file);
            fclose(file);
        }
    }
}
*/

//xml解析
void Xmller:: XmlParse(std::string xmlfile)
{
    
    FileUtils *fe=FileUtils::getInstance();
    wpath=fe->getWritablePath();
    wpath+=xmlfile;
    
	myDocument = new tinyxml2::XMLDocument();
    XMLError errorID=myDocument->LoadFile(wpath.c_str());

    if (errorID != 0) 
	{
        log("解析错误!");
        return;
    }

    XMLElement * rootelement=myDocument->RootElement();
    
    while(!rootelement->GetText())
    {
        parentelement=rootelement;
        
        rootelement=rootelement->FirstChildElement();
    }

    int index=0;
    
    do
    {
        if(index++)
        parentelement=parentelement->NextSiblingElement();
        
        rootelement=parentelement->FirstChildElement();
        
        name=rootelement->GetText();////
        nameNode = rootelement->FirstChild();
        
        rootelement=rootelement->NextSiblingElement();
        
            num=rootelement->GetText();////
        numberNode = rootelement->FirstChild();
        
        rootelement=rootelement->NextSiblingElement();
        
         lock=rootelement->GetText();////
         lockNode = rootelement->FirstChild();
        
        // int  number=atoi(num.c_str());    //类型转换
        // int  locked=atoi(lock.c_str());
        
//        vec.push_back(name);   //存到容器里面
//        vec.push_back(num);
//        vec.push_back(lock);
        
    }while (parentelement->NextSiblingElement());
    log("解析文件成功");
}

void Xmller:: createwithxmlfile(std::string xmlfile)
{

   // copyFileToPath(xmlfile);    //拷贝xml文件到沙盒
    XmlParse(xmlfile);          //解析xml文件
}

//修改节点
void Xmller:: changeName(std::string name)
{

    nameNode->SetValue(name.c_str());
    myDocument->SaveFile(wpath.c_str());
}

void Xmller:: changeNumber(std::string number)
{
    numberNode->SetValue(number.c_str());
    myDocument->SaveFile(wpath.c_str());

}

void Xmller:: changeLock(std::string lock){

    lockNode->SetValue(lock.c_str());
    myDocument->SaveFile(wpath.c_str());
}

std:: string Xmller:: getName()
{
    
    return name;
}

std:: string Xmller:: getNumber()
{
    return num;
}

std:: string Xmller:: getLock()
{
    return lock;
}
//生成文件
void Xmller:: giveBirthTo(std::string xmlfile)
{

    std::string filePath = FileUtils::getInstance()->getWritablePath() + xmlfile;
    log("生成文件＝%s",filePath.c_str());
	tinyxml2::XMLDocument *pDoc = new tinyxml2::XMLDocument();
    
    //xml 声明（参数可选）
    XMLDeclaration *pDel = pDoc->NewDeclaration("xml version=\"1.0\" encoding=\"UTF-8\"");
    
    pDoc->LinkEndChild(pDel);
    
    //添加plist节点
    XMLElement *plistElement = pDoc->NewElement("Chapters");
//    plistElement->SetAttribute("version", "1.0");
    pDoc->LinkEndChild(plistElement);
    
//    XMLComment *commentElement = pDoc->NewComment("this is xml comment");
//    plistElement->LinkEndChild(commentElement);
    
    //添加dic节点
//    XMLElement *dicElement = pDoc->NewElement("dic");
//    plistElement->LinkEndChild(dicElement);
    
    //添加key节点
//    XMLElement *keyElement = pDoc->NewElement("key");
//    keyElement->LinkEndChild(pDoc->NewText("Text"));
//    dicElement->LinkEndChild(keyElement);
    
    XMLElement *arrayElement = pDoc->NewElement("Chapter");
    plistElement->LinkEndChild(arrayElement);
    
//    for (int i = 0; i<3; i++) {
//        XMLElement *elm = pDoc->NewElement("name");
//        elm->LinkEndChild(pDoc->NewText("Cocos2d-x"));
//        arrayElement->LinkEndChild(elm);
//    }
    
    XMLElement* elm = pDoc->NewElement("name");
     elm->LinkEndChild(pDoc->NewText("zhangsan"));
     arrayElement->LinkEndChild(elm);
    
    XMLElement* elm1 = pDoc->NewElement("number");
    elm1->LinkEndChild(pDoc->NewText("123"));
    arrayElement->LinkEndChild(elm1);
    
    XMLElement* elm2 = pDoc->NewElement("lock");
    elm2->LinkEndChild(pDoc->NewText("0"));
    arrayElement->LinkEndChild(elm2);
    
    pDoc->SaveFile(filePath.c_str());
    pDoc->Print();
    
    delete pDoc;
}




