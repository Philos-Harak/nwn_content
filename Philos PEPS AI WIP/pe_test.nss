/*//////////////////////////////////////////////////////////////////////////////
 Script Name: pe_test
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    PEPS Plugin to help test errors.
    Gives gold, Heals, etc.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_main"
void main()
{
    // Get the last player to use targeting mode
    object oPC = GetLastPlayerToSelectTarget();
    string sTargetMode = GetLocalString(oPC, AI_TARGET_MODE);
    if(oPC == OBJECT_SELF && sTargetMode != "")
    {
        // Get the targeting mode data
        object oTarget = GetTargetingModeSelectedObject();
        vector vTarget = GetTargetingModeSelectedPosition();
        location lLocation = Location(GetArea(oPC), vTarget, GetFacing(oPC));
        object oAssociate = GetLocalObject(oPC, AI_TARGET_ASSOCIATE);
        // If the user manually exited targeting mode without selecting a target, return
        if(!GetIsObjectValid(oTarget) && vTarget == Vector())
        {
            return;
        }
        // Targeting code here.
        if(sTargetMode == "TEST_LEVEL_TARGET")
        {
            int nLevel = ai_GetCharacterLevels(oTarget);
            int nXPNeeded = StringToInt(Get2DAString("exptable", "XP", nLevel));
            int nXPToGive = nXPNeeded - GetXP(oTarget);
            GiveXPToCreature(oTarget, nXPToGive);
            ai_SendMessages(GetName(oTarget) + " has gained " + IntToString(nXPToGive) + " experience to gain 1 level.", AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "TEST_GOLD_TARGET")
        {
            GiveGoldToCreature(oTarget, 10000);
            ai_SendMessages(GetName(oTarget) + " has gained 10,000 gold.", AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "TEST_REST_TARGET")
        {
            ForceRest(oTarget);
            ai_SendMessages(GetName(oTarget) + " has rested.", AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "TEST_HEAL_TARGET")
        {
            int nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
            if(nHeal > 0)
            {
                effect eHeal = EffectHeal(nHeal);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
                ai_SendMessages(GetName(oTarget) + " has been healed.", AI_COLOR_YELLOW, oPC);
            }
        }
        else if(sTargetMode == "TEST_KILL_TARGET")
        {
            effect eDmg = EffectDamage(10000);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
            ai_SendMessages(GetName(oTarget) + " has been killed.", AI_COLOR_YELLOW, oPC);
        }
    }
    // Run all non-targeting code here, usually NUI events.
    else
    {
        object oPC = NuiGetEventPlayer();
        int nToken  = NuiGetEventWindow();
        string sEvent = NuiGetEventType();
        string sElem  = NuiGetEventElement();
        int nIndex = NuiGetEventArrayIndex();
        //string sWndId = NuiGetWindowId(oPC, nToken);
        //**********************************************************************
        //if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
        if(sEvent == "click")
        {
            if(sElem == "btn_level")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_test");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "TEST_LEVEL_TARGET");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE , MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_gold")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_test");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "TEST_GOLD_TARGET");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE , MOUSECURSOR_USE, MOUSECURSOR_NOUSE);
            }
            else if(sElem == "btn_rest")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_test");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "TEST_REST_TARGET");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE , MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_heal")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_test");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "TEST_HEAL_TARGET");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_HEAL, MOUSECURSOR_NOHEAL);
            }
            else if(sElem == "btn_kill")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_test");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "TEST_KILL_TARGET");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_KILL, MOUSECURSOR_NOKILL);
            }
        }
        else if(sEvent == "watch")
        {
            if(sElem == "txt_debug_creature")
            {
            }
        }
    }
}


