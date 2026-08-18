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
    string sTargetMode = GetLocalString(oPC, "0_Target_Mode");
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
        else if(sTargetMode == "0_DM_EXAMINE_TARGET")
        {
            int nObjectType = GetObjectType(oTarget);
            if(nObjectType == OBJECT_TYPE_CREATURE)
            {
                SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_CREATURE);
                SetLocalObject(oPC, DM_TARGET_CREATURE, oTarget);
                PopUpDMCreatureGUIPanel(oPC);
            }
            else if(nObjectType == OBJECT_TYPE_DOOR)
            {
                SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_PLACEABLE);
                SetLocalObject(oPC, DM_TARGET_PLACEABLE, oTarget);
                PopUpDMObjectGUIPanel(oPC);
            }
            else if(nObjectType == OBJECT_TYPE_PLACEABLE)
            {
                SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_PLACEABLE);
                SetLocalObject(oPC, DM_TARGET_PLACEABLE, oTarget);
                PopUpDMObjectGUIPanel(oPC);
            }
            else if(nObjectType == OBJECT_TYPE_TRIGGER)
            {
                SetLocalObject(oPC, DM_TARGET_TRIGGER, oTarget);
                PopUpDMTriggerGUIPanel(oPC);
            }
            else if(nObjectType == OBJECT_TYPE_ITEM)
            {
                SetLocalObject(oPC, DM_TARGET_ITEM, oTarget);
                string sTag = GetTag(oTarget);
                if(sTag == "0_quest_paper") 
                {
                    SetLocalObject(oPC, "0_DM_QUEST_TARGET", oTarget);
                    PopUpDMQuestItemGUIPanel(oPC);
                }
                else PopUpDMItemGUIPanel(oPC);
            }
            else if(nObjectType == 0)
            {
                SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_CREATURE);
                SetLocalObject(oPC, DM_TARGET_PLACEABLE, oTarget);
                oTarget = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lTarget);
                PopUpDMMovePlaceableGUIPanel(oPC);
            }
        }
        //**********************************************************************
        // Target mode: Get Placeable
        else if(sTargetMode == "0_DM_GET_PLACEABLE_TARGET")
        {
            if(GetObjectType(oTarget) != OBJECT_TYPE_PLACEABLE)
            {
                oTarget = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lTarget);
            }
            SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_PLACEABLE);
            SetLocalObject(oPC, DM_TARGET_PLACEABLE, oTarget);
            PopUpDMMovePlaceableGUIPanel(oPC);
        }
        //**********************************************************************
        // Target mode: Set NPC create location.
        else if(sTargetMode == "0_DM_NPC_LOCATION")
        {
            SetLocalLocation(oPC, DM_TARGET_LOCATION, lTarget);
            PopUpDMNPCGUIPanel(oPC);
            return;
        }
        //**********************************************************************
        // Target mode: Create transition at mouse location.
        else if(sTargetMode == "0_DM_TRANSITION_LOCATION")
        {
            string sResRef = GetLocalString (oPC, "0_Trans_ResRef");
            SetDMTransition (oPC, sResRef, lTarget);
        }
        //**********************************************************************
        // Target mode: Get DM Target
        else if (sTargetMode == "0_DM_GET_TARGET")
        {
            RemoveAllExamineWindows (oPC);
            int nObjectType = GetObjectType(oTarget);
            if(nObjectType == OBJECT_TYPE_CREATURE) 
            {
                SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_CREATURE);
                SetLocalObject (oPC, DM_TARGET_CREATURE, oTarget);
            }
            else if(nObjectType == OBJECT_TYPE_ITEM) SetLocalObject (oPC, DM_TARGET_ITEM, oTarget);
            else if(nObjectType == OBJECT_TYPE_PLACEABLE || 
                    nObjectType == OBJECT_TYPE_DOOR) 
                    {
                        SetLocalInt(oPC, DM_TARGET_TYPE,OBJECT_TYPE_PLACEABLE);
                        SetLocalObject (oPC, DM_TARGET_PLACEABLE, oTarget);
                    }
            else if(nObjectType == OBJECT_TYPE_TILE) SetLocalObject (oPC, DM_TARGET_TILE, oTarget);
            else if(nObjectType == OBJECT_TYPE_TRIGGER) SetLocalObject (oPC, DM_TARGET_TRIGGER, oTarget);
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
                if(HasMaxNumberOfHenchman(oPC, TRUE))
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
        // Quest Menu target selections - NPC's for Start, Quest, Finish.
        else if(sTargetMode == "0_QUEST_START_NPC")
        {
            if(GetLocalInt(oTarget, "0_QUEST_TYPE") != 0 ||
               GetLocalString(oTarget, "0_Quest_Name") != "")
            {
                SendMessages("This NPC is already set to a quest.", COLOR_RED, oPC);
                return;
            }
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            SetLocalInt(oTarget, "0_Quest_Type",DM_QUESTS);
            SetLocalString(oTarget, "0_QUEST_ID", sQuestID);
            string sArray = SaveNPCToArray("-----------4--2--", oTarget, 0, OBJECT_INVALID, oPaper);
            sArray = SetStringArray(sArray, 2, sQuestID, "-");
            SetLocalString (oPaper, "0_Q_GIVER", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "giver", sArray, sQuestID);
            }
            if(GetItemPossessor(oPaper) != oTarget) CopyItem(oPaper, oTarget, TRUE);
            SendMessages(GetName(oTarget) + " has been set as the quest giver for " + GetName(oPaper) + ".", COLOR_GREEN, oPC);
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "start_npc_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_GIVE_ITEM")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sName = StripColorCodes(GetName(oTarget));
            string sArray = "-" + sName + "-";
            sArray += GetName(oTarget, TRUE) + "-";
            sArray += IntToString(GetBaseItemType(oTarget)) + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "---";
            SetLocalString (oPaper, "0_Q_GIVEITEM", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "giveitem", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "give_item_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_QUEST_NPC")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = SaveNPCToArray("-----------4--2--", oTarget, 0, OBJECT_INVALID, oPaper);
            sArray = SetStringArray(sArray, 2, sQuestID, "-");
            SetLocalString (oPaper, "0_Q_NPC", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                string sQuestID = GetLocalString(oPaper, "0_Q_ID");
                SetServerDatabaseString(oOwner, QUEST_TABLE, "npc", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "quest_npc_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_QUEST_VILLAIN")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = SaveNPCToArray("-----------0--2--", oTarget, 0, OBJECT_INVALID, oPaper);
            sArray = SetStringArray(sArray, 2, sQuestID, "-");
            SetLocalString (oPaper, "0_Q_VILLAIN", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                string sQuestID = GetLocalString(oPaper, "0_Q_ID");
                SetServerDatabaseString(oOwner, QUEST_TABLE, "villain", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "quest_villain_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_QUEST_CREATURES")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = "-" + StripColorCodes(GetName(oTarget)) + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "-4---";
            sArray += IntToString(GetCreatureSize(oTarget)) + "-";
            sArray += IntToString(GetRacialType(oTarget)) + "-";
            SetLocalString (oPaper, "0_Q_CREATURES", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "creatures", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "quest_creatures_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_QUEST_ALLIES")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = "-" + StripColorCodes(GetName(oTarget)) + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "-4---";
            SetLocalString (oPaper, "0_Q_ALLIES", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "allies", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "quest_allies_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_QUEST_PLACEABLE")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sName = StripColorCodes(GetName(oTarget));
            string sArray = "-" + sName + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "--";
            SetLocalString (oPaper, "0_Q_PLACEABLE", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "placeable", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "quest_placeable_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_QUEST_ITEM")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sName = GetName(oTarget);
            string sArray = "-" + sName + "-";
            sArray += GetName(oTarget, TRUE) + "-";
            sArray += IntToString(GetBaseItemType(oTarget)) + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "---";
            SetLocalString (oPaper, "0_Q_ITEM", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "item", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "quest_item_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_FINISH_NPC")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = SaveNPCToArray("-----------4--2--", oTarget, 0, OBJECT_INVALID, oPaper);
            sArray = SetStringArray(sArray, 2, sQuestID, "-");
            SetLocalString (oPaper, "0_Q_FINISHER", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                string sQuestID = GetLocalString(oPaper, "0_Q_ID");
                SetServerDatabaseString(oOwner, QUEST_TABLE, "finisher", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "finish_npc_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_FINISH_ENEMIES")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = "-" + StripColorCodes(GetName(oTarget)) + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "-4---";
            SetLocalString (oPaper, "0_Q_ENEMIES", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "enemies", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "finish_enemies_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_FINISH_ALLIES")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sArray = "-" + StripColorCodes(GetName(oTarget)) + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "-4---";
            SetLocalString (oPaper, "0_Q_FOLLOWERS", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "followers", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "finish_allies_value", JsonString(sArray));
        }
        else if(sTargetMode == "0_QUEST_FINISH_PLACEABLE")
        {
            object oPaper = GetLocalObject (oPC, "0_DM_QUEST_TARGET");
            string sQuestID = GetLocalString(oPaper, "0_Q_ID");
            string sName = StripColorCodes(GetName(oTarget));
            string sArray = "-" + sName + "-";
            sArray += GetResRef(oTarget) + "-";
            sArray += sQuestID + "--";
            SetLocalString (oPaper, "0_Q_FPLACEABLE", sArray);
            object oOwner = GetItemPossessor(oPaper);
            if(GetIsCharacter(oOwner))
            {
                SetServerDatabaseString(oOwner, QUEST_TABLE, "fplaceable", sArray, sQuestID);
            }
            int nToken = NuiFindWindow( oPC,  "dmquestswin");
            NuiSetBind(oPC, nToken, "finish_placeable_value", JsonString(sArray));
        }
    }
    int nDMToken;
    if (oTarget != OBJECT_INVALID) SetPlayerWinTarget (oPC, GetName (oTarget));
    else SetPlayerWinTarget (oPC, "None");
}



