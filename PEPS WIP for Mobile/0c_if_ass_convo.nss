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
    object oAssociate = OBJECT_SELF;
    string sParam = GetScriptParam("sOption");
    if(sParam == "BaseMode")
    {
        string sBaseMode = "I'm ready to attack.";
        string sVolume = " While shouting when I see things.";
        // Lets get which base mode the henchman is in.
        if(ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND)) sBaseMode = "I'm holding here.";
        else if(ai_GetAIMode(oAssociate, AI_MODE_DEFEND_MASTER)) sBaseMode = "I'm defending you.";
        else if(ai_GetAIMode(oAssociate, AI_MODE_FOLLOW)) sBaseMode = "I'm following you.";
        if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_peaceful") sBaseMode = "I will not fight the enemy!";
        if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK)) sVolume = " While not speaking unless spoken to.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN, sBaseMode + sVolume);
    }
    else if(sParam == "CombatTactics")
    {
        string sRangedUse = "", sCombatTactic = "I'm using my best judgement in combat ";
        string sAtkAssociates = "";
        string sTargets = "against all enemies and ";
        // Lets get which base mode the henchman is in.
        if(ai_GetAIMode(oAssociate, AI_MODE_CHECK_ATTACK)) sTargets = "against enemies I can handle and ";
        if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_ambusher") sCombatTactic = "I'm using ambush tactics ";
        else if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_defensive") sCombatTactic = "I'm using defensive tactics ";
        else if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_taunter") sCombatTactic = "I'm ready to taunt ";
        else if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_cntrspell") sCombatTactic = "I'm ready to counter spell ";
        if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_peaceful")
        {
            sCombatTactic = "I will not fight the enemy!";
            sTargets = "";
        }
        else
        {
            if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED)) sRangedUse = "will not use a ranged weapon.";
            else sRangedUse = "will use a ranged weapon.";
            if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES)) sAtkAssociates = " I will also ignore familiars, companions, and summons.";
            else sAtkAssociates = " I will also attack familiars, companions, and summons.";
        }
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 1, sCombatTactic + sTargets + sRangedUse + sAtkAssociates);
    }
    else if(sParam == "Plans")
    {
        float fFollowRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE);
        string sFollowRange = FloatToString(fFollowRange, 0, 0);
        string sDistance = "I'm following from " + sFollowRange + " meters away while";
        string sStealth, sSearch, sPickup;
        if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sPickup = " picking up items";
        else sPickup = " not picking up any items";
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sStealth = " in stealth";
        else sStealth = "";
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sSearch = " and searching";
        else sSearch = "";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 2, sDistance + sPickup + sStealth + sSearch + ".");
    }
    else if(sParam == "Healing")
    {
        string sHealingIn = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT)) + "%";
        string sHealingOut = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT)) + "%";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 4, "I'm healing our allies if they go below " +
                 sHealingIn + " health in combat and " + sHealingOut + " out of combat.");
    }
    else if(sParam == "Spells")
    {
        string sCastingLevel = "[" + IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT)) + "] ";
        string sCasting = "I'm casting";
        string sType = " spells I choose.";
        string sBuff = " I'll also targeting anyone that needs it ";
        string sDispel = "while using Dispel spells.";
        string sMagicItems = " Lastly I'll use any magic items I have.";
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER)) sBuff = " Ofcourse I'll target you first ";
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_STOP_DISPEL)) sDispel = "while not using Dispel spells.";
        if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_a_cntrspell")
        {
            sCasting = "I'm ready to counter spell our enemies.";
            sType = "";
            sBuff = "";
            sDispel = "";
        }
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC))
        {
            sCasting = "I'm not use any magic.";
            sType = "";
            sBuff = "";
            sDispel = "";
        }
        else if(ai_GetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sType = " defensive spells only.";
        else if(ai_GetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING))
        {
            sType = " offensive spells only.";
            sBuff = "";
        }
        else if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS)) sMagicItems = " Finally I'll not use magic items.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 5, sCastingLevel + sCasting + sType + sBuff + sDispel+ sMagicItems);
    }
    else if(sParam == "Objects")
    {
        int bTraps = ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS);
        int bLocks = ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS);
        int bBash = ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS);
        string sText = "I'm going to ignore all traps and locks.";
        if(bTraps && bLocks && bBash)
        {
            sText = "I'm disarming all the traps and am either picking or bashing any of the locks we find.";
        }
        else if(bTraps && bLocks) sText = "I'm going to disarm all the traps and I'll pick all the locks we encounter.";
        else if(bTraps && bBash) sText = "I shall disarm all the traps and will bash any locks we come across.";
        else if(bTraps) sText = "I will disarm all the traps I can but will leave any locks for you to deal with.";
        else if(bLocks && bBash) sText = "I will leave the traps for you but will either pick or bash any locks we see.";
        else if(bLocks) sText = "I'll keep my distance from any traps we see, but will pick the locks found.";
        else if(bBash) sText = "I'll let you mess with the traps, but I'll bash any locks that are out there.";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 3, sText);
    }
    else if(sParam == "RestBuffing")
    {
        string sRestBuffing = "";
        if(!ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sRestBuffing = "not ";
        SetCustomToken(AI_BASE_CUSTOM_TOKEN + 10, "After we rest I am " + sRestBuffing + "casting my long buff spells on us.");
    }
    return TRUE;
}
