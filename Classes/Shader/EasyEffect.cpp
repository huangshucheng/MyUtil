#include "EasyEffect.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
//#include "debug_def.h"
#endif

/*-------------------抖动，case：0-------------------*/
//create参数：抖动程度、网格大小、持续时间、Z轴是否可用
class Shaky3DDemo : public CCShaky3D 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCShaky3D::create(t, CCSizeMake(15,10),10, false);
	}
};

/*-------------------波浪，case：1-------------------*/
//create参数：持续时间、网格大小、波浪数、振幅
class Waves3DDemo : public CCWaves3D 
{
public:
	static CCFiniteTimeAction* create(float t)
	{	
		return CCWaves3D::create(t,CCSizeMake(15,10),3,20);
		
	}
};
/*-------------------X轴翻转，case：2-------------------*/
//create参数：持续时间
class FlipX3DDemo : public CCFlipX3D 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCFlipX3D* flipx  = CCFlipX3D::create(t);
		CCActionInterval* flipx_back = flipx->reverse();
		CCDelayTime* delay = CCDelayTime::create(2);

		return CCSequence::create(flipx, delay, flipx_back, NULL);
	}
};
/*-------------------Y轴翻转，case：3-------------------*/
//create参数：持续时间
class FlipY3DDemo : public CCFlipY3D 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCFlipY3D* flipy  = CCFlipY3D::create(t);
		CCActionInterval* flipy_back = flipy->reverse();
		CCDelayTime* delay = CCDelayTime::create(2);

		return CCSequence::create(flipy, delay, flipy_back, NULL);
	}
};
/*-------------------放大镜，case：4-------------------*/	
//create参数：持续时间、网格大小、圆心坐标、半径
class Lens3DDemo : public CCLens3D 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCSize size = CCDirector::sharedDirector()->getWinSize();
		return CCLens3D::create(t,CCSizeMake(15,10),ccp(size.width*0.5,size.height*0.5),200);
	}
};

/*-------------------水波，case：5-------------------*/
//create参数：持续时间、网格大小、圆心坐标、半径、波浪数、振幅
class Ripple3DDemo : public CCRipple3D 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCSize size = CCDirector::sharedDirector()->getWinSize();



		return CCRipple3D::create(t,CCSizeMake(15,10),ccp(size.width*0.95,size.height/2),600, 6, 20);
	}
};

/*-------------------液态，case：6-------------------*/	
//create参数：持续时间、网格大小、波浪数、振幅
class LiquidDemo : public CCLiquid
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCLiquid::create(t,CCSizeMake(15,10),5,10);
	}
};

/*-------------------扭曲波浪，case：7-------------------*/
//create参数：持续时间、网格大小、波浪数、振幅、水平Sin、竖直Sin
class WavesDemo : public CCWaves 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCWaves::create(t,CCSizeMake(15,10),5,10,0.5,0.5);
	}
};

/*-------------------扭曲旋转，case：8-------------------*/
//create参数：持续时间、网格大小、中心点、扭曲数、振幅
class TwirlDemo : public CCTwirl 
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCSize size = CCDirector::sharedDirector()->getWinSize();
		return CCTwirl::create(t, CCSizeMake(12,8), ccp(size.width/2, size.height/2), 1, 2.5f); 
	}
};

/*-------------------水波，case：9-------------------*/
//create参数：持续时间、网格大小、波动范围、Z轴是否可用
class ShakyTiles3DDemo : public CCShakyTiles3D
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCShakyTiles3D::create(t, CCSizeMake(16,12), 5, false) ;
	}
};

/*-------------------破碎歪曲，case：10-------------------*/
//create参数：持续时间、网格大小、波动范围、Z轴是否可用
class ShatteredTiles3DDemo : public CCShatteredTiles3D
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCShatteredTiles3D::create(t, CCSizeMake(16,12), 5, false); 
	}
};


/*-------------------网格散开，case：11-------------------*/
//create参数：持续时间、网格大小、随机数种子
class ShuffleTilesDemo : public CCShuffleTiles
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCShuffleTiles* shuffle = CCShuffleTiles::create(t, CCSizeMake(16,12), 25);
		CCActionInterval* shuffle_back = shuffle->reverse();
		CCDelayTime* delay = CCDelayTime::create(2);

		return CCSequence::create(shuffle, delay, shuffle_back, NULL);
	}
};


/*-------------------顶右淡出，case：12-------------------*/
//create参数：持续时间、网格大小
class FadeOutTRTilesDemo : public CCFadeOutTRTiles
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCFadeOutTRTiles* fadeout = CCFadeOutTRTiles::create(t, CCSizeMake(15,10));
		CCActionInterval* back = fadeout->reverse();
		CCDelayTime* delay = CCDelayTime::create(0.5f);

		return CCSequence::create(fadeout, delay, back, NULL);
	}
};


/*-------------------底左淡出，case：13-------------------*/
//create参数：持续时间、网格大小
class FadeOutBLTilesDemo : public CCFadeOutBLTiles
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCFadeOutBLTiles* fadeout = CCFadeOutBLTiles::create(t, CCSizeMake(15,10));
		CCActionInterval* back = fadeout->reverse();
		CCDelayTime* delay = CCDelayTime::create(0.5f);

		return CCSequence::create(fadeout, delay, back, NULL);
	}
};


/*-------------------向上淡出，case：14-------------------*/
//create参数：持续时间、网格大小
class FadeOutUpTilesDemo : public CCFadeOutUpTiles
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCFadeOutUpTiles* fadeout = CCFadeOutUpTiles::create(t, CCSizeMake(15,10));
		CCActionInterval* back = fadeout->reverse();
		CCDelayTime* delay = CCDelayTime::create(0.5f);

		return CCSequence::create(fadeout, delay, back, NULL);
	}
};

/*-------------------向下淡出，case：15-------------------*/
//create参数：持续时间、网格大小
class FadeOutDownTilesDemo : public CCFadeOutDownTiles
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCFadeOutDownTiles* fadeout = CCFadeOutDownTiles::create(t, CCSizeMake(15,10));
		CCActionInterval* back = fadeout->reverse();
		CCDelayTime* delay = CCDelayTime::create(0.5f);

		return CCSequence::create(fadeout, delay, back, NULL);
	}
};

/*-------------------网格消失，case：16-------------------*/
//create参数：持续时间、网格大小、随机数种子
class TurnOffTilesDemo : public CCTurnOffTiles
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCActionInterval* fadeout=CCTurnOffTiles::create(t, CCSizeMake(15,10), 25);
		CCActionInterval* back = fadeout->reverse();
		CCDelayTime* delay = CCDelayTime::create(0.5f);

		return CCSequence::create(fadeout, delay, back, NULL);
	}
};

/*-------------------网格波浪，case：17-------------------*/
//create参数：持续时间、网格大小、波浪数、振幅
class WavesTiles3DDemo : public CCWavesTiles3D
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCWavesTiles3D::create(t, CCSizeMake(15,10), 4, 120); 
	}
};

/*-------------------跳跃网格，case：18-------------------*/
//create参数：持续时间、网格大小、跳跃次数、振幅
class JumpTiles3DDemo : public CCJumpTiles3D
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCJumpTiles3D::create(t, CCSizeMake(15,10), 2, 30); 

	}
};

/*-------------------行错开，case：19-------------------*/
//create参数：持续时间、行数
class SplitRowsDemo : public CCSplitRows
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCSplitRows::create(t, 20); 
	}
};

/*-------------------列错开，case：20-------------------*/
//create参数：持续时间、列数
class SplitColsDemo : public CCSplitCols
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		return CCSplitCols::create(t, 30); 
	}
};

/*-------------------翻页，case：21-------------------*/
//create参数：持续时间、网格大小
class PageTurn3DDemo : public CCPageTurn3D
{
public:
	static CCFiniteTimeAction* create(float t)
	{
		CCDirector::sharedDirector()->setDepthTest(true);
		return CCPageTurn3D::create(t,CCSizeMake(15,10)); 
	}
};




//===========================================================================================================

//getAction参数：特效编号（0～21,31,32）、持续时间
CCFiniteTimeAction* EasyEffect::getAction(int nIndex, float t,CCNode* pNode)
{
	CCDirector::sharedDirector()->setDepthTest(false);
	CCFiniteTimeAction* pAct1;
	switch(nIndex)
	{
	case 0:pAct1	=	 Shaky3DDemo::create(t);
		break;
	case 1: pAct1	=	 Waves3DDemo::create(t);
		break;
	case 2: pAct1	=	 FlipX3DDemo::create(t);
		break;
	case 3: pAct1	=	 FlipY3DDemo::create(t);
		break;
	case 4: pAct1	=	 Lens3DDemo::create(t);
		break;
	case 5: pAct1	=	 Ripple3DDemo::create(t);
		break;
	case 6: pAct1	=	 LiquidDemo::create(t);
		break;
	case 7: pAct1	=	 WavesDemo::create(t);
		break;
	case 8: pAct1	=	 TwirlDemo::create(t);
		break;
	case 9: pAct1	=	 ShakyTiles3DDemo::create(t);
		break;
	case 10: pAct1	=	 ShatteredTiles3DDemo::create(t);
		break;
	case 11: pAct1	=	 ShuffleTilesDemo::create(t);
		break;
	case 12: pAct1	=	 FadeOutTRTilesDemo::create(t);
		break;
	case 13: pAct1	=	 FadeOutBLTilesDemo::create(t);
		break;
	case 14: pAct1	=	 FadeOutUpTilesDemo::create(t);
		break;
	case 15: pAct1	=	 FadeOutDownTilesDemo::create(t);
		break;
	case 16: pAct1	=	 TurnOffTilesDemo::create(t);
		break;
	case 17: pAct1	=	 WavesTiles3DDemo::create(t);
		break;
	case 18: pAct1	=	 JumpTiles3DDemo::create(t);
		break;
	case 19: pAct1	=	 SplitRowsDemo::create(t);
		break;
	case 20: pAct1	=	 SplitColsDemo::create(t);
		break;
	case 21: pAct1	=	 PageTurn3DDemo::create(t);
		break;
	case 31:	//抖动
		{
			CCActionInterval* pMove1	= CCMoveBy::create(t/4,ccp(-1.5,0));
			CCActionInterval* pMove2	= CCMoveBy::create(t/4,ccp(1.5,0));
			CCActionInterval* pMove3	= CCMoveBy::create(t/4,ccp(-0.8,0));
			CCActionInterval* pMove4	= CCMoveBy::create(t/4,ccp(0.8,0));
			CCActionInterval*	pSeq	= CCSequence::create(pMove1,pMove2,pMove3,pMove4,NULL);
			return pSeq;
		}
		break;
	case 32:	//抖动
		{
			CCActionInterval* pMove1	= CCMoveBy::create(t/4,ccp(-1.5,0));
			CCActionInterval* pMove2	= CCMoveBy::create(t/4,ccp(1.5,0));
			CCActionInterval* pMove3	= CCMoveBy::create(t/4,ccp(-0.8,0));
			CCActionInterval* pMove4	= CCMoveBy::create(t/4,ccp(0.8,0));

			CCActionInterval*	pSeq	= CCSequence::create(pMove2,pMove1,pMove4,pMove3,NULL);
			return pSeq;
		}
		break;
	default: return NULL;
	}

	CCFiniteTimeAction* pRun = CCSequence::create (pAct1,NULL);
	return pRun;
}

void EasyEffect::clearGirdAction(CCNode* pNode)
{	
	//if(pNode->getGrid()!=NULL)pNode->setGrid(NULL);
}

//淡入淡出=====================================================

void EasyEffect::setFadeEffect(float fTime,fadeTYPE fType)
{
	CCLayerColor* clrLayer	= (CCLayerColor*)CCDirector::sharedDirector()->getRunningScene()->getChildByTag(99);
	if(clrLayer == NULL)
		return;

	switch(fType)
	{
	case white_FADE_IN:
		{
			clrLayer->initWithColor(Color4B(255,255,255,255));
			CCActionInterval* whtFadeOut=CCFadeTo::create(fTime,0);
			clrLayer->runAction(whtFadeOut);
			break;
		}
	case white_FADE_OUT:
		{
			clrLayer->initWithColor(ccc4(255,255,255,0));
			CCActionInterval* whtFadeIn=CCFadeTo::create(fTime,255);
			clrLayer->runAction(whtFadeIn);
			break;
		}
	case black_FADE_IN:
		{
			clrLayer->initWithColor(ccc4(0,0,0,255));
			CCActionInterval* blkFadeOut=CCFadeTo::create(fTime,0);
			clrLayer->runAction(blkFadeOut);
			break;
		}
	case black_FADE_OUT:
		{
			clrLayer->initWithColor(ccc4(0,0,0,0));
			CCActionInterval* blkFadeIn=CCFadeTo::create(fTime,255);
			clrLayer->runAction(blkFadeIn);
			break;
		}
	case black_FADE_HOLD:
		{
			clrLayer->initWithColor(ccc4(0,0,0,255));
		}
		break;
	case black_FADE_OUTIN:
		{
			CCActionInterval* blkFadeOut=CCFadeTo::create(fTime,255);
			CCActionInterval* blkFadeIn=CCFadeTo::create(fTime,0);
			CCActionInterval*	seq	= CCSequence::create(blkFadeOut,blkFadeIn,NULL);
			clrLayer->runAction(seq);
		}
		break;
	}
}

//抖动
CCFiniteTimeAction* EasyEffect::shakeAction(float range)
{
	CCPointArray* pointAry=CCPointArray::create(7);
	pointAry->addControlPoint(ccp(range*(-0.5),range*0.866));
	pointAry->addControlPoint(ccp(range*0.5,range*0.866));
	pointAry->addControlPoint(ccp(range,0));
	pointAry->addControlPoint(ccp(range*0.5,range*(-0.866)));
	pointAry->addControlPoint(ccp(range*(-0.5),range*(-0.866)));
	pointAry->addControlPoint(ccp(-range,0));
	pointAry->addControlPoint(ccp(0,0));
	return CCCardinalSplineBy::create(0.05f,pointAry,0);
}

//战斗信息
CCFiniteTimeAction* EasyEffect::numAction(NUM_TYPE nType)
{
	switch(nType)
	{
	//伤害
	case num_DAMAGE:
		{
			CCActionInterval* pMove     =CCMoveBy::create(0.7,ccp(0,30));
			CCActionInterval* move_ease	=CCEaseSineIn::create(pMove);
			CCActionInterval* pFadeout  =CCFadeOut::create(0.7f);
			CCActionInterval* pAction	=CCSpawn::create(pFadeout,move_ease,NULL);
			//CCActionInterval* pAction	=CCSequence::create(pScale,pDelay,pSpawn,NULL);
			return pAction;
		}
		break;
	case num_STATUS:
		{
			CCActionInterval* pJump		= CCJumpBy::create(0.7f,ccp(rand()%60-30,-50),50,1);
			//CCActionInterval* move_ease	=CCEaseSineIn::create(pMove);
			CCActionInterval* pFadeout  =CCFadeOut::create(0.7f);
			//CCActionInterval* pScaleS  =CCScaleTo::create(0.7f,1.0f);
			CCActionInterval* pAction	=CCSpawn::create(pFadeout,pJump,NULL);
			//CCActionInterval* pAction	=CCSequence::create(pScale,pDelay,pSpawn,NULL);
			return pAction;
		}
		break;
	//暴击
	case num_CRIT:
		{
			CCActionInterval* pScale    =CCScaleTo::create(0.05f,1.8f);			
			CCActionInterval* pDelay	=CCDelayTime::create(0.15f);			
			CCActionInterval* pMove     =CCMoveBy::create(0.8,ccp(0,100));
			CCActionInterval* move_ease	=CCEaseSineIn::create(pMove);
			CCActionInterval* pFadeout  =CCFadeOut::create(0.8f);
			CCActionInterval* pScaleS  =CCScaleTo::create(0.8f,1.2f);
			CCActionInterval* pSpawn	=CCSpawn::create(pFadeout,move_ease,CCEaseSineIn::create(pScaleS),NULL);
			CCActionInterval* pAction	=CCSequence::create(pScale,pDelay,pSpawn,NULL);
			return pAction;
		}
		break;
	//治疗、能量
	case num_CURE_ENERGY:
		{
			CCActionInterval* pMove     =CCMoveBy::create(0.9,ccp(0,150));
			CCActionInterval* pFadeout  =CCFadeOut::create(0.9f);
			CCActionInterval* pAction	=CCSpawn::create(pMove,pFadeout,NULL);
			return pAction;
		}
		break;
	//击杀
	case num_KILL:
		{
			CCActionInterval* pScale    =CCScaleTo::create(0.08,1.8f);
			CCActionInterval* pDelay	=CCDelayTime::create(0.14);
			CCActionInterval* pFadeout  =CCFadeOut::create(0.8f);
			CCActionInterval* pAction	=CCSequence::create(pScale,pDelay,pFadeout,NULL);
			return pAction;
		}
		break;
	}
}
 
/*
//Frame渐隐边框
CCSprite* EasyEffect::setShaderEffect(int size_x, int size_y,shaderEffType sType, float ROtate,int origin_x,int origin_y,int source_x,int source_y,char* FileName)
{
	CCSprite* pParam=CCSprite::create("ui/AAA.png");
	pParam->setScaleX(size_x/10.0f);
	pParam->setScaleY(size_y/10.0f);
	CCGLProgram* pProgram = new CCGLProgram();
	switch (sType)
	{
	case shader_FadeTB:
		{
			string fileName = FileName;
			fileName = "ui/"+fileName;
			float Ewfez_ox = (float)origin_y/source_y;
			float Ewfez_oy = (float)(origin_y+10)/source_y;
			float Ewfez_oz = (float)(origin_y+size_y-10)/source_y;
			float Ewfez_ow = (float)(origin_y+size_y)/source_y;

			pParam->initWithFile(fileName.c_str(),CCRectMake(origin_x,origin_y,size_x,size_y));
			pParam->setScale(1.);

			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/ShaderFadeTB.fsh");
			pParam->setShaderProgram(pProgram);
			//pParam->getShaderProgram()->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
			pParam->getShaderProgram()->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
			pParam->getShaderProgram()->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
			pParam->getShaderProgram()->link();
			GLuint m_uniform;
			glUseProgram(pParam->getShaderProgram()->getProgram());
			m_uniform=glGetUniformLocation(pParam->getShaderProgram()->getProgram(),"Ewfez_o");
			pParam->getShaderProgram()->setUniformLocationWith4f(m_uniform,Ewfez_ox,Ewfez_oy,Ewfez_oz,Ewfez_ow);
			pParam->getShaderProgram()->updateUniforms();
			CHECK_GL_ERROR_DEBUG();
		}
		break;
	default:
		return NULL;
	}
	pProgram->autorelease();
	return pParam;
}
*/
/*
void MySetShader(SHADER_TYPE byType,void* pParam){
	//CCostTime time1;
	if(pParam == NULL)
		return;
	CCNode* pBtn	= (CCNode*)pParam;
	if(byType >= 100)
	{
		byType	= (SHADER_TYPE)(((int)byType)%100);
	}
	else if(byType == SHADER_BRIGHTNESS || byType == SHADER_NULL || byType == SHADER_GRAY || byType == SHADER_GAUSSBLUR)
	{
		CCObject* child;

		//CCARRAY_FOREACH(pBtn->getChildren(), child)
		//{
		//	CCNode* pCNode = (CCNode*) child;
		//	MySetShader((SHADER_TYPE)byType,pCNode);

		//}

		for (auto& child: pBtn->getChildren())
		{
			CCNode* pCNode = (CCNode*)child;
			if (pCNode)
			{
				MySetShader((SHADER_TYPE)byType, pCNode);
			}
		}
	}
	CCGLProgram* pProgram;
	if (CCShaderCache::sharedShaderCache()->programForKey(szCompShdKey[byType])){
		pProgram = CCShaderCache::sharedShaderCache()->programForKey(szCompShdKey[byType]);
		pBtn->setShaderProgram(pProgram);
	}
	else{
		pProgram = new CCGLProgram();
		switch (byType)
		{
		case SHADER_GRAY:{
			static GLchar * pszFragSource = 
				"#ifdef GL_ES \n \
				precision mediump float; \n \
				#endif \n \
				uniform sampler2D u_texture; \n \
				varying vec2 v_texCoord; \n \
				varying vec4 v_fragmentColor; \n \
				void main(void) \n \
				{ \n \
				// Convert to greyscale using NTSC weightings \n \
				float grey = dot(texture2D(u_texture, v_texCoord).rgb, vec3(0.299, 0.587, 0.114)); \n \
				gl_FragColor = vec4(grey, grey, grey, texture2D(u_texture, v_texCoord).a); \n \
				}";
			pProgram->initWithVertexShaderByteArray(ccPositionTextureColor_vert, pszFragSource);
						 }
						 break;
		case SHADER_BRIGHTNESS:
			{
				static GLchar * pszFragSource = 
					"#ifdef GL_ES \n \
					precision mediump float; \n \
					#endif \n \
					uniform sampler2D u_texture; \n \
					varying vec2 v_texCoord; \n \
					varying vec4 v_fragmentColor; \n \
					void main(void) \n \
					{ \n \
					// Convert to greyscale using NTSC weightings \n \
					vec4 irgb = texture2D(u_texture,v_texCoord)*v_fragmentColor; \n \
					gl_FragColor = irgb*(CC_SinTime.a*.1+1.2); \n \
					}";
				pProgram->initWithVertexShaderByteArray(ccPositionTextureColor_vert, pszFragSource);
			}
			//pProgram->initWithVertexShaderFilename("shader/BrightnessShader.vsh","shader/BrightnessShader.fsh");
			break;
		case SHADER_STONE:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_STONE.fsh");
			break;
		case SHADER_POISON:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_POISON.fsh");
			break;
		case SHADER_FREEZE:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_FREEZE.fsh");
			break;
		case SHADER_SHADOW:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_SHADOW.fsh");
			break;
		case SHADER_SHADOW_GOLD:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_SHADOW_GOLD.fsh");
			break;
		case SHADER_SHADOW_PURPLE:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_SHADOW_PURPLE.fsh");
			break;
		case SHADER_WAVE:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_WAVE.fsh");
			break;
		case SHADER_DRUNK:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_DRUNK.fsh");
			break;
		case SHADER_GAUSSBLUR:
		case SHADER_GAUSSBLUR_BIG:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_GAUSSBLUR.fsh");
			break;
		case SHADER_GLOW:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_GLOW.fsh");
			break;
		case SHADER_STREAMER:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_STREAMER.fsh");
			break;
		case SHADER_STREAMER_ITEM:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_STREAMER_ITEM.fsh");
			break;
		case SHADER_CUT:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_CUT.fsh");
			break;
		case SHADER_CUT_H:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_CUT_H.fsh");
			break;
		case SHADER_BRIGHTNESS_S:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_BRIGHTNESS_S.fsh");
			break;
		case SHADER_BREATHLIGHT:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_BREATHLIGHT.fsh");
			break;
		case SHADER_DARK:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_DARK.fsh");
			break;
		case SHADER_HUE1:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_HUE1.fsh");
			break;
		case SHADER_HUE2:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_HUE2.fsh");
			break;
		case SHADER_ALPHA_PATH:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_ALPHA_PATH.fsh");
			break;
		case SHADER_SKILL_LOCK:
			pProgram->initWithVertexShaderFilename("shader/vert.vsh","shader/SHADER_SKILLLOCK.fsh");
			break;
		default:
			return;
		}
		pProgram->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
		pProgram->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
		pProgram->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
		CCShaderCache::sharedShaderCache()->addProgram(pProgram,szCompShdKey[byType]);
		pProgram->link();
		switch(byType)
		{
		case SHADER_GLOW:
			{
				float		fGlowArea	=	3;			//发光范围
				GLuint		gLunUni;
				GLfloat		gLfWidth	=	fGlowArea/pBtn->getContentSize().width;
				GLfloat		gLfHeight	=	fGlowArea/pBtn->getContentSize().height;
				glUseProgram(pProgram->getProgram());
				gLunUni=glGetUniformLocation(pProgram->getProgram(),"size");
				pProgram->setUniformLocationWith2f(gLunUni,gLfWidth,gLfHeight);
			}
			break;
		case SHADER_GAUSSBLUR:
			{
				GLuint m_BlurSize;
				glUseProgram(pProgram->getProgram());
				m_BlurSize=glGetUniformLocation(pProgram->getProgram(),"size");

				pProgram->setUniformLocationWith1f(m_BlurSize,0.002);
			}
			break;
		case SHADER_GAUSSBLUR_BIG:
			{
				GLuint m_BlurSize;
				glUseProgram(pProgram->getProgram());
				m_BlurSize=glGetUniformLocation(pProgram->getProgram(),"size");

				pProgram->setUniformLocationWith1f(m_BlurSize,0.01);
			}
			break;
		}
		pProgram->updateUniforms();
		pBtn->setShaderProgram(pProgram);
		pProgram->autorelease();
	}
}
*/
/*
CCSprite* GFun_InitSpriteByJPG( char* szFile )
{
	Sprite* pSprTmp	= Sprite::create ();

	Texture2D*	pText2D	= TextureCache::sharedTextureCache()->addImage(szFile);
	if(pText2D == NULL)
	{
		pSprTmp->init();
		return pSprTmp;
	}

	pSprTmp->initWithTexture(pText2D);
	pSprTmp->getTexture()->setAliasTexParameters();
	if (szFile[0] == '_' || strstr(szFile,"/_"))
		MySetShader(SHADER_ALPHA_PATH,(void*)pSprTmp);
	return pSprTmp;
}
*/