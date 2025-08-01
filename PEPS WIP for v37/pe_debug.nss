/*//////////////////////////////////////////////////////////////////////////////
 Script Name: pe_debug
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    PEPS Plugin to allow use of special Debug scripts
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_main"
#include "0i_module"
#include "0i_menus"
//#include "prc_inc_eventhk"
// Gets a variable from oTarget, if oTarget is OBJECT_INVALID then
// it will get the variable from the Module and Area.
void debug_GetObjectVariable(object oPC, object oTarget, string sDesc = "");
// Lists the variables from oTarget to the screen.
void debug_ListObjectVariables(object oPC, object oTarget);
// Force event script change to default for oCreature.
void ai_ForceAssociateEventScriptsToDefault(object oPC, object oCreature);
// Reverts event script change from default for oCreature.
void ai_RevertAssociateEventScriptsToDefault(object oPC, object oCreature);
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
        object oObject = GetLocalObject(oPC, "AI_TARGET_OBJECT");
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
            jRules = JsonObjectSet(jRules, AI_RULE_DEBUG_CREATURE, JsonString(sDebugName));
            ai_SetCampaignDbJson("rules", jRules);
            SetLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT", oTarget);
            ExecuteScript("pi_debug", oPC);
        }
        else if(sTargetMode == "CLEAR_REPUTATION")
        {
            int nReputation = GetFactionAverageReputation(oTarget, oPC);
            object oPCMember = GetFirstFactionMember(oPC, FALSE);
            while(GetIsObjectValid(oPCMember))
            {
                ClearPersonalReputation(oPCMember, oTarget);
                oPCMember = GetNextFactionMember(oPC, FALSE);
            }
            ai_SendMessages("Your reputation with " + GetName(oTarget) + " has been set to neutral.", AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "SET_REPUTATION")
        {
            SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oTarget);
            SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oTarget);
            SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 50, oTarget);
            SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oTarget);
            ai_SendMessages(GetName(oTarget) + " has been set to a neutral reputation.", AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "DEBUG_INFO")
        {
            ai_SendMessages("Information for " + GetName(oTarget), AI_COLOR_WHITE, oPC);
            ai_SendMessages("ResRef: " + GetResRef(oTarget), AI_COLOR_GREEN, oPC);
            ai_SendMessages("Tag: " + GetTag(oTarget), AI_COLOR_ORANGE, oPC);
            ai_SendMessages("UUID: " + GetObjectUUID(oTarget), AI_COLOR_LIGHT_MAGENTA, oPC);
            ai_SendMessages("Faction Commoner: " + IntToString(GetStandardFactionReputation(STANDARD_FACTION_COMMONER, oTarget)), AI_COLOR_GREEN, oPC);
            ai_SendMessages("Faction Defender: " + IntToString(GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, oTarget)), AI_COLOR_GREEN, oPC);
            ai_SendMessages("Faction Merchant: " + IntToString(GetStandardFactionReputation(STANDARD_FACTION_MERCHANT, oTarget)), AI_COLOR_GREEN, oPC);
            ai_SendMessages("Faction Hostile: " + IntToString(GetStandardFactionReputation(STANDARD_FACTION_HOSTILE, oTarget)), AI_COLOR_RED, oPC);
            int nObjectType = GetObjectType(oTarget);
            if(nObjectType == OBJECT_TYPE_CREATURE)
            {
                json jObject = ObjectToJson(oTarget);
                string sConversation = JsonGetString(GffGetResRef(jObject, "Conversation"));
                ai_SendMessages("Conversation: " + sConversation, AI_COLOR_CYAN, oPC);
                int nCurrentAction = GetCurrentAction(oTarget);
                ai_SendMessages("Current Action: " + IntToString(nCurrentAction), AI_COLOR_RED, oPC);
                SendMessageToPC(oPC, "Creature Event Scripts:");
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
                SendMessageToPC(oPC, "Door Event Scripts:");
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
                SendMessageToPC(oPC, "Placeable Event Scripts:");
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
                SendMessageToPC(oPC, "Trigger Event Scripts:");
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
                SendMessageToPC(oPC, "Area Event Scripts:");
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
            /* Checks PRC virtual events. See prc_inc_eventhk
            int nIndex = 1;
            string sEvent = GetFirstEventScript(oTarget, EVENT_VIRTUAL_ONHEARTBEAT, FALSE);
            if(sEvent != "")
            {
                SendMessageToPC(oPC, "HB event script " + IntToString(nIndex) + ": " + sEvent);
                for(nIndex = 2; nIndex < 20; nIndex++)
                {
                    sEvent = GetNextEventScript(oTarget, EVENT_VIRTUAL_ONHEARTBEAT, FALSE);
                    if(sEvent == "") break;
                    SendMessageToPC(oPC, "HB event script " + IntToString(nIndex) + ": " + sEvent);
                }
            }*/
        }
        else if(sTargetMode == "SET_NPC_SCRIPTS")
        {
            if(GetLocalString(oTarget, "AI_ON_HEARTBEAT") == "")
            {
                ai_ForceAssociateEventScriptsToDefault(oPC, oTarget);
            }
            else ai_RevertAssociateEventScriptsToDefault(oPC, oTarget);
        }
        else if(sTargetMode == "CLEAR_CREATURE_EVENTS")
        {
            ai_SendMessages("Set event scripts for " + GetName(oTarget) + " to default.", AI_COLOR_YELLOW, oPC);
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "default");
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "default");
            DeleteLocalInt(oTarget, "AI_I_AM_BEING_HEALED");
            DeleteLocalString(oTarget, "AIScript");
            ai_ClearCreatureActions();
        }
        else if(sTargetMode == "DEBUG_JSON_DUMP")
        {
            json jObject = ObjectToJson(oTarget, TRUE);
            WriteTimestampedLogEntry(GetName(oTarget) + " JsonDump: " + JsonDump(jObject, 1));
            ai_SendMessages(GetName(oTarget) + " has been dumped to the log file!", AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "DEBUG_LIST_VAR")
        {
            debug_ListObjectVariables(oPC, oTarget);
        }
        else if(sTargetMode == "DEBUG_SET_VARIABLE")
        {
            string sVarName = GetLocalString(oPC, "Debug_Var_Name");
            int nVarType = GetLocalInt(oPC, "Debug_Var_Type");
            if(nVarType == 0) // Int
            {
                string sVarValue = GetLocalString(oPC, "Debug_Var_Value");
                int nVarValue = StringToInt(sVarValue);
                SetLocalInt(oTarget, sVarName, nVarValue);
                ai_SendMessages(sVarName + " [Int] has been set to " + IntToString(nVarValue) + " for " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
            }
            else if(nVarType == 1) // Float
            {
                string sVarValue = GetLocalString(oPC, "Debug_Var_Value");
                DeleteLocalString(oPC, "Debug_Var_Name");
                float fVarValue = StringToFloat(sVarValue);
                SetLocalFloat(oTarget, sVarName, fVarValue);
                ai_SendMessages(sVarName + " [Float] has been set to " + FloatToString(fVarValue, 0, 2) + " for " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
            }
            else if(nVarType == 2) // String
            {
                string sVarValue = GetLocalString(oPC, "Debug_Var_Value");
                SetLocalString(oTarget, sVarName, sVarValue);
                ai_SendMessages(sVarName + " [String] has been set to " + sVarValue + " for " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
            }
            else if(nVarType == 3) // Object
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, "AI_TARGET_OBJECT", oTarget);
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_SET_OBJECT_VARIABLE");
                ai_SendMessages("Select an object to save to " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
                                   OBJECT_TYPE_ITEM | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_TRIGGER, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(nVarType == 4) // Location
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, "AI_TARGET_OBJECT", oTarget);
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_SET_LOCATION_VARIABLE");
                ai_SendMessages("Select a location to save to " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_TILE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            DeleteLocalString(oPC, "Debug_Var_Name");
            DeleteLocalInt(oPC, "Debug_Var_Type");
            DeleteLocalString(oPC, "Debug_Var_Value");
        }
        else if(sTargetMode == "DEBUG_SET_OBJECT_VARIABLE")
        {
            string sVarName = GetLocalString(oPC, "Debug_Var_Name");
            SetLocalObject(oObject, sVarName, oTarget);
            DeleteLocalObject(oPC, "AI_TARGET_OBJECT");
            DeleteLocalString(oPC, "Debug_Var_Name");
            ai_SendMessages(sVarName + " [Object] has been set to " + GetName(oObject) + " for " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "DEBUG_SET_LOCATION_VARIABLE")
        {
            string sVarName = GetLocalString(oPC, "Debug_Var_Name");
            SetLocalLocation(oObject, sVarName, lLocation);
            DeleteLocalObject(oPC, "AI_TARGET_OBJECT");
            DeleteLocalString(oPC, "Debug_Var_Name");
            ai_SendMessages(sVarName + " [Location] has been set to " + LocationToString(lLocation) + " for " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
        }
        else if(sTargetMode == "DEBUG_DELETE_VARIABLE")
        {
            string sVarName = GetLocalString(oPC, "Debug_Var_Name");
            int nVarType = GetLocalInt(oPC, "Debug_Var_Type");
            if(nVarType == 0) DeleteLocalInt(oTarget, sVarName);
            else if(nVarType == 1) DeleteLocalFloat(oTarget, sVarName);
            else if(nVarType == 2) DeleteLocalString(oTarget, sVarName);
            else if(nVarType == 4) DeleteLocalObject(oTarget, sVarName);
            else if(nVarType == 5) DeleteLocalLocation(oTarget, sVarName);
            ai_SendMessages(sVarName + " has been deleted from " + GetName(oTarget), AI_COLOR_YELLOW, oPC);
            DeleteLocalString(oPC, "Debug_Var_Name");
            DeleteLocalInt(oPC, "Debug_Var_Type");
        }
        else if(sTargetMode == "DEBUG_GET_VARIABLE")
        {
            debug_GetObjectVariable(oPC, oTarget);
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
            if(sElem == "btn_npc_scripts")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "SET_NPC_SCRIPTS");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select an npc to change scripts for.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE , MOUSECURSOR_CREATE, MOUSECURSOR_NOCREATE);
            }
            else if(sElem == "btn_set_reputation")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "SET_REPUTATION");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select a creature to set all standard reputations to neutral.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_clear_reputation")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "CLEAR_REPUTATION");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select a creature to clear your PC's reputation with that creature's faction.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_info")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_INFO");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select an object to send it's information to the players screen.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL , MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_obj_json")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_JSON_DUMP");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select an object to dump it's json values to the log.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
                                   OBJECT_TYPE_ITEM | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_TRIGGER, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_obj_var")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_LIST_VAR");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select an object to list it's variables to the player screen.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_debug_creature")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_CREATURE");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select a creature to start sending debug information to the log for.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_clear_events")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, OBJECT_SELF);
                SetLocalString(oPC, AI_TARGET_MODE, "CLEAR_CREATURE_EVENTS");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select a creature to set event scripts to default.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_clear_debug")
            {
                object oModule = GetModule();
                SetLocalString(oModule, AI_RULE_DEBUG_CREATURE, "");
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, AI_RULE_DEBUG_CREATURE, JsonString(""));
                ai_SetCampaignDbJson("rules", jRules);
                DeleteLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT");
                ai_SendMessages("Creature Debug mode has been cleared.", AI_COLOR_YELLOW, oPC);
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_debug", oPC);
            }
            else if(sElem == "btn_delete_var")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                string sVarName = JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name"));
                SetLocalString(oPC, "Debug_Var_Name", sVarName);
                SetLocalString(oPC, "Debug_Var_Value", JsonGetString(NuiGetBind(oPC, nToken, "txt_var_value")));
                SetLocalInt(oPC, "Debug_Var_Type", JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected")));
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_DELETE_VARIABLE");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select Object to delete (" + sVarName + ") variable from.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_get_var")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                string sVarName = JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name"));
                SetLocalString(oPC, "Debug_Var_Name", sVarName);
                SetLocalString(oPC, "Debug_Var_Value", JsonGetString(NuiGetBind(oPC, nToken, "txt_var_value")));
                SetLocalInt(oPC, "Debug_Var_Type", JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected")));
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_GET_VARIABLE");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select Object to get (" + sVarName + ") variable from.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_set_var")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                // Set Targeting variables.
                string sVarName = JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name"));
                SetLocalString(oPC, "Debug_Var_Name", sVarName);
                SetLocalString(oPC, "Debug_Var_Value", JsonGetString(NuiGetBind(oPC, nToken, "txt_var_value")));
                SetLocalInt(oPC, "Debug_Var_Type", JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected")));
                SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_SET_VARIABLE");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select Object to set (" + sVarName + ") variable to.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
        }
        if(sEvent == "watch")
        {
            if(sElem == "txt_var_name" || sElem == "txt_var_value" ||
               sElem == "cmb_var_type_selected")
            {
                if(JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name")) != "")
                {
                    NuiSetBind(oPC, nToken, "btn_get_var_event", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_delete_var_event", JsonBool(TRUE));
                    if(JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected")) == 3 || // Objects
                       JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected")) == 4 || // Locations
                       JsonGetString(NuiGetBind(oPC, nToken, "txt_var_value")) != "")
                    {
                        NuiSetBind(oPC, nToken, "btn_set_var_event", JsonBool(TRUE));
                        return;
                    }
                }
                else
                {
                    NuiSetBind(oPC, nToken, "btn_get_var_event", JsonBool(FALSE));
                    NuiSetBind(oPC, nToken, "btn_delete_var_event", JsonBool(FALSE));
                }
                NuiSetBind(oPC, nToken, "btn_set_var_event", JsonBool(FALSE));
            }
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(sElem == "btn_delete_var")
                {
                    object oModule = GetModule();
                    // Set Targeting variables.
                    string sVarName = JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name"));
                    int nVarType = JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected"));
                    if(nVarType == 0) DeleteLocalInt(oModule, sVarName);
                    else if(nVarType == 1) DeleteLocalFloat(oModule, sVarName);
                    else if(nVarType == 2) DeleteLocalString(oModule, sVarName);
                    else if(nVarType == 4) DeleteLocalObject(oModule, sVarName);
                    else if(nVarType == 5) DeleteLocalLocation(oModule, sVarName);
                    ai_SendMessages(sVarName + " has been deleted from the Module", AI_COLOR_YELLOW, oPC);
                }
                else if(sElem == "btn_get_var")
                {
                    // Set Targeting variables.
                    SetLocalString(oPC, "Debug_Var_Name", JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name")));
                    SetLocalInt(oPC, "Debug_Var_Type", JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected")));
                    debug_GetObjectVariable(oPC, GetModule(), "(Module)");
                }
                else if(sElem == "btn_set_var")
                {
                    // Set Targeting variables.
                    string sVarName = JsonGetString(NuiGetBind(oPC, nToken, "txt_var_name"));
                    string sVarValue = JsonGetString(NuiGetBind(oPC, nToken, "txt_var_value"));
                    int nVarType = JsonGetInt(NuiGetBind (oPC, nToken, "cmb_var_type_selected"));
                    SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_SET_VARIABLE");
                    if(nVarType == 0) // Int
                    {
                        int nVarValue = StringToInt(sVarValue);
                        SetLocalInt(GetModule(), sVarName, nVarValue);
                        ai_SendMessages(sVarName + " [Int] has been set to " + IntToString(nVarValue) + " on the Module.", AI_COLOR_YELLOW, oPC);
                    }
                    else if(nVarType == 1) // Float
                    {
                        float fVarValue = StringToFloat(sVarValue);
                        SetLocalFloat(GetModule(), sVarName, fVarValue);
                        ai_SendMessages(sVarName + " [Float] has been set to " + FloatToString(fVarValue, 0, 2) + " on the Module.", AI_COLOR_YELLOW, oPC);
                    }
                    else if(nVarType == 2) // String
                    {
                        SetLocalString(GetModule(), sVarName, sVarValue);
                        ai_SendMessages(sVarName + " [String] has been set to " + sVarValue + " on the Module.", AI_COLOR_YELLOW, oPC);
                    }
                    else if(nVarType == 3) // Object
                    {
                        object oModule = GetModule();
                        // Set this variable on the player so PEPS can run the targeting script for this plugin.
                        SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                        // Set Targeting variables.
                        SetLocalString(oPC, "Debug_Var_Name", sVarName);
                        SetLocalObject(oPC, "AI_TARGET_OBJECT", oModule);
                        SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_SET_OBJECT_VARIABLE");
                        ai_SendMessages("Select an object to save to " + GetName(oModule), AI_COLOR_YELLOW, oPC);
                        EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
                                           OBJECT_TYPE_ITEM | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_TRIGGER, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                    }
                    else if(nVarType == 4) // Location
                    {
                        object oModule = GetModule();
                        // Set this variable on the player so PEPS can run the targeting script for this plugin.
                        SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_debug");
                        // Set Targeting variables.
                        SetLocalString(oPC, "Debug_Var_Name", sVarName);
                        SetLocalObject(oPC, "AI_TARGET_OBJECT", oModule);
                        SetLocalString(oPC, AI_TARGET_MODE, "DEBUG_SET_LOCATION_VARIABLE");
                        ai_SendMessages("Select a location to save to " + GetName(oModule), AI_COLOR_YELLOW, oPC);
                        EnterTargetingMode(oPC, OBJECT_TYPE_TILE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                    }
                }
            }
        }
    }
}
void debug_GetObjectVariable(object oPC, object oTarget, string sDesc = "")
{
    string sVar, sVarName = GetLocalString(oPC, "Debug_Var_Name");
    int nVarType = GetLocalInt(oPC, "Debug_Var_Type");
    if(nVarType == 0) sVar = IntToString(GetLocalInt(oTarget, sVarName));
    else if(nVarType == 1) sVar = FloatToString(GetLocalFloat(oTarget, sVarName), 0, 2);
    else if(nVarType == 2) sVar = GetLocalString(oTarget, sVarName);
    else if(nVarType == 4) sVar = GetName(GetLocalObject(oTarget, sVarName));
    else if(nVarType == 5) sVar = LocationToString(GetLocalLocation(oTarget, sVarName));
    ai_SendMessages(sVarName + " on " + GetName(oTarget) + sDesc + " is set to " + sVar, AI_COLOR_YELLOW, oPC);
}
void debug_ListObjectVariables(object oPC, object oTarget)
{
    string sName = GetName(oTarget);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    ai_SendMessages(sName + " variables:", AI_COLOR_GREEN, oPC);
    json jObject = ObjectToJson(oTarget, TRUE);
    json jVarTable = GffGetList(jObject, "VarTable");
    string sVariable;
    int nIndex, nVarType;
    json jVar = JsonArrayGet(jVarTable, nIndex);
    while(JsonGetType(jVar) != JSON_TYPE_NULL)
    {
        sVariable = JsonGetString(GffGetString(jVar, "Name"));
        nVarType = JsonGetInt(GffGetDword(jVar, "Type"));
        if(nVarType == 1)
        {
            sVariable += " [int] ";
            sVariable += IntToString(JsonGetInt(GffGetInt(jVar, "Value")));
        }
        else if(nVarType == 2)
        {
            sVariable += " [float] ";
            sVariable += FloatToString(JsonGetFloat(GffGetFloat(jVar, "Value")), 0, 2);
        }
        else if(nVarType == 3)
        {
            sVariable += " [string] ";
            sVariable += JsonGetString(GffGetString(jVar, "Value"));
        }
        else if(nVarType == 4)
        {
            sName = GetName(GetLocalObject(oTarget, sVariable));
            sVariable += " [object] " + sName;
        }
        else if(nVarType == 5)
        {
            sName = LocationToString(GetLocalLocation(oTarget, sVariable));
            sVariable += " [location] " + sName;
        }
        else if(nVarType == 7)
        {
            sVariable += " [struct] ";
            sVariable += JsonDump(GffGetStruct(jVar, "Value"));
        }
        sVariable += JsonGetString(JsonObjectGet(jVar, "Value"));
        ai_SendMessages(sVariable, AI_COLOR_YELLOW, oPC);
        jVar = JsonArrayGet(jVarTable, ++nIndex);
    }
    if(!nIndex) ai_SendMessages("No variables to list!", AI_COLOR_YELLOW, oPC);
}
void ai_ForceAssociateEventScriptsToDefault(object oPC, object oCreature)
{
    ai_SendMessages("Changing " + GetName(oCreature) + "'s event scripts to default event scripts!", AI_COLOR_YELLOW, oPC);
    ai_SendMessages("Use this tool on them again to revert this creatures event scripts back!", AI_COLOR_YELLOW, oPC);
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "0e_id_events" || sScript == "0e_prc_id_events")
    {
        ai_SendMessages("You cannot use this on creatures in Infinite Dungeons!");
        return;
    }
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac6");
    //********** On Disturbed **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_aca");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_acb");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    if(!GetCommandable(oCreature)) SetCommandable(TRUE, oCreature);
}
void ai_RevertAssociateEventScriptsToDefault(object oPC, object oCreature)
{
    ai_SendMessages("Changing " + GetName(oCreature) + "'s event scripts back to original!", AI_COLOR_YELLOW, oPC);
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "0e_id_events" || sScript == "0e_prc_id_events")
    {
        ai_SendMessages("You cannot use this on creatures in Infinite Dungeons!", AI_COLOR_RED, oPC);
        return;
    }
    sScript = GetLocalString(oCreature, "AI_ON_HEARTBEAT");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sScript);
    //********** On Perception **********
    sScript = GetLocalString(oCreature, "AI_ON_NOTICE");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sScript);
    //********** On End Combat Round **********
    sScript = GetLocalString(oCreature, "AI_ON_END_COMBATROUND");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, sScript);
    //********** On Dialogue **********
    sScript = GetLocalString(oCreature, "AI_ON_DIALOGUE");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sScript);
    //********** On Melee Attacked **********
    sScript = GetLocalString(oCreature, "AI_ON_MELEE_ATTACKED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, sScript);
    //********** On Damaged **********
    sScript = GetLocalString(oCreature, "AI_ON_DAMAGED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, sScript);
    //********** On Disturbed **********
    sScript = GetLocalString(oCreature, "AI_ON_DISTURBED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetLocalString(oCreature, "AI_ON_RESTED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, sScript);
    //********** On Spell Cast At **********
    sScript = GetLocalString(oCreature, "AI_ON_SPELLCASTAT");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
    //********** On Blocked **********
    sScript = GetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    if(!GetCommandable(oCreature)) SetCommandable(TRUE, oCreature);
}

