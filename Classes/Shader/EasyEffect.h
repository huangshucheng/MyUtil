#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;

enum fadeTYPE{
	white_FADE_IN,  
	white_FADE_OUT,
	black_FADE_IN,
	black_FADE_OUT,
	black_FADE_OUTIN,
	black_FADE_HOLD,
};
enum NUM_TYPE{
	num_DAMAGE,
	num_CRIT,
	num_CURE_ENERGY,
	num_STATUS,
	num_KILL,
};


//渲染空白图片并返回
enum shaderEffType{
	shader_FadeTB,
};


class EasyEffect
{
public:
	static CCFiniteTimeAction* getAction(int nIndex, float t,CCNode* pNode=NULL);       //网格动作//getAction参数：(0-抖动、1-波浪、2-X轴翻转、3-Y轴翻转、4-放大镜、5-水波、6-液态、7-扭曲波浪、8-扭曲旋转、9-水波、10-破碎歪曲、11-网格散开、12-顶右淡出、13-底左淡出、14-向上淡出、15-向下淡出、16-网格消失、17-网格波浪、18-跳跃网格、19-行错开、20-列错开、21-翻页)、持续时间
	void clearGirdAction(CCNode* pNode);									 //清除网格动作
	static CCSprite* setShaderEffect(int size_x=0, int size_y=0, shaderEffType sType=shader_FadeTB, float ROtate=0,int origin_x=0,int origin_y=0,int source_x=0,int source_y=0,char* FileName="");//闪电链：x、y、旋转角度（顺时针）
	static void setFadeEffect(float time,fadeTYPE fType);		 	 //淡入淡出效果，白色，黑色
	static CCFiniteTimeAction* shakeAction(float range);			 //抖动：范围
	static CCFiniteTimeAction* numAction(NUM_TYPE nType);            //战斗信息显示：伤害，治愈、能量，状态，击杀
};

//渲染DComponent类
enum SHADER_TYPE{
	SHADER_NULL,
	SHADER_STONE,					//石化
	SHADER_POISON,				//中毒状态,绿色加深
	SHADER_FREEZE,				//冰冻状态,蓝色加深
	SHADER_BRIGHTNESS,
	SHADER_SHADOW,				//蓝色残影
	SHADER_GAUSSBLUR,			//模糊	
	SHADER_SHADOW_GOLD,			//金色残影
	SHADER_HUE1,		//R->G->B->A
	SHADER_HUE2,		//R->B->G->A
	SHADER_WAVE,					//波浪特效
	SHADER_DRUNK,				//醉酒状态,红色加深
	SHADER_SHADOW_PURPLE,		//紫色残影
	SHADER_GLOW,
	SHADER_STREAMER,
	SHADER_STREAMER_ITEM,	
	SHADER_CUT,
	SHADER_CUT_H,		  
	SHADER_BRIGHTNESS_S,  //加亮，变化范围更大，更亮
	SHADER_BREATHLIGHT,
	SHADER_DARK,
	SHADER_ALPHA_PATH,		//替换纯黑色(r=0,g=0,b=0)为透明
	SHADER_GRAY,

	SHADER_GAUSSBLUR_BIG,
	SHADER_SKILL_LOCK,

	SHADER_MAX,
};
//优先通过关键字从缓存加载shader程序，找不到再初始化并加入缓存
static const char* szCompShdKey[SHADER_MAX]={
	"ShaderPositionTextureColor",
	"SHADER_STONE",
	"SHADER_POISON",
	"SHADER_FREEZE",
	"SHADER_BRIGHTNESS",
	"SHADER_SHADOW",
	"SHADER_GAUSSBLUR",
	"SHADER_SHADOW_GOLD",
	"SHADER_HUE1",
	"SHADER_HUE2",
	"SHADER_WAVE",
	"SHADER_DRUNK",
	"SHADER_SHADOW_PURPLE",	
	"SHADER_GLOW",
	"SHADER_STREAMER",
	"SHADER_STREAMER_ITEM",
	"SHADER_CUT",
	"SHADER_CUT_H",
	"SHADER_BRIGHTNESS_S",
	"SHADER_BREATHLIGHT",
	"SHADER_DARK",
	"SHADER_ALPHA_PATH",	
	"SHADER_GRAY",
	"SHADER_GAUSSBLUR_BIG",
	"SHADER_SKILLLOCK",
};
CCSprite* GFun_InitSpriteByJPG( char* szFile );
void MySetShader(SHADER_TYPE byType,void* pParam);





