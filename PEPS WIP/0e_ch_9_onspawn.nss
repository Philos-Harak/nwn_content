/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_9_onspawn
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate OnSpawn script;
  This fires when an associate spawns.
  Philos AI does not use this in override versions.
  Included for servers as an example to help add Philos AI to a server.
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2001 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
    2007-12-31: Deva Winblood
    Modified to look for X3_HORSE_OWNER_TAG and if
    it is defined look for an NPC with that tag
    nearby or in the module (checks near first).
    It will make that NPC this horse's master.
////////////////////////////////////////////////////////////////////////////////
// Created By: Preston Watamaniuk
// Created On: Nov 19, 2001
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
#include "0i_menus"
//#include "X0_INC_HENAI"
void main()
{
    // * Philos AI uses a diffreent Listening Patter system.
    // *
    // * SetAssociateListenPatterns();//Sets up the special henchmen listening patterns
    // * bkSetListeningPatterns();      // Goes through and sets up which shouts the NPC will listen to.

    // * Philos AI uses a different set of Associate States/Modes.
    // *
    // * SetAssociateState(NW_ASC_POWER_CASTING);
    // * SetAssociateState(NW_ASC_HEAL_AT_50);
    // * SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    // * SetAssociateState(NW_ASC_DISARM_TRAPS);
    // * SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    // * SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE); //User ranged weapons by default if true.
    // * SetAssociateState(NW_ASC_DISTANCE_2_METERS);

    // * April 2002: Summoned monsters, associates and familiars need to stay
    // * further back due to their size.
    // * int nType = GetAssociateType(OBJECT_SELF);
    // * switch (nType)
    // * {
    // *   case ASSOCIATE_TYPE_ANIMALCOMPANION:
    // *   case ASSOCIATE_TYPE_DOMINATED:
    // *   case ASSOCIATE_TYPE_FAMILIAR:
    // *   case ASSOCIATE_TYPE_SUMMONED:
    //        SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    //        break;
    // *
    // * }

    // * Philos AI - Horse code has not been tested with it, use at own risk!
    /*string sTag;
    object oNPC;
    sTag=GetLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
    if (GetStringLength(sTag)>0)
    { // look for master
        oNPC=GetNearestObjectByTag(sTag);
        if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
        { // master found
            AddHenchman(oNPC);
        } // master found
        else
        { // look in module
            oNPC=GetObjectByTag(sTag);
            if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
            { // master found
                AddHenchman(oNPC);
            } // master found
            else
            { // master does not exist - remove X3_HORSE_OWNER_TAG
                DeleteLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
            } // master does not exist - remove X3_HORSE_OWNER_TAG
        } // look in module
    } // look for master /*
/*    if (GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, GetMaster()) == OBJECT_SELF  ||
        GetAssociate(ASSOCIATE_TYPE_DOMINATED, GetMaster()) == OBJECT_SELF  ||
        GetAssociate(ASSOCIATE_TYPE_FAMILIAR, GetMaster()) == OBJECT_SELF  ||
        GetAssociate(ASSOCIATE_TYPE_SUMMONED, GetMaster()) == OBJECT_SELF)
    {
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    }
*/
    // * Feb 2003: Set official campaign henchmen to have no inventory
    // * SetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY", 10) ;

        // * SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
    // * SetAssociateStartLocation();
    // SPECIAL CONVERSATION SETTTINGS
    // * SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
    // * SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
            // This causes the creature to say a special greeting in their conversation file
            // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
            // greeting in order to designate it. As the creature is actually saying this to
            // himself, don't attach any player responses to the greeting.

    // Philos AI - This is valid to use.
    // *
// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

//****************************  ADDED AI CODE  *****************************
    object oCreature = OBJECT_SELF;
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    // We change this script so we can setup permanent summons on/off.
    // If you don't use this you may remove the next 3 lines 122 - 124.
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
    // Initialize Associate modes for basic use.
    ai_SetListeningPatterns(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAssociateAIScript(oCreature, FALSE);
    ai_SetAura(oCreature);
    if(GetLocalInt(GetModule(), AI_RULE_PARTY_SCALE)) ai_CheckXPPartyScale(oCreature);
    // Bioware summoned shadows are not incorporeal, also set the ai code.
    if (GetTag(OBJECT_SELF) == "NW_S_SHADOW")
    {
        SetLocalInt(OBJECT_SELF, "X2_L_IS_INCORPOREAL", TRUE);
        SetLocalString(OBJECT_SELF, AI_DEFAULT_SCRIPT, "ai_shadow");
    }
    // ***** Code for Henchman data and menus *****
    object oMaster = GetMaster(oCreature);
    if(ai_GetIsCharacter(oMaster))
    {
        string sAssociateType = ai_GetAssociateType(oMaster, oCreature);
        ai_CheckAssociateData(oMaster, oCreature, sAssociateType);
        if(AI_HENCHMAN_WIDGET)
        {
            // This keeps widgets from disappearing and reappearing.
            int nUiToken = NuiFindWindow(oMaster, sAssociateType + AI_WIDGET_NUI);
            if(nUiToken)
            {
                json jData = NuiGetUserData(oMaster, nUiToken);
                object oAssociate = StringToObject(JsonGetString(JsonArrayGet(jData, 0)));
                if(oAssociate != oCreature) NuiDestroy(oMaster, nUiToken);
            }
            else
            {
                if(!ai_GetWidgetButton(oMaster, BTN_WIDGET_OFF, oCreature, sAssociateType))
                {
                    ai_CreateWidgetNUI(oMaster, oCreature);
                }
            }
        }
    }
//****************************  ADDED AI CODE  *****************************
}



