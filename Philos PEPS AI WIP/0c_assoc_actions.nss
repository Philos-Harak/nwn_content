/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_assoc_actions
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Conversation script that sets modes or allows henchmen to do actions from a conversation.
 Param "sAction"
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oPC = GetPCSpeaker();
    object oHenchman = OBJECT_SELF;
    object oArea = GetArea(oHenchman);
    string sAction = GetScriptParam("sAction");
    // Scout ahead is done int 0e_ch_1_hb (heartbeat script).
    if(sAction == "Scout")
    {
        ai_ClearCreatureActions();
        ai_HaveCreatureSpeak(oHenchman, 4, ":29:35:46:");
        ai_SetAIMode(oHenchman, AI_MODE_SCOUT_AHEAD, TRUE);
        ai_ScoutAhead(oHenchman);
    }
    else if(sAction == "BasicTactics")
    {
        ai_SetAIMode(oHenchman, FALSE);
    }
    else if(sAction == "AmbushTactics")
    {
        SetLocalString(oHenchman, AI_COMBAT_SCRIPT, "ai_a_ambusher");
    }
    else if(sAction == "DefensiveTactics")
    {
        SetLocalString(oHenchman, AI_COMBAT_SCRIPT, "ai_a_defensive");
    }
    else if(sAction == "Taunt")
    {
        SetLocalString(oHenchman, AI_COMBAT_SCRIPT, "ai_a_taunter");
    }
    else if(sAction == "CounterSpell")
    {
        SetLocalString(oHenchman, AI_COMBAT_SCRIPT, "ai_a_cntrspell");
    }
    else if(sAction == "StopTaunting" || sAction == "StopCounterSpelling")
    {
        string sAIScript = GetLocalString(oHenchman, AI_DEFAULT_SCRIPT);
        SetLocalString(oHenchman, AI_COMBAT_SCRIPT, sAIScript);
    }
    else if(sAction == "PeaceTactics")
    {
        SetLocalString(oHenchman, AI_COMBAT_SCRIPT, "ai_coward");
    }
    else if(sAction == "AttackAlwaysTactics")
    {
        ai_SetAIMode(oHenchman, AI_MODE_CHECK_ATTACK, FALSE);
    }
    else if(sAction == "CheckAttackTactics")
    {
        ai_SetAIMode(oHenchman, AI_MODE_CHECK_ATTACK, TRUE);
    }
    else if(sAction == "Distance2m")
    {
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_CLOSE, TRUE);
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_MEDIUM, FALSE);
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_LONG, FALSE);
    }
    else if(sAction == "Distance4m")
    {
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_CLOSE, FALSE);
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_MEDIUM, TRUE);
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_LONG, FALSE);
    }
    else if(sAction == "Distance6m")
    {
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_CLOSE, FALSE);
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_MEDIUM, FALSE);
        ai_SetAIMode(oHenchman, AI_MODE_DISTANCE_LONG, TRUE);
    }
    else if(sAction == "PickupNone")
    {
        ai_SetAIMode(oHenchman, AI_MODE_PICKUP_ITEMS, FALSE);
    }
    else if(sAction == "PickupAll")
    {
        ai_SetAIMode(oHenchman, AI_MODE_PICKUP_ITEMS, TRUE);
    }
    else if(sAction == "HealIn25")
    {
    }
    else if(sAction == "HealIn50")
    {
    }
    else if(sAction == "HealIn75")
    {
    }
    else if(sAction == "HealOut25")
    {
    }
    else if(sAction == "HealOut50")
    {
    }
    else if(sAction == "HealOut75")
    {
    }
    else if(sAction == "UseRanged")
    {
        ai_SetAIMode(oHenchman, AI_MODE_STOP_RANGED, FALSE);
    }
    else if(sAction == "StopRanged")
    {
        ai_SetAIMode(oHenchman, AI_MODE_STOP_RANGED, TRUE);
    }
    else if(sAction == "AtkAssociates")
    {
        ai_SetAIMode(oHenchman, AI_MODE_IGNORE_ASSOCIATES, FALSE);
    }
    else if(sAction == "StopAtkAssociates")
    {
        ai_SetAIMode(oHenchman, AI_MODE_IGNORE_ASSOCIATES, TRUE);
    }
    else if(sAction == "Invisibility")
    {
        ai_SetAIMode(oHenchman, AI_MODE_NO_STEALTH, FALSE);
    }
    else if(sAction == "NoInvisibility")
    {
        ai_SetAIMode(oHenchman, AI_MODE_NO_STEALTH, TRUE);
        ai_SetAIMode(oHenchman, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
    }
    else if(sAction == "TrapsOn")
    {
        ai_SetAIMode(oHenchman, AI_MODE_DISARM_TRAPS, TRUE);
    }
    else if(sAction == "TrapsOff")
    {
        ai_SetAIMode(oHenchman, AI_MODE_DISARM_TRAPS, FALSE);
    }
    else if(sAction == "LocksOn")
    {
        ai_SetAIMode(oHenchman, AI_MODE_PICK_LOCKS, TRUE);
    }
    else if(sAction == "LocksOff")
    {
        ai_SetAIMode(oHenchman, AI_MODE_PICK_LOCKS, FALSE);
    }
    else if(sAction == "Search")
    {
        ai_HaveCreatureSpeak(oHenchman, 6, ":29:46:27:33:35:");
        SetActionMode(oHenchman, ACTION_MODE_DETECT, TRUE);
    }
    else if(sAction == "StopSearching")
    {
        SetActionMode(oHenchman, ACTION_MODE_DETECT, FALSE);
    }
    else if(sAction == "StealthOn")
    {
        ai_HaveCreatureSpeak(oHenchman, 6, ":29:46:28:42:31:35:");
        ai_SetAIMode(oHenchman, AI_MODE_AGGRESSIVE_STEALTH, TRUE);
        ai_SetAIMode(oHenchman, AI_MODE_NO_STEALTH, FALSE);
    }
    else if(sAction == "StealthOff")
    {
        ai_SetAIMode(oHenchman, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
        SetActionMode(oHenchman, ACTION_MODE_STEALTH, FALSE);
    }
    else if(sAction == "StealthNow")
    {
        ai_HaveCreatureSpeak(oHenchman, 6, ":29:46:28:42:31:35:");
        DelayCommand(0.5, SetActionMode(oHenchman, ACTION_MODE_STEALTH, TRUE));
        ai_SetAIMode(oHenchman, AI_MODE_NO_STEALTH, FALSE);
    }
    else if(sAction == "BuffMaster")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_BUFF_MASTER, TRUE);
    }
    else if(sAction == "BuffAnyone")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_BUFF_MASTER, FALSE);
    }
    else if(sAction == "RestBuffing")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_BUFF_AFTER_REST, TRUE);
    }
    else if(sAction == "DoNotRestBuffing")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_BUFF_AFTER_REST, FALSE);
    }
    else if(sAction == "NoMagic")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_NO_MAGIC, TRUE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
    }
    else if(sAction == "UseMagic")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_NO_MAGIC, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
    }
    else if(sAction == "DefensiveCasting")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_NO_MAGIC, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_DEFENSIVE_CASTING, TRUE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
    }
    else if(sAction == "OffensiveCasting")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_NO_MAGIC, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_OFFENSIVE_CASTING, TRUE);
    }
    else if(sAction == "Dispel")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_STOP_DISPEL, FALSE);
    }
    else if(sAction == "DoNotDispel")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_STOP_DISPEL, TRUE);
    }
    else if(sAction == "NoMagicItems")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_NO_MAGIC_ITEMS, TRUE);
    }
    else if(sAction == "UseMagicItems")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_NO_MAGIC_ITEMS, FALSE);
    }
    else if(sAction == "LowMagic")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_LOW_MAGIC_USE, TRUE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_NORMAL_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_HEAVY_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_CONSTANT_MAGIC_USE, FALSE);
        SetLocalInt(oHenchman, AI_DIFFICULTY_ADJUSTMENT, -10);
    }
    else if(sAction == "NormalMagic")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_LOW_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_NORMAL_MAGIC_USE, TRUE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_HEAVY_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_CONSTANT_MAGIC_USE, FALSE);
        SetLocalInt(oHenchman, AI_DIFFICULTY_ADJUSTMENT, 0);
    }
    else if(sAction == "HeavyMagic")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_LOW_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_NORMAL_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_HEAVY_MAGIC_USE, TRUE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_CONSTANT_MAGIC_USE, FALSE);
        SetLocalInt(oHenchman, AI_DIFFICULTY_ADJUSTMENT, 10);
    }
    else if(sAction == "ConstantMagic")
    {
        ai_SetMagicMode(oHenchman, AI_MAGIC_LOW_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_NORMAL_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_HEAVY_MAGIC_USE, FALSE);
        ai_SetMagicMode(oHenchman, AI_MAGIC_CONSTANT_MAGIC_USE, TRUE);
        SetLocalInt(oHenchman, AI_DIFFICULTY_ADJUSTMENT, 40);
    }
    else if(sAction == "Identify")
    {
        ai_IdentifyAllVsKnowledge(oPC, oPC);
        ai_IdentifyAllVsKnowledge(oHenchman, oPC);
        return;
    }
    else if(sAction == "GiveUnIdentifiedItems")
    {
        ai_ClearCreatureActions();
        object oItem = GetFirstItemInInventory(oHenchman);
        while(oItem != OBJECT_INVALID)
        {
            if(!GetIdentified(oItem)) ActionGiveItem(oItem, oPC);
            oItem = GetNextItemInInventory(oHenchman);
        }
        return;
    }
    else if(sAction == "GiveMagicItems")
    {
        ai_ClearCreatureActions();
        itemproperty ipItemProp;
        object oItem = GetFirstItemInInventory(oHenchman);
        while(oItem != OBJECT_INVALID)
        {
            ipItemProp = GetFirstItemProperty(oItem);
            if(GetIsItemPropertyValid(ipItemProp)) ActionGiveItem(oItem, oPC);
            oItem = GetNextItemInInventory(oHenchman);
        }
        return;
    }
    aiSaveAssociateAIModesToDb(oPC, oHenchman);
}
