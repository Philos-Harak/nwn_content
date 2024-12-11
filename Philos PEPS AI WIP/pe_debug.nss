/*//////////////////////////////////////////////////////////////////////////////
 Script Name: pe_debug
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    PEPS Plugin to allow use of special Debug scripts
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_main"
#include "0i_module"
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
        if(sTargetMode == "DEBUG_CREATURE")
        {
            object oModule = GetModule();
            string sDebugName = GetName(oTarget);
            SetLocalString(oModule, AI_RULE_DEBUG_CREATURE, sDebugName);
            json jRules = ai_GetCampaignDbJson("rules");
            JsonObjectSetInplace(jRules, AI_RULE_DEBUG_CREATURE, JsonString(sDebugName));
            ai_SetCampaignDbJson("rules", jRules);
            SetLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT", oTarget);
            ExecuteScript("pi_debug", oPC);
        }
        else if(sTargetMode == "FIX_ASSOCIATE_SCRIPTS")
        {
            if(GetMaster(oTarget) == oPC)
            {
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
                    string sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH);
                    if(sScript != "0e_ch_7_ondeath" && sScript != "0e_ch_7_death")
                    {
                        SetLocalString(oTarget, "AI_ON_DEATH", sScript);
                    }
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
                    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
                }
            else ai_SendMessages(GetName(oTarget) + " is not one of your associates!", AI_COLOR_RED, oPC);
        }
        else if(sTargetMode == "DEBUG_EVENT_SCRIPTS")
        {
            int nObjectType = GetObjectType(oTarget);
            if(nObjectType == OBJECT_TYPE_CREATURE)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " Event Scripts.");
                string sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_HEARTBEAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_NOTICE SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_END_COMBATROUND SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DIALOGUE SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_MELEE_ATTACKED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DAMAGED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DEATH SCRIPT: " + sScript);
                sScript = GetLocalString(oTarget, "AI_ON_DEATH");
                if(sScript != "")
                {
                    sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                    SendMessageToPC(oPC, "ON_DEATH SECOND SCRIPT: " + sScript);
                }
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DISTURBED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_SPAWN_IN SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_RESTED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_SPELLCASTAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_BLOCKED_BY_DOOR SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USER_DEFINED_EVENT SCRIPT: " + sScript);
            }
            else if(nObjectType == OBJECT_TYPE_DOOR)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " Event Scripts.");
                string sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_CLICKED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_CLICKED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_CLOSE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_CLOSED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_DAMAGE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DAMAGE SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_DEATH);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DEATH SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_DIALOGUE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DIALOGUE SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_DISARM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DISARM SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_FAIL_TO_OPEN SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_HEARTBEAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_HEARTBEAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_LOCK);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_LOCK SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_MELEE_ATTACKED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_OPEN);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_OPEN SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_SPELLCASTAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_SPELLCASTAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_TRAPTRIGGERED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_TRAPTRIGGERED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_UNLOCK);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_UNLOCK SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_DOOR_ON_USERDEFINED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USERDEFINED SCRIPT: " + sScript);
            }
            else if(nObjectType == OBJECT_TYPE_PLACEABLE)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " Event Scripts.");
                string sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_CLOSED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_CLOSED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DAMAGED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_DEATH);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DEATH SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DIALOGUE SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_DISARM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DISARM SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_HEARTBEAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_INVENTORYDISTURBED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_LEFT_CLICK SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_LOCK);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_LOCK SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_MELEEATTACKED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_OPEN);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_OPEN SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_SPELLCASTAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_TRAPTRIGGERED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_UNLOCK SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_USED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USER_DEFINED_EVENT SCRIPT: " + sScript);
            }
            else if(nObjectType == OBJECT_TYPE_TRIGGER)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " Event Scripts.");
                string sScript = GetEventScript(oTarget, EVENT_SCRIPT_TRIGGER_ON_CLICKED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_CLICKED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_DISARM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_DISARM SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_HEARTBEAT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_OBJECT_ENTER SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_OBJECT_EXIT SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_TRAPTRIGGERED SCRIPT: " + sScript);
                sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USER_DEFINED_EVENT SCRIPT: " + sScript);
            }
            else
            {
                // Area event scripts.
                object oArea = GetArea(oPC);
                SendMessageToPC(oPC, GetName(oArea) + " Area Event Scripts.");
                string sScript = GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_ENTER SCRIPT: " + sScript);
                sScript = GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_EXIT SCRIPT: " + sScript);
                sScript = GetEventScript(oArea, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_HEARTBEAT SCRIPT: " + sScript);
                sScript = GetEventScript(oArea, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USER_DEFINED_EVENT SCRIPT: " + sScript);
                // Module event scripts.
                object oModule = GetModule();
                SendMessageToPC(oPC, GetModuleName() + " Module Event Scripts.");
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_ACQUIRE_ITEM SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_ACTIVATE_ITEM SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_CLIENT_ENTER);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_CLIENT_ENTER SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_CLIENT_EXIT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_CLIENT_EXIT SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_EQUIP_ITEM SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_HEARTBEAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_HEARTBEAT SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_LOSE_ITEM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_LOSE_ITEM SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_MODULE_LOAD);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_MODULE_LOAD SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_MODULE_START);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_MODULE_START SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_NUI_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_NUI_EVENT SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_CANCEL_CUTSCENE);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_CANCEL_CUTSCENE SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_CHAT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_CHAT SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_DEATH);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_DEATH SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_DYING);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_DYING SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_GUIEVENT SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_LEVEL_UP SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_REST);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_REST SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_TARGET SCRIPT: " + sScript);
                sScript = GetLocalString(oModule, AI_MODULE_TARGET_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                if(sScript != "")
                {
                    sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                    SendMessageToPC(oPC, "ON_PLAYER_TARGET SECOND SCRIPT: " + sScript);
                }
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_TILE_ACTION);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_PLAYER_TILE_ACTION SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_RESPAWN_BUTTON_PRESSED SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_UNEQUIP_ITEM SCRIPT: " + sScript);
                sScript = GetEventScript(oModule, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT);
                sScript += " [" + ResManGetAliasFor(sScript, RESTYPE_NCS) + "]";
                SendMessageToPC(oPC, "ON_USER_DEFINED_EVENT SCRIPT: " + sScript);
            }
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
            if(sElem == "btn_event_scripts")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_EVENT_SCRIPTS");
                NuiDestroy(oPC, nToken);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL , MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_fix_associate")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "FIX_ASSOCIATE_SCRIPTS");
                NuiDestroy(oPC, nToken);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_debug_creature")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_CREATURE");
                NuiDestroy(oPC, nToken);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_clear_debug")
            {
                object oModule = GetModule();
                SetLocalString(oModule, AI_RULE_DEBUG_CREATURE, "");
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_RULE_DEBUG_CREATURE, JsonString(""));
                ai_SetCampaignDbJson("rules", jRules);
                DeleteLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT");
                ai_SendMessages("Creature Debug mode has been cleared.", AI_COLOR_YELLOW, oPC);
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_debug", oPC);
            }
        }
    }
}


