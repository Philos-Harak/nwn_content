/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pctarget
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the character sets a target.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_adventure"
#include "0i_henchmen"
#include "0i_win_layout_pc"
#include "0i_win_layout_dm"

void main()
{
    object oPC = GetLastPlayerToSelectTarget ();
    object oTarget = GetTargetingModeSelectedObject ();
    location lTarget = Location (GetArea (oPC), GetTargetingModeSelectedPosition (), 0.0f);
    string sTargetMode = GetLocalString (oPC, "0_Target_Mode");
    if (oTarget != OBJECT_INVALID)
    {
        DeleteLocalString (oPC, "0_Target_Mode");
        //**********************************************************************
        // Target mode: Dice
        if (sTargetMode == "0_Dice_Target")
        {
            // If you select yourself then you clear your dice target.
            if (oTarget == oPC)
            {
                DeleteLocalObject (oPC, "0_Dice_Target");
                SendMessages ("You have cleared your dice target and now all dice rolls will be for your character.", COLOR_GREEN, oPC);
                PopUpDiceGUIPanel (oPC);
                return;
            }
            // If you are a DM then you can target anyone.
            if (GetIsDungeonMaster (oPC))
            {
                SetLocalObject (oPC, "0_Dice_Target", oTarget);
                PopUpDiceGUIPanel (oPC, oTarget);
                SendMessages ("You set " + GetName (oTarget) + " to roll dice for.", COLOR_GREEN, oPC);
                SendMessages ("Defaults to local broadcast mode, but you can change it.", COLOR_GREEN, oPC);
            }
            // If your a player you can only target your own associates.
            else
            {
                if (GetMaster (oTarget) == oPC)
                {
                    SetLocalObject (oPC, "0_Dice_Target", oTarget);
                    PopUpDiceGUIPanel (oPC, oTarget);
                    SendMessages ("You set " + GetName (oTarget) + " to roll dice for.", COLOR_GREEN, oPC);
                    SendMessages ("Defaults to DM broadcast mode, but you can change it.", COLOR_GREEN, oPC);
                    SendMessages ("Target yourself to clear your dice target.", COLOR_GREEN, oPC);
                }
                else SendMessages ("You can only target your henchman and summons!", COLOR_RED, oPC);
            }
        }
        //**********************************************************************
        // Target mode: DM Examine
        else if (sTargetMode == "0_DM_EXAMINE_TARGET")
        {
            int nObjectType = GetObjectType (oTarget);
            SetLocalObject (oPC, "0_DM_Target", oTarget);
            if (nObjectType == OBJECT_TYPE_CREATURE)
            {
                PopUpDMCreatureGUIPanel (oPC);
            }
            else if (nObjectType == OBJECT_TYPE_DOOR)
            {
                PopUpDMObjectGUIPanel (oPC);
            }
            else if (nObjectType == OBJECT_TYPE_PLACEABLE)
            {
                PopUpDMObjectGUIPanel (oPC);
            }
            else if (nObjectType == OBJECT_TYPE_TRIGGER)
            {
                PopUpDMTriggerGUIPanel (oPC);
            }
            else if (nObjectType == OBJECT_TYPE_ITEM)
            {
                string sTag = GetTag (oTarget);
                if (sTag == "0_quest_paper") PopUpDMQuestItemGUIPanel (oPC);
                else PopUpDMItemGUIPanel (oPC);
            }
            else if (nObjectType == 0)
            {
                oTarget = GetNearestObjectToLocation (OBJECT_TYPE_PLACEABLE, lTarget);
                SetLocalObject (oPC, "0_DM_Target", oTarget);
                PopUpDMMovePlaceableGUIPanel (oPC);
            }
        }
        //**********************************************************************
        // Target mode: DM craft
        else if (sTargetMode == "0_DM_CRAFT_TARGET")
        {
            if (oTarget != OBJECT_INVALID)
            {
                SetLocalObject (oPC, "0_DM_Target", oTarget);
                PopUpCraftingGUIPanel (oPC);
            }
        }
        //**********************************************************************
        // Target mode: Get Placeable
        else if (sTargetMode == "0_DM_GET_PLACEABLE_TARGET")
        {
            if (GetObjectType(oTarget) != OBJECT_TYPE_PLACEABLE)
            {
                oTarget = GetNearestObjectToLocation (OBJECT_TYPE_PLACEABLE, lTarget);
            }
            SetLocalObject (oPC, "0_DM_Target", oTarget);
            PopUpDMMovePlaceableGUIPanel (oPC);
        }
        //**********************************************************************
        // Target mode: Set NPC create location.
        else if (sTargetMode == "0_DM_NPC_LOCATION")
        {
            SetLocalLocation (oPC, "0_DM_Target_Location", lTarget);
            PopUpDMNPCGUIPanel (oPC);
            return;
        }
        //**********************************************************************
        // Target mode: Create transition at mouse location.
        else if (sTargetMode == "0_DM_TRANSITION_LOCATION")
        {
            string sResRef = GetLocalString (oPC, "0_Trans_ResRef");
            SetDMTransition (oPC, sResRef, lTarget);
        }
        //**********************************************************************
        // Target mode: Get DM Target
        else if (sTargetMode == "0_DM_GET_TARGET")
        {
            RemoveAllExamineWindows (oPC);
            SetLocalObject (oPC, "0_DM_Target", oTarget);
        }
        //**********************************************************************
        // Target mode: Get PLAYER Target
        else if (sTargetMode == "0_PLAYER_GET_TARGET")
        {
            // If you select yourself then you clear your dice target.
            if (oTarget == oPC)
            {
                SendMessages ("You have cleared your target and will not throw your voice.", COLOR_GRAY, oPC);
                DeleteLocalObject (oPC, "0_PLAYER_Target");
            }
            else
            {
                // Check and make sure they are only targeting an associate.
                if (GetMaster (oTarget) == oPC)
                {
                    SetLocalObject (oPC, "0_PLAYER_Target", oTarget);
                    SendMessages ("To throw your voice on " + GetName (oTarget) + " place a / at the begining of your text!", COLOR_GRAY, oPC);
                }
                else
                {
                    oTarget = OBJECT_INVALID;
                    SendMessages ("You do not have control of " + GetName (oTarget) + "!", COLOR_RED, oPC);
                    DeleteLocalObject (oPC, "0_PLAYER_Target");
                }
            }
        }
        //**********************************************************************
        // Target mode: Get PLAYER Target
        else if (sTargetMode == "0_HENCH_TARGET")
        {
            if (GetIsCharacter (oTarget))
            {
                if (HasMaxNumberOfHenchman(oPC))
                {
                    SendMessages (GetName (oTarget) + " already has a henchman! They can only have one henchman at a time.", COLOR_RED, oPC);
                }
                else
                {
                    object oHenchman = GetLocalObject(oPC, "0_HenchmanTarget");
                    SetUpHenchman (oTarget, oHenchman, TRUE);
                    AddHenchman (oTarget, oHenchman);
                    DeleteLocalObject (oPC, "0_HenchmanTarget");
                    SendMessages (GetName (oHenchman) + " has become a henchman for " + GetName (oTarget), COLOR_GREEN, oPC);
                    SendMessages (GetName (oHenchman) + " has become your henchman!", COLOR_GREEN, oTarget);
                }
            }
            else
            {
                SendMessages ("You did not select a player character for the NPC to become a henchmen for.", COLOR_RED, oPC);
                oTarget = OBJECT_INVALID;
                DeleteLocalObject (oPC, "0_PLAYER_Target");
            }
        }
        //**********************************************************************
        // Target mode: Get object to set on variable.
        else if (sTargetMode == "0_DM_SET_VAR_OBJ")
        {
            string sName = GetLocalString (oPC, "0_Obj_Var_Name");
            object oOrgTarget = GetLocalObject (oPC, "0_Obj_Org_Target");
            SetLocalObject (oOrgTarget, sName, oTarget);
            DeleteLocalObject (oPC, "0_Obj_Org_Target");
            DeleteLocalString (oPC, "0_Obj_Var_Name");
            PopupDMVariablesGUIPanel (oPC);
        }
    }
    int nDMToken;
    if (oTarget != OBJECT_INVALID) SetPlayerWinTarget (oPC, GetName (oTarget));
    else SetPlayerWinTarget (oPC, "None");
}



