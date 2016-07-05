#include "EasePop.h"

bool EasePop::init()
{
	return Base::init();
}

void EasePop::onEnter()
{
	Base::onEnter();

	m_popNode->setOpacity(100);
	m_popNode->setScale(0.75);

	auto scaleTo = ScaleTo::create(0.5f, 1.0f);
	auto ease = EaseExponentialOut::create(scaleTo);
	auto fadeTo = FadeTo::create(0.1f, 255);
	auto spawn = Spawn::create(ease, fadeTo, nullptr);

	m_popNode->runAction(spawn);
}

void EasePop::close()
{
	auto scaleTo_1 = ScaleTo::create(0.1f, 1.05f);
	auto ease = EaseSineIn::create(scaleTo_1);
	auto fadeTo = FadeTo::create(0.1f, 0);
	auto callFunc = CallFunc::create(this, callfunc_selector(EasePop::onExitAnimComplete));

	auto spawn = Spawn::create(fadeTo, callFunc, nullptr);
	auto seq = Sequence::create(ease, spawn, nullptr);

	m_popNode->runAction(seq);
}

void EasePop::onEnterAnimComplete()
{

}

void EasePop::onExitAnimComplete()
{
	Base::close();
}