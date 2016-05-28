#include "AnimationUtil.h"

AnimationUtil::AnimationUtil()
{
	/*
	使用：（笨木头的）

	SpriteFrameCache* frameCache = SpriteFrameCache::getInstance();
	frameCache->addSpriteFramesWithFile("huang.plist", "huang.png");
	auto sp = Sprite::createWithSpriteFrameName("10003");
	sp->setPosition(visibleSize/2);
	addChild(sp);

	//auto animation = AnimationUtil::createWithSingleFrameName("1000",0.1f,-1);
	//sp->runAction(Animate::create(animation));

	auto animation1 = AnimationUtil::createWithFrameNameAndNum("1000",7,0.1f,-1);
	sp->runAction(Animate::create(animation1));
	*/
}

AnimationUtil::~AnimationUtil()
{

}
/*
	1.先加载 plist png 图片到缓存池
	2.用这个方法创建Animation对象
	3.创建animate
	4.精灵运行此动画

*/

/*
不用指定有多少张图片，直接传入图片名字就是了

name:图片名字
delay: 每帧的延迟(0.1)
iLoops:循环 （-1循环,0不循环,1一次）
*/
Animation* AnimationUtil::createWithSingleFrameName(const char* name, float delay, int iLoops){
	SpriteFrameCache* cache = SpriteFrameCache::getInstance();
	Vector<SpriteFrame*> frameVec;
	SpriteFrame* frame = nullptr;
	int index = 1;
	do
	{
		/*不断获取SpriteFrame对象直到获取的值为空*/
		frame = cache->getSpriteFrameByName(StringUtils::format("%s%02d.png",name,index++));
		if (frame ==nullptr)
		{
			break;
		}
	frameVec.pushBack(frame);
	} while (true);

	Animation* animation = Animation::createWithSpriteFrames(frameVec);
	animation->setLoops(iLoops);
	animation->setRestoreOriginalFrame(true);
	animation->setDelayPerUnit(delay);	//0.1f
	return animation;
}

/*
需要传入图片的数量

name:图片名字
iNum:图片帧数量
delay:每帧的延迟(0.1)
iLoops:循环 （-1循环,0不循环,1一次）
*/
Animation* AnimationUtil::createWithFrameNameAndNum(const char* name, int iNum, float delay, int iLoops){
	SpriteFrameCache* cache = SpriteFrameCache::getInstance();
	Vector<SpriteFrame*> frameVec;
	SpriteFrame* frame = nullptr;
	int index = 1;
	for (int i = 1; i <= iNum; i++)
	{
		frame = cache->getSpriteFrameByName(StringUtils::format("%s%02d.png", name, i));
		if (frame == nullptr)
		{
			break;
		}
		frameVec.pushBack(frame);
	}

	Animation* animation = Animation::createWithSpriteFrames(frameVec);
	animation->setLoops(iLoops);
	animation->setRestoreOriginalFrame(true);
	animation->setDelayPerUnit(delay);	//0.1f
	return animation;
}
/*
需要传入图片的数量

name:图片名字
startFrame:开始帧
endFrame：结束帧
delay:每帧的延迟(0.1)
iLoops:循环 （-1循环,0不循环,1一次）
*/
Animation* AnimationUtil::createWithFrameFromStartToEnd(const char* name, int startFrame, int endFrame, float delay, int iLoops){
	SpriteFrameCache* cache = SpriteFrameCache::getInstance();
	Vector<SpriteFrame*> frameVec;
	SpriteFrame* frame = nullptr;

	for (int i = startFrame; i <= endFrame; i++)
	{
		frame = cache->getSpriteFrameByName(StringUtils::format("%s%02d.png", name, i));

		//std::string str = StringUtils::format("%s%2d.png", name, i);

		//log("%s", str.c_str());

		if (frame == nullptr)
		{
			break;
		}
		frameVec.pushBack(frame);
	}

	Animation* animation = Animation::createWithSpriteFrames(frameVec);
	animation->setLoops(iLoops);
	animation->setRestoreOriginalFrame(true);
	animation->setDelayPerUnit(delay);	//0.1f
	return animation;
}
//张少华的
Animate* AnimationUtil::getAnimate(std::string imageName, float &actionTime, float intervalTime ){
	Size size;
	return getAnimate(imageName, size, actionTime, intervalTime);
}

Animate* AnimationUtil::getAnimate(std::string imageName, float intervalTime ){
	float actionTime = 0;
	return getAnimate(imageName, actionTime, intervalTime);
}

Animate* AnimationUtil::getAnimate(std::string imageName, Size &spriteSize, float intervalTime ){
	float actionTime = 0;
	return getAnimate(imageName, spriteSize, actionTime, intervalTime);
}

Animate* AnimationUtil::getAnimate(std::string imageName, Size &spriteSize, float &actionTime, float intervalTime ){
	Vector<SpriteFrame*> animFrames;
	SpriteFrame *spriteFrame;
	char path[50];

	int index = 1;
	while (1)
	{
		sprintf(path, "%s%d.png", imageName.c_str(), index);
		spriteFrame = SpriteFrameCache::getInstance()->getSpriteFrameByName(path);
		if (spriteFrame == NULL)
			break;

		spriteSize = spriteFrame->getOriginalSize();
		actionTime += intervalTime;
		animFrames.pushBack(spriteFrame);
		index++;
	}

	if (animFrames.size() > 0)
	{
		Animation *animation = Animation::createWithSpriteFrames(animFrames, intervalTime);
		Animate *termpAnimate = Animate::create(animation);

		animFrames.clear();
		return termpAnimate;
	}

	return NULL;
}

Armature * AnimationUtil::loadArmature(std::string imagePath, std::string plistPath, std::string configFilePath, std::string armatureName){
	ArmatureDataManager::getInstance()->addArmatureFileInfo(imagePath,  plistPath,  configFilePath);
	Armature * m_armature = Armature::create(armatureName);
	m_armature->setCascadeOpacityEnabled(true);
	m_armature->setVersion(1);
	m_armature->getAnimation()->playByIndex(0);
	return m_armature;
}
Armature * AnimationUtil::loadArmatures(std::string imagePath, std::string plistPath, std::string configFilePath, std::string armatureName){
	ArmatureDataManager::getInstance()->addArmatureFileInfo(imagePath, plistPath, configFilePath);
	Armature * m_armature = Armature::create(armatureName);
	m_armature->setCascadeOpacityEnabled(true);
	m_armature->setVersion(1);
	return m_armature;

	//可以用ExportJson+png+plist 也可以用pong+ plist+ xml 文件
	//也可以只用 ExportJson
	//ArmatureDataManager::getInstance()->addArmatureFileInfo("Cowboy.ExportJson");
	//ArmatureDataManager::getInstance()->addArmatureFileInfo("robot.png", "robot.plist", "robot.xml");
}