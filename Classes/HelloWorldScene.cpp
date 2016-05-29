#include "HelloWorldScene.h"
#include "Shader/EasyEffect.h"
#include "Utils/CommonFunction.h"

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

	//auto layerColor = LayerColor::create(Color4B::GRAY);
	//layerColor->setTag(99);
	//scene->addChild(layerColor);

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

	Sprite* _sp = Sprite::create("HelloWorld.png");
	_sp->setPosition(CommonFunction::getVisibleAchor(Anchor::Center,Vec2(0,0)));

	nodegrid = NodeGrid::create(); //3D效果放在NodeGrid才能显示
	nodegrid->addChild(_sp);
	this->addChild(nodegrid);

	//run Shaky3D action
    return true;
}

void HelloWorld::menuCloseCallback(Ref* pSender)
{
    //Director::getInstance()->end();
	//auto shaky3D = Shaky3D::create(5, CCSize(10, 10), 15, false);

	if (nodegrid)
	{
		//nodegrid->runAction(EasyEffect::getAction(3, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(4, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(5, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(6, 3.0));			//抖动效果1
		//nodegrid->runAction(EasyEffect::getAction(7, 3.0));				//抖动效果2
		//nodegrid->runAction(EasyEffect::getAction(8, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(9, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(10, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(11, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(12, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(13, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(14, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(15, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(16, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(17, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(18, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(19, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(20, 3.0));
		//nodegrid->runAction(EasyEffect::getAction(21, 3.0));  //翻书效果
		//nodegrid->runAction(EasyEffect::getAction(31, 6.0));
		//nodegrid->runAction(EasyEffect::getAction(32, 6.0));

		//CommonFunction::runShakeAction(nodegrid, ShakeMode::SlightNormal);
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif

}

