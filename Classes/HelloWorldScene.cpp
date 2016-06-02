#include "HelloWorldScene.h"
#include "Shader/EasyEffect.h"
#include "Utils/CommonFunction.h"
#include "LayerTest.h"

HelloWorld::HelloWorld()
{

}
HelloWorld::~HelloWorld()
{

}

Scene* HelloWorld::createScene()
{
    auto scene = Scene::create();
    auto layer = HelloWorld::create();
    scene->addChild(layer);
    return scene;
}

bool HelloWorld::init()
{
    if ( !Layer::init() )
    {
        return false;
    }

    auto visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();

    auto closeItem = MenuItemImage::create(
                                           "CloseNormal.png",
                                           "CloseSelected.png",
                                           CC_CALLBACK_1(HelloWorld::menuCloseCallback, this));
    
	closeItem->setPosition(Vec2(origin.x + visibleSize.width - closeItem->getContentSize().width/2 ,
                                origin.y + closeItem->getContentSize().height/2));

    auto menu = Menu::create(closeItem, NULL);
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);

	//------------------------------------------//

	Sprite* _sp = Sprite::create("tollgateBG.png");
	_sp->setScale(2.0f);
	_sp->setPosition(CommonFunction::getVisibleAchor(Anchor::Center,Vec2(0,0)));

	nodegrid = NodeGrid::create(); //3D效果放在NodeGrid才能显示
	nodegrid->addChild(_sp);
	this->addChild(nodegrid);

	/*runNumber = RunNumLabel::create(CommonFunction::getString(0), "fonts/fnt/huangshe.fnt", 0.5f, 0, TextHAlignment::LEFT, Vec2::ZERO);
	runNumber->setAnchorPoint(Vec2(0, 0.5));
	runNumber->setPosition(CommonFunction::getVisibleAchor(0, 1, Vec2(390, -85)));
	addChild(runNumber);*/

	runNumber_1 = AttackRunNumLabel::create("0",1.0f,100,TextHAlignment::LEFT);
	runNumber_1->setAnchorPoint(Vec2(0, 0.5));
	runNumber_1->setPosition(CommonFunction::getVisibleAchor(0.5, 0.5, Vec2(0, 0)));
	addChild(runNumber_1);
    return true;
}

void HelloWorld::menuCloseCallback(Ref* pSender)
{
	//addChild(LayerTest::create(),10);
	static int index = 0;
	index += 10;
	runNumber_1->setString(Value(index).asString());

	ToastManger::getInstance()->createToast(CommonFunction::WStrToUTF8(L"黄塾城"));
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif

}

