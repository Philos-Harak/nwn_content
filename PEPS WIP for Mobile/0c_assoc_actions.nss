/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_assoc_actions
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Conversation script that sets modes or allows oAssociate to do actions from a
 conversation.
 Param "sAction"
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
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
        if(ai_GetAIMode(oAssociate, AI_MODE_SCOUT_AHEAD))
        {
            ai_ClearCreatureActions();
            ai_HaveCreatureSpeak(oAssociate, 6, ":29:35:46:10");
            ai_SetAIMode(oAssociate, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SendMessages(GetName(oAssociate) + " has stopped patrolling ahead.", AI_COLOR_YELLOW, oPC);
        }
        else
        {
            ai_ClearCreatureActions();
            ai_HaveCreatureSpeak(oAssociate, 6, ":29:35:46:22:");
            ai_SetAIMode(oAssociate, AI_MODE_SCOUT_AHEAD, TRUE);
            ai_SendMessages(GetName(oAssociate) + " is now patrolling ahead.", AI_COLOR_YELLOW, oPC);
            ai_ScoutAhead(oAssociate);
        }
    }
    else if(sAction == "BasicTactics")
    {
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, "");
        ai_SetAssociateAIScript(oAssociate, FALSE);
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
    else if(sAction == "RangedTactics")
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_ranged");
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, "ai_a_ranged");
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
    else if(sAction == "HealSelf") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
    else if(sAction == "HealAllies") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
    else if(sAction == "HealOutMinus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "HealOutPlus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "HealInMinus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "HealInPlus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
    else if(sAction == "Traps") ai_Traps(oPC, oAssociate, sAssociateType);
    else if(sAction == "Locks") ai_Locks(oPC, oAssociate, sAssociateType, 1);
    else if(sAction == "Bash") ai_Locks(oPC, oAssociate, sAssociateType, 2);
    else if(sAction == "Search") ai_Search(oPC, oAssociate, sAssociateType);
    else if(sAction == "Stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
    else if(sAction == "NoMagic") ai_UseMagic(oPC, oAssociate, sAssociateType);
    else if(sAction == "DefensiveCasting") ai_UseOffensiveMagic(oPC, oAssociate, TRUE, FALSE, sAssociateType);
    else if(sAction == "OffensiveCasting") ai_UseOffensiveMagic(oPC, oAssociate, FALSE, TRUE, sAssociateType);
    else if(sAction == "MagicMinus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
    else if(sAction == "MagicPlus") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
    else if(sAction == "Speaking")
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK))
        {
            ai_SetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK, FALSE);
        }
        else ai_SetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK, TRUE);
    }
    else if(sAction == "Ranged")
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED))
        {
            ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, FALSE);
        }
        else ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, TRUE);
    }
    else if(sAction == "AtkAssociates")
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES))
        {
            ai_SetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES, FALSE);
        }
        else ai_SetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES, TRUE);
    }
    else if(sAction == "BuffFirst")
    {
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER))
        {
            ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER, FALSE);
        }
        else ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER, TRUE);
    }
    else if(sAction == "RestBuffing")
    {
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST))
        {
            ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, FALSE);
        }
        else ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, TRUE);
    }
    else if(sAction == "Dispel")
    {
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_STOP_DISPEL))
        {
            ai_SetMagicMode(oAssociate, AI_MAGIC_STOP_DISPEL, FALSE);
        }
        else ai_SetMagicMode(oAssociate, AI_MAGIC_STOP_DISPEL, TRUE);
    }
    else if(sAction == "MagicItems")
    {
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS))
        {
            ai_SetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS, FALSE);
        }
        else ai_SetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS, TRUE);
    }
    else if(sAction == "Identify")
    {
        ai_IdentifyAllVsKnowledge(oAssociate, oPC, oPC);
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
    else if(sAction == "GetHenchTokens")
    {
        int nCount, nCntr = 1;
        object oHenchman = GetHenchman(oPC, nCntr);
        while(oHenchman != OBJECT_INVALID && nCntr <= AI_MAX_HENCHMAN)
        {
            if(oHenchman == OBJECT_INVALID) break;
            if(oHenchman != oAssociate)
            {
                SetCustomToken(77101 + nCount, GetName(oHenchman));
                nCount++;
            }
            oHenchman = GetHenchman(oPC, ++nCntr);
        }
        ai_SetupAllyTargets(oAssociate, oPC);
        return;
    }
    aiSaveAssociateModesToDb(oPC, oAssociate);
}

