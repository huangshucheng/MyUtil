﻿#include "HelloWorldScene.h"
#include "Shader/EasyEffect.h"
#include "Utils/CommonFunction.h"
#include "Shader/Water.h"

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

	/*runNumber_1 = AttackRunNumLabel::create("0",1.0f,100,TextHAlignment::LEFT);
	runNumber_1->setAnchorPoint(Vec2(0, 0.5));
	runNumber_1->setPosition(CommonFunction::getVisibleAchor(0.5, 0.5, Vec2(0, 0)));
	addChild(runNumber_1);*/

	//Water test
	auto water = Water::create("shader3D/water.png", "shader3D/wave1.jpg", "shader3D/wave1.jpg", Size(512, 512), 10.f, 10.f, 10.f);
	addChild(water);
	water->setPosition(Vec2(visibleSize.width / 2, visibleSize.height / 2));
    return true;
}

void HelloWorld::menuCloseCallback(Ref* pSender)
{

	/*ShaderNode* shader = ShaderNode::shaderNodeWithVertex("shader.vsh", "shader.fsh");
	if (shader)
	{
		log("shader is exit");
		shader->setContentSize(Size(1136,640));
		shader->setColor(Color4F(1.0, 1.0, 0, 0.5));
		this->addChild(shader, 100);
	}*/


	//auto layer = LayerTest::create(this);
	//addChild(layer, 10);
	ToastManger::getInstance()->createToast(CommonFunction::WStrToUTF8(L"黄塾城"));
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif

}

void HelloWorld::sureclick()	//实现虚方法
{
	std::cout << "我在helloworld层上哟" << std::endl;
}