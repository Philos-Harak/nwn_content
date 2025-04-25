/*//////////////////////////////////////////////////////////////////////////////
 Script Name: pe_mod_settings
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    PEPS Plugin to set module and area settings.
/*//////////////////////////////////////////////////////////////////////////////
const string AI_MODULE_HEARTBEAT_SCRIPT = "AI_MODULE_HEARTBEAT_SCRIPT";

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
            ai_SendMessages(GetName(oTarget) + " has rested.", AI_COLOR_GREEN, oPC);
        }
        else if(sTargetMode == "TEST_HEAL_TARGET")
        {
            int nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
            if(nHeal > 0)
            {
                effect eHeal = EffectHeal(nHeal);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
                ai_SendMessages(GetName(oTarget) + " has been healed.", AI_COLOR_GREEN, oPC);
            }
        }
        else if(sTargetMode == "TEST_ID_TARGET") SetIdentified(oTarget, !GetIdentified(oTarget));
        else if(sTargetMode == "TEST_CLEAR_TARGET")
        {
            //ClearAllActions(TRUE, oTarget);
        }
        else if(sTargetMode == "TEST_KILL_TARGET")
        {
            effect eDmg = EffectDamage(10000);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
            ai_SendMessages(GetName(oTarget) + " has been killed.", AI_COLOR_RED, oPC);
        }
        else if(sTargetMode == "TEST_REMOVE_TARGET")
        {
            //SetIsDestroyable(TRUE, FALSE, FALSE, oTarget);
            DestroyObject(oTarget);
            ai_SendMessages(GetName(oTarget) + " has been removed!", AI_COLOR_RED, oPC);
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
            if(sElem == "btn_combat_music_off")
            {
                object oArea = GetFirstArea();
                while(GetIsObjectValid(oArea))
                {
                    MusicBattleChange(oArea, 0);
                    oArea = GetNextArea();
                }
                ai_SendMessages(GetModuleName() + " has had the combat music removed. Save your game or you may loose this change!", AI_COLOR_GREEN, oPC);
            }
            if(sElem == "btn_night_to_day")
            {
                object oModule = GetModule();
                string sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_HEARTBEAT);
                if(sScript == "pc_mod_set")
                {
                    sScript = GetLocalString(oPC, AI_MODULE_HEARTBEAT_SCRIPT);
                    SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_HEARTBEAT, sScript);
                    DeleteLocalString(oPC, AI_MODULE_HEARTBEAT_SCRIPT);
                    SendMessageToPC(oPC, "Module has been set to use normal time passage!");
                }
                else
                {
                    SetLocalString(oPC, AI_MODULE_HEARTBEAT_SCRIPT, sScript);
                    SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_HEARTBEAT, "pc_mod_set");
                    SendMessageToPC(oPC, "Module has been set to pass through nighttime to make it morning!");
                }
            }
        }
    }
}


