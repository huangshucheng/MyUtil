#include "DownTopLayer.h"

bool DownTopLayer::init()
{
	return BaseLayer::init();
}

void DownTopLayer::onEnter()
{
	BaseLayer::onEnter();

	// 弹出动画
	Size winSize = CCDirector::getInstance()->getVisibleSize();

	m_popNode->setPosition(Vec2(0, -winSize.height));
	m_popNode->runAction(CCSequence::create(EaseBackOut::create(MoveTo::create(0.2, Vec2::UNIT_Y)),
		CCCallFunc::create(this, callfunc_selector(DownTopLayer::onEnterAnimComplete)), nullptr));
}

void DownTopLayer::close()
{
	Size winSize = CCDirector::getInstance()->getVisibleSize();

	m_popNode->runAction(CCSequence::create(EaseBackIn::create(MoveTo::create(0.2, Vec2(0, -winSize.height))),
		CCCallFunc::create(this, callfunc_selector(DownTopLayer::onExitAnimComplete)), nullptr));
}

void DownTopLayer::onEnterAnimComplete()
{

}

void DownTopLayer::onExitAnimComplete()
{
	BaseLayer::close();
}