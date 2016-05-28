#include "TopDownLayer.h"

bool TopDownLayer::init()
{
	return BaseLayer::init();
}

void TopDownLayer::onEnter()
{
	BaseLayer::onEnter();

	// 弹出动画
	Size winSize = CCDirector::getInstance()->getVisibleSize();

	m_popNode->setPosition(Vec2(0, winSize.height));
	m_popNode->runAction(CCSequence::create(EaseBackOut::create(MoveTo::create(0.5, Vec2::ZERO)),
		CCCallFunc::create(this, callfunc_selector(TopDownLayer::onEnterAnimComplete)), nullptr));
}

void TopDownLayer::close()
{
	Size winSize = CCDirector::getInstance()->getVisibleSize();

	m_popNode->runAction(CCSequence::create(EaseBackIn::create(MoveTo::create(0.2, Vec2(0, winSize.height))),
		CCCallFunc::create(this, callfunc_selector(TopDownLayer::onExitAnimComplete)), nullptr));
}

void TopDownLayer::onEnterAnimComplete()
{

}

void TopDownLayer::onExitAnimComplete()
{
	BaseLayer::close();
}