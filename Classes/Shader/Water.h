#pragma  once

#include "cocos2d.h"

USING_NS_CC;

NS_CC_BEGIN

class Water : public cocos2d::Sprite
{
public:
	static Water * create(const std::string& fileName, const std::string& waveFileOne, const std::string& waveFileTwo, const cocos2d::Size& size, float hSpeed, float vSpeed, float saturation);
	//    virtual void draw(Renderer *renderer, const Mat4 &transform, uint32_t flags) override;

protected:
	//    CustomCommand _beforeDraw;
	//    CustomCommand _afterDraw;
	//    void onBeforeDraw();
	//    void onAfterDraw();
};

NS_CC_END
