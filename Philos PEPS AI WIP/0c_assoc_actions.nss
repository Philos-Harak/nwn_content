/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_assoc_actions
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Conversation script that sets modes or allows oAssociate to do actions from a
 conversation.
 Param "sAction"
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_assoc_debug"
void main()
{
    object oPC = GetPCSpeaker();
    object oAssociate = OBJECT_SELF;
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    object oArea = GetArea(oAssociate);
    string sAction = GetScriptParam("sAction");
    // Scout ahead is done int 0e_ch_1_hb (heartbeat script).
    if(sAction == "Scout")
    {
        ai_ClearCreatureActions();
        ai_HaveCreatureSpeak(oAssociate, 4, ":29:35:46:");
        ai_SetAIMode(oAssociate, AI_MODE_SCOUT_AHEAD, TRUE);
        ai_ScoutAhead(oAssociate);
    }
    else if(sAction == "BasicTactics")
    {
        ai_SetAIMode(oAssociate, FALSE);
    }
    else if(sAction == "AmbushTactics")
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_ambusher");
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, "ai_a_ambusher");
    }
    else if(sAction == "DefensiveTactics")
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_defensive");
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, "ai_a_defensive");
    }
    else if(sAction == "Taunt")
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_taunter");
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, "ai_a_taunter");
    }
    else if(sAction == "CounterSpell")
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_cntrspell");
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, "ai_a_cntrspell");
    }
    else if(sAction == "PeaceTactics")
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_peaceful");
    }
    else if(sAction == "AttackTactics")
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_CHECK_ATTACK))
        {
            ai_SetAIMode(oAssociate, AI_MODE_CHECK_ATTACK, FALSE);
        }
        else ai_SetAIMode(oAssociate, AI_MODE_CHECK_ATTACK, TRUE);
    }
    else if(sAction == "FollowCloser") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
    else if(sAction == "FollowFarther") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
    else if(sAction == "Pickup") ai_Loot(oPC, oAssociate, sAssociateType);
    else if(sAction == "NoHealSelf") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
    else if(sAction == "NoHealAllies") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
    else if(sAction == "HealOutMinus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "HealOutPlus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "HealInMinus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "HealInPlus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "UseRanged")
    {
        ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, FALSE);
    }
    else if(sAction == "Ranged")
    {
        ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, TRUE);
    }
    else if(sAction == "AtkAssociates")
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES))
        {
            ai_SetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES, FALSE);
        }
        else ai_SetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES, TRUE);
    }
    else if(sAction == "Invisibility")
    {
        ai_SetAIMode(oAssociate, AI_MODE_NO_STEALTH, FALSE);
    }
    else if(sAction == "NoInvisibility")
    {
        ai_SetAIMode(oAssociate, AI_MODE_NO_STEALTH, TRUE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
    }
    else if(sAction == "Traps") ai_Traps(oPC, oAssociate, sAssociateType);
    else if(sAction == "Locks") ai_Locks(oPC, oAssociate, sAssociateType, 1);
    else if(sAction == "Bash") ai_Locks(oPC, oAssociate, sAssociateType, 2);
    else if(sAction == "Search") ai_Search(oPC, oAssociate, sAssociateType);
    else if(sAction == "Stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
    else if(sAction == "BuffMaster")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER, TRUE);
    }
    else if(sAction == "BuffAnyone")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER, FALSE);
    }
    else if(sAction == "RestBuffing")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, TRUE);
    }
    else if(sAction == "DoNotRestBuffing")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, FALSE);
    }
    else if(sAction == "NoMagic") ai_UseMagic(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
    else if(sAction == "UseMagic")ai_UseMagic(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
    else if(sAction == "DefensiveCasting") ai_UseMagic(oPC, oAssociate, FALSE, TRUE, FALSE, sAssociateType);
    else if(sAction == "OffensiveCasting") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, TRUE, sAssociateType);
    else if(sAction == "Dispel")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_STOP_DISPEL, FALSE);
    }
    else if(sAction == "DoNotDispel")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_STOP_DISPEL, TRUE);
    }
    else if(sAction == "NoMagicItems")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS, TRUE);
    }
    else if(sAction == "UseMagicItems")
    {
        ai_SetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS, FALSE);
    }
    else if(sAction == "MagicMinus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
    else if(sAction == "MagicPlus") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
    else if(sAction == "Identify")
    {
        ai_IdentifyAllVsKnowledge(oPC, oPC);
        ai_IdentifyAllVsKnowledge(oAssociate, oPC);
        return;
    }
    else if(sAction == "GiveUnIdentifiedItems")
    {
        ai_ClearCreatureActions();
        object oItem = GetFirstItemInInventory(oAssociate);
        while(oItem != OBJECT_INVALID)
        {
            if(!GetIdentified(oItem)) ActionGiveItem(oItem, oPC);
            oItem = GetNextItemInInventory(oAssociate);
        }
        return;
    }
    else if(sAction == "GiveMagicItems")
    {
        ai_ClearCreatureActions();
        itemproperty ipItemProp;
        object oItem = GetFirstItemInInventory(oAssociate);
        while(oItem != OBJECT_INVALID)
        {
            ipItemProp = GetFirstItemProperty(oItem);
            if(GetIsItemPropertyValid(ipItemProp)) ActionGiveItem(oItem, oPC);
            oItem = GetNextItemInInventory(oAssociate);
        }
        return;
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
