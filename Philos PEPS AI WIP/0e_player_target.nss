/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_player_target
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnPlayerTarget event script
    Used to allow player targeting while passing any module player targeting
    script through to work as intended.

    We Use a string variable upon the player using the targeting mode to define the
    action of the target.
    AI_TARGET_MODE is the constant used.
    AI_TARGET_ASSOCIATE is the associate that triggered the target mode.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_player_target"
void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    // Get any plugin target scripts and run it instead of this one.
    string sPluginTargetScript = GetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT);
    if(sPluginTargetScript != "")
    {
        DeleteLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT);
        ExecuteScript(sPluginTargetScript, oPC);
        // Remove the plugin script as it must be set each time the plugin uses the target event.
    }
    else
    {
        // Get the targeting mode data
        object oTarget = GetTargetingModeSelectedObject();
        vector vTarget = GetTargetingModeSelectedPosition();
        location lLocation = Location(GetArea(oPC), vTarget, GetFacing(oPC));
        object oAssociate = GetLocalObject(oPC, AI_TARGET_ASSOCIATE);
        string sTargetMode = GetLocalString(oPC, AI_TARGET_MODE);
        // ********************* Exiting Target Actions ************************
        // If the user manually exited targeting mode without selecting a target, return
        if(!GetIsObjectValid(oTarget) && vTarget == Vector())
        {
            if(sTargetMode == "ASSOCIATE_ACTION_ALL")
            {
                ai_SendMessages("You have exited selecting an action for the party.", AI_COLOR_YELLOW, oPC);
                if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) == "")
                {
                    if(GetLocalInt(oPC, sGhostModeVarname)) ai_OriginalRemoveAllActionMode(oPC);
                }
                else ai_RemoveAllActionMode(oPC);
            }
            else if(sTargetMode == "ASSOCIATE_ACTION")
            {
                ai_SendMessages("You have exited selecting an action for " + GetName(oAssociate) + ".", AI_COLOR_YELLOW, oPC);
                if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) == "")
                {
                    if(GetLocalInt(oPC, sGhostModeVarname))
                    {
                        ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                        DeleteLocalInt(oAssociate, sGhostModeVarname);
                    }
                }
                else
                {
                    ai_SetAIMode(oAssociate, AI_MODE_COMMANDED, FALSE);
                    if(ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST) && !ai_GetAIMode(oPC, AI_MODE_GHOST) &&
                       GetLocalInt(oAssociate, sGhostModeVarname))
                    {

                        ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                        DeleteLocalInt(oAssociate, sGhostModeVarname);
                    }
                    ExecuteScript("nw_ch_ac1", oAssociate);
                }
            }
            else if(sTargetMode == "ASSOCIATE_GET_TRAP")
            {
                ai_SendMessages(GetName(oAssociate) + " has exited selecing a trap!", AI_COLOR_YELLOW, oPC);
            }
            else if(sTargetMode == "ASSOCIATE_PLACE_TRAP")
            {
                ai_SendMessages(GetName(oAssociate) + " has exited placing the trap!", AI_COLOR_YELLOW, oPC);
            }
            else if(sTargetMode == "DM_SELECT_CAMERA_VIEW")
            {
                AttachCamera(oPC, oPC);
                ai_SendMessages(GetName(oPC) + " has defaulted camera view back to the player!", AI_COLOR_YELLOW, oPC);
            }
            return;
        }
        // ************************* Targeted Actions **************************
        else
        {
            // This action makes an associates move to vTarget.
            if(sTargetMode == "ASSOCIATE_ACTION_ALL")
            {
                if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) == "")
                {
                    ai_OriginalActionAllAssociates(oPC, oTarget, lLocation);
                }
                else ai_ActionAllAssociates(oPC, oTarget, lLocation);
            }
            else if(sTargetMode == "ASSOCIATE_ACTION")
            {
                if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) == "")
                {
                    AssignCommand(oAssociate, ai_OriginalActionAssociate(oPC, oTarget, lLocation));
                }
                else AssignCommand(oAssociate, ai_ActionAssociate(oPC, oTarget, lLocation));
            }
            else if(sTargetMode == "ASSOCIATE_FOLLOW_TARGET") ai_SelectFollowTarget(oPC, oAssociate, oTarget);
            else if(sTargetMode == "ASSOCIATE_GET_TRAP") ai_SelectTrap(oPC, oAssociate, oTarget);
            else if(sTargetMode == "ASSOCIATE_PLACE_TRAP") AssignCommand(oAssociate, ai_PlaceTrap(oPC, lLocation));
            else if(sTargetMode == "ASSOCIATE_USE_ITEM")
            {
                if(oTarget == GetArea(oPC)) oTarget = OBJECT_INVALID;
                ai_UseWidgetItem(oPC, oAssociate, oTarget, lLocation);
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            }
            else if(sTargetMode == "ASSOCIATE_USE_FEAT")
            {
                if(oTarget == GetArea(oPC)) oTarget = OBJECT_INVALID;
                ai_UseWidgetFeat(oPC, oAssociate, oTarget, lLocation);
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            }
            else if(sTargetMode == "ASSOCIATE_CAST_SPELL")
            {
                if(oTarget == GetArea(oPC)) oTarget = OBJECT_INVALID;
                ai_CastWidgetSpell(oPC, oAssociate, oTarget, lLocation);
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            }
            else if(sTargetMode == "DM_SELECT_CAMERA_VIEW")
            {
                AttachCamera(oPC, oTarget);
                ai_SendMessages(GetName(oPC) + " has changed the cavera view to " + GetName(oTarget) + ".", AI_COLOR_YELLOW, oPC);
            }
            else if(sTargetMode == "DM_SELECT_OPEN_INVENTORY")
            {
                if(LineOfSightObject(oPC, oTarget))
                {
                    OpenInventory(oTarget, oPC);
                    ai_SendMessages("You have opened the inventory of "+ GetName(oTarget) + ".", AI_COLOR_YELLOW, oPC);
                }
                else ai_SendMessages(GetName(oTarget) + " is not in your line of sight!", AI_COLOR_YELLOW, oPC);
            }
            else if(GetStringLeft(sTargetMode, 15) == "DM_SELECT_GROUP")
            {
                ai_AddToGroup(oPC, oTarget, sTargetMode);
            }
            else if(GetStringLeft(sTargetMode, 15) == "DM_ACTION_GROUP")
            {
                ai_DMAction(oPC, oTarget, lLocation, sTargetMode);
            }
            // Get saved module player target script and execute it for pass through compatibility.
            string sModuleTargetScript = GetLocalString(GetModule(), AI_MODULE_TARGET_EVENT);
            ExecuteScript(sModuleTargetScript);
        }
    }
}
