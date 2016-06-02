#include "LayerTest.h"
#include "Utils/CommonFunction.h"

bool LayerTest::init()
{
	if (!Pop::init())
	{
		return false;
	}

	auto sp = Sprite::create("supercell.png");
	sp->setScale(0.7f);
	sp->setTag(99);
	m_popNode->addChild(sp);

	return true;
}