/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_ass_convo
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that has the henchman tell the player what options
 have been selected.

 sOption will decide what the henchman says.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oHenchman = OBJECT_SELF;
    string sParam = GetScriptParam("sOption");
    if(sParam == "BaseMode")
    {
        string sBaseMode = "I'm ready to attack.";
        // Lets get which base mode the henchman is in.
        if(ai_GetAssociateMode(oHenchman, AI_MODE_STAND_GROUND)) sBaseMode = "I'm holding here.";
        else if(ai_GetAssociateMode(oHenchman, AI_MODE_DEFEND_MASTER)) sBaseMode = "I'm defending you.";
        else if(ai_GetAssociateMode(oHenchman, AI_MODE_FOLLOW)) sBaseMode = "I'm following you.";
        if(GetLocalString(oHenchman, AI_COMBAT_SCRIPT) == "ai_coward") sBaseMode = "I will not fight the enemy!";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN, sBaseMode);
    }
    else if(sParam == "CombatTactics")
    {
        string sRangedUse = "", sCombatTactic = "I'm using my best judgement in combat ";
        string sAtkAssociates = "";
        string sTargets = "against all enemies and ";
        // Lets get which base mode the henchman is in.
        if(ai_GetAssociateMode(oHenchman, AI_MODE_CHECK_ATTACK)) sTargets = "against enemies I can handle and ";
        if(GetLocalString(oHenchman, AI_COMBAT_SCRIPT) == "ai_a_ambusher") sCombatTactic = "I'm using ambush tactics ";
        else if(GetLocalString(oHenchman, AI_COMBAT_SCRIPT) == "ai_a_defensive") sCombatTactic = "I'm using defensive tactics ";
        else if(GetLocalString(oHenchman, AI_COMBAT_SCRIPT) == "ai_a_taunter") sCombatTactic = "I'm ready to taunt ";
        if(GetLocalString(oHenchman, AI_COMBAT_SCRIPT) == "ai_coward")
        {
            sCombatTactic = "I will not fight the enemy!";
            sTargets = "";
        }
        else
        {
            if(ai_GetAssociateMode(oHenchman, AI_MODE_STOP_RANGED)) sRangedUse = "will not use a ranged weapon.";
            else sRangedUse = "will use a ranged weapon.";
            if(ai_GetAssociateMode(oHenchman, AI_MODE_IGNORE_ASSOCIATES)) sAtkAssociates = " I will also ignore familiars, companions, and summons.";
            else sAtkAssociates = " I will also attack familiars, companions, and summons.";
        }
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 1, sCombatTactic + sTargets + sRangedUse + sAtkAssociates);
    }
    else if(sParam == "Healing")
    {
        string sHealingIn = IntToString(GetLocalInt(oHenchman, AI_HEAL_IN_COMBAT_LIMIT)) + "%";
        string sHealingOut = IntToString(GetLocalInt(oHenchman, AI_HEAL_OUT_OF_COMBAT_LIMIT)) + "%";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 2, "I'm healing our allies if they go below " +
                 sHealingIn + " health in combat and " + sHealingOut + " out of combat.");
    }
    else if(sParam == "Distance")
    {
        string sDistance = "I'm staying close.";
        if(ai_GetAssociateMode(oHenchman, AI_MODE_DISTANCE_MEDIUM)) sDistance = "I'm not getting too close.";
        else if(ai_GetAssociateMode(oHenchman, AI_MODE_DISTANCE_LONG)) sDistance = "I'm hanging way back.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 3, sDistance);
    }
    else if(sParam == "Pickup")
    {
        string sPickup = "I'm not picking up any items.";
        if(ai_GetAssociateMode(oHenchman, AI_MODE_PICKUP_MAGIC_ITEMS)) sPickup = "I'm picking up gold and magic items.";
        else if(ai_GetAssociateMode(oHenchman, AI_MODE_PICKUP_GEMS_ITEMS)) sPickup = "I'm picking up gold, gems, art objects, and magic items.";
        else if(ai_GetAssociateMode(oHenchman, AI_MODE_PICKUP_ITEMS)) sPickup = "I'm picking everything up.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 4, sPickup);
    }
    else if(sParam == "Spells")
    {
        string sCasting = "I'm casting";
        string sType = " spells I choose.";
        string sBuff = " I'll also targeting anyone that needs it.";
        string sDispel = " Finally I may use Dispel spells.";
        if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_BUFF_MASTER)) sBuff = " Ofcourse I'll target you first.";
        if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_STOP_DISPEL)) sDispel = " Finally I will not use Dispel spells.";
        if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_LOW_MAGIC_USE)) sCasting = "I'm sparingly casting";
        if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_HEAVY_MAGIC_USE)) sCasting = "I'm heavily casting";
        if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_CONSTANT_MAGIC_USE)) sCasting = "I'm always casting";
        if(GetLocalString(oHenchman, AI_COMBAT_SCRIPT) == "ai_a_cntrspell")
        {
            sCasting = "I'm ready to counter spell our enemies.";
            sType = "";
            sBuff = "";
            sDispel = "";
        }
        if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_NO_MAGIC))
        {
            sCasting = "I'm not use any magic.";
            sType = "";
            sBuff = "";
            sDispel = "";
        }
        else if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_DEFENSIVE_CASTING)) sType = " defensive spells only.";
        else if(ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_OFFENSIVE_CASTING))
        {
            sType = " offensive spells only.";
            sBuff = "";
        }
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 5, sCasting + sType + sBuff + sDispel);
    }
    else if(sParam == "Traps")
    {
        string sTraps = "I'll leave any traps we find for you to deal with.";
        if(ai_GetAssociateMode(oHenchman, AI_MODE_DISARM_TRAPS)) sTraps = "I'll help you disarm any traps we find.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 6, sTraps);
    }
    else if(sParam == "Locks")
    {
        string sLocks = "I'll leave any locked doors or chests we find for you to deal with.";
        if(ai_GetAssociateMode(oHenchman, AI_MODE_OPEN_LOCKS)) sLocks = "I'll help you open any locked doors or chests we find.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 7, sLocks);
    }
    else if(sParam == "RestBuffing")
    {
        string sRestBuffing = "";
        if(!ai_GetAssociateMagicMode(oHenchman, AI_MAGIC_BUFF_AFTER_REST)) sRestBuffing = "not ";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 10, "After we rest I am " + sRestBuffing + "casting my long buff spells on us.");
    }
    return TRUE;
}
