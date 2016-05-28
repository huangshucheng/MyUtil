#include "PopLayer.h"

bool PopLayer::init()
{
	return BaseLayer::init();
}

void PopLayer::onEnter()
{
	BaseLayer::onEnter();

	// 弹出动画
	m_popNode->setScale(0.01);
	m_popNode->runAction(CCSequence::create(CCEaseElasticOut::create(ScaleTo::create(0.7, 1.0f)),
		CCCallFunc::create(this, callfunc_selector(PopLayer::onEnterAnimComplete)), nullptr));
}

void PopLayer::close()
{
	m_popNode->runAction(CCSequence::create(ScaleTo::create(0.1, 0.01f),
		CCCallFunc::create(this, callfunc_selector(PopLayer::onExitAnimComplete)),
		nullptr));
}

void PopLayer::onEnterAnimComplete()
{

}

void PopLayer::onExitAnimComplete()
{
	BaseLayer::close();
}
