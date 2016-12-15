LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

$(call import-add-path,$(LOCAL_PATH)/../../cocos2d)
$(call import-add-path,$(LOCAL_PATH)/../../cocos2d/external)
$(call import-add-path,$(LOCAL_PATH)/../../cocos2d/cocos)

LOCAL_MODULE := cocos2dcpp_shared

LOCAL_MODULE_FILENAME := libcocos2dcpp

LOCAL_SRC_FILES := hellocpp/main.cpp \
                   ../../Classes/AppDelegate.cpp\
				   ../../Classes/Data/BattleData.cpp\
				   ../../Classes/Data/GameData.cpp\
				   ../../Classes/Data/DataCache.cpp\
				   ../../Classes/Data/PlayerData.cpp\
				   ../../Classes/Data/GiftData.cpp\
				   ../../Classes/Data/PayData.cpp\
				   ../../Classes/Resource/ResourceCache.cpp\
				   ../../Classes/Layer/BaseLayer.cpp\
				   ../../Classes/Layer/PopLayer.cpp\
				   ../../Classes/Layer/TopDownLayer.cpp\
				   ../../Classes/Layer/ExitLayer/ExitLayer.cpp\
				   ../../Classes/Layer/GuideLayer/GuideLayer.cpp\
				   ../../Classes/Layer/ToastLayer/ToastLayer.cpp\
				   ../../Classes/Layer/ToastLayer/ToastManger.cpp\
				   ../../Classes/Layer/PrepareLayer/PrepareLayer.cpp\
				   ../../Classes/Layer/MenuLayer/MenuLayer.cpp\
				   ../../Classes/Layer/MenuLayer/SetLayer.cpp\
				   ../../Classes/Layer/CardLayer/CardLayer.cpp\
				   ../../Classes/Layer/PauseLayer/PauseLayer.cpp\
				   ../../Classes/Layer/RestoreLayer/RestoreLayer.cpp\
				   ../../Classes/Layer/SettlementLayer/SettlementLayer.cpp\
				   ../../Classes/Layer/SettlementLayer/SettlementLayerLeft.cpp\
				   ../../Classes/Layer/SettlementLayer/SettlementLayerRight.cpp\
				   ../../Classes/Layer/SettlementLayer/SettlementTaskLayer.cpp\
				   ../../Classes/Layer/ShopBuyLayer/ShopBuyGoodsLayer.cpp\
				   ../../Classes/Layer/ShopBuyLayer/BuyButtonItem.cpp\
				   ../../Classes/Layer/SkipTaskLayer/SkipTaskLayer.cpp\
				   ../../Classes/Layer/StartGameTaskLayer/StartGameTaskLayer.cpp\
				   ../../Classes/Layer/TaskLayer/TaskLayer.cpp\
				   ../../Classes/Layer/UpgradeTaskLayer/UpgradeTaskLayer.cpp\
				   ../../Classes/Scene/BaseScene.cpp\
				   ../../Classes/Scene/Battle/BattleMap.cpp\
				   ../../Classes/Scene/Battle/BattleLayer.cpp\
				   ../../Classes/Scene/Battle/BattleManager.cpp\
				   ../../Classes/Scene/Battle/BattleScene.cpp\
				   ../../Classes/Scene/Battle/Boat.cpp\
				   ../../Classes/Scene/Battle/Bullet.cpp\
				   ../../Classes/Scene/Battle/CreateEnemyLayer.cpp\
				   ../../Classes/Scene/Battle/DropGoodsNode.cpp\
				   ../../Classes/Scene/Battle/Enemy.cpp\
				   ../../Classes/Scene/Battle/EnemyBoat.cpp\
				   ../../Classes/Scene/Battle/EnemyBomber.cpp\
				   ../../Classes/Scene/Battle/EnemyBullet.cpp\
				   ../../Classes/Scene/Battle/EnemyCopter.cpp\
				   ../../Classes/Scene/Battle/EnemyDropGoods.cpp\
				   ../../Classes/Scene/Battle/EnemyNode.cpp\
				   ../../Classes/Scene/Battle/EnemySubmarine.cpp\
				   ../../Classes/Scene/Battle/EnemyWaterRay.cpp\
				   ../../Classes/Scene/Battle/EnemyFish.cpp\
				   ../../Classes/Scene/Battle/Hero.cpp\
				   ../../Classes/Scene/Battle/MoveListener.cpp\
				   ../../Classes/Scene/ShopScene/ButtonCommon.cpp\
				   ../../Classes/Scene/ShopScene/ShopAddSkillLayer.cpp\
				   ../../Classes/Scene/ShopScene/ShopBoatItem.cpp\
				   ../../Classes/Scene/ShopScene/ShopBoatLayer.cpp\
				   ../../Classes/Scene/ShopScene/ShopHeroItem.cpp\
				   ../../Classes/Scene/ShopScene/ShopHeroLayer.cpp\
				   ../../Classes/Scene/ShopScene/ShopScene.cpp\
				   ../../Classes/Scene/ShopScene/ShopSkilItem.cpp\
				   ../../Classes/Scene/ShopScene/ShopSkillLayer.cpp\
				   ../../Classes/Scene/ShopScene/ShopTopLayer.cpp\
				   ../../Classes/Scene/ShopScene/ShopWeaponItem.cpp\
				   ../../Classes/Scene/ShopScene/ShopWeaponLayer.cpp\
				   ../../Classes/Scene/LoadingScene/LoadingScene.cpp\
				   ../../Classes/Scene/GameLoding/GameLoding.cpp\
				   ../../Classes/Scene/TransitionAnimation/TransitionAnimation.cpp\
				   ../../Classes/Scene/TransitionAnimation/TransitionIn.cpp\
				   ../../Classes/Scene/TransitionAnimation/TransitionOut.cpp\
				   ../../Classes/Scene/Logo/LogoScene.cpp\
				   ../../Classes/Sound/SoundManager.cpp\
				   ../../Classes/Sound/SoundPoolManager.cpp\
				   ../../Classes/Util/GiftManager.cpp\
				   ../../Classes/Util/SceneBgLayer.cpp\
				   ../../Classes/Util/GuideManager.cpp\
				   ../../Classes/Util/CommonFunction.cpp\
				   ../../Classes/Util/GameJniHelper.cpp\
				   ../../Classes/Util/TradeManager.cpp\
				   ../../Classes/Util/Loading.cpp\
				   ../../Classes/Widget/Scale9Progress.cpp\
				   ../../Classes/Widget/RunNumLabel.cpp\
				   ../../Classes/Widget/RichText.cpp\
				   ../../Classes/Widget/AttackRunNumLabel.cpp
				   

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/cocos/editor-support
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/cocos/ui 
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/extensions
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/cocos
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/external
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/cocos/audio/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/external/chipmunk/include/chipmunk
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2d/external/libcppsqlite3/android/include

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static
LOCAL_WHOLE_STATIC_LIBRARIES += libcppsqlite3_static

# LOCAL_WHOLE_STATIC_LIBRARIES += box2d_static
# LOCAL_WHOLE_STATIC_LIBRARIES += cocosbuilder_static
# LOCAL_WHOLE_STATIC_LIBRARIES += spine_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocostudio_static
# LOCAL_WHOLE_STATIC_LIBRARIES += cocos_network_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static


include $(BUILD_SHARED_LIBRARY)

$(call import-module,.)
$(call import-module,audio/android)
$(call import-module,external/libcppsqlite3/android)

# $(call import-module,Box2D)
# $(call import-module,editor-support/cocosbuilder)
# $(call import-module,editor-support/spine)
$(call import-module,editor-support/cocostudio)
# $(call import-module,network)
$(call import-module,extensions)

