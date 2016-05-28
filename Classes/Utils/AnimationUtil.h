#pragma once

#include "cocos2d.h"
#include "cocostudio/CocoStudio.h"  

USING_NS_CC;
using namespace cocostudio;
/*
帧动画工具
*/
class AnimationUtil
{
public:

	AnimationUtil();
	~AnimationUtil();

	//笨木头的
	static Animation* createWithSingleFrameName(const char* name,float dely,int iLoops);
	static Animation* createWithFrameNameAndNum(const char* name,int iNum,float delay, int iLoops);
	Animation*createWithFrameFromStartToEnd(const char* name, int startFrame, int endFrame, float delay, int iLoops);

	//骨骼动画
	static Armature * loadArmature(std::string imagePath, std::string plistPath, std::string configFilePath, std::string armatureName);
	static Armature * loadArmatures(std::string imagePath, std::string plistPath, std::string configFilePath, std::string armatureName);
public:
	//张少华的
	static Animate* getAnimate(std::string imageName, float &actionTime, float intervalTime = 0.1);
	static Animate* getAnimate(std::string imageName, float intervalTime = 0.1);
	static Animate* getAnimate(std::string imageName, Size &spriteSize, float intervalTime = 0.1);
	static Animate* getAnimate(std::string imageName, Size &spriteSize, float &actionTime, float intervalTime = 0.1);
};

