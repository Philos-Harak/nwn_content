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
        ExecuteScript(sPluginTargetScript, oPC);
        // Remove the plugin script as it must be set each time the plugin uses the target event.
        DeleteLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT);
    }
    else
    {
        // Get the targeting mode data
        object oTarget = GetTargetingModeSelectedObject();
        vector vTarget = GetTargetingModeSelectedPosition();
        location lLocation = Location(GetArea(oPC), vTarget, GetFacing(oPC));
        object oAssociate = GetLocalObject(oPC, AI_TARGET_ASSOCIATE);
        string sTargetMode = GetLocalString(oPC, AI_TARGET_MODE);
        // If the user manually exited targeting mode without selecting a target, return
        if(!GetIsObjectValid(oTarget) && vTarget == Vector())
        {
            if(sTargetMode == "ASSOCIATE_ACTION_ALL")
            {
                ai_SendMessages("Party has exited action mode!", AI_COLOR_YELLOW, oPC);
                if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
                {
                    if(GetLocalInt(oPC, sGhostModeVarname)) ai_OriginalRemoveAllActionMode(oPC);
                }
                else ai_RemoveAllActionMode(oPC);
            }
            else if(sTargetMode == "ASSOCIATE_ACTION")
            {
                ai_SendMessages(GetName(oAssociate) + " has exited action mode!", AI_COLOR_YELLOW, oPC);
                if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
                {
                    if(GetLocalInt(oPC, sGhostModeVarname))
                    {
                        ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                        DeleteLocalInt(oAssociate, sGhostModeVarname);
                    }
                }
                else
                {
                    if(ai_GetAIMode(oPC, AI_MODE_GHOST))
                    {
                        ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                        DeleteLocalInt(oAssociate, sGhostModeVarname);
                    }
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
            return;
        }
        // This action makes an associates move to vTarget.
        if(sTargetMode == "ASSOCIATE_ACTION_ALL")
        {
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                ai_OriginalActionAllAssociates(oPC, oTarget, lLocation);
            }
            else ai_ActionAllAssociates(oPC, oTarget, lLocation);
        }
        else if(sTargetMode == "ASSOCIATE_ACTION")
        {
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_OriginalActionAssociate(oPC, oTarget, lLocation));
            }
            else AssignCommand(oAssociate, ai_ActionAssociate(oPC, oTarget, lLocation));
        }
        else if(sTargetMode == "ASSOCIATE_FOLLOW_TARGET") ai_SelectTarget(oPC, oAssociate, oTarget);
        else if(sTargetMode == "ASSOCIATE_GET_TRAP") ai_SelectTrap(oPC, oAssociate, oTarget);
        else if(sTargetMode == "ASSOCIATE_PLACE_TRAP") AssignCommand(oAssociate, ai_PlaceTrap(oPC, lLocation));
        // Get saved module player target script and execute it for pass through compatibility.
        string sModuleTargetScript = GetLocalString(GetModule(), AI_MODULE_TARGET_EVENT);
        ExecuteScript(sModuleTargetScript);
    }
}
