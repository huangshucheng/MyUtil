#include "AppDelegate.h"
#include "HelloWorldScene.h"
USING_NS_CC;

static cocos2d::Size designResolutionSize = cocos2d::Size(480, 320);
static cocos2d::Size smallResolutionSize = cocos2d::Size(480, 320);
static cocos2d::Size mediumResolutionSize = cocos2d::Size(1024, 768);
static cocos2d::Size largeResolutionSize = cocos2d::Size(2048, 1536);

static cocos2d::Size mydesignResolutionSize = cocos2d::Size(960, 640);

float DESIGN_RATIO = 1.5;  //  96./640= 1.5
int DESIGN_PAD_WIDTH = 1024;  //ipad

AppDelegate::AppDelegate()
{

}

AppDelegate::~AppDelegate() 
{
	
}

void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

static int register_all_packages()
{
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching() 
{
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
		glview = GLViewImpl::createWithRect("MyUtil", Rect(0, 0, 960, 640));
#else
        glview = GLViewImpl::create("MyUtil");
#endif
        director->setOpenGLView(glview);
    }

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	AllocConsole();
	freopen("CONIN$", "r", stdin);
	freopen("CONOUT$", "w", stdout);
	freopen("CONOUT$", "w", stderr);
#endif

    director->setDisplayStats(true);

    director->setAnimationInterval(1.0 / 60);

	Size size = Director::getInstance()->getWinSize();

	float ratio = size.width / size.height;

	if (ratio >= DESIGN_RATIO)
	{
		float height = mydesignResolutionSize.height;
		float width = height * ratio;
		glview->setDesignResolutionSize(width, height, ResolutionPolicy::EXACT_FIT);
	}
	else
	{
		//float width = mydesignResolutionSize.width;
		float width = DESIGN_PAD_WIDTH;
		float height = width / ratio;
		glview->setDesignResolutionSize(width, height, ResolutionPolicy::EXACT_FIT);
	}

	register_all_packages();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	glview->setFrameSize(960, 640);
	//glview->setFrameSize(640, 960);
	//glview->setFrameSize(768, 1024);

#endif

    auto scene = HelloWorld::createScene();
    director->runWithScene(scene);

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground() {
    Director::getInstance()->stopAnimation();

    // if you use SimpleAudioEngine, it must be pause
    // SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground() {
    Director::getInstance()->startAnimation();

    // if you use SimpleAudioEngine, it must resume here
    // SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
