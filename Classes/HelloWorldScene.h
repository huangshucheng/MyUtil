#pragma once

#include "cocos2d.h"
#include "UIEffect/RunNumLabel.h"
#include "UIEffect/AttackRunNumLabel.h"
#include "Layer/ToastLayer/ToastManger.h"

USING_NS_CC;

class HelloWorld : public cocos2d::Layer
{
public:
	HelloWorld();
	~HelloWorld();

    static cocos2d::Scene* createScene();
    virtual bool init();

    void menuCloseCallback(cocos2d::Ref* pSender);

	CREATE_FUNC(HelloWorld);

public:
	NodeGrid* nodegrid;
	RunNumLabel* runNumber;
	AttackRunNumLabel* runNumber_1;
};

