#include "0i_server_const"
#include "0i_database"


/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_window
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_win_layout_pc"
#include "0i_win_layout_dm"
#include "0i_quest"
#include "0i_journal"
#include "0i_henchmen"
#include "0i_adventure"
#include "0i_effects"
#include "nwnx_player"
#include "nwnx_admin"
#include "nwnx_feedback"

// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId (object oPC);

// Locks/Unlocks specific buttons when an item has been changed.
void LockItemInCraftingWindow (object oPC, object oItem, int nToken);

// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow (object oPC, object oItem, int nToken);

// Change the button or item based on this buttons special function.
void DoSpecialButton (object oPC, object oItem, int nToken);

// Saves the crafted item for the player removing the original.
void SaveCraftedItem (object oPC, object oTarget, int nToken);

// Can hide or unhide text while crafting.
void HideFeedbackForCraftText (object oPC, int bHidden);

// Used in deity field to check for valid deity.
void CheckDeityInDatabase (object oPC, object oTarget);

void CheckForDMButtonClick (object oPC, int nToken, string sElem);

void main()
{
    // Let the inspector handle what it wants.
    //HandleWindowInspectorEvent ();
    object oPC = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();
    int    nIndex  = NuiGetEventArrayIndex();
    string sWndId  = NuiGetWindowId (oPC, nToken);
    int bNumberRolls;
    //Debug("0e_window", "54", "sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem);
    //**************************************************************************
    // Watch to see if the window moves and save to database unless its the small window.
    if (sElem == "window_geometry" && sEvent == "watch" && sWndId != "plsmallwin")
    {
        if (!GetLocalInt (oPC, "0_No_Win_Save"))
        {
            json jWindows = GetServerDatabaseJson(oPC, PLAYER_TABLE, "playerwindows");
            if(JsonGetType(jWindows) == JSON_TYPE_NULL) jWindows = JsonObject();
            json jGeometry = NuiGetBind (oPC, nToken, "window_geometry");
            // sWndID is the same as the jWindows key name.
            jWindows = JsonObjectSet(jWindows, sWndId, jGeometry);
            SetServerDatabaseJson(oPC, PLAYER_TABLE, "playerwindows", jWindows);
        }
    }
    /***************************************************************************
    * Player events                                                            *
    ***************************************************************************/
    //**************************************************************************
    // Player list events.
    else if (sWndId == "pllistwin")
    {
        if (sEvent == "click")
        {
            object oTarget = GetLocalObject (oPC, "0_List_Target");
            if (sElem == "btn_p_invite")
            {
            }
            else if (sElem == "btn_p_kick")
            {
            }
            else if (sElem == "btn_p_leave")
            {
            }
            else if (sElem == "btn_p_ch_leader")
            {
            }
            else if (sElem == "btn_p_examine")
            {
                AssignCommand (oPC, ActionExamine (oTarget));
            }
            else if (sElem == "btn_role_play")
            {
                int nOption = GetLocalInt (oPC, "0_ROLE_PLAY") + 1;
                if (nOption > 3) nOption = 0;
                SetLocalInt (oPC, "0_ROLE_PLAY", nOption);
                if (nOption == 0)
                    NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("None"));
                else if (nOption == 1)
                    NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("Light"));
                else if (nOption == 2)
                    NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("Heavy"));
                else if (nOption == 3)
                    NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("Always"));
            }
            else if (sElem == "btn_party_interest")
            {
                int nOption = GetLocalInt (oPC, "0_PARTY") + 1;
                if (nOption > 2) nOption = 0;
                SetLocalInt (oPC, "0_PARTY", nOption);
                if (nOption == 0) NuiSetBind (oPC, nToken, "btn_party_interest_label", JsonString ("None"));
                else if (nOption == 1) NuiSetBind (oPC, nToken, "btn_party_interest_label", JsonString ("Small"));
                else if (nOption == 2) NuiSetBind (oPC, nToken, "btn_party_interest_label", JsonString ("Any"));
            }
            else if (sElem == "btn_dm_events")
            {
                int nOption = GetLocalInt (oPC, "0_DM_EVENTS") + 1;
                if (nOption > 3) nOption = 0;
                SetLocalInt (oPC, "0_DM_EVENTS", nOption);
                if (nOption == 0) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("None"));
                else if (nOption == 1) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("Short"));
                else if (nOption == 2) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("Long"));
                else if (nOption == 3) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("Any"));
            }
        }
        else if (sEvent == "mousedown")
        {
            if (sElem == "character_name" || sElem == "character_pic")
            {
                json jListData = NuiGetUserData (oPC, nToken);
                json jListPlayerUUID = JsonArrayGet (jListData, nIndex);
                object oPlayer = GetObjectByUUID (JsonGetString (jListPlayerUUID));
                if (GetIsCharacter (oPlayer)) NuiSetBind (oPC, nToken, "target_color", NuiColor (210, 160, 0));
                else NuiSetBind (oPC, nToken, "target_color", NuiColor (255, 255, 255));
                NuiSetBind (oPC, nToken, "target_label", JsonString (GetName (oPlayer)));
                SetLocalObject (oPC, "0_List_Target", oPlayer);
                NuiSetBind (oPC, nToken, "btn_p_invite_event", JsonBool (TRUE));
                NuiSetBind (oPC, nToken, "btn_p_kick_event", JsonBool (TRUE));
                NuiSetBind (oPC, nToken, "btn_p_leave_event", JsonBool (TRUE));
                NuiSetBind (oPC, nToken, "btn_p_ch_leader_event", JsonBool (TRUE));
                NuiSetBind (oPC, nToken, "btn_p_examine_event", JsonBool (TRUE));
            }
        }
    }
    //**************************************************************************
    // Core player window events.
    else if (sWndId == "plplayerwin")
    {
        if (sEvent == "watch")
        {
            if(GetIsDungeonMaster(oPC))
            {
                if(sElem == "cmb_target_selected")
                {
                    string sValue;
                    int nTargetType = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                    if(nTargetType == 0) sValue = GetName(GetLocalObject(oPC, DM_TARGET_CREATURE));
                    else if(nTargetType == 1) sValue = GetName(GetLocalObject(oPC, DM_TARGET_ITEM));
                    else if(nTargetType == 2) sValue = GetName(GetLocalObject(oPC, DM_TARGET_PLACEABLE));
                    else if(nTargetType == 3) sValue = GetName(GetLocalObject(oPC, DM_TARGET_AREA));
                    else if(nTargetType == 4) sValue = GetName(GetLocalObject(oPC, DM_TARGET_TRIGGER));
                    //else if(nTargetType == 5) sValue = GetName(GetLocalObject(oPC, DM_TARGET_LOCATION));
                    NuiSetBind(oPC, nToken, "dm_target_value_label", JsonString(StripColorCodes(sValue)));                        
                }
            }
        }
        if (sEvent == "click")
        {
            if (GetIsDungeonMaster (oPC)) CheckForDMButtonClick (oPC, nToken, sElem);
            // player button options.
            else
            {
                if (sElem == "btn_options")
                {
                    if (IsWindowClosed (oPC, "ploptionwin")) PopUpPlayerOptionsGUIPanel (oPC);
                }
                else if (sElem == "btn_news")
                {
                    if(IsWindowClosed (oPC, "plnewspanel")) PopUpNewsPanel(oPC);
                }
                else if (sElem == "btn_stats")
                {
                    if (IsWindowClosed (oPC, "plstatswin")) PopUpPlayerStatsGUIPanel (oPC);
                }
                else if (sElem == "btn_magic")
                {
                    if (IsWindowClosed (oPC, "pcmagicwin")) PopUpCharacterMagicGUIPanel (oPC);
                }
                else if (sElem == "btn_lang")
                {
                    if (IsWindowClosed (oPC, "pclangwin")) PopUpCharacterLanguageGUIPanel (oPC);
                }
                else if (sElem == "btn_desc")
                {
                    if (IsWindowClosed (oPC, "pcdescwin")) PopUpCharacterDescriptionGUIPanel (oPC);
                }
                else if (sElem == "btn_craft") ExecuteScript("pi_crafting", oPC);
                else if (sElem == "btn_dice")
                {
                    if (IsWindowClosed (oPC, "pldicewin")) PopUpDiceGUIPanel (oPC);
                }
                else if (sElem == "btn_bug_report")
                {
                    if (IsWindowClosed (oPC, "plbugwin")) PopUpBugReportGUIPanel (oPC);
                }
                else if (sElem == "btn_cynosure") AssignCommand (oPC, JumpToObject (GetWaypointByTag ("WP_Cynosure")));
                else if (sElem == "btn_dm_mode")
                {
                    SendMessages ("You have gained DM status as a player.", COLOR_GRAY, oPC);
                    SendMessages (GetName (oPC, TRUE) + " has gained DM status as a player.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
                    NuiDestroy (oPC, NuiFindWindow (oPC, "plplayerwin"));
                    NuiDestroy (oPC, NuiFindWindow (oPC, "ploptionwin"));
                    NuiDestroy (oPC, NuiFindWindow (oPC, "pcmagicwin"));
                    NuiDestroy (oPC, NuiFindWindow (oPC, "pclangwin"));
                    NWNX_Player_ToggleDM (oPC, TRUE);
                    //NuiDestroy(oPC, NuiFindWindow(oPC, "pc_widget"));
                    //ExecuteScript("peps", oPC);
                    //CheckServerDataAndInitialize (oPC, DM_TABLE);
                    PopUpDMGUIPanel(oPC);
                }
            }
        }
        else if (sEvent == "mousedown")
        {
            if (sElem == "dm_target_value")
            {
                // Get Target.
                SetLocalString (oPC, "0_Target_Mode", "0_DM_EXAMINE_TARGET");
                EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
        }
    }
    //**************************************************************************
    // Small window events.
    else if(sWndId == "plsmallwin")
    {
        // Small display button to open the vertical option.
        if(sEvent == "click" && sElem == "btn_open" && GetLocalInt (oPC, "0_Password"))
        {
            NuiDestroy(oPC, GetLocalInt(oPC, "0_Menu_Token"));
            PopUpPlayerVerGUIPanel(oPC);
        }
    }
    //**************************************************************************
    // Bug report window events.
    else if (sWndId == "plbugwin")
    {
        if (sEvent == "watch" && sElem == "bug_value")
        {
            string sMessage = JsonGetString (NuiGetBind (oPC, nToken, "bug_value"));
            if (sMessage != "") NuiSetBind (oPC, nToken, "btn_bug_save_event", JsonBool (TRUE));
            else NuiSetBind (oPC, nToken, "btn_bug_save_event", JsonBool (FALSE));
        }
        else if (sEvent == "click" && sElem == "btn_bug_save")
        {
            // Get location so we can report it.
            string sLocation;
            object oArea;
            vector vPosition;
            float fFacing;
            location lLocation = GetLocation (oPC);
            oArea = GetAreaFromLocation (lLocation);
            vPosition = GetPositionFromLocation (lLocation);
            fFacing = GetFacingFromLocation (lLocation);
            sLocation = "(Tag: " + GetTag (oArea) + ", X: " + FloatToString(vPosition.x, 0, 2) + ", Y: " +
            FloatToString(vPosition.y, 0, 2) + ", Z: " + FloatToString(vPosition.z, 0, 2) + ", Face: " +
            FloatToString (fFacing, 0, 2) + ")";
            // Send bug report.
            string sMessage = JsonGetString (NuiGetBind (oPC, nToken, "bug_value"));
            sLocation = "[" + GetName (GetArea (oPC)) + "] Location: " + sLocation;
            WriteTimestampedLogEntry ("!!!BUG REPORT!!! " + sLocation);
            WriteTimestampedLogEntry ("!!!BUG REPORT!!! [" + GetPCPlayerName (oPC) + " : " + GetName (oPC) + "] " + sMessage);
            SendServerDebugToDiscord (oPC, sLocation, sMessage);
            // Thank the player for the report.
            SendMessages ("Your report has been sent, Thank you!", COLOR_WHITE, oPC);
            NuiDestroy (oPC, nToken);
        }
    }
    //**************************************************************************
    // Dice window events.
    else if (sWndId == "pldicewin")
    {
        if (sEvent == "click" && sElem == "btn_roll")
        {
            int nRoll;
            string sText = JsonGetString (NuiGetBind (oPC, nToken, "roll_text"));
            string sRoll = CheckDiceRollText (oPC, sText);
            if (sRoll == "")
            {
                nRoll = RollDiceString (sText);
                // Check for target.
                object oTarget = GetLocalObject (oPC, "0_Dice_Target");
                if (oTarget != OBJECT_INVALID) sRoll = GetName (oTarget) + " rolls a " + sText + " and the result is " + IntToString (nRoll);
                else sRoll = GetName (oPC) + " rolls a " + sText + " and the result is " + IntToString (nRoll);
                SendBroadcastMessage (oPC, sRoll);
            }
            else
            {
                int i = 1;
                int iNumOfDice = GetLocalInt (oPC, "0_NumDice") + 1;
                if (iNumOfDice > 1) bNumberRolls = TRUE;
                while (iNumOfDice > 0)
                {
                    if (bNumberRolls)
                    {
                        sRoll = IntToString (i++) + ") " + sRoll;
                    }
                    SendBroadcastMessage (oPC, sRoll);
                    sRoll = CheckDiceRollText (oPC, sText);
                    iNumOfDice --;
                }
            }
        }
        else if (sEvent == "watch")
        {
            if (sElem == "num_dice_combo_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetLocalInt (oPC, "0_NumDice", nSelected);
                NuiSetBind (oPC, nToken, "roll_text", JsonString (GetRollText (oPC)));
                //Debug ("0e_window", "237", "nSelected: " + IntToString (nSelected));
            }
            else if (sElem == "type_roll_combo_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetLocalInt (oPC, "0_TypeRoll", nSelected);
                NuiSetBind (oPC, nToken, "roll_text", JsonString (GetRollText (oPC)));
            }
            else if (sElem == "die_bonus_combo_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                if (nSelected > 20) nSelected = 20 - nSelected;
                SetLocalInt (oPC, "0_DieBonus", nSelected);
                NuiSetBind (oPC, nToken, "roll_text", JsonString (GetRollText (oPC)));
            }
            else if (sElem == "broadcast_combo_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                int iStatus = GetServerDatabaseInt (oPC, PLAYER_TABLE, "status");
                if (nSelected == 4 || (iStatus < 2 && nSelected == 3))
                {
                    SetLocalString (oPC, "0_Target_Mode", "0_Dice_Target");
                    EnterTargetingMode (oPC, OBJECT_TYPE_CREATURE);
                    // Default the broad cast mode to DM.
                    nSelected = 0;
                    NuiSetBind (oPC, nToken, "broadcast_combo_selected", JsonInt (0));
                }
                SetLocalInt (oPC, "0_Broadcast", nSelected);
            }
        }
    }
    //**************************************************************************
    // Player options window events.
    else if (sWndId == "ploptionwin")
    {
        if (sEvent == "watch")
        {
            if(GetIsDungeonMaster(oPC))
            {
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                if(!GetLocalInt(oPC, "0_No_Option_Save"))
                {
                    if(sElem == "cmb_target")
                    {
                        string sValue;
                        int nTargetType = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                        if(nTargetType == 0) sValue = GetName(GetLocalObject(oPC, DM_TARGET_CREATURE));
                        else if(nTargetType == 1) sValue = GetName(GetLocalObject(oPC, DM_TARGET_ITEM));
                        else if(nTargetType == 2) sValue = GetName(GetLocalObject(oPC, DM_TARGET_PLACEABLE));
                        else if(nTargetType == 3) sValue = GetName(GetLocalObject(oPC, DM_TARGET_AREA));
                        else if(nTargetType == 4) sValue = GetName(GetLocalObject(oPC, DM_TARGET_TRIGGER));
                        //else if(nTargetType == 5) sValue = GetName(GetLocalObject(oPC, DM_TARGET_LOCATION));
                        NuiSetBind(oPC, nToken, "dm_target_value_label", JsonString(sValue));                        
                    }
                    string sOptionsArray = GetServerDatabaseString (oPC, PLAYER_TABLE, "ploptionwin");
                    nIndex = 0;
                    if(sElem == "str_cmbt_check") nIndex = 4;
                    if(sElem == "stp_cmbt_check") nIndex = 5;
                    if(sElem == "examine_check") nIndex = 6;
                    if(sElem == "dice_check") nIndex = 7;
                    if(sElem == "server_check") nIndex = 8;
                    if(sElem == "area_check") nIndex = 9;
                    if(sElem == "adventure_check") nIndex = 10;
                    if(sElem == "npc_check") nIndex = 11;
                    if(sElem == "transitions_check") nIndex = 12;
                    if(sElem == "craft_check") nIndex = 13;
                    if(sElem == "bug_report_check") nIndex = 14;
                    if(sElem == "cynosure_check") nIndex = 15;
                    if(sElem == "target_check") nIndex = 16;
                    if(sElem == "dm_chest_check") nIndex = 17;
                    if(sElem == "pc_mode_check") nIndex = 18;
                    // If we have changed a check then save the new options.
                    if(nIndex != 0)
                    {
                        sOptionsArray = SetStringArray (sOptionsArray, nIndex, IntToString (bCheck));
                        SetServerDatabaseString (oPC, PLAYER_TABLE, "ploptionwin", sOptionsArray);
                        // Reset the window with the new buttons.
                        NuiDestroy (oPC, NuiFindWindow (oPC, "plplayerwin"));
                        PopUpDMGUIPanel (oPC);
                    }
                }
                else NuiSetBind(oPC, nToken, sElem, JsonBool (!bCheck));
            }
            // Player watch for combo.
            else
            {
                if (sElem == "sleep_opt_selected")
                {
                    int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                    string sOption = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance");
                    sOption = SetStringArray (sOption, 3, IntToString (nSelected));
                    SetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance", sOption);
                    SetRestingOption (oPC, IntToString (nSelected));
                }
            }
        }
        else if (sEvent == "click")
        {
            if(GetIsDungeonMaster (oPC)) CheckForDMButtonClick(oPC, nToken, sElem);
            // player button options.
            else
            {
                if (sElem == "btn_credits") PopUpCreditsGUIPanel (oPC);
                else if (sElem == "btn_minimize")
                {
                    NuiDestroy (oPC, GetLocalInt (oPC, "0_Menu_Token"));
                    int nOldToken = NuiFindWindow (oPC, "ploptionwin");
                    if (nOldToken != 0) NuiDestroy (oPC, nOldToken);
                    PopUpSmallGUIPanel (oPC);
                }
                else if (sElem == "btn_delete_char")
                {
                    string sCharName = JsonGetString (NuiGetBind (oPC, nToken, "delete_char_value"));
                    if (sCharName == GetName (oPC)) DeleteCharacterFromDatabase(oPC);
                    else SendMessages ("You must type the name of your character before " +
                                       "hitting the delete character button.", COLOR_GRAY, oPC, FALSE, FALSE);
                }
                else if (sElem == "btn_set_password")
                {
                    string sPassword = JsonGetString (NuiGetBind (oPC, nToken, "password_value"));
                    if (sPassword == "") SendMessages ("There is nothing to set! Please type a password.", COLOR_RED, oPC);
                    else
                    {
                        SendMessages ("Password has been set!", COLOR_GREEN, oPC);
                        SetServerDatabaseString (oPC, PLAYER_TABLE, "password", sPassword);
                    }
                }
            }
        }
    }
    //**************************************************************************
    // Player options window events.
    else if (sWndId == "plyesnowin")
    {
        if (sEvent == "click")
        {
            string sMenuOption = GetLocalString(oPC, "YES_NO_MENU");
            DeleteLocalString(oPC, "YES_NO_MENU");
            if(sMenuOption == "REMOVE_QUEST_PAPER")
            {
                object oPaper = GetLocalObject(oPC, "REMOVE_QUEST_PAPER");
                if (sElem == "btn_no")
                {
                    SendMessages (GetName (oPaper) + " has not been removed.", COLOR_GREEN, oPC);
                    NuiDestroy(oPC, nToken);
                    return;
                }
                if (sElem == "btn_yes")
                {
                    // Check for an NPC henchman to remove.
                    string sNPCArray = GetLocalString (oPaper, "0_Q_NPC");
                    if (sNPCArray != "")
                    {
                        int i = 1;
                        string sName = GetStringArray  (sNPCArray, 0, "-");
                        string sID = GetStringArray  (sNPCArray, 2, "-");
                        object oHenchman = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oPC, i);
                        while (oHenchman != OBJECT_INVALID)
                        {
                            string sHenchmanID = GetLocalString (oHenchman, "0_QUEST_ID");
                            if (GetName (oHenchman) == sName && sID == sHenchmanID)
                            {
                                RemoveQuestNPC (oPC, oHenchman);
                            }
                            oHenchman = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oPC, ++i);
                        }
                    }
                    RemoveQuestPaperFromDatabase(oPC, oPaper);
                    DestroyObject(oPaper);
                    DeleteLocalObject(oPC, "REMOVE_QUEST_PAPER");
                    SendMessages(GetName (oPaper) + " has been removed.", COLOR_RED, oPC);
                    int nPointer = GetLocalInt(GetCreatureHasItem(oPC, "players_book"), "0_SideQuest_Num");
                    if(nPointer > 0)
                    {
                        nPointer ++;
                        if(nPointer > 8) nPointer = 1;
                        SetLocalInt(GetCreatureHasItem(oPC, "players_book"), "0_SideQuest_Num", 0);
                    }
                    NuiDestroy(oPC, nToken);
                }
            }
        }
    }
    //**************************************************************************
    // Player death window events.
    else if (sWndId == "pldeathpanel")
    {
        if (sEvent == "click")
        {
            if (sElem == "btn_respawn") ExecuteScript("0e_pcrespawn", oPC);
            NuiDestroy(oPC, nToken);
        }
    }
    //**************************************************************************
    // Player news window events.
    else if (sWndId == "plnewspanel")
    {
        if (sEvent == "click")
        {
            if (sElem == "btn_ok") NuiDestroy(oPC, nToken);
        }
    }
    /***************************************************************************
    * Player Character only events                                             *
    ***************************************************************************/
    //**************************************************************************
    // Player description and portrait events.
    else if (sWndId == "pcdescwin")
    {
        int nChange = 0;
        int nID;
        string sResRef, sID, sPlot;
        if (sEvent == "watch" && sElem == "port_name")
        {
            nID = JsonGetInt (NuiGetUserData (oPC, nToken));
            if (GetLocalInt (oPC, "0_Port_ID"))
            {
                NuiSetBind (oPC, nToken, "port_id_label", JsonString (IntToString (nID)));
                DeleteLocalInt (oPC, "0_Port_ID");
            }
            else NuiSetBind (oPC, nToken, "port_id_label", JsonString ("Custom Portrait"));
            sResRef = JsonGetString (NuiGetBind (oPC, nToken, "port_name"));
            if(ResManGetAliasFor(sResRef, RESTYPE_TGA) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef));
            else if(ResManGetAliasFor(sResRef + "l", RESTYPE_TGA) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "l"));
            else if(ResManGetAliasFor(sResRef + "m", RESTYPE_TGA) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "m"));
        }
        if (sEvent == "click")
        {
            if (sElem == "btn_desc_save")
            {
                string sDescription = JsonGetString (NuiGetBind (oPC, nToken, "desc_value"));
                SetDescription (oPC, sDescription);
            }
            else if (sElem == "btn_portrait_next")
            {
                nID = JsonGetInt (NuiGetUserData (oPC, nToken)) + 1;
                nChange = 1;
            }
            else if (sElem == "btn_portrait_prev")
            {
                nID = JsonGetInt (NuiGetUserData (oPC, nToken)) - 1;
                nChange = -1;
            }
            else if (sElem == "btn_portrait_ok")
            {
                sResRef = JsonGetString (NuiGetBind (oPC, nToken, "port_name"));
                sID = JsonGetString (NuiGetBind (oPC, nToken, "port_id_label"));
                //Debug ("0e_window", "575", "sID: " + sID);
                if (sID != "Custom Portrait") SetPortraitId(oPC, StringToInt (sID));
                else SetPortraitResRef (oPC, sResRef);
            }
            if (nChange != 0)
            {
                int nPRace, nPGender;
                if (nID > 2999) nID = 1;
                if (nID < 1) nID = 2999;
                int nGender = GetGender (oPC);
                int nRace = GetRaceType(oPC, TRUE);
                string sPRace = Get2DAString ("portraits", "Race", nID);
                if (sPRace != "") nPRace = StringToInt (sPRace);
                else nPRace = -1;
                string sPGender = Get2DAString ("portraits", "Sex", nID);
                if (sPGender != "") nPGender = StringToInt (sPGender);
                else nPGender = -1;
                while ((nRace != nPRace &&
                        (nRace != RACIAL_TYPE_HALFELF ||
                         (nPRace != RACIAL_TYPE_ELF && nPRace != RACIAL_TYPE_HUMAN))) ||
                       nGender != nPGender)
                {
                    nID += nChange;
                    if (nID > 2999) nID = 1;
                    if (nID < 1) nID = 2999;
                    // Plot portraits are skipped.
                    if (Get2DAString ("portraits", "Plot", nID) == "0")
                    {
                        sPRace = Get2DAString ("portraits", "Race", nID);
                        if (sPRace != "") nPRace = StringToInt (sPRace);
                        else nPRace = -1;
                        sPGender = Get2DAString ("portraits", "Sex", nID);
                        if (sPGender != "") nPGender = StringToInt (sPGender);
                        else nPGender = -1;
                    }
                    else nPRace = -1;
                }
                string sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID);
                NuiSetUserData (oPC, nToken, JsonInt (nID));
                SetLocalInt (oPC, "0_Port_ID", TRUE);
                NuiSetBind (oPC, nToken, "port_name", JsonString (sResRef));
            }
        }
    }
    //**************************************************************************
    // Player magic window events.
    else if (sWndId == "pcmagicwin")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_enh_comp")
            {
                object oPlayersHandBook = GetCreatureHasItem(oPC, "players_book");
                int bEnhancing = !GetLocalInt(oPC, "0_Use_Enhancing_Component");
                if(bEnhancing) SendMessages ("Enhancing Components have been turned on for your spells.", COLOR_GREEN, oPC);
                else SendMessages("Enhancing Components have been turned off for your spells.", COLOR_RED, oPC);
                SetLocalInt(oPlayersHandBook, "0_Use_Enhancing_Component", bEnhancing);
                SetLocalInt(oPC, "0_Use_Enhancing_Component", bEnhancing);
            }
            else if (sElem == "btn_fast_buff")
            {
                NuiDestroy (oPC, nToken);
                ExecuteScript("pi_buffing", oPC);
            }
            else if (sElem == "btn_teleport")
            {
                NuiDestroy (oPC, nToken);
                // Make sure we have cleared any spell cast.
                DeleteLocalInt (Spell.oCaster, "0_Teleport_Spell");
                PopUpPlayerTeleportGUIPanel (oPC);
            }
        }
        string sCombo = GetStringLeft (sElem, 8);
        if (sEvent == "watch" && sCombo == "sm_combo" && !GetLocalInt (oPC, "0_No_Win_Save"))
        {
            int nSelected, nIndex = StringToInt (GetSubString (sElem, 9, GetStringLength (sElem) - 9));
            string sResRef;
            json jComboBox = JsonArray ();
            json jWindow = JsonArray ();
            jWindow = NuiGetUserData (oPC, nToken);
            string sSummonArray = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "summons");
            nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
            jComboBox = JsonArrayGet (jWindow, nIndex - 1);
            sResRef = JsonGetString (JsonArrayGet (jComboBox, nSelected));
            sSummonArray = SetStringArray (sSummonArray, nIndex, sResRef);
            //Debug ("0e_window", "552", "sSummonArray: " + sSummonArray);
            SetObjectDatabaseString (oPC, CHARACTER_TABLE, "summons", sSummonArray);
        }
    }
    //**************************************************************************
    // Player magic teleport window events.
    else if (sWndId == "plteleportwin")
    {
        if (sEvent == "click")
        {
            // Get the selected button.
            int nSelected = JsonGetInt (NuiGetUserData (oPC, nToken));
            if (GetStringLeft (sElem, 8) == "btn_loc_")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, sElem)))
                {
                    // Get the selection from the element.
                    nSelected = StringToInt (GetStringRight (sElem, 1));
                    if (nSelected == 0) nSelected = 10;
                }
                else
                {
                    nSelected = 0;
                }
                // Set the button selected in the UI and database.
                NuiSetUserData (oPC, nToken, JsonInt (nSelected));
                json jTArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
                jTArray = JsonArraySet (jTArray, 21, JsonInt (nSelected));
                SetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport", jTArray);
                // Make sure all other buttons are off.
                int nTh = 1;
                while (nTh < 11)
                {
                    if (nSelected != nTh) NuiSetBind (oPC, nToken, "btn_loc_" + IntToString (nTh), JsonBool (FALSE));
                    nTh ++;
                }
            }
            if (sElem == "btn_save_location")
            {
                json jTArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
                // If one is not selected then get the first empty one.
                int nTh = 1;
                if (nSelected == 0)
                {
                    while (nTh < 11)
                    {
                        if (JsonGetString (JsonArrayGet (jTArray, nTh)) == "")
                        {
                            nSelected = nTh;
                            break;
                        }
                        nTh ++;
                    }
                }
                // No button was selected and none of them are free.
                if (nTh > 10)
                {
                    SendMessages ("This area was not saved for Teleport! You did not select a button and none of the buttons are free!", COLOR_RED, oPC);
                }
                else
                {
                    // Save the location to the button.
                    location lLocation = GetLocation (oPC);
                    string sAreaName = GetName (GetArea (oPC));
                    // Limit the size of the names on the buttons.
                    if (GetStringLength (sAreaName) > 20) sAreaName = GetStringLeft (sAreaName, 20);
                    jTArray = JsonArraySet (jTArray, nSelected, JsonString (LocationToStringArray (lLocation)));
                    jTArray = JsonArraySet (jTArray, nSelected + 10, JsonString (sAreaName));
                    SetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport", jTArray);
                    NuiSetBind (oPC, nToken, "btn_loc_" + IntToString (nSelected) + "_label", JsonString (sAreaName));
                    SendMessages (sAreaName + " was saved as a location for Teleport!", COLOR_GREEN, oPC);
                }
            }
            if (sElem == "btn_clear_location")
            {
                if (nSelected == 0)
                {
                    SendMessages ("A button was not selected for us to clear.", COLOR_RED, oPC);
                    return;
                }
                json jTArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
                // Clear the location to the button.
                jTArray = JsonArraySet (jTArray, nSelected, JsonString (""));
                jTArray = JsonArraySet (jTArray, nSelected + 10, JsonString (""));
                SetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport", jTArray);
                NuiSetBind (oPC, nToken, "btn_loc_" + IntToString (nSelected) + "_label", JsonString ("None"));
                SendMessages ("Cleared selected location for Teleport!", COLOR_GREEN, oPC);
            }
            if (sElem == "btn_cast_teleport")
            {
                int nSpell = GetLocalInt (oPC, "0_Teleport_Spell");
                string sLocation;
                // Make sure we have cleared any spell cast.
                DeleteLocalInt (oPC, "0_Teleport_Spell");
                if (nSelected == 0)
                {
                    string sAreaTag = JsonGetString (NuiGetBind (oPC, nToken, "area_tag"));
                    if (sAreaTag == "")
                    {
                        string sXPos = JsonGetString (NuiGetBind (oPC, nToken, "x_pos"));
                        string sYPos = JsonGetString (NuiGetBind (oPC, nToken, "y_pos"));
                        string sZPos = JsonGetString (NuiGetBind (oPC, nToken, "z_pos"));
                        sAreaTag = sXPos + "_" + sYPos;
                        if (sZPos != "") sAreaTag += "_" + sZPos;
                    }
                    object oArea = GetObjectByTag (sAreaTag);
                    if (oArea == OBJECT_INVALID) oArea = GenerateArea (sAreaTag);
                    if (!GetIsObjectValid (oArea))
                    {
                        SendMessages ("The area tag or position entered is not a valid location!", COLOR_RED, oPC);
                        return;
                    }
                    // Create an array for sLocation to pass to the teleport.
                    // Leave the index 1 slot blank "";
                    sLocation = ":" + sAreaTag + "::";
                }
                else
                {
                    json jTArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
                    sLocation = JsonGetString (JsonArrayGet (jTArray, nSelected));
                    jTArray = JsonArraySet (jTArray, 21, JsonInt (0));
                    SetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport", jTArray);
                }
                Teleport(oPC, sLocation, nSpell, 20);
                NuiDestroy (oPC, nToken);
            }
        }
    }
    //**************************************************************************
    // Player language events.
    else if (sWndId == "pclangwin")
    {
        if (sEvent == "click")
        {
            if (sElem == "btn_take_lang")
            {
                json jComboBox = JsonArray ();
                json jWindow = JsonArray ();
                jWindow = NuiGetUserData (oPC, nToken);
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "take_combo_selected")) - 1;
                jComboBox = JsonArrayGet (jWindow, 1);
                int nLanguage = JsonGetInt (JsonArrayGet (jComboBox, nSelected));
                NWNX_Creature_AddFeatByLevel (oPC, nLanguage, GetCharacterLevels (oPC, FALSE));
                PopUpCharacterLanguageGUIPanel (oPC);
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_throw_voice")
            {
                SetLocalString (oPC, "0_Target_Mode", "0_PLAYER_GET_TARGET");
                EnterTargetingMode (oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
        }
        else if (sEvent == "watch" && sElem == "use_combo_selected" && !GetLocalInt (oPC, "0_No_Sum_Save"))
        {
            int nSelected, nLang;
            json jComboBox = JsonArray ();
            json jWindow = JsonArray ();
            jWindow = NuiGetUserData (oPC, nToken);
            nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem)) - 1;
            jComboBox = JsonArrayGet (jWindow, 0);
            nLang = JsonGetInt (JsonArrayGet (jComboBox, nSelected));
            SetLocalInt (oPC, "0_Language", nLang);
            string sLang = Get2DAString ("feat", "LABEL", nLang);
            SendMessages ("You have changed your language to " + sLang + ".", COLOR_GRAY, oPC, FALSE, FALSE);
            SendMessages ("Any text typed within [] will be in " + sLang + ".", COLOR_GRAY, oPC, FALSE, FALSE);
        }
    }
    /***************************************************************************
    * DM only events                                                           *
    ***************************************************************************/
    //**************************************************************************
    // DM creature window events.
    else if(sWndId == "dmcreaturewin")
    {
        int nID;
        string sID, sResRef;
        // Get the DM creature target.
        object oTarget = GetLocalObject(oPC, DM_TARGET_CREATURE);
        if(oTarget == OBJECT_INVALID) oTarget = oPC;
        // Change character textedit boxes.
        if(sEvent == "watch")
        {
            if (sElem == "char_name")
            {
                // Saving name to target.
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "char_name"));
                SetName (oTarget, sName);
            }
            else if (sElem == "desc_value")
            {
                // Save the Description to target.
                string sDescription = JsonGetString (NuiGetBind (oPC, nToken, "desc_value"));
                SetDescription (oTarget, sDescription);
            }
            else if (sElem == "port_name")
            {
                nID = JsonGetInt (NuiGetUserData (oPC, nToken));
                if (GetLocalInt (oPC, "0_Port_ID"))
                {
                    NuiSetBind (oPC, nToken, "port_id_label", JsonString (IntToString (nID)));
                }
                else NuiSetBind (oPC, nToken, "port_id_label", JsonString ("Custom Portrait"));
                DeleteLocalInt (oPC, "0_Port_ID");
                sResRef = JsonGetString (NuiGetBind (oPC, nToken, "port_name"));
                NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "l"));
                // Save the portrait
                sResRef = JsonGetString (NuiGetBind (oPC, nToken, "port_name"));
                SetPortraitResRef (oTarget, sResRef);
            }
            else if (sElem == "deity_box")
            {
                string sDeity = JsonGetString (NuiGetBind (oPC, nToken, "deity_box"));
                SetDeity (oTarget, sDeity);
                CheckDeityInDatabase (oPC, oTarget);
            }
            else if(sElem == "wings_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                if(Get2DAString ("wingmodel", "Label", nSelected) != "")
                {
                    SetCreatureWingType(nSelected, oTarget);
                }
                else NuiSetBind (oPC, nToken, "wings_combo_selected", JsonInt(0));
            }
            else if(sElem == "tails_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                if(Get2DAString ("tailmodel", "Label", nSelected) != "")
                {
                    SetCreatureTailType(nSelected, oTarget);
                }
                else NuiSetBind (oPC, nToken, "tails_combo_selected", JsonInt(0));
            }
        }
        else if (sEvent == "mousedown")
        {
            int bPC = GetIsPC (oTarget);
            if (sElem == "align") PopUpDMAlignGUIPanel (oPC);
            else if (!bPC && (sElem == "class1" || sElem == "class2" ||
                sElem == "class3")) PopUpDMClassGUIPanel (oPC);
            else if (sElem == "hp_value") PopUpDMHPGUIPanel (oPC);
            else if (bPC && (sElem == "fame_value" || sElem == "infamy_value")) PopUpDMReputationGUIPanel (oPC);
            else if (bPC && sElem == "racial_xp_value") PopUpDMXPGUIPanel (oPC);
            else if (bPC && sElem == "xp_value") PopUpDMXPGUIPanel (oPC);
            else if (sElem == "gold_value") PopUpDMGoldGUIPanel (oPC);
            else if (sElem == "wealth_value") PopupDMItemWealthGUIPanel (oPC);
            else if (bPC && sElem == "player_value") PopUpDMPlayerGUIPanel (oPC);
            else if (!bPC && sElem == "c_faction_value") PopUpDMFactionsGUIPanel (oPC);
            else if (!bPC && sElem == "p_faction_value") PopUpDMFactionsGUIPanel (oPC);
        }
        else if (sEvent == "click")
        {
            int nAbility = 6, nAdj = 0, nChange = 0;
            // Adjust portrait id **********************************************
            if (sElem == "btn_portrait_next")
            {
                nID = JsonGetInt(NuiGetUserData (oPC, nToken)) + 1;
                nChange = 1;
            }
            else if (sElem == "btn_portrait_prev")
            {
                nID = JsonGetInt(NuiGetUserData (oPC, nToken)) - 1;
                nChange = -1;
            }
            // Adjust ability scores *******************************************
            else if (sElem == "btn_up_str") {nAbility = ABILITY_STRENGTH; nAdj = 1;}
            else if (sElem == "btn_down_str") {nAbility = ABILITY_STRENGTH; nAdj = -1;}
            else if (sElem == "btn_up_dex") {nAbility = ABILITY_DEXTERITY; nAdj = 1;}
            else if (sElem == "btn_down_dex") {nAbility = ABILITY_DEXTERITY; nAdj = -1;}
            else if (sElem == "btn_up_con") {nAbility = ABILITY_CONSTITUTION; nAdj = 1;}
            else if (sElem == "btn_down_con") {nAbility = ABILITY_CONSTITUTION; nAdj = -1;}
            else if (sElem == "btn_up_int") {nAbility = ABILITY_INTELLIGENCE; nAdj = 1;}
            else if (sElem == "btn_down_int") {nAbility = ABILITY_INTELLIGENCE; nAdj = -1;}
            else if (sElem == "btn_up_wis") {nAbility = ABILITY_WISDOM; nAdj = 1;}
            else if (sElem == "btn_down_wis") {nAbility = ABILITY_WISDOM; nAdj = -1;}
            else if (sElem == "btn_up_cha") {nAbility = ABILITY_CHARISMA; nAdj = 1;}
            else if (sElem == "btn_down_cha") {nAbility = ABILITY_CHARISMA; nAdj = -1;}
            // Open the variable menu ******************************************
            else if (sElem == "btn_variables") 
            {
                SetLocalInt(oPC, DM_VAR_TARGET_TYPE, OBJECT_TYPE_CREATURE);
                PopupDMVariablesGUIPanel(oPC);
            }
            // Open the quest menu *********************************************
            else if (sElem == "btn_quest")
            {
                if(GetIsDungeonMaster(oTarget)) 
                {
                    SendMessages("You cannot change a DM's quests!", COLOR_RED, oPC);
                    return;
                }
                NuiDestroy (oPC, nToken);
                PopUpQuestsGUIPanel (oPC);
            }
            else if (sElem == "btn_inventory")
            {
                NWNX_Player_OpenInventory (oPC, oTarget);
                NuiDestroy (oPC, nToken);
                SetLocalInt(oPC, DM_INV_TARGET_TYPE, OBJECT_TYPE_CREATURE);
                PopUpDMInventoryGUIPanel (oPC);
            }
            // Remove associate as a henchman **********************************
            else if (sElem == "btn_assoc")
            {
                object oPC = GetMaster (oTarget);
                if (GetLocalInt (oTarget, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_HENCHMAN) FireHenchman (oPC, oTarget);
                else if (GetLocalInt (oTarget, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_NPC) RemoveQuestNPC (oPC, oTarget);
            }
            // Add an npc as a henchmen ****************************************
            else if (sElem == "btn_hench")
            {
                SetLocalString (oPC, "0_Target_Mode", "0_HENCH_TARGET");
                SendMessages ("Select a player for this NPC to become a henchman for.", COLOR_GRAY, oPC);
                SetLocalObject (oPC, "0_HenchmanTarget", oTarget);
                EnterTargetingMode (oPC, OBJECT_TYPE_CREATURE);
            }
            // Map area for player *********************************************
            else if (sElem == "btn_map_area") ExploreAreaForPlayer (GetArea (oTarget), oTarget, TRUE);
            // Reset a player **************************************************
            else if (sElem == "btn_reset")
            {
                SendMessages ("Your factions and last rest have been reset!", COLOR_GREEN, oTarget);
                SendMessages ("You have reset " + GetName (oTarget) + "'s factions!", COLOR_GREEN, oTarget);
                SetStandardFactionReputation (STANDARD_FACTION_COMMONER, 50, oPC);
                SetStandardFactionReputation (STANDARD_FACTION_MERCHANT, 50, oPC);
                SetStandardFactionReputation (STANDARD_FACTION_DEFENDER, 50, oPC);
                SetCommandable (TRUE, oTarget);
                RemoveASpecificEffect (oTarget, EFFECT_TYPE_CUTSCENEIMMOBILIZE);
                RemoveASpecificEffect (oTarget, EFFECT_TYPE_CUTSCENEGHOST);
                SetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "lastrested", 0);
            }
            else if(sElem == "btn_database") PopUpDMDatabaseGUIPanel(oPC);
            // Changes the portrait id if adjusted.
            if(nChange != 0)
            {
                int nPRace, nPGender;
                if(nID > 1317) nID = 1;
                if(nID < 1) nID = 1317;
                int nGender = GetGender(oTarget);
                int nRace = GetRaceType(oTarget, TRUE);
                string sPRace = Get2DAString("portraits", "Race", nID);
                if(sPRace != "") nPRace = StringToInt(sPRace);
                else nPRace = -1;
                string sPGender = Get2DAString ("portraits", "Sex", nID);
                if(sPGender != "") nPGender = StringToInt (sPGender);
                else nPGender = -1;
                while((nRace != nPRace && (nRace != 4 || (nPRace != 1 && nPRace != 6))) || 
                      (nGender != nPGender && nPGender < 2))
                {
                    nID += nChange;
                    if(nID > 1317) nID = 1;
                    if(nID < 1) nID = 1317;
                    sPRace = Get2DAString ("portraits", "Race", nID);
                    if(sPRace != "") nPRace = StringToInt (sPRace);
                    else nPRace = -1;
                    sPGender = Get2DAString ("portraits", "Sex", nID);
                    if(sPGender != "") nPGender = StringToInt (sPGender);
                    else nPGender = -1;
                }
                string sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID);
                NuiSetUserData (oPC, nToken, JsonInt (nID));
                SetLocalInt (oPC, "0_Port_ID", TRUE);
                NuiSetBind (oPC, nToken, "port_name", JsonString (sResRef));
                // Save the portrait
                SetPortraitId (oTarget, nID);
            }
            // Change abilitiy scores if adjusted.
            if (nAbility < 6)
            {
                int nScore = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, IntToString (nAbility) + "_value_label"))) + nAdj;
                if (nScore > 40) nScore = 3;
                else if (nScore < 3) nScore = 40;
                int nMod;
                if (nScore < 10) nMod = (nScore - 11) / 2;
                else nMod = (nScore - 10) / 2;
                NuiSetBind (oPC, nToken, IntToString (nAbility) + "_value_label", JsonString (IntToString (nScore)));
                NuiSetBind (oPC, nToken, IntToString (nAbility) + "_mod_label", JsonString (IntToString (nMod)));
                NWNX_Creature_ModifyRawAbilityScore (oTarget, nAbility, nAdj);
            }
            else if(sElem == "btn_quest_create") 
            {
                object oPaper = CreateBlankQuest(oPC, oTarget);
                SetLocalObject(oPC, "0_DM_QUEST_TARGET", oPaper);
                PopUpDMQuestItemGUIPanel(oPC);
            }
        }
    }
    //**************************************************************************
    // DM server main quests window events.
    else if(sWndId == "dmmainquestswin")
    {
        object oTarget = GetLocalObject(oPC, DM_TARGET_CREATURE);
        if(GetIsDungeonMaster(oTarget)) 
        {
            SendMessages("You cannot change a DM's quests!", COLOR_RED, oPC);
            return;
        }
        int nSelected;
        string sQuestName, sOption;
        int nQuestType = GetLocalInt(oTarget, "0_Menu_Quest_type");
        string s2daQuestColumn, sText;
        if(nQuestType == STORY_QUESTS) s2daQuestColumn = "Story_Quest";
        else if(nQuestType == SIDE_QUESTS) s2daQuestColumn = "Side_Quest";
        else s2daQuestColumn = "Loc_Quest";
        if(sEvent == "watch")
        {
            if(sElem == "menu_quest_selected")
            {
                // Save the selection.
                nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                sOption = GetServerDatabaseString(oPC, PLAYER_TABLE, "dmmainquestswin");
                sOption = SetStringArray(sOption, 0, IntToString(nSelected));
                sQuestName = Get2DAString("quest_list", s2daQuestColumn + "_Name", nSelected);
                SetServerDatabaseString(oPC, PLAYER_TABLE, "dmmainquestswin", sOption);
                // Get the quest description to display.
                string sQuestDesc = Get2DAString("quest_list", s2daQuestColumn + "_Desc", nSelected);
                NuiSetBind(oPC, nToken, "menu_quest_desc_label", JsonString (sQuestDesc));
                // Get the quest name and player quest pointer.
                int nTargetPointer = GetObjectDatabaseInt(oTarget, QUEST_TABLE, "questpointer", sQuestName);
                // Set the buttons based on players location in the quest.
                int bQuestSet = FALSE, bQuestClear = FALSE, bQuestComplete = FALSE;
                string sText;
                if(nTargetPointer == 0) 
                {
                    bQuestClear = TRUE;
                    sText = " has not started.";
                }
                else if(nTargetPointer == -1) 
                {
                    bQuestComplete = TRUE;
                    sText = " is Completed!";
                }
                else 
                {
                    if(nQuestType == STORY_QUESTS) sText = " is on part " + GetStringLeft(Get2DAString ("quest_list", s2daQuestColumn + "_Desc", nTargetPointer), 1);
                    else if(nQuestType == SIDE_QUESTS || nQuestType == LOCATION_QUESTS) sText = " is active.";
                }
                NuiSetBind (oPC, nToken, "btn_quest_clear", JsonBool (bQuestClear));
                if (nTargetPointer == nSelected) bQuestSet = TRUE;
                NuiSetBind (oPC, nToken, "btn_quest_set", JsonBool (bQuestSet));
                NuiSetBind (oPC, nToken, "btn_quest_complete", JsonBool (bQuestComplete));
                NuiSetBind(oPC, nToken, "lbl_quest_part_label", JsonString(sQuestName + sText));
            }
            if (sElem == "quest_type_selected")
            {
                // Save the selection.
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetLocalInt (oTarget, "0_Menu_Quest_type", nSelected);
                // Get the quest name and player quest pointer.
                sQuestName = Get2DAString ("quest_list", s2daQuestColumn + "_Name", nSelected);
                int nTargetPointer = GetObjectDatabaseInt (oTarget, QUEST_TABLE, "questpointer", sQuestName);
                int bQuestSet;
                if(nTargetPointer == nSelected) bQuestSet = TRUE;
                NuiSetBind (oPC, nToken, "btn_quest_set", JsonBool (bQuestSet));
                PopUpQuestsGUIPanel (oPC);
            }
            if (sElem == "mquests_done")
            {
                nSelected = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "mquests_done")));
                SetObjectDatabaseInt (oPC, CHARACTER_TABLE, "mainquests", nSelected);
            }
            if (sElem == "squests_done")
            {
                nSelected = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "squests_done")));
                SetObjectDatabaseInt (oPC, CHARACTER_TABLE, "sidequests", nSelected);
            }
        }
        else if (sEvent == "click")
        {
            // Get the players selection in the combo box.
            sOption = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmmainquestswin");
            nSelected = StringToInt(GetStringArray (sOption, 0));
            // Get the quest name and save the quest as finished, make sure to initialize.
            sQuestName = Get2DAString ("quest_list", s2daQuestColumn + "_Name", nSelected);
            // Make sure this quest is setup in the database.
            CheckObjectDataAndInitialize (oTarget, QUEST_TABLE, sQuestName);
            if (sElem == "btn_quest_clear")
            {
                SetObjectDatabaseInt (oTarget, QUEST_TABLE, "questpointer", 0, sQuestName);
                //Debug ("0e_window", "931", "oTarget: " + GetName (oTarget) + " sQuestName: " + sQuestName);
                // Set the buttons to the new point.
                NuiSetBind (oPC, nToken, "btn_quest_complete", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_quest_set", JsonBool (FALSE));
                NuiSetBind(oPC, nToken, "lbl_quest_part_label", JsonString(sQuestName + " has not started."));
                RemoveJournalEntry(sQuestName, oTarget);
                string sQuestID = GetQuestIDByQuestName(oTarget, sQuestName);
                // Find the quest paper on oPC for sQuestID and destroy it!
                object oPaper = GetFirstItemInInventory(oTarget);
                while(oPaper != OBJECT_INVALID)
                {
                    if(sQuestID == GetLocalString(oPaper, "0_Q_ID") && GetTag(oPaper) == "0_quest_paper") 
                    {
                        RemoveQuestPaperFromDatabase(oTarget, oPaper);
                        DestroyObject(oPaper);
                        break;
                    }
                    oPaper = GetNextItemInInventory(oTarget);
                }
            }
            else if(sElem == "btn_quest_set")
            {
                // Get the paper for this quest if it exists and destroy it.
                string sQuestID = GetQuestIDByQuestName(oTarget, sQuestName);
                // Get the quest StrRef and create the quest selected.
                string sStrRef = Get2DAString("quest_list", s2daQuestColumn + "_StrRef", nSelected);
                // Find the quest paper on oPC for sQuestID and destroy it!
                object oPaper = GetFirstItemInInventory(oTarget);
                while(oPaper != OBJECT_INVALID)
                {
                    if(sQuestID == GetLocalString(oPaper, "0_Q_ID") && GetTag(oPaper) == "0_quest_paper") 
                    {
                        RemoveQuestPaperFromDatabase(oTarget, oPaper);
                        DestroyObject(oPaper);
                        break;
                    }
                    oPaper = GetNextItemInInventory(oTarget);
                }
                // Move paper to Quest book if they have one else give to the PC and lock it.
                object oBook = GetItemPossessedBy(oTarget, "0_quest_book");
                if(oBook != OBJECT_INVALID) oPaper = CreateQuest(oTarget, oBook, nQuestType, StringToInt(sStrRef));
                else oPaper = CreateQuest(oTarget, oTarget, nQuestType, StringToInt(sStrRef));
                SetItemCursedFlag(oPaper, TRUE);
                // Save the pointer for the quest in the database.
                SetObjectDatabaseInt(oTarget, QUEST_TABLE, "questpointer", nSelected, sQuestName);
                // Set the quest papers description.
                // Quest givers StrRef Lines are +1 Starting convo
                int nQuestStrRef = StringToInt(GetLocalString (oPaper, "0_Q_STRREF"));
                string sQuestText = GetStringByStrRef(nQuestStrRef + 1);
                sQuestText = ParseQuestTextByPaper(sQuestText, oPaper, oTarget);
                // Get the givers name to place on papers.
                string sArray = GetLocalString(oPaper, "0_Q_GIVER");
                string sName = AddColorToText(GetStringArray (sArray, 0, "-"), COLOR_GREEN);
                sArray = GetLocalString(oPaper, "0_Q_START");
                string sArea = AddColorToText(GetStringArray (sArray, 0, "-"), COLOR_GREEN);
                // Set the Papers description.
                if(sName != "" && sArea != "") sQuestText = sName + " located in " + sArea + " has given you a quest. '" + sQuestText + "'.";
                SetDescription(oPaper, sQuestText);
                // Set the quest papers name using parts via journal ID.
                string sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
                string sJournalID = GetStringArray(sQuestArray, 6, "-");
                string sPaperQuestName = sQuestName + " Quest (Part " + sJournalID + ")";
                SetName(oPaper, AddColorToText(sPaperQuestName, COLOR_MAGENTA));
                // Plot #2: Delivering Item.
                string sPlot = GetLocalString(oPaper, "0_Q_PLOT");
                if(sPlot == "2") DelayCommand(0.5f, CreateQuestItem(oTarget, oTarget, sQuestID, "item"));
                // Check to see if they are giving an item.
                if(GetLocalString(oPaper, "0_Q_GIVEITEM") != "")
                {
                    DelayCommand(0.5f, CreateQuestItem(oTarget, oTarget, sQuestID, "giveitem"));
                }
               // Plot #1:Destroy Placeable, #5:Kill, #6/#7:Delivering NPC, #8:Clear area.
                if(sPlot == "1" || sPlot == "5" || sPlot == "6" || sPlot == "7" || sPlot == "8")
                {
                    string sNPCArray = GetLocalString(oPaper, "0_Q_NPC");
                    DelayCommand (0.2f, GiveQuestNPC(oPaper, sQuestID, sNPCArray, sQuestArray));
                }
                // Does this quest add a Journal entry on quest start?
                int nJournalID = StringToInt(GetStringArray (sQuestArray, 6, "-"));
                if(nJournalID > 0) 
                {
                    RemoveJournalEntry(sQuestName, oTarget);
                    AddJournalEntry(sQuestName, nJournalID, oTarget);
                }
                // Set the buttons to the new point.
                NuiSetBind(oPC, nToken, "btn_quest_clear", JsonBool (FALSE));
                NuiSetBind(oPC, nToken, "btn_quest_set", JsonBool (TRUE));
                NuiSetBind(oPC, nToken, "btn_quest_complete", JsonBool (FALSE));
                string sText = " is on part " + GetStringLeft(Get2DAString ("quest_list", s2daQuestColumn + "_Desc", nSelected), 1);
                NuiSetBind(oPC, nToken, "lbl_quest_part_label", JsonString(sQuestName + sText));
            }
            else if(sElem == "btn_quest_complete")
            {
                SetObjectDatabaseInt(oTarget, QUEST_TABLE, "questpointer", -1, sQuestName);
                // Set the buttons to the new point.
                NuiSetBind(oPC, nToken, "btn_quest_clear", JsonBool (FALSE));
                NuiSetBind(oPC, nToken, "btn_quest_set", JsonBool (FALSE));
                NuiSetBind(oPC, nToken, "lbl_quest_part_label", JsonString(sQuestName + " is Completed!"));
                RemoveJournalEntry(sQuestName, oTarget);
                // Add the final journal entry if there is one.
                if(nQuestType == STORY_QUESTS)
                { 
                    int nIndex = nSelected;
                    string s2DAQuestName = Get2DAString ("quest_list", "Story_Quest_Name", nIndex);
                    while(s2DAQuestName == sQuestName)
                    {
                        s2DAQuestName = Get2DAString ("quest_list", "Story_Quest_Name", ++nIndex);
                    }
                    string sStrRef = GetStringByStrRef( StringToInt(Get2DAString("quest_list", "Story_Quest_StrRef", --nIndex)));
                    int i = FindSubString(sStrRef, "[REWARDS:");
                    string sRewardsArray = GetQuestData(sStrRef, i + 8);
                    int nJournalID = StringToInt(GetStringArray (sRewardsArray, 5, "-"));
                    AddJournalEntry(sQuestName, nJournalID, oTarget);
                }
                if(nQuestType == LOCATION_QUESTS)
                {
                    AddJournalEntry(sQuestName, 2, oTarget);
                }
                // Get the paper and destroy it if it exists.
                string sID = GetQuestIDByQuestName(oTarget, sQuestName);
                string sQuestID = GetQuestIDByQuestName(oTarget, sQuestName);
                // Find the quest paper on oPC for sQuestID and destroy it!
                object oPaper = GetFirstItemInInventory(oPC);
                while(oPaper != OBJECT_INVALID)
                {
                    if(sQuestID == GetLocalString(oPaper, "0_Q_ID")) 
                    {
                        DestroyObject(oPaper);
                        break;
                    }
                    oPaper = GetNextItemInInventory(oPC);
                }
            }
        }
    }
    //**************************************************************************
    // DM server main quests window events.
    else if (sWndId == "dmdatabasewin")
    {
        object oTarget = GetLocalObject(oPC, DM_TARGET_CREATURE);
        if (sEvent == "click")
        {
            if(sElem == "btn_o_delete")
            {
                string sTag, sObjectTag;
                int nDatabaseIndex;
                string sQuery = "SELECT tag, objecttag FROM " + OBJECT_TABLE + " WHERE name = @name;";
                sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
                SqlBindString(sql, "@name", GetName(oTarget, TRUE));
                if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
                while(sTag != "")
                {
                    if(nDatabaseIndex == nIndex)
                    {
                        SendMessages(GetName(oPC) + " has removed " + sTag + " (" + sObjectTag + ") from the database.", COLOR_YELLOW, oPC, TRUE, TRUE);
                        DeleteServerDatabaseObject(oTarget, OBJECT_TABLE, sTag);
                        break;
                    }
                    nDatabaseIndex++;
                    if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
                    else sTag = "";
                }
                NuiDestroy(oPC, nToken);
                PopUpDMDatabaseGUIPanel(oPC);
            }
            else if(sElem == "btn_q_delete")
            {
                string sTag, sName;
                int nDatabaseIndex;
                string sQuery = "SELECT tag, quest, area FROM " + QUEST_TABLE + " WHERE name = @name;";
                sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
                SqlBindString(sql, "@name", GetName(oTarget, TRUE));
                if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
                while(sTag != "")
                {
                    if(nDatabaseIndex == nIndex)
                    {
                        sName = SqlGetString(sql, 1);
                        sName = GetStringArray(sName, 0, "-");
                        if(sName == "Treasure Map")
                        {
                            sName = SqlGetString(sql, 2);
                            sName = GetStringArray(sName, 0, "-");
                        }
                        SendMessages(GetName(oPC) + " has removed " + sName + " (" + sTag + ") from the database.", COLOR_YELLOW, oPC, TRUE, TRUE);
                        DeleteServerDatabaseObject(oTarget, QUEST_TABLE, sTag);
                        break;
                    }
                    nDatabaseIndex++;
                    if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
                    else sTag = "";
                }
                NuiDestroy(oPC, nToken);
                PopUpDMDatabaseGUIPanel(oPC);
            }
        }
    }
    //**************************************************************************
    // DM Experience window events.
    else if(sWndId == "dmxpwin")
    {
        object oTarget = GetLocalObject(oPC, DM_TARGET_CREATURE);
        if(sEvent == "click")
        {
            if(sElem == "btn_party_xp") return;
            string sType;
            string sXpAdj = JsonGetString(NuiGetBind(oPC, nToken, "xp_amount"));
            string sRacialXpAdj = JsonGetString(NuiGetBind(oPC, nToken, "racial_xp_amount"));
            int nXp;
            int nXpAdj = StringToInt(sXpAdj);
            float fRacialXpAdj = StringToFloat(sRacialXpAdj);
            float fRacialXp = GetLocalFloat(oTarget, "0_RacialXP");
            object oPlayer;
            int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, "xp_opt_selected"));
            if(nSelected == 0) sType = "";
            else if(nSelected == 1) sType = " roleplay";
            else if(nSelected == 2) sType = " quest";
            else if(nSelected == 3) sType = " puzzle";
            else if(nSelected == 4) sType = " milestone";
            else if(nSelected == 5) sType = " adventure";
            if(sElem == "btn_1_xp")
            {
                nXpAdj = FloatToInt(IntToFloat(GetXpForNextLevel(GetCharacterLevels(oTarget))) * 0.01f);
                sXpAdj = IntToString(nXpAdj);
                NuiSetBind(oPC, nToken, "xp_amount", JsonString(sXpAdj));
            }
            else if(sElem == "btn_5_xp")
            {
                nXpAdj = FloatToInt(IntToFloat(GetXpForNextLevel(GetCharacterLevels(oTarget))) * 0.05f);
                sXpAdj = IntToString(nXpAdj);
                NuiSetBind(oPC, nToken, "xp_amount", JsonString(sXpAdj));
            }
            else if(sElem == "btn_10_xp")
            {
                nXpAdj = FloatToInt(IntToFloat(GetXpForNextLevel(GetCharacterLevels(oTarget))) * 0.10f);
                sXpAdj = IntToString(nXpAdj);
                NuiSetBind(oPC, nToken, "xp_amount", JsonString(sXpAdj));
            }
            else if(nXpAdj == 0 && fRacialXpAdj == 0.0f)
            {
                SendMessages("Invalid amount of Experience!", COLOR_RED, oPC);
            }
            else if(sElem == "btn_give_xp")
            {
                if(JsonDump(NuiGetBind(oPC, nToken, "btn_party_xp")) == "true")
                {
                    if(nXpAdj != 0) SendMessages("Party gains" + sType + " experience of " + sXpAdj + "!", COLOR_GREEN, oPC);
                    if(fRacialXpAdj != 0.0f) SendMessages("Party gains" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_RED, oPC);
                    oPlayer = GetFirstFactionMember(oTarget);
                    while(oPlayer != OBJECT_INVALID)
                    {
                        if(fRacialXpAdj > 0.0f)
                        {
                            SetLocalFloat(oPlayer, "0_RacialXP", fRacialXp + fRacialXpAdj);
                            SendMessages("You have gained" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_RED, oPlayer);
                        }
                        if(nXpAdj > 0)
                        {
                            nXp = GetXP(oPlayer);
                            SetXP(oPlayer, nXp + nXpAdj);
                            SendMessages("You have gained" + sType + " experience of " + sXpAdj + "!", COLOR_GREEN, oPlayer);
                        }
                        oPlayer = GetNextFactionMember(oTarget);
                    }
                }
                else
                {
                    if(fRacialXpAdj > 0.0f)
                    {
                        SetLocalFloat(oTarget, "0_RacialXP", fRacialXp + fRacialXpAdj);
                        SendMessages(GetName(oTarget) + " has gained" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_RED, oPC);
                        SendMessages("You have gained" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_RED, oTarget);
                    }
                    if(nXpAdj > 0)
                    {
                        nXp = GetXP(oTarget);
                        SetXP(oTarget, nXp + nXpAdj);
                        SendMessages(GetName (oTarget) + " has gained" + sType + " experience of " + sXpAdj + "!", COLOR_GREEN, oPC);
                        SendMessages("You have gained" + sType + " experience of " + sXpAdj + "!", COLOR_GREEN, oTarget);
                    }
                }
                NuiDestroy(oPC, nToken);
            }
            else if(sElem == "btn_take_xp")
            {
                if(JsonDump(NuiGetBind (oPC, nToken, "btn_party_xp")) == "true")
                {
                    if(nXpAdj != 0) SendMessages("Party loses" + sType + " experience of " + sXpAdj + "!", COLOR_RED, oPC);
                    if(fRacialXpAdj != 0.0f) SendMessages("Party loses" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_GREEN, oPC);
                    oPC = GetFirstFactionMember(oTarget);
                    while(oPC != OBJECT_INVALID)
                    {
                        if(fRacialXpAdj > 0.0f)
                        {
                            SetLocalFloat(oPC, "0_RacialXP", fRacialXp - fRacialXpAdj);
                            SendMessages("You have lost" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_GREEN, oPC);
                        }
                        if(nXpAdj > 0)
                        {
                            nXp = GetXP(oPC);
                            SetXP(oPC, nXp - nXpAdj);
                            SendMessages("You have lost" + sType + " experience of " + sXpAdj + "!", COLOR_RED, oPC);
                        }
                        oPC = GetNextFactionMember(oTarget);
                    }
                }
                else
                {
                    if(fRacialXpAdj > 0.0f)
                    {
                        SetLocalFloat(oTarget, "0_RacialXP", fRacialXp - fRacialXpAdj);
                        SendMessages(GetName (oTarget) + " has lost" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_GREEN, oPC);
                        SendMessages("You have lost" + sType + " racial experience of " + sRacialXpAdj + "!", COLOR_GREEN, oTarget);
                    }
                    if(nXpAdj > 0)
                    {
                        nXp = GetXP(oTarget);
                        SetXP(oTarget, nXp - nXpAdj);
                        SendMessages(GetName (oTarget) + " has lost" + sType + " experience of " + sXpAdj + "!", COLOR_RED, oPC);
                        SendMessages("You have lost" + sType + " experience of " + sXpAdj + "!", COLOR_RED, oTarget);
                    }
                }
                NuiDestroy(oPC, nToken);
            }
            else if(sElem == "btn_set_xp")
            {
                if(JsonDump (NuiGetBind (oPC, nToken, "btn_party_xp")) == "true")
                {
                    if(nXpAdj != 0) SendMessages("Parties experience has been set to " + sXpAdj + "!", COLOR_YELLOW, oPC);
                    if(fRacialXpAdj != 0.0f) SendMessages("Parties racial experience has been set to " + sRacialXpAdj + "!", COLOR_YELLOW, oPC);
                    oPC = GetFirstFactionMember (oTarget);
                    while(oPC != OBJECT_INVALID)
                    {
                        if(fRacialXpAdj > 0.0f)
                        {
                            SetLocalFloat(oPC, "0_RacialXP", fRacialXpAdj);
                            SendMessages("Your racial experience has been set to " + sRacialXpAdj + "!", COLOR_YELLOW, oPC);
                        }
                        if(nXpAdj > 0)
                        {
                            SetXP(oPC, nXpAdj);
                            SendMessages("Your experience has been set to " + sXpAdj + "!", COLOR_YELLOW, oPC);
                        }
                        oPC = GetNextFactionMember(oTarget);
                    }
                }
                else
                {
                    if(fRacialXpAdj > 0.0f)
                    {
                        SetLocalFloat(oTarget, "0_RacialXP", fRacialXpAdj);
                        SendMessages(GetName(oTarget) + "'s racial experience has been set to " + sRacialXpAdj + "!", COLOR_YELLOW, oPC);
                        SendMessages("Your racial experience has been set to " + sRacialXpAdj + "!", COLOR_YELLOW, oTarget);
                    }
                    if(nXpAdj > 0)
                    {
                        SetXP(oTarget, nXpAdj);
                        SendMessages(GetName(oTarget) + "'s experience has been set to " + sXpAdj + "!", COLOR_YELLOW, oPC);
                        SendMessages("Your experience has been set to " + sXpAdj + "!", COLOR_YELLOW, oTarget);
                    }
                }
                NuiDestroy(oPC, nToken);
            }
            UpdateDMCreatureScreen(oPC, oTarget);
        }
    }
    //**************************************************************************
    // DM Hitpoint window events.
    else if (sWndId == "dmhpwin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        if (sEvent == "click")
        {
            string sHp, sHpAdj = JsonGetString (NuiGetBind (oPC, nToken, "hp_amount"));
            int nHp, nHpMax, nHpAdj = StringToInt (sHpAdj);
            object oPlayer;
            if (sElem == "btn_roll")
            {
                sHpAdj = JsonGetString (NuiGetBind (oPC, nToken, "box_roll"));
                sHpAdj = IntToString (RollDiceString (sHpAdj));
                NuiSetBind (oPC, nToken, "hp_amount", JsonString (sHpAdj));
            }
            else if (sElem == "btn_full_heal")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_hp")) == "true")
                {
                    SendMessages ("Party is fully healed!", COLOR_GREEN, oPC);
                    oPlayer = GetFirstFactionMember (oTarget, FALSE);
                    while (oPlayer != OBJECT_INVALID)
                    {
                        nHpMax = GetMaxHitPoints (oPlayer);
                        NWNX_Object_SetCurrentHitPoints (oPlayer, nHpMax);
                        SendMessages ("You have been fully healed!", COLOR_GREEN, oPlayer);
                        oPlayer = GetNextFactionMember (oTarget, FALSE);
                    }
                }
                else
                {
                    nHpMax = GetMaxHitPoints (oTarget);
                    NWNX_Object_SetCurrentHitPoints (oTarget, nHpMax);
                    SendMessages (GetName (oTarget) + " has been fully healed!", COLOR_GREEN, oPC);
                    SendMessages ("You have been fully healed!", COLOR_GREEN, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_cure_poison")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_hp")) == "true")
                {
                    SendMessages ("Party has been cured of poisoning!", COLOR_GREEN, oPC);
                    oPlayer = GetFirstFactionMember (oTarget, FALSE);
                    while (oPlayer != OBJECT_INVALID)
                    {
                        RemoveASpecificEffect (oPlayer, EFFECT_TYPE_POISON);
                        SendMessages ("You have been cured of poisoning!", COLOR_GREEN, oPlayer);
                        oPlayer = GetNextFactionMember (oTarget, FALSE);
                    }
                }
                else
                {
                    RemoveASpecificEffect (oTarget, EFFECT_TYPE_POISON);
                    SendMessages (GetName (oTarget) + " has been cured of poisoning!", COLOR_GREEN, oPC);
                    SendMessages ("You have been cured of poisoning!", COLOR_GREEN, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_cure_disease")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_hp")) == "true")
                {
                    SendMessages ("Party has been cured of all diseases!", COLOR_GREEN, oPC);
                    oPlayer = GetFirstFactionMember (oTarget, FALSE);
                    while (oPlayer != OBJECT_INVALID)
                    {
                        RemoveASpecificEffect (oPlayer, EFFECT_TYPE_DISEASE);
                        SendMessages ("You have been cured of disease!", COLOR_GREEN, oPlayer);
                        oPlayer = GetNextFactionMember (oTarget, FALSE);
                    }
                }
                else
                {
                    RemoveASpecificEffect (oTarget, EFFECT_TYPE_DISEASE);
                    SendMessages (GetName (oTarget) + " has been cured of disease!", COLOR_GREEN, oPC);
                    SendMessages ("You have been cured of disease!", COLOR_GREEN, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (nHpAdj == 0 && sElem != "btn_party_hp")
            {
                SendMessages ("Invalid hitpoint amount!", COLOR_RED, oPC);
            }
            else if (sElem == "btn_heal_hp")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_hp")) == "true")
                {
                    SendMessages ("Party is healed " + sHpAdj + " hitpoints each!", COLOR_GREEN, oPC);
                    oPlayer = GetFirstFactionMember (oTarget, FALSE);
                    while (oPlayer != OBJECT_INVALID)
                    {
                        nHp = GetCurrentHitPoints (oPlayer);
                        nHpMax = GetMaxHitPoints (oPlayer);
                        if (nHpAdj + nHp > nHpMax)
                        {
                            nHpAdj = nHpMax - nHp;
                            sHpAdj = IntToString (nHpAdj);
                        }
                        NWNX_Object_SetCurrentHitPoints (oPlayer, nHpAdj + nHp);
                        SendMessages ("You have gained " + sHpAdj + " hitpoints!", COLOR_GREEN, oPlayer);
                        oPlayer = GetNextFactionMember (oTarget, FALSE);
                    }
                }
                else
                {
                    nHp = GetCurrentHitPoints (oTarget);
                    nHpMax = GetMaxHitPoints (oTarget);
                    if (nHpAdj + nHp > nHpMax)
                    {
                        nHpAdj = nHpMax - nHp;
                        sHpAdj = IntToString (nHpAdj);
                    }
                    NWNX_Object_SetCurrentHitPoints (oTarget, nHpAdj + nHp);
                    SendMessages (GetName (oTarget) + " has gained " + sHpAdj + " hitpoints!", COLOR_GREEN, oPC);
                    SendMessages ("You have gained " + sHpAdj + " hitpoints!", COLOR_GREEN, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_damage_hp")
            {
                int nDmgType;
                string sDmgType, sColor;
                effect eDmg;
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "dmg_opt_selected"));
                if (nSelected == 0) { nDmgType = DAMAGE_TYPE_BLUDGEONING; sColor = COLOR_ORANGE; sDmgType = "bludgeoning"; }
                else if (nSelected == 1) { nDmgType = DAMAGE_TYPE_PIERCING; sColor = COLOR_ORANGE; sDmgType = "piercing"; }
                else if (nSelected == 2) { nDmgType = DAMAGE_TYPE_SLASHING; sColor = COLOR_ORANGE; sDmgType = "slashing"; }
                else if (nSelected == 3) { nDmgType = DAMAGE_TYPE_ACID; sColor = "040"; sDmgType = "acid"; }
                else if (nSelected == 4) { nDmgType = DAMAGE_TYPE_COLD; sColor = "599"; sDmgType = "cold"; }
                else if (nSelected == 5) { nDmgType = DAMAGE_TYPE_DIVINE; sColor = COLOR_YELLOW; sDmgType = "divine"; }
                else if (nSelected == 6) { nDmgType = DAMAGE_TYPE_ELECTRICAL; sColor = "049"; sDmgType = "electrical"; }
                else if (nSelected == 7) { nDmgType = DAMAGE_TYPE_FIRE; sColor = COLOR_RED; sDmgType = "fire"; }
                else if (nSelected == 8) { nDmgType = DAMAGE_TYPE_MAGICAL; sColor = "749"; sDmgType = "magical"; }
                else if (nSelected == 9) { nDmgType = DAMAGE_TYPE_NEGATIVE; sColor = "555"; sDmgType = "negative"; }
                else if (nSelected == 10) { nDmgType = DAMAGE_TYPE_POSITIVE; sColor = COLOR_WHITE; sDmgType = "positive"; }
                else if (nSelected == 11) { nDmgType = DAMAGE_TYPE_SONIC; sColor = "960"; sDmgType = "sonic"; }

                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_hp")) == "true")
                {
                    SendMessages ("Party takes " + sHpAdj + " hitpoints of " + sDmgType + " damage!", sColor, oPC);
                    oPC = GetFirstFactionMember (oTarget, FALSE);
                    while (oPC != OBJECT_INVALID)
                    {
                        eDmg = EffectDamage (nHpAdj, nDmgType);
                        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oPC);
                        SendMessages ("You have taken " + sHpAdj + " hitpoints of " + sDmgType + " damage!", sColor, oPC);
                        oPC = GetNextFactionMember (oTarget, FALSE);
                    }
                }
                else
                {
                    eDmg = EffectDamage (nHpAdj, nDmgType);
                    ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget);
                    SendMessages (GetName (oTarget) + " has taken " + sHpAdj + " hitpoints of " + sDmgType + " damage!", sColor, oPC);
                    SendMessages ("You have taken " + sHpAdj + " hitpoints of " + sDmgType + " damage!", sColor, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_set_hp")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_hp")) == "true")
                {
                    SendMessages ("Parties hitpoints has been set to " + sHpAdj + "!", COLOR_YELLOW, oPC);
                    oPC = GetFirstFactionMember (oTarget, FALSE);
                    while (oPC != OBJECT_INVALID)
                    {
                        nHpMax = GetMaxHitPoints (oPC);
                        if (nHpAdj > nHpMax) nHp = nHpMax;
                        else nHp = nHpAdj;
                        sHp = IntToString (nHp);
                        SetCurrentHitPoints (oPC, nHp);
                        SendMessages ("Your hitpoints has been set to " + sHp + "!", COLOR_YELLOW, oPC);
                        oPC = GetNextFactionMember (oTarget, FALSE);
                    }
                }
                else
                {
                    nHpMax = GetMaxHitPoints (oTarget);
                    if (nHpAdj > nHpMax) nHp = nHpMax;
                    else nHp = nHpAdj;
                    sHp = IntToString (nHp);
                    SetCurrentHitPoints (oTarget, nHp);
                    SendMessages (GetName (oTarget) + "'s hitpoints has been set to " + sHp + "!", COLOR_YELLOW, oPC);
                    SendMessages ("Your hitpoints has been set to " + sHp + "!", COLOR_YELLOW, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            UpdateDMCreatureScreen (oPC, oTarget);
        }
    }
    //**************************************************************************
    // DM class window events.
    else if (sWndId == "dmclasswin")
    {
        int nSelected, nClass, nLevel, nIndex = 0;
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        if (sEvent == "click")
        {
            if (sElem == "btn1_up_lvl") nIndex = 1;
            if (sElem == "btn2_up_lvl") nIndex = 2;
            if (sElem == "btn3_up_lvl") nIndex = 3;
            if (sElem == "btn4_up_lvl") nIndex = 4;
            if (sElem == "btn5_up_lvl") nIndex = 5;
            //if (sElem == "btn6_up_lvl") nIndex = 6;
            if (nIndex > 0)
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "class" + IntToString (nIndex) + "_opt_selected"));
                if (nSelected == 46)
                {
                    SendMessages ("You must select a class!", COLOR_RED, oPC);
                }
                else
                {
                    nClass = GetSelectedClassForCombo (nSelected);
                    nLevel = LevelUpHenchman (oTarget, nClass, TRUE);
                    if (nLevel > 0)
                    {
                        NuiSetBind (oPC, nToken, "class" + IntToString (nIndex) + "_opt_event", JsonBool (FALSE));
                        nLevel = GetLevelByClass (nClass, oTarget);
                        NuiSetBind (oPC, nToken, "class" + IntToString (nIndex) + "_lvl_label", JsonString (IntToString (nLevel)));
                    }
                    else SendMessages ("This creature cannot gain levels in this class!", COLOR_RED, oPC);
                }
            }
        }
        UpdateDMCreatureScreen (oPC, oTarget);
    }
    //**************************************************************************
    // DM Reputation window events.
    else if (sWndId == "dmreputationwin")
    {
        int nSelected;
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        if (sEvent == "watch")
        {
            if (sElem == "fame_opt_selected")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "fame_opt_selected"));
                SetObjectDatabaseInt  (oTarget, CHARACTER_TABLE, "fame", nSelected);
            }
            if (sElem == "infamy_opt_selected")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "infamy_opt_selected"));
                SetObjectDatabaseInt  (oTarget, CHARACTER_TABLE, "infamy", nSelected);
            }
            UpdateDMCreatureScreen (oPC, oTarget);
        }
    }
    //**************************************************************************
    // DM Gold window events.
    else if (sWndId == "dmgoldwin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        if (sEvent == "click")
        {
            string sType, sGoldAdj = JsonGetString (NuiGetBind (oPC, nToken, "gold_amount"));
            int nGP, nGoldAdj = StringToInt (sGoldAdj);
            object oPlayer;
            int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "gold_opt_selected"));
            if (sElem == "btn_5_gold")
            {
                nGoldAdj = FloatToInt (IntToFloat (GetGoldForCurrentLevel (GetCharacterLevels (oTarget))) * 0.05f);
                sGoldAdj = IntToString (nGoldAdj);
                NuiSetBind (oPC, nToken, "gold_amount", JsonString (sGoldAdj));
            }
            else if (sElem == "btn_10_gold")
            {
                nGoldAdj = FloatToInt (IntToFloat (GetGoldForCurrentLevel (GetCharacterLevels (oTarget))) * 0.10f);
                sGoldAdj = IntToString (nGoldAdj);
                NuiSetBind (oPC, nToken, "gold_amount", JsonString (sGoldAdj));
            }
            else if (sElem == "btn_wealth_gold")
            {
                nGoldAdj = GetGoldForCurrentLevel (GetCharacterLevels (oTarget));
                sGoldAdj = IntToString (nGoldAdj);
                NuiSetBind (oPC, nToken, "gold_amount", JsonString (sGoldAdj));
            }
            else if (nGoldAdj == 0)
            {
                SendMessages ("Invalid amount of Gold!", COLOR_RED, oPC);
            }
            else if (sElem == "btn_give_gold")
            {
                if (nSelected == 0) sType = "";
                else if (nSelected == 1) sType = " from a chest";
                else if (nSelected == 2) sType = " from a treasure pile";
                else if (nSelected == 3) sType = " from a merchant";
                else if (nSelected == 4) sType = " from an ally";
                else if (nSelected == 5) sType = " from a windfall";
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_gold")) == "true")
                {
                    SendMessages ("Each party member gains " + sGoldAdj + " gold" + sType + "!", COLOR_GREEN, oPC);
                    oPlayer = GetFirstFactionMember (oTarget);
                    while (oPlayer != OBJECT_INVALID)
                    {
                        nGP = GetGold (oPlayer);
                        NWNX_Creature_SetGold (oPlayer, nGP + nGoldAdj);
                        SendMessages ("You have gained " + sGoldAdj + " gold" + sType + "!", COLOR_GREEN, oPlayer);
                        oPlayer = GetNextFactionMember (oTarget);
                    }
                }
                else
                {
                    nGP = GetGold (oTarget);
                    NWNX_Creature_SetGold (oTarget, nGP + nGoldAdj);
                    SendMessages (GetName (oTarget) + " has gained " + sGoldAdj + " gold" + sType + "!", COLOR_GREEN, oPC);
                    SendMessages ("You have gained " + sGoldAdj + " gold" + sType + "!", COLOR_GREEN, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_take_gold")
            {
                if (nSelected == 0) sType = "";
                else if (nSelected == 1) sType = " while gambling";
                else if (nSelected == 2) sType = " to the barkeep";
                else if (nSelected == 3) sType = " to the merchant";
                else if (nSelected == 4) sType = " from a thief";
                else if (nSelected == 5) sType = " to taxes";
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_gold")) == "true")
                {
                    SendMessages ("Each party member loses " + sGoldAdj + " gold" + sType + "!", COLOR_RED, oPC);
                    oPC = GetFirstFactionMember (oTarget);
                    while (oPC != OBJECT_INVALID)
                    {
                        nGP = GetGold (oPC);
                        NWNX_Creature_SetGold (oPC, nGP - nGoldAdj);
                        SendMessages ("You have lost " + sGoldAdj + " gold" + sType + "!", COLOR_RED, oPC);
                        oPC = GetNextFactionMember (oTarget);
                    }
                }
                else
                {
                    nGP = GetGold (oTarget);
                    NWNX_Creature_SetGold (oTarget, nGP - nGoldAdj);
                    SendMessages (GetName (oTarget) + " has lost " + sGoldAdj + " gold" + sType + "!", COLOR_RED, oPC);
                    SendMessages ("You have lost " + sGoldAdj + " gold" + sType + "!", COLOR_RED, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            else if (sElem == "btn_set_gold")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_party_gold")) == "true")
                {
                    SendMessages ("Each party members gold has been set to " + sGoldAdj + "!", COLOR_YELLOW, oPC);
                    oPC = GetFirstFactionMember (oTarget);
                    while (oPC != OBJECT_INVALID)
                    {
                        NWNX_Creature_SetGold (oPC, nGoldAdj);
                        SendMessages ("Your gold has been set to " + sGoldAdj + "!", COLOR_YELLOW, oPC);
                        oPC = GetNextFactionMember (oTarget);
                    }
                }
                else
                {
                    NWNX_Creature_SetGold (oTarget, nGoldAdj);
                    SendMessages (GetName (oTarget) + "'s gold has been set to " + sGoldAdj + "!", COLOR_YELLOW, oPC);
                    SendMessages ("Your gold has been set to " + sGoldAdj + "!", COLOR_YELLOW, oTarget);
                }
                NuiDestroy (oPC, nToken);
            }
            UpdateDMCreatureScreen (oPC, oTarget);
        }
    }
    //**************************************************************************
    // DM alignment window events.
    else if (sWndId == "dmalignwin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        int nLC = JsonGetInt (NuiGetBind (oPC, nToken, "law_chaos_value"));
        int nGE = JsonGetInt (NuiGetBind (oPC, nToken, "good_evil_value"));
        if (sEvent == "click")
        {
            int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "gold_opt_selected"));
            if (sElem == "btn_lg") { nLC = 85; nGE = 85; }
            else if (sElem == "btn_ln") { nLC = 85; nGE = 50; }
            else if (sElem == "btn_le") { nLC = 85; nGE = 15; }
            else if (sElem == "btn_ng") { nLC = 50; nGE = 85; }
            else if (sElem == "btn_tn") { nLC = 50; nGE = 50; }
            else if (sElem == "btn_ne") { nLC = 50; nGE = 15; }
            else if (sElem == "btn_cg") { nLC = 15; nGE = 85; }
            else if (sElem == "btn_cn") { nLC = 15; nGE = 50; }
            else if (sElem == "btn_ce") { nLC = 15; nGE = 15; }
            NuiSetBind (oPC, nToken, "law_chaos_value", JsonInt (nLC));
            NuiSetBind (oPC, nToken, "good_evil_value", JsonInt (nGE));
        }
        if (!GetLocalInt (oPC, "0_No_Align_Save"))
        {
            NWNX_Creature_SetAlignmentLawChaos (oTarget, nLC);
            NWNX_Creature_SetAlignmentGoodEvil (oTarget, nGE);
            NuiSetBind (oPC, nToken, "law_chaos_desc_label", JsonString (GetLawChaosText (nLC)));
            NuiSetBind (oPC, nToken, "good_evil_desc_label", JsonString (GetGoodEvilText (nGE)));
            int nToken = NuiFindWindow (oPC, "dmcreaturewin");
            NuiSetBind (oPC, nToken, "align_label", JsonString (GetAlignText (oTarget)));
        }
    }
    //**************************************************************************
    // DM player window events.
    else if (sWndId == "dmplayerwin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        if (sEvent == "watch" && sElem == "status_opt_selected")
        {
            // Get the selection.
            int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
            int nDMStatus = GetServerDatabaseStatusByCDKey(oPC);
            int nTargetStatus = GetServerDatabaseStatusByCDKey(oTarget);
            if(nDMStatus <= nTargetStatus)
            {
                SendMessages("You cannot change a players status that is equal or higher than yours!", COLOR_RED, oPC);
                NuiDestroy(oPC, nToken);
                return;
            }
            if (nSelected < 6)
            {
                string sStatusText;
                if (nSelected == 0) sStatusText = "new player";
                else if (nSelected == 1) sStatusText = "player";
                else if (nSelected == 2) sStatusText = "privileged player";
                else if (nSelected == 3) sStatusText = "dungeon master";
                else if (nSelected == 4) sStatusText = "privileged dm";
                else if (nSelected == 5) sStatusText = "administrator";
                SetServerDatabaseInt (oTarget, PLAYER_TABLE, "status", nSelected);
                SendMessages ("You have been set to " + sStatusText + " status by " + GetName (oPC) + ".", COLOR_YELLOW, oTarget);
                SendMessages (GetName (oPC) + " has set " + GetName (oTarget) + " " + sStatusText + "!", COLOR_RED, OBJECT_INVALID, FALSE, TRUE);
            }
            if (nSelected == 6) SendMessages ("Now hit the Ban button to ban " + GetName (oTarget) + "!", COLOR_YELLOW, oPC);
        }
        if (sEvent == "click")
        {
            int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, "status_opt_selected"));
            if (sElem == "btn_boot")
            {
                if (JsonGetInt (NuiGetUserData (oPC, nToken)))
                {
                    SendMessages ("You have booted " + GetName (oTarget) + "!", COLOR_YELLOW, oPC);
                    SendMessages (GetName (oPC) + " has booted " + GetName (oTarget) + "!", COLOR_RED, OBJECT_INVALID, FALSE, TRUE);
                    BootPC (oTarget, "You have been booted by " + GetName (oPC, TRUE));
                }
                else
                {
                    NuiSetUserData (oPC, nToken, JsonInt (TRUE));
                    DelayCommand (6.0f, NuiSetUserData (oPC, nToken, JsonInt (FALSE)));
                    SendMessages ("You have 6 seconds to hit the boot button again to boot " + GetName (oTarget) + "!", COLOR_YELLOW, oPC);
                }
            }
            else if (sElem == "btn_ban")
            {
                if (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "status") != -1)
                {
                    if (nSelected == 6)
                    {
                        SetServerDatabaseInt (oTarget, PLAYER_TABLE, "status", -1);
                        SendMessages ("You have banned " + GetName (oTarget) + "!", COLOR_RED, oPC);
                        SendMessages (GetName (oPC) + " has been banned " + GetName (oTarget) + "!", COLOR_RED, OBJECT_INVALID, FALSE, TRUE);
                        SendMessages ("You have been banned by " + GetName (oPC) + "!", COLOR_RED, oTarget);
                        object oWaypoint = GetWaypointByTag (WP_LIMBO);
                        location lLocation = GetLocation (oWaypoint);
                        AssignCommand (oTarget, JumpToLocation (lLocation));
                        NuiSetBind (oPC, nToken, "btn_ban", JsonInt (TRUE));
                    }
                    else
                    {
                        SendMessages ("You must select players status banned then hit the ban button to ban a player!", COLOR_RED, oPC);
                        NuiSetBind (oPC, nToken, "btn_ban", JsonInt (FALSE));
                    }
                }
                else
                {
                    if (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "status") == -1)
                    {
                        if (nSelected > 5) nSelected = 0;
                        SetServerDatabaseInt (oTarget, PLAYER_TABLE, "status", nSelected);
                        SendMessages ("You have unbanned " + GetName (oTarget) + "!", COLOR_GREEN, oPC);
                        SendMessages (GetName (oPC) + " has been unbanned " + GetName (oTarget) + "!", COLOR_GREEN, OBJECT_INVALID, FALSE, TRUE);
                        SendMessages ("You have been unbanned by " + GetName (oPC) + "!", COLOR_GREEN, oTarget);
                        NuiSetBind (oPC, nToken, "btn_ban", JsonInt (FALSE));
                    }
                }
            }
            else if (sElem == "btn_watch")
            {
                if (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "watched"))
                {
                    SetServerDatabaseInt (oTarget, PLAYER_TABLE, "watched", FALSE);
                    SendMessages ("You have turned text watching off for " + GetName (oTarget) + "!", COLOR_GREEN, oPC);
                    SendMessages (GetName (oPC) + " has turned text watching off for " + GetName (oTarget) + "!", COLOR_GREEN, OBJECT_INVALID, FALSE, TRUE);
                    NuiSetBind (oPC, nToken, "btn_watch", JsonBool (FALSE));
                }
                else
                {
                    SetServerDatabaseInt (oTarget, PLAYER_TABLE, "watched", TRUE);
                    SendMessages ("You have turned text watching on for " + GetName (oTarget) + "!", COLOR_RED, oPC);
                    SendMessages (GetName (oPC) + " has turned text watching on for " + GetName (oTarget) + "!", COLOR_RED, OBJECT_INVALID, FALSE, TRUE);
                    NuiSetBind (oPC, nToken, "btn_watch", JsonBool (TRUE));
                }
            }
        }
    }
    // DM Object window events.
    else if (sWndId == "dmobjectwin")
    {
        int nLevel, nDC = 00, nDC1, nDC2, nDC3, nDC4, nDC5, nTreasureLevel;
        object oTarget = GetLocalObject(oPC, DM_TARGET_PLACEABLE);
        if (sEvent == "click")
        {
            if(sElem == "btn_open")
            {
                if (GetIsOpen (oTarget))
                {
                    NuiSetBind (oPC, nToken, "btn_open_label", JsonString ("Open"));
                    AssignCommand (oTarget, ActionCloseDoor (oTarget));
                }
                else
                {
                    NuiSetBind (oPC, nToken, "btn_open_label", JsonString ("Close"));
                    AssignCommand (oTarget, ActionOpenDoor (oTarget));
                }
            }
            else if (sElem == "btn_container")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_container")) == "true")
                {
                    NuiSetBind (oPC, nToken, "btn_container", JsonBool (TRUE));
                    NWNX_Object_SetHasInventory (oTarget, TRUE);
                    PopUpDMObjectGUIPanel (oPC);
                }
                else
                {
                    NuiSetBind (oPC, nToken, "btn_container", JsonBool (FALSE));
                    NWNX_Object_SetHasInventory (oTarget, FALSE);
                    PopUpDMObjectGUIPanel (oPC);
                }
            }
            else if(sElem == "btn_variables") 
            {
                SetLocalInt(oPC, DM_VAR_TARGET_TYPE, OBJECT_TYPE_PLACEABLE);
                PopupDMVariablesGUIPanel(oPC);
            }
            else if(sElem == "btn_inventory") 
            {
                SetLocalInt(oPC, DM_INV_TARGET_TYPE, OBJECT_TYPE_PLACEABLE);
                PopUpDMInventoryGUIPanel(oPC);
            }
            else if(sElem == "btn_move")
            {
                NuiDestroy(oPC, nToken);
                PopUpDMMovePlaceableGUIPanel(oPC);
            }
            else if (sElem == "btn_dc_1") // Per level
            {
                nLevel = GetLocalInt (GetArea (oTarget), "0_Area_Level");
                nDC = LOCK_BASE_DC + Random (LOCK_DIE) + 1 + nLevel;
                nDC2 = LOCK_BASE_DC + Random (LOCK_DIE) + 1 + nLevel;
                nDC3 = TRAP_DETECT_BASE_DC + Random (TRAP_DETECT_DIE) + 1 + nLevel;
                nDC4 = TRAP_DISARM_BASE_DC + Random (TRAP_DISARM_DIE) + 1 + nLevel;
                nDC5 = BASH_BASE_DC + Random (BASH_DIE) + (nLevel / 2);
                nTreasureLevel = nLevel;
            }
            else if (sElem == "btn_dc_2") // Easy
                { nDC = 20; nDC2 = 15; nDC3 = 20; nDC4 = 20; nDC5 = 5; nLevel = 1; nTreasureLevel = 1; }
            else if (sElem == "btn_dc_3") // Average
                { nDC = 25; nDC2 = 20; nDC3 = 25; nDC4 = 25; nDC5 = 10; nLevel = 4; nTreasureLevel = 4; }
            else if (sElem == "btn_dc_4") // Tough
                { nDC = 30; nDC2 = 25; nDC3 = 30; nDC4 = 30; nDC5 = 15; nLevel = 7; nTreasureLevel = 7; }
            else if (sElem == "btn_dc_5") // Challenging
                { nDC = 35; nDC2 = 30; nDC3 = 35; nDC4 = 35; nDC5 = 20; nLevel = 11; nTreasureLevel = 11; }
            else if (sElem == "btn_dc_6") // Formidable
                { nDC = 40; nDC2 = 35; nDC3 = 40; nDC4 = 40; nDC5 = 25; nLevel = 14; nTreasureLevel = 14; }
            else if (sElem == "btn_dc_7") // Heroic
                { nDC = 45; nDC2 = 40; nDC3 = 45; nDC4 = 45; nDC5 = 30; nLevel = 17; nTreasureLevel = 17; }
            else if (sElem == "btn_dc_8") // Godly
                { nDC = 55; nDC2 = 50; nDC3 = 55; nDC4 = 55; nDC5 = 40; nLevel = 20; nTreasureLevel = 20; }
            if (nDC > 0)
            {
                SetLocalInt (oPC, "0_No_Object_Save", TRUE);
                DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Object_Save"));
                NuiSetBind (oPC, nToken, "open_dc_value", JsonInt (nDC));
                SetLockUnlockDC (oTarget, nDC);
                NuiSetBind (oPC, nToken, "close_dc_value", JsonInt (nDC2));
                SetLockLockDC (oTarget, nDC2);
                NuiSetBind (oPC, nToken, "detect_dc_value", JsonInt (nDC3));
                SetTrapDetectDC (oTarget, nDC3);
                NuiSetBind (oPC, nToken, "disarm_dc_value", JsonInt (nDC4));
                SetTrapDisarmDC (oTarget, nDC4);
                NuiSetBind (oPC, nToken, "bash_dc_value", JsonInt (nDC5));
                SetLocalInt (oTarget, "0_BashDC", nDC5);
                NuiSetBind (oPC, nToken, "trap_level_value", JsonInt (nLevel));
                SetLocalInt (oTarget, "0_Trap_Level", nLevel);
                NuiSetBind (oPC, nToken, "level_value", JsonInt (nTreasureLevel));
                SetLocalInt (oTarget, "0_TreasureLevel", nTreasureLevel);
            }
        }
        if (sEvent == "watch" && !GetLocalInt (oPC, "0_No_Object_Save"))
        {
            if (sElem == "desc_value")
            {
                // Save the Description to target.
                string sDescription = JsonGetString (NuiGetBind (oPC, nToken, "desc_value"));
                SetDescription (oTarget, sDescription);
            }
            else if (sElem == "name_value")
            {
                // Saving name to target.
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "name_value"));
                SetName (oTarget, sName);
            }
            else if (sElem == "tag_value")
            {
                // Saving tag to target.
                string sTag = JsonGetString (NuiGetBind (oPC, nToken, "tag_value"));
                SetTag (oTarget, sTag);
            }
            else if (sElem == "plot_check")
            {
                int bPlot = JsonGetInt (NuiGetBind (oPC, nToken, "plot_check"));
                SetPlotFlag (oTarget, bPlot);
            }
            else if (sElem == "fort_value")
            {
                int nValue = JsonGetInt (NuiGetBind (oPC, nToken, "fort_value"));
                SetFortitudeSavingThrow (oTarget, nValue);
            }
            else if (sElem == "hard_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "hard_value")));
                SetHardness (nValue, oTarget);
            }
            else if (sElem == "reflex_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "reflex_value")));
                SetReflexSavingThrow (oTarget, nValue);
            }
            else if (sElem == "hp_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "hp_value")));
                SetCurrentHitPoints (oTarget, nValue);
            }
            else if (sElem == "will_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "will_value")));
                SetWillSavingThrow (oTarget, nValue);
            }
            else if (sElem == "level_value")
            {
                int nValue = JsonGetInt (NuiGetBind (oPC, nToken, "level_value"));
                if (nValue == 0) nValue = GetLocalInt (GetArea (oTarget), "0_Area_Level");
                SetLocalInt (oTarget, "0_TreasureLevel", nValue);
            }
            else if (sElem == "gen_treasure_check")
            {
                int bRollTreasure = JsonGetInt (NuiGetBind (oPC, nToken, "gen_treasure_check"));
                if (bRollTreasure)
                {
                    // Resets the target to allow for a new roll.
                    SetLocalInt (oTarget, "0_Used", FALSE);
                    SetEventScript (oTarget, EVENT_SCRIPT_PLACEABLE_ON_OPEN, "0e_rolltreasure");
                }
                else SetEventScript (oTarget, EVENT_SCRIPT_PLACEABLE_ON_OPEN, "");
            }
            else if (sElem == "locked_check")
            {
                int bLock = JsonGetInt (NuiGetBind (oPC, nToken, "locked_check"));
                SetLocked (oTarget, bLock);
            }
            else if (sElem == "relocked_check")
            {
                int bRelocked = JsonGetInt (NuiGetBind (oPC, nToken, "relocked_check"));
                SetLockLockable (oTarget, bRelocked);
            }
            else if (sElem == "remove_key_check")
            {
                int bRemoveKey = JsonGetInt (NuiGetBind (oPC, nToken, "remove_key_check"));
                NWNX_Object_SetAutoRemoveKey (oTarget, bRemoveKey);
            }
            else if (sElem == "key_required_check")
            {
                int bRequireKey = JsonGetInt (NuiGetBind (oPC, nToken, "key_required_check"));
                SetLockKeyRequired (oTarget, bRequireKey);
            }
            else if (sElem == "key_tag_value")
            {
                string sValue = JsonGetString (NuiGetBind (oPC, nToken, "key_tag_value"));
                SetLockKeyTag (oTarget, sValue);
            }
            else if (sElem == "open_dc_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "open_dc_value")));
                SetLockUnlockDC (oTarget, nValue);
            }
            else if (sElem == "close_dc_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "close_dc_value")));
                SetLockLockDC (oTarget, nValue);
            }
            else if (sElem == "bash_dc_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "bash_dc_value")));
                SetLocalInt (oTarget, "0_BashDC", nValue);
            }
            else if (sElem == "trap_opt_selected")
            {
                // Get the selection.
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                int nTrapType;
                if (nSelected == 0)
                {

                    // Set the no xp for disable variable to not give xp for triggering a trap.
                    SetLocalInt (oTarget, "0_NoDisableXP", TRUE);
                    SetTrapDisabled (oTarget);
                    SetTrapDetectable (oTarget, FALSE);
                    SetTrapDisarmable (oTarget, FALSE);
                    NuiSetBind (oPC, nToken, "detect_trap_check", JsonBool (FALSE));
                    NuiSetBind (oPC, nToken, "disarm_trap_check", JsonBool (FALSE));
                }
                // Randomize the type of trap.
                else if (nSelected == 1)
                {
                    nTrapType = Random (18) + 2;
                    NuiSetBind (oPC, nToken, "trap_opt_selected", JsonInt (nTrapType));
                    if (d100() > 80)
                    {
                        SetLocalInt (oTarget, "0_AOE_Trap", TRUE);
                        NuiSetBind (oPC, nToken, "aoe_check", JsonBool (TRUE));
                    }
                    else
                    {
                        SetLocalInt (oTarget, "0_AOE_Trap", FALSE);
                        NuiSetBind (oPC, nToken, "aoe_check", JsonBool (FALSE));
                    }
                }
                else nTrapType = nSelected;
                if (nTrapType > 0)
                {
                    CreateTrapOnObject (nTrapType, oTarget, STANDARD_FACTION_HOSTILE, "0e_disarmtrap", "0e_trigtrap");
                    SetTrapActive (oTarget, TRUE);
                    SetTrapDetectable (oTarget, TRUE);
                    SetTrapDisarmable (oTarget, TRUE);
                    NuiSetBind (oPC, nToken, "detect_trap_check", JsonBool (TRUE));
                    NuiSetBind (oPC, nToken, "disarm_trap_check", JsonBool (TRUE));
                }
            }
            else if (sElem == "aoe_check")
            {
                int bAOE = JsonGetInt (NuiGetBind (oPC, nToken, "aoe_check"));
                SetLocalInt (oTarget, "0_AOE_Trap", bAOE);
            }
            else if (sElem == "oneshot_check")
            {
                int bOneShot = JsonGetInt (NuiGetBind (oPC, nToken, "oneshot_check"));
                SetTrapOneShot (oTarget, bOneShot);
            }
            else if (sElem == "detect_trap_check")
            {
                int bDetectable = JsonGetInt (NuiGetBind (oPC, nToken, "detect_trap_check"));
                SetTrapDetectable (oTarget, bDetectable);
            }
            else if (sElem == "disarm_trap_check")
            {
                int bDisarmable = JsonGetInt (NuiGetBind (oPC, nToken, "disarm_trap_check"));
                SetTrapDisarmable (oTarget, bDisarmable);
            }
            else if (sElem == "detect_dc_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "detect_dc_value")));
                SetTrapDetectDC (oTarget, nValue);
            }
            else if (sElem == "disarm_dc_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "disarm_dc_value")));
                SetTrapDisarmDC (oTarget, nValue);
            }
            else if (sElem == "trap_level_value")
            {
                int nValue = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "trap_level_value")));
                if (nValue == 0) nValue = GetLocalInt (GetArea (oTarget), "0_Area_Level");
                SetLocalInt (oTarget, "0_Trap_Level", nValue);
            }
        }
    }
    //**************************************************************************
    // DM Inventory window events.
    else if (sWndId == "dminventorywin")
    {
        object oTarget;
        int nTargetType = GetLocalInt(oPC, DM_INV_TARGET_TYPE);
        if(nTargetType == OBJECT_TYPE_CREATURE) oTarget = GetLocalObject(oPC, DM_TARGET_CREATURE);
        else if(nTargetType == OBJECT_TYPE_PLACEABLE) oTarget = GetLocalObject(oPC, DM_TARGET_PLACEABLE);
        if (sEvent == "click")
        {
            int nTreasureType = JsonGetInt (NuiGetBind (oPC, nToken, "treasure_type_selected"));
            int nTreasureLevel = JsonGetInt (NuiGetBind (oPC, nToken, "treasure_level_selected")) + 1;
            if (sElem == "btn_give_treasure")
            {
                if (nTreasureType == 0) RollMagicItems (oTarget, nTreasureLevel, 1);  // Any
                else if (nTreasureType == 1) RollMagicItems (oTarget, nTreasureLevel, 1, 132);  // Weapon
                else if (nTreasureType == 2) RollMagicItems (oTarget, nTreasureLevel, 1, 134);  // Simple Weapon
                else if (nTreasureType == 3) RollMagicItems (oTarget, nTreasureLevel, 1, 135);  // Martial Weapon
                else if (nTreasureType == 4) RollMagicItems (oTarget, nTreasureLevel, 1, 136);  // Exotic Weapon
                else if (nTreasureType == 5) RollMagicItems (oTarget, nTreasureLevel, 1, 133);  // Melee Weapon
                else if (nTreasureType == 6) RollMagicItems (oTarget, nTreasureLevel, 1, 138);  // Thrown Weapon
                else if (nTreasureType == 7) RollMagicItems (oTarget, nTreasureLevel, 1, 137);  // Ranged Weapon
                else if (nTreasureType == 8) RollMagicItems (oTarget, nTreasureLevel, 1, 20);  // Arrows
                else if (nTreasureType == 9) RollMagicItems (oTarget, nTreasureLevel, 1, 25);  // Bolts
                else if (nTreasureType == 10) RollMagicItems (oTarget, nTreasureLevel, 1, 27);  // Bullets
                else if (nTreasureType == 11) RollMagicItems (oTarget, nTreasureLevel, 1, 16);  // Armor
                else if (nTreasureType == 12) RollMagicItems (oTarget, nTreasureLevel, 1, 143);  // Lgt Armor
                else if (nTreasureType == 13) RollMagicItems (oTarget, nTreasureLevel, 1, 144);  // Med Armor
                else if (nTreasureType == 14) RollMagicItems (oTarget, nTreasureLevel, 1, 145);  // Hvy Armor
                else if (nTreasureType == 15) RollMagicItems (oTarget, nTreasureLevel, 1, 140);  // Shields
                else if (nTreasureType == 16) RollMagicItems (oTarget, nTreasureLevel, 1, 146);  // Wondrous Items
                else if (nTreasureType == 17) RollMagicItems (oTarget, nTreasureLevel, 1, 19);  // Amulets
                else if (nTreasureType == 18) RollMagicItems (oTarget, nTreasureLevel, 1, 21);  // Belts
                else if (nTreasureType == 19) RollMagicItems (oTarget, nTreasureLevel, 1, 26);  // Boots
                else if (nTreasureType == 20) RollMagicItems (oTarget, nTreasureLevel, 1, 78);  // Bracers
                else if (nTreasureType == 21) RollMagicItems (oTarget, nTreasureLevel, 1, 80);  // Cloaks
                else if (nTreasureType == 22) RollMagicItems (oTarget, nTreasureLevel, 1, 142);  // Clothing
                else if (nTreasureType == 23) RollMagicItems (oTarget, nTreasureLevel, 1, 36);  // Gloves
                else if (nTreasureType == 24) RollMagicItems (oTarget, nTreasureLevel, 1, 17);  // Helmet
                else if (nTreasureType == 25) RollMagicItems (oTarget, nTreasureLevel, 1, 23);  // Head Gear
                else if (nTreasureType == 26) RollMagicItems (oTarget, nTreasureLevel, 1, 49);  // Potions
                else if (nTreasureType == 27) RollMagicItems (oTarget, nTreasureLevel, 1, 52);  // Rings
                else if (nTreasureType == 28) RollMagicItems (oTarget, nTreasureLevel, 1, 151);  // Unique Items
            }
            else if (sElem == "btn_fully_equip")
            {
                GiveMagicalEquipment (oTarget, nTreasureLevel);
                EquipItems (oTarget, FALSE);
            }
            else if (sElem == "btn_gen_loot") RollTreasure (oTarget, OBJECT_INVALID, nTreasureLevel);
            else if (sElem == "btn_id_all") IdAllInventory (oTarget);
            else if (sElem == "btn_all_drop") SetDroppableFlagAllInventory (oTarget, TRUE, TRUE);
            else if (sElem == "btn_none_drop") SetDroppableFlagAllInventory (oTarget, FALSE, TRUE);
            else if (sElem == "btn_destroy_all" && !GetIsPC (oTarget)) RemoveItems (oTarget, TRUE);
            else if (sElem == "btn_destroy_unequip" && !GetIsPC (oTarget)) RemoveItems (oTarget, FALSE);
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                object oItem;
                if(sElem == "img_left") oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget);
                else if(sElem == "img_right") oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget);
                else if(sElem == "img_special") oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget);
                else if(sElem == "img_skin") oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget);
                if(oItem != OBJECT_INVALID) AssignCommand(oPC, ActionExamine(oItem));
            }
            if(nMouseButton == NUI_MOUSE_BUTTON_LEFT)
            {
                object oItem;
                if(sElem == "img_left") oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget);
                else if(sElem == "img_right") oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget);
                else if(sElem == "img_special") oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget);
                else if(sElem == "img_skin") oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget);
                if(oItem != OBJECT_INVALID)
                {
                    AssignCommand(oTarget, ActionUnequipItem(oItem));
                    NuiDestroy(oPC, nToken);
                    DelayCommand(0.2, PopUpDMInventoryGUIPanel(oPC));
                }
            }
        }
    }
    //**************************************************************************
    // DM Move Placeable window events.
    else if(sWndId == "dmmoveplaceablewin")
    {
        object oTarget = GetLocalObject(oPC, DM_TARGET_PLACEABLE);
        if(sEvent == "click")
        {
            if(sElem == "btn_get_placeable")
            {
                NuiDestroy(oPC, nToken);
                // Get Target.
                SetLocalString (oPC, "0_Target_Mode", "0_DM_GET_PLACEABLE_TARGET");
                EnterTargetingMode (oPC, OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_TILE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if (sElem == "btn_rotate_left")
            {
                float fFacing = GetFacing (oTarget) + 20.0f;
                if (fFacing > 360.0f) fFacing = fFacing - 360.0f;
                AssignCommand (oTarget, SetFacing (fFacing));
            }
            else if (sElem == "btn_north")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.y = vPosition.y + 0.2f;
                NWNX_Object_SetPosition (oTarget, vPosition);
            }
            else if (sElem == "btn_rotate_right")
            {
                float fFacing = GetFacing (oTarget) - 20.0f;
                if (fFacing < 0.0f) fFacing = 360.0f + fFacing;
                AssignCommand (oTarget, SetFacing (fFacing));
            }
            else if (sElem == "btn_west")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.x = vPosition.x - 0.2f;
                NWNX_Object_SetPosition (oTarget, vPosition);
            }
            else if (sElem == "btn_reset")
            {
                location lReset = GetLocalLocation (oTarget, "0_Reset_Location");
                vector vPosition = GetPositionFromLocation (lReset);
                float fFacing = GetFacingFromLocation (lReset);
                NWNX_Object_SetPosition (oTarget, vPosition);
                AssignCommand (oTarget, SetFacing (fFacing));
            }
            else if (sElem == "btn_east")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.x = vPosition.x + 0.2f;
                NWNX_Object_SetPosition (oTarget, vPosition);
            }
            else if (sElem == "btn_up")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.z = vPosition.z + 0.2f;
                NWNX_Object_SetPosition (oTarget, vPosition);
            }
            else if (sElem == "btn_south")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.y = vPosition.y - 0.2f;
                NWNX_Object_SetPosition (oTarget, vPosition);
            }
            else if (sElem == "btn_down")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.z = vPosition.z - 0.2f;
                NWNX_Object_SetPosition (oTarget, vPosition);
            }
            if (sElem == "btn_destroy")
            {
                DestroyObject (oTarget);
                SetLocalObject(oPC, DM_TARGET_PLACEABLE, OBJECT_INVALID);
                SetDMTargetNUI(oPC, OBJECT_INVALID, OBJECT_TYPE_PLACEABLE);
                oTarget = OBJECT_INVALID;
                NuiSetBind (oPC, nToken, "btn_rotate_right_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_north_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_rotate_left_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_west_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_reset_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_east_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_up_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_south_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_down_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_destroy_event", JsonBool (FALSE));
            }
        }
    }
    //**************************************************************************
    // DM Item window events.
    else if (sWndId == "dmitemwin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_ITEM);
        if (sEvent == "watch")
        {
            if (sElem == "desc_value")
            {
                // Save the Description to target.
                string sDescription = JsonGetString (NuiGetBind (oPC, nToken, "desc_value"));
                SetDescription (oTarget, sDescription);
            }
            else if (sElem == "name_value")
            {
                // Saving name to target.
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "name_value"));
                SetName (oTarget, sName);
            }
            else if (sElem == "tag_value")
            {
                // Saving tag to target.
                string sTag = JsonGetString (NuiGetBind (oPC, nToken, "tag_value"));
                SetTag (oTarget, sTag);
            }
            else if (sElem == "stack_value")
            {
                // Saving stack to target.
                int nStack = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "stack_value")));
                if (nStack > 0)
                {
                    int nBaseItemType = GetBaseItemType (oTarget);
                    string sMaxStack = Get2DAString ("baseitems", "Stacking", nBaseItemType);
                    int nMaxStack = StringToInt (sMaxStack);
                    if (nStack > nMaxStack)
                    {
                        nStack = nMaxStack;
                        SendMessages ("Maximum stack size is " + sMaxStack + "!", COLOR_RED, oPC);
                        NuiSetBind (oPC, nToken, "stack_value", JsonString (sMaxStack));
                    }
                    SetItemStackSize (oTarget, nStack);
                }
                else SendMessages ("Invalid stack size!", COLOR_RED, oPC);
            }
            else if (sElem == "charges_value")
            {
                // Saving charges to target.
                int nCharges = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "charges_value")));
                if (nCharges > 0)
                {
                    if (nCharges > 250)
                    {
                        nCharges = 250;
                        SendMessages ("Maximum amount of charges per item is 250!", COLOR_RED, oPC);
                        NuiSetBind (oPC, nToken, "charges_value", JsonString ("250"));
                    }
                    SetItemCharges (oTarget, nCharges);
                }
                else SendMessages ("Invalid amount of charges!", COLOR_RED, oPC);
            }
            else if (sElem == "add_gold_value")
            {
                // Saving add gold value to target.
                int nGold = StringToInt (JsonGetString (NuiGetBind (oPC, nToken, "add_gold_value")));
                NWNX_Item_SetAddGoldPieceValue (oTarget, nGold);
                string sValue = IntToString (NWNX_Item_GetMinEquipLevel (oTarget));
                NuiSetBind (oPC, nToken, "min_lvl_label", JsonString (sValue));
            }
            else if (sElem == "plot_check")
            {
                int bPlot = JsonGetInt (NuiGetBind (oPC, nToken, "plot_check"));
                SetPlotFlag (oTarget, bPlot);
            }
            else if (sElem == "stolen_check")
            {
                int bPlot = JsonGetInt (NuiGetBind (oPC, nToken, "stolen_check"));
                SetStolenFlag (oTarget, bPlot);
            }
            else if (sElem == "identified_check")
            {
                int bPlot = JsonGetInt (NuiGetBind (oPC, nToken, "identified_check"));
                SetIdentified (oTarget, bPlot);
            }
            else if (sElem == "droppable_check")
            {
                int bPlot = JsonGetInt (NuiGetBind (oPC, nToken, "droppable_check"));
                SetDroppableFlag (oTarget, bPlot);
            }
            else if (sElem == "quality_selected")
            {
                // Get the selection.
                int nSelected = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                itemproperty ipQuality = HasProperty (oTarget, 86);
                RemoveItemProperty(oTarget, ipQuality);
                if (nSelected > 0)
                {
                    ipQuality = ItemPropertyQuality (nSelected);
                    AddItemProperty (DURATION_TYPE_PERMANENT, ipQuality, oTarget);
                }
            }
        }
        else if (sEvent == "click")
        {
            if (sElem == "btn_destroy")
            {
                DestroyObject (oTarget);
                NuiDestroy (oPC, nToken);
                // Get Target.
                SetLocalString (oPC, "0_Target_Mode", "0_DM_EXAMINE_TARGET");
                EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            else if(sElem == "btn_variables") 
            {
                SetLocalInt(oPC, DM_VAR_TARGET_TYPE, OBJECT_TYPE_ITEM);
                PopupDMVariablesGUIPanel(oPC);
            }
            else if(sElem == "btn_equip")
            {
                object oOwner = GetItemPossessor(oTarget);
                int nBaseItemType = GetBaseItemType(oTarget);
                string sSlot = Get2DAString("baseitems", "EquipableSlots", nBaseItemType);
                int nSlot = HexStringToInt(sSlot);
                if(nSlot != 0)
                {
                    if(nSlot & 1) nSlot = INVENTORY_SLOT_HEAD;
                    else if(nSlot & 2) nSlot = INVENTORY_SLOT_CHEST;
                    else if(nSlot & 4) nSlot = INVENTORY_SLOT_BOOTS;
                    else if(nSlot & 8) nSlot = INVENTORY_SLOT_ARMS;
                    else if(nSlot & 16) nSlot = INVENTORY_SLOT_RIGHTHAND;
                    else if(nSlot & 32) nSlot = INVENTORY_SLOT_LEFTHAND;
                    else if(nSlot & 64) nSlot = INVENTORY_SLOT_CLOAK;
                    else if(nSlot & 384) nSlot = INVENTORY_SLOT_RIGHTRING;
                    else if(nSlot & 512) nSlot = INVENTORY_SLOT_NECK;
                    else if(nSlot & 1024) nSlot = INVENTORY_SLOT_BELT;
                    else if(nSlot & 2048) nSlot = INVENTORY_SLOT_ARROWS;
                    else if(nSlot & 4096) nSlot = INVENTORY_SLOT_BULLETS;
                    else if(nSlot & 8192) nSlot = INVENTORY_SLOT_BOLTS;
                    else if(nSlot & 114688)
                    {
                        object oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oOwner);
                        if(oWeapon == OBJECT_INVALID) nSlot = INVENTORY_SLOT_CWEAPON_R;
                        else
                        {
                            oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oOwner);
                            if(oWeapon == OBJECT_INVALID) nSlot = INVENTORY_SLOT_CWEAPON_L;
                            else
                            {
                                oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oOwner);
                                if(oWeapon == OBJECT_INVALID) nSlot = INVENTORY_SLOT_CWEAPON_B;
                                else nSlot = INVENTORY_SLOT_CWEAPON_R;
                            }
                        }
                    }
                    else if(nSlot & 131072) nSlot = INVENTORY_SLOT_CARMOUR;
                    AssignCommand(oOwner, ActionEquipItem(oTarget, nSlot));
                    NuiDestroy (oPC, nToken);
                    // Get Target.
                    SetLocalString (oPC, "0_Target_Mode", "0_DM_EXAMINE_TARGET");
                    EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                }
            }
            if(sElem == "btn_properties")
            {
                int nActualProperty;
                itemproperty ip;
                json jProperty;
                if(nIndex > 0)
                {
                    int nListedProperty, nIPType;
                    ip = GetFirstItemProperty(oTarget);
                    while(GetIsItemPropertyValid(ip))
                    {
                        nIPType = GetItemPropertyType(ip);
                        if(nIPType != ITEM_PROPERTY_QUALITY) nListedProperty++;
                        nActualProperty++;
                        if(nIndex == nListedProperty) break;
                        ip = GetNextItemProperty(oTarget);
                    }
                    // jProperty {Item property index, Property Type, SubPropertyType,
                    //            CostTable Value, Param1 Value, Item window fX, Item window fY}
                    jProperty = JsonArrayInsert(JsonArray(), JsonInt(nActualProperty));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(GetItemPropertyType(ip)));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(GetItemPropertySubType(ip)));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(GetItemPropertyCostTableValue(ip)));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(GetItemPropertyParam1Value(ip)));
                }
                else
                {
                    // jProperty {Item property index, Property Type, SubPropertyType,
                    //            CostTable Value, Param1 Value, Item window fX, Item window fY}
                    jProperty = JsonArrayInsert(JsonArray(), JsonInt(0));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(0));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(0));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(0));
                    jProperty = JsonArrayInsert(jProperty, JsonInt(0));
                }
                json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
                float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
                float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
                if(fX == 0.0) fX = 0.0001;
                if(fY == 0.0) fY = 0.0001;
                jProperty = JsonArrayInsert(jProperty, JsonFloat(fX));
                jProperty = JsonArrayInsert(jProperty, JsonFloat(fY));
                PopUpDMItemPropertiesGUIPanel(oPC, oTarget, jProperty);
            }
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(sElem == "btn_equip")
                {
                    object oOwner = GetItemPossessor(oTarget);
                    int nBaseItemType = GetBaseItemType(oTarget);
                    string sSlot = Get2DAString("baseitems", "EquipableSlots", nBaseItemType);
                    int nSlot = HexStringToInt(sSlot);
                    if(nSlot != 0)
                    {
                        if(nSlot & 1) nSlot = INVENTORY_SLOT_HEAD;
                        else if(nSlot & 2) nSlot = INVENTORY_SLOT_CHEST;
                        else if(nSlot & 4) nSlot = INVENTORY_SLOT_BOOTS;
                        else if(nSlot & 8) nSlot = INVENTORY_SLOT_ARMS;
                        else if(nSlot & 16) nSlot = INVENTORY_SLOT_LEFTHAND;
                        else if(nSlot & 32) nSlot = INVENTORY_SLOT_LEFTHAND;
                        else if(nSlot & 64) nSlot = INVENTORY_SLOT_CLOAK;
                        else if(nSlot & 384) nSlot = INVENTORY_SLOT_LEFTRING;
                        else if(nSlot & 512) nSlot = INVENTORY_SLOT_NECK;
                        else if(nSlot & 1024) nSlot = INVENTORY_SLOT_BELT;
                        else if(nSlot & 2048) nSlot = INVENTORY_SLOT_ARROWS;
                        else if(nSlot & 4096) nSlot = INVENTORY_SLOT_BULLETS;
                        else if(nSlot & 8192) nSlot = INVENTORY_SLOT_BOLTS;
                        else if(nSlot & 114688)
                        {
                            object oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oOwner);
                            if(oWeapon == OBJECT_INVALID) nSlot = INVENTORY_SLOT_CWEAPON_R;
                            else
                            {
                                oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oOwner);
                                if(oWeapon == OBJECT_INVALID) nSlot = INVENTORY_SLOT_CWEAPON_L;
                                else
                                {
                                    oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oOwner);
                                    if(oWeapon == OBJECT_INVALID) nSlot = INVENTORY_SLOT_CWEAPON_B;
                                    else nSlot = INVENTORY_SLOT_CWEAPON_R;
                                }
                            }
                        }
                        else if(nSlot & 131072) nSlot = INVENTORY_SLOT_CARMOUR;
                        AssignCommand(oOwner, ActionEquipItem(oTarget, nSlot));
                        NuiDestroy (oPC, nToken);
                        // Get Target.
                        SetLocalString (oPC, "0_Target_Mode", "0_DM_EXAMINE_TARGET");
                        EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                    }
                }
            }
        }
    }
    //**************************************************************************
    // DM Item Property window events.
    else if(sWndId == "dmitempropertywin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_ITEM);
        json jProperty = NuiGetUserData(oPC, nToken);
        if(sEvent == "click")
        {
            if(sElem == "btn_add")
            {
                int nPropertyIndex = JsonGetInt(JsonArrayGet(jProperty, 0));
                if(nPropertyIndex > 0)
                {
                    int nListedProperty, nIPType;
                    itemproperty ip = GetFirstItemProperty(oTarget);
                    while(GetIsItemPropertyValid(ip))
                    {
                        nIPType = GetItemPropertyType(ip);
                        if(nPropertyIndex == ++nListedProperty) break;
                        ip = GetNextItemProperty(oTarget);
                    }
                    RemoveItemProperty(oTarget, ip);
                }
                AddRawItemProperty(oPC, oTarget, jProperty);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dmitemwin"));
                float fX = JsonGetFloat(JsonArrayGet(jProperty, 5));
                float fY = JsonGetFloat(JsonArrayGet(jProperty, 6));
                PopUpDMItemGUIPanel(oPC, fX, fY);
                NuiDestroy(oPC, nToken);
            }
            if(sElem == "btn_remove")
            {
                int nPropertyIndex = JsonGetInt(JsonArrayGet(jProperty, 0));
                int nListedProperty, nIPType;
                itemproperty ip = GetFirstItemProperty(oTarget);
                while(GetIsItemPropertyValid(ip))
                {
                    nIPType = GetItemPropertyType(ip);
                    if(nPropertyIndex == ++nListedProperty) break;
                    ip = GetNextItemProperty(oTarget);
                }
                RemoveItemProperty(oTarget, ip);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dmitemwin"));
                float fX = JsonGetFloat(JsonArrayGet(jProperty, 5));
                float fY = JsonGetFloat(JsonArrayGet(jProperty, 6));

                PopUpDMItemGUIPanel(oPC, fX, fY);
                NuiDestroy(oPC, nToken);
            }
        }
        else if(sEvent == "watch" && !GetLocalInt (oPC, "0_No_Win_Save"))
        {
            if(GetStringLeft(sElem, 3) == "ip_")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                if(sElem == "ip_selected")
                {
                    jProperty = JsonArraySet(jProperty, 1, JsonInt(nSelected)); // Property Type
                    jProperty = JsonArraySet(jProperty, 2, JsonInt(0)); // Property SubType
                    jProperty = JsonArraySet(jProperty, 3, JsonInt(0)); // Property CostTableValue
                    jProperty = JsonArraySet(jProperty, 4, JsonInt(0)); // Property Param1Value
                }
                if(sElem == "ip_sub_selected")
                {
                    jProperty = JsonArraySet(jProperty, 2, JsonInt(nSelected));
                }
                if(sElem == "ip_bonus_selected")
                {
                    jProperty = JsonArraySet(jProperty, 3, JsonInt(nSelected));
                    jProperty = JsonArraySet(jProperty, 4, JsonInt(0));
                }
                if(sElem == "ip_param_selected")
                {
                    jProperty = JsonArraySet(jProperty, 4, JsonInt(nSelected));
                }
                PopUpDMItemPropertiesGUIPanel(oPC, oTarget, jProperty);
            }
        }
    }
    //**************************************************************************
    // DM quest item window events.
    else if (sWndId == "dmquestswin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
        if(!GetIsCharacter(oTarget)) 
        {
            SendMessages(GetName(oTarget) + " is not a character! Only characters can have quests information changed.");
            return;
        }
        if (sEvent == "watch" && !GetLocalInt (oPC, "0_No_Win_Save"))
        {
            string sVar = "";
            if(sElem == "cmb_plot_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                SetLocalString(oTarget, "0_Q_PLOT", IntToString(nSelected + 1));
                object oOwner = GetItemPossessor(oTarget);
                if(GetIsCharacter(oOwner))
                {
                    string sQuestID = GetLocalString(oTarget, "0_Q_ID");
                    SetServerDatabaseString(oOwner, QUEST_TABLE, "plot", IntToString(nSelected + 1), sQuestID);
                }
            }
            else if (sElem == "desc_value")
            {
                // Save the Description to target.
                string sDescription = JsonGetString (NuiGetBind (oPC, nToken, "desc_value"));
                SetDescription(oTarget, sDescription);
                string sQuestID = GetLocalString(oTarget, "0_Q_ID");
                object oOwner = GetItemPossessor(oTarget);
                if(GetIsCharacter(oOwner))
                {
                    object oOwner = GetItemPossessor(oTarget);
                    SetServerDatabaseString(oOwner, QUEST_TABLE, "description", sDescription, sQuestID);
                }
            }
            else if (sElem == "quest_name_value")
            {
                // Saving name to target.
                string sName = JsonGetString(NuiGetBind(oPC, nToken, "quest_name_value"));
                SetName(oTarget, sName);
            }
            else if (sElem == "quest_data_value") sVar = "QUEST";
            else if (sElem == "start_area_value") sVar = "START";
            else if (sElem == "start_npc_value") sVar = "GIVER";
            else if (sElem == "quest_area_value") sVar = "AREA";
            else if (sElem == "quest_npc_value") sVar = "NPC";
            else if (sElem == "quest_villain_value") sVar = "VILLAIN";
            else if (sElem == "quest_creatures_value") sVar = "CREATURES";
            else if (sElem == "finish_enemies_value") sVar = "ENEMIES";
            else if (sElem == "quest_allies_value") sVar = "ALLIES";
            else if (sElem == "finish_allies_value") sVar = "FOLLOWERS";
            else if (sElem == "give_item_value") sVar = "GIVEITEM";
            else if (sElem == "quest_item_value") sVar = "ITEM";
            else if (sElem == "quest_placeable_value") sVar = "PLACEABLE";
            else if (sElem == "finish_placeable_value") sVar = "FPLACEABLE";
            else if (sElem == "finish_area_value") sVar = "FINISH";
            else if (sElem == "finish_npc_value") sVar = "FINISHER";
            else if (sElem == "rewards_value") sVar = "REWARDS";
            else if (sElem == "states_value") sVar = "STATE";
            if (sVar != "")
            {
                // Save quest variable to the item.
                string sValue = JsonGetString(NuiGetBind (oPC, nToken, sElem));
                SetLocalString (oTarget, "0_Q_" + sVar, sValue);
                object oOwner = GetItemPossessor(oTarget);
                if(GetIsCharacter(oOwner))
                {
                    string sQuestID = GetLocalString(oTarget, "0_Q_ID");
                    SetServerDatabaseString(oOwner, QUEST_TABLE, GetStringLowerCase(sVar), sValue, sQuestID);
                }
            }
        }
        else if(sEvent == "click")
        {
            if(sElem == "btn_quest_info")
            {
                PopUpInformationPanel(oPC, "Quest Information", GetStringByStrRef(16777223), 600.0, 500.0);
            }
            else if(sElem == "btn_start_area")
            {
                object oArea = GetArea(oPC);
                string sArray = "-" + GetName(oArea) + "-" + GetTag(oArea) + "--";
                NuiSetBind(oPC, nToken, "start_area_value", JsonString(sArray));
            }
            else if(sElem == "btn_start_npc")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_START_NPC");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_give_item")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_GIVE_ITEM");
                EnterTargetingMode(oPC, OBJECT_TYPE_ITEM, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_quest_area")
            {
                object oArea = GetArea(oPC);
                string sArray = "-" + GetName(oArea) + "-" + GetTag(oArea) + "--";
                NuiSetBind(oPC, nToken, "quest_area_value", JsonString(sArray));
            }
            else if(sElem == "btn_quest_npc")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_QUEST_NPC");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_quest_villain")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_QUEST_VILLAIN");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_quest_creatures")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_QUEST_CREATURES");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_quest_allies")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_QUEST_ALLIES");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_quest_placeable")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_QUEST_PLACEABLE");
                EnterTargetingMode(oPC, OBJECT_TYPE_PLACEABLE, MOUSECURSOR_ACTION);
            }
           else if(sElem == "btn_quest_item")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_QUEST_ITEM");
                EnterTargetingMode(oPC, OBJECT_TYPE_ITEM, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_finish_area")
            {
                object oArea = GetArea(oPC);
                string sArray = "-" + GetName(oArea) + "-" + GetTag(oArea) + "--";
                NuiSetBind(oPC, nToken, "finish_area_value", JsonString(sArray));
            }
            else if(sElem == "btn_finish_npc")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_FINISH_NPC");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_finish_enemies")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_FINISH_ENEMIES");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_finish_allies")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_FINISH_ALLIES");
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_finish_placeable")
            {
                SetLocalString(oPC, "0_Target_Mode", "0_QUEST_FINISH_PLACEABLE");
                EnterTargetingMode(oPC, OBJECT_TYPE_PLACEABLE, MOUSECURSOR_ACTION);
            }
            else if(sElem == "btn_delete")
            {
                object oOwner = GetItemPossessor(oTarget);
                if(GetIsCharacter(oOwner))
                {
                    RemoveQuestPaperFromDatabase(oOwner, oTarget);
                    // If there is a quest NPC then remove them for the player.
                    string sNPC = GetLocalString(oTarget, "0_Q_NPC");
                    if(sNPC != "")
                    {
                        int nIndex = 1;
                        string sQuestID = GetStringArray(sNPC, 2, "-");
                        object oNPC = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                        while(oNPC != OBJECT_INVALID)
                        {
                            if(sQuestID == GetLocalString(oNPC, "0_QUEST_ID"))
                            {
                                RemoveQuestNPC(oPC, oNPC);
                                SetIsDestroyable(TRUE, FALSE, FALSE, oNPC);
                                DestroyObject(oNPC);
                                break;
                            }
                            oNPC = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
                        }
                    }
                }
                NuiDestroy(oPC, nToken);
                DestroyObject(oTarget);
            }
        }
    }
    //**************************************************************************
    // DM Variable window events.
    else if (sWndId == "dmvariableswin")
    {
        object oTarget;
        int nTargetType = GetLocalInt(oPC, DM_VAR_TARGET_TYPE);
        if(nTargetType == OBJECT_TYPE_CREATURE) oTarget = GetLocalObject(oPC, DM_TARGET_CREATURE);
        else if(nTargetType == OBJECT_TYPE_ITEM) oTarget = GetLocalObject(oPC, DM_TARGET_ITEM);
        else if(nTargetType == OBJECT_TYPE_PLACEABLE) oTarget = GetLocalObject(oPC, DM_TARGET_PLACEABLE);
        else if(nTargetType == OBJECT_TYPE_TRIGGER) oTarget = GetLocalObject(oPC, DM_TARGET_TRIGGER);
        else if(nTargetType == OBJECT_TYPE_TILE) oTarget = GetLocalObject(oPC, DM_TARGET_AREA);
        if (sEvent == "watch")
        {
            if (sElem == DMV_FILTER_ID)
            {
                string sFilter = JsonGetString (NuiGetBind (oPC, nToken, DMV_FILTER_ID));
                ApplyDMVFilter (oPC, nToken, sFilter);
                if(sFilter == "") NuiSetBind (oPC, nToken, DMV_FILTER_CLEAR + "_event", JsonBool (FALSE));
                else NuiSetBind (oPC, nToken, DMV_FILTER_CLEAR + "_event", JsonBool (TRUE));
            }
        }
        else if (sEvent == "click")
        {
            string sName = JsonGetString (NuiGetBind (oPC, nToken, "name_value"));
            string sVariable = JsonGetString (NuiGetBind (oPC, nToken, "value_value"));
            if (sElem == DMV_FILTER_CLEAR)
            {
                NuiSetBind (oPC, nToken, DMV_FILTER_ID, JsonString (""));
                NuiSetBind (oPC, nToken, DMV_FILTER_CLEAR + "_event", JsonBool (FALSE));
                ApplyDMVFilter (oPC, nToken, "");
            }
            else if (sElem == "btn_int")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, "btn_delete")))
                    DeleteLocalInt (oTarget, sName);
                else SetLocalInt (oTarget, sName, StringToInt (sVariable));
            }
            else if (sElem == "btn_float")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, "btn_delete")))
                    DeleteLocalFloat (oTarget, sName);
                else SetLocalFloat (oTarget, sName, StringToFloat (sVariable));
            }
            else if (sElem == "btn_string")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, "btn_delete")))
                    DeleteLocalString (oTarget, sName);
                else SetLocalString (oTarget, sName, sVariable);
            }
            else if (sElem == "btn_object")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, "btn_delete")))
                    DeleteLocalObject (oTarget, sName);
                else
                {
                    SetLocalString (oPC, "0_Target_Mode", "0_DM_SET_VAR_OBJ");
                    SetLocalString (oPC, "0_Obj_Var_Name", sName);
                    SetLocalObject (oPC, "0_Obj_Org_Target", oTarget);
                    EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                }
            }
            if (sElem != "btn_delete" && sElem != DMV_FILTER_CLEAR)
            {
                string sRefresh = GetVariableText (oTarget);
                NuiSetBind (oPC, nToken, DMV_BIND_ITEMS_FULL, JsonString (sRefresh));
                ApplyDMVFilter (oPC, nToken, JsonGetString (NuiGetBind (oPC, nToken, DMV_FILTER_ID)));
            }
        }
    }
    //**************************************************************************
    // DM Area window events.
    else if (sWndId == "dmareawin")
    {
        int nLightType = 0;
        object oTarget = GetLocalObject(oPC, DM_TARGET_AREA);
        if (sEvent == "watch")
        {
            if (sElem == "name_value")
            {
                // Saving name to target.
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "name_value"));
                SetName (oTarget, sName);
            }
            else if (sElem == "g_treasure_check")
            {
                int bGTreasure = !JsonGetInt (NuiGetBind (oPC, nToken, "g_treasure_check"));
                SetLocalInt (oTarget, "0_LootOFF", bGTreasure);
            }
            else if (sElem == "give_xp_check")
            {
                int bGiveXP = !JsonGetInt (NuiGetBind (oPC, nToken, "give_xp_check"));
                SetLocalInt (oTarget, "0_XPOFF", bGiveXP);
            }
            else if (sElem == "populate_empty_check")
            {
                int bPopulate = !JsonGetInt (NuiGetBind (oPC, nToken, "populate_empty_check"));
                SetLocalInt (oTarget, "0_PopulateOFF", bPopulate);
            }
            else if (sElem == "clear_empty_check")
            {
                int bClear = !JsonGetInt (NuiGetBind (oPC, nToken, "clear_empty_check"));
                SetLocalInt (oTarget, "0_CleanOFF", bClear);
            }
            else if (sElem == "allow_resting_check")
            {
                int bRest = !JsonGetInt (NuiGetBind (oPC, nToken, "allow_resting_check"));
                if (bRest)
                {
                    object oWaypoint = GetNearestObjectByTag ("ip_no_rest", GetFirstObjectInArea (oTarget));
                    DestroyObject (oWaypoint);
                }
                else CreateObject (OBJECT_TYPE_WAYPOINT, "ip_no_rest", GetLocation (GetFirstObjectInArea (oTarget)));
            }
            else if (sElem == "animations_check")
            {
                int bAnimation = !JsonGetInt (NuiGetBind (oPC, nToken, "animations_check"));

                SetLocalInt (oTarget, "0_AnimationsOFF", bAnimation);
            }
            else if (sElem == "lock_level_check")
            {
                int bLock = JsonGetInt (NuiGetBind (oPC, nToken, "lock_level_check"));
                SetLocalInt (oTarget, "0_DM_Level_Set", bLock);
            }
            else if (sElem == "area_level_selected")
            {
                // Get the selection.
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem)) + 1;
                SetLocalInt (oTarget, "0_Area_Level", nSelected);
            }
            else if (sElem == "encounter_selected")
            {
                // Get the selection.
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                object oWaypoint = GetNearestObjectByTag ("ip_area_level", GetFirstObjectInArea (oTarget));
                // If the waypoint doesn't exist then create it.
                if (!GetIsObjectValid (oWaypoint))
                {
                    location lLocation = GetLocation (GetFirstObjectInArea (oTarget));
                    oWaypoint = CreateObject (OBJECT_TYPE_WAYPOINT, "ip_area_level", lLocation);
                }
                string sText;
                if (nSelected == 0) sText = "";
                else sText = Get2DAString ("quest_list", "Encounter", nSelected);
                SetLocalString (oWaypoint, "0_Encounter_2da", sText);
            }
            else if (sElem == "enc_chance_selected")
            {
                // Get the selection.
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                object oWaypoint = GetNearestObjectByTag ("ip_randomencounter", GetFirstObjectInArea (oTarget));
                // If the waypoint doesn't exist then create it.
                if (!GetIsObjectValid (oWaypoint))
                {
                    location lLocation = GetLocation (GetFirstObjectInArea (oTarget));
                    oWaypoint = CreateObject (OBJECT_TYPE_WAYPOINT, "ip_randomencounter", lLocation);
                    SetLocalInt (oWaypoint, "0_Enc_Chance", nSelected * 5);
                }
            }
        }
        else if (sEvent == "click")
        {
            if (sElem == "btn_variables") 
            {
                SetLocalInt(oPC, DM_VAR_TARGET_TYPE, OBJECT_TYPE_TILE);
                PopupDMVariablesGUIPanel(oPC);
            }
            else if (sElem == "btn_populate")
            {
                int nLevel = JsonGetInt (NuiGetBind (oPC, nToken, "area_level_selected")) +1;
                PopulateArea (oTarget, OBJECT_INVALID);
                SendMessages ("Populating " + GetName (oTarget) + " at a level " + IntToString (nLevel) + " difficulty.", COLOR_GREEN, oPC);
            }
            else if (sElem == "btn_clear")
            {
                // Check for clear area object.
                object oClearArea = GetObjectInAreaByTag (oTarget, "0_clear_area", 1, OBJECT_TYPE_PLACEABLE, TRUE);
                if (oClearArea != OBJECT_INVALID)
                {
                    SetLocalInt (GetModule (), "0_Clear_Objects", GetLocalInt (GetModule (), "0_Clear_Objects") - 1);
                    //Debug ("0e_window", "2433", "Area: " + GetName (oTarget) + " (" + GetTag (oTarget) +
                    //       ") Destroy " + GetName (oClearArea) + "[" + IntToString (GetLocalInt (GetModule (), "0_Clear_Objects")) +
                    //       "] due to " + GetName (oPC) + " force clearing the area.");
                    DestroyObject (oClearArea);
                }
                ClearArea (oTarget, TRUE);
                SendMessages ("Clearing " + GetName (oTarget) + ", this could take a few seconds.", COLOR_RED, oPC);
            }
            else if (sElem == "btn_wild_magic")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_wild_magic")) == "true")
                {
                    NuiSetBind (oPC, nToken, "btn_wild_magic", JsonBool (TRUE));
                    SetLocalInt (oTarget, "0_Spell_State", 2);
                    NuiSetBind (oPC, nToken, "btn_dead_magic", JsonBool (FALSE));
                }
                else
                {
                    NuiSetBind (oPC, nToken, "btn_wild_magic", JsonBool (FALSE));
                    SetLocalInt (oTarget, "0_Spell_State", 0);
                }
            }
            else if (sElem == "btn_dead_magic")
            {
                if (JsonDump (NuiGetBind (oPC, nToken, "btn_dead_magic")) == "true")
                {
                    NuiSetBind (oPC, nToken, "btn_dead_magic", JsonBool (TRUE));
                    SetLocalInt (oTarget, "0_Spell_State", 1);
                    NuiSetBind (oPC, nToken, "btn_wild_magic", JsonBool (FALSE));
                }
                else
                {
                    NuiSetBind (oPC, nToken, "btn_dead_magic", JsonBool (FALSE));
                    SetLocalInt (oTarget, "0_Spell_State", 0);
                }
            }
            else if (sElem == "btn_colors") PopUpDMColorsGUIPanel (oPC);
            else if (sElem == "btn_sounds") PopUpDMSoundsGUIPanel (oPC);
        }
    }
    //**************************************************************************
    // DM Colors window events.
    else if (sWndId == "dmcolorswin")
    {
        int nLightType = 0;
        object oTarget = GetLocalObject (oPC, DM_TARGET_AREA);
        if (sEvent == "watch" && !GetLocalInt (oPC, "0_No_Color_Save"))
        {
            if (sElem == "sun_ambient_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                NWNX_Area_SetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_SUN_AMBIENT, ComboNumberToFogColor (nSelected));
                SendMessages ("You will have to reload the area to see the effect change.", COLOR_YELLOW, oPC);
            }
            else if (sElem == "sun_diffuse_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                NWNX_Area_SetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_SUN_DIFFUSE, ComboNumberToFogColor (nSelected));
                SendMessages ("You will have to reload the area to see the effect change.", COLOR_YELLOW, oPC);
            }
            else if (sElem == "moon_ambient_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                NWNX_Area_SetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_MOON_AMBIENT, ComboNumberToFogColor (nSelected));
                SendMessages ("You will have to reload the area to see the effect change.", COLOR_YELLOW, oPC);
            }
            else if (sElem == "moon_diffuse_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                NWNX_Area_SetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_MOON_DIFFUSE, ComboNumberToFogColor (nSelected));
                SendMessages ("You will have to reload the area to see the effect change.", COLOR_YELLOW, oPC);
            }
            else if (sElem == "sun_fog_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetFogColor (FOG_TYPE_SUN, ComboNumberToFogColor (nSelected), oTarget);
            }
            else if (sElem == "moon_fog_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetFogColor (FOG_TYPE_MOON, ComboNumberToFogColor (nSelected), oTarget);
            }
            else if (sElem == "lights_m1_selected") nLightType = 1;
            else if (sElem == "lights_m2_selected") nLightType = 2;
            else if (sElem == "lights_s1_selected") nLightType = 3;
            else if (sElem == "lights_s2_selected") nLightType = 4;
            if (nLightType > 0)
            {
                // Get the selection.
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetAreaMainLightColor (oTarget, nSelected, nLightType);
            }
        }
    }
    //**************************************************************************
    // DM Sounds window events.
    else if (sWndId == "dmsoundswin")
    {
        object oTarget = GetLocalObject (oPC, DM_TARGET_AREA);
        if (sEvent == "watch")
        {
            if (sElem == "day_sounds_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                AmbientSoundChangeDay (oTarget, nSelected);
            }
            else if (sElem == "night_sounds_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                AmbientSoundChangeNight (oTarget, nSelected);
            }
            else if (sElem == "day_volume_value")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                AmbientSoundSetDayVolume (oTarget, nSelected);
            }
            else if (sElem == "night_volume_value")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                AmbientSoundSetNightVolume (oTarget, nSelected);
            }
        }
        else if (sEvent == "click")
        {
            if (sElem == "btn_play_sound") AmbientSoundPlay (oTarget);
            else if (sElem == "btn_stop_sound") AmbientSoundStop (oTarget);
        }
    }
    //**************************************************************************
    // DM NPC window events, lets not change it when the system is changing things.
    else if (sWndId == "dmnpcwin" && !GetLocalInt (oPC, "0_No_NPCWin_Save"))
    {
        object oLocationTarget = GetLocalObject (oPC, DM_TARGET_LOCATION);
        if (sEvent == "watch")
        {
            json jNPC = GetLocalJson (oPC, "0_JNPC");
            if (sElem == "desc_value")
            {
                string sDesc = JsonGetString (NuiGetBind (oPC, nToken, "desc_value"));
                jNPC = JsonObjectSet (jNPC, "description", JsonString (sDesc));
            }
            else if (sElem == "npc_port_name")
            {
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "npc_name"));
                jNPC = JsonObjectSet (jNPC, "name", JsonString (sName));
                jNPC = JsonObjectSet (jNPC, "portrait_id", JsonInt (65535));
                NuiSetBind (oPC, nToken, "npc_port_id_label", JsonString ("Custom Portrait"));
            }
            else if (sElem == "npc_name")
            {
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "npc_name"));
                jNPC = JsonObjectSet (jNPC, "name", JsonString (sName));
            }
            else if (sElem == "npc_deity")
            {
                string sName = JsonGetString (NuiGetBind (oPC, nToken, "npc_deity"));
                jNPC = JsonObjectSet (jNPC, "deity", JsonString (sName));
            }
            else if (sElem == "npc_gender_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "gender", JsonInt (nSelected));
            }
            else if (sElem == "npc_race_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                nSelected = GetSelectedNPCRaceForCombo (nSelected);
                jNPC = JsonObjectSet (jNPC, "race", JsonInt (nSelected));
            }
            else if (sElem == "npc_class1_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                nSelected = GetSelectedNPCClassForCombo (nSelected);
                jNPC = JsonObjectSet (jNPC, "class1", JsonInt (nSelected));
                if (nSelected != 13)
                {
                    NuiSetBind (oPC, nToken, "npc_class2_event", JsonBool (TRUE));
                    NuiSetBind (oPC, nToken, "npc_level2_event", JsonBool (TRUE));
                }
                else
                {
                    NuiSetBind (oPC, nToken, "npc_class2_event", JsonBool (FALSE));
                    NuiSetBind (oPC, nToken, "npc_level2_event", JsonBool (FALSE));
                }
            }
            else if (sElem == "npc_class2_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                nSelected = GetSelectedNPCRaceForCombo (nSelected);
                jNPC = JsonObjectSet (jNPC, "class2", JsonInt (nSelected));
                if (nSelected < 29)
                {
                    NuiSetBind (oPC, nToken, "npc_class3_event", JsonBool (TRUE));
                    NuiSetBind (oPC, nToken, "npc_level3_event", JsonBool (TRUE));
                }
                else
                {
                    NuiSetBind (oPC, nToken, "npc_class3_event", JsonBool (FALSE));
                    NuiSetBind (oPC, nToken, "npc_level3_event", JsonBool (FALSE));
                }
            }
            else if (sElem == "npc_class3_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                nSelected = GetSelectedNPCRaceForCombo (nSelected);
                jNPC = JsonObjectSet (jNPC, "class3", JsonInt (nSelected));
            }
            else if (sElem == "npc_level1_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "level1", JsonInt (nSelected));
            }
            else if (sElem == "npc_level2_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "level2", JsonInt (nSelected));
            }
            else if (sElem == "npc_level3_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "level3", JsonInt (nSelected));
            }
            else if (sElem == "npc_align1_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "alignlc", JsonInt (nSelected));
            }
            else if (sElem == "npc_align2_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "alignge", JsonInt (nSelected));
            }
            else if (sElem == "npc_faction_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                jNPC = JsonObjectSet (jNPC, "faction", JsonInt (nSelected));
            }
            SetLocalJson (oPC, "0_JNPC", jNPC);
        }
        else if (sEvent == "click")
        {
            int nID, nAdj = 0, nChange = 0;
            string sAbility = "";
            json jNPC = GetLocalJson (oPC, "0_JNPC");
            if (sElem == "btn_clear")
            {
                SetJsonNPC (oPC);
                UpdateNPCWindow (oPC, nToken);
            }
            else if (sElem == "btn_random")
            {
                json jNPC = GetLocalJson (oPC, "0_JNPC");
                jNPC = RanomizeJsonNPC (jNPC);
                SetLocalJson (oPC, "0_JNPC", jNPC);
                UpdateNPCWindow (oPC, nToken);
            }
            else if (sElem == "btn_create") CreateJsonNPC (oPC);
            // Adjust ability scores *******************************************
            else if (sElem == "btn_up_str") { sAbility = "str"; nAdj = 1;}
            else if (sElem == "btn_down_str") { sAbility = "str"; nAdj = -1;}
            else if (sElem == "btn_up_dex") { sAbility = "dex"; nAdj = 1;}
            else if (sElem == "btn_down_dex") { sAbility = "dex"; nAdj = -1;}
            else if (sElem == "btn_up_con") { sAbility = "con"; nAdj = 1;}
            else if (sElem == "btn_down_con") { sAbility = "con"; nAdj = -1;}
            else if (sElem == "btn_up_int") { sAbility = "int"; nAdj = 1;}
            else if (sElem == "btn_down_int") { sAbility = "int"; nAdj = -1;}
            else if (sElem == "btn_up_wis") { sAbility = "wis"; nAdj = 1;}
            else if (sElem == "btn_down_wis") { sAbility = "wis"; nAdj = -1;}
            else if (sElem == "btn_up_cha") { sAbility = "cha"; nAdj = 1;}
            else if (sElem == "btn_down_cha") { sAbility = "cha"; nAdj = -1;}
            // Adjust portrait id **********************************************
            else if (sElem == "btn_portrait_next")
            {
                nID = JsonGetInt (JsonObjectGet (jNPC, "portrait_id")) + 1;
                nChange = 1;
            }
            else if (sElem == "btn_portrait_prev")
            {
                nID = JsonGetInt (JsonObjectGet (jNPC, "portrait_id")) - 1;
                nChange = -1;
            }
            // Change abilitiy scores if adjusted.
            if (sAbility != "")
            {
                int nScore = JsonGetInt (JsonObjectGet (jNPC, sAbility)) + nAdj;
                if (nScore > 40) nScore = 2;
                else if (nScore < 2) nScore = 40;
                jNPC = JsonObjectSet (jNPC, sAbility, JsonInt (nScore));
                SetLocalJson (oPC, "0_JNPC", jNPC);
                int nMod;
                if (nScore < 10) nMod = (nScore - 11) / 2;
                else nMod = (nScore - 10) / 2;
                if (nScore == 2)
                {
                    NuiSetBind (oPC, nToken, sAbility + "_value_label", JsonString ("-"));
                    NuiSetBind (oPC, nToken, sAbility + "_mod_label", JsonString ("-"));
                }
                else
                {
                    NuiSetBind (oPC, nToken, sAbility + "_value_label", JsonString (IntToString (nScore)));
                    NuiSetBind (oPC, nToken, sAbility + "_mod_label", JsonString (IntToString (nMod)));
                }
            }
            // Changes the npc portrait id if adjusted.
            if (nChange != 0)
            {
                int nPRace, nPGender;
                if (nID > 1317) nID = 1;
                if (nID < 1) nID = 1317;
                int nGender = JsonGetInt (JsonObjectGet (jNPC, "gender"));
                if (nGender == 2) return;
                int nRace = GetRaceType(OBJECT_INVALID, TRUE, JsonGetInt (JsonObjectGet (jNPC, "race")));
                if (nRace == -1) return;
                string sPRace = Get2DAString ("portraits", "Race", nID);
                if (sPRace != "") nPRace = StringToInt (sPRace);
                else nPRace = -1;
                string sPGender = Get2DAString ("portraits", "Sex", nID);
                if (sPGender != "") nPGender = StringToInt (sPGender);
                else nPGender = -1;
                while ((nRace != nPRace && (nRace != 4 || (nPRace != 1 && nPRace != 6))) || nGender != nPGender)
                {
                    nID += nChange;
                    if (nID > 1317) nID = 1;
                    if (nID < 1) nID = 1317;
                    sPRace = Get2DAString ("portraits", "Race", nID);
                    if (sPRace != "") nPRace = StringToInt (sPRace);
                    else nPRace = -1;
                    sPGender = Get2DAString ("portraits", "Sex", nID);
                    if (sPGender != "") nPGender = StringToInt (sPGender);
                    else nPGender = -1;
                }
                string sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID);
                jNPC = JsonObjectSet (jNPC, "portrait_id", JsonInt (nID));
                SetLocalJson (oPC, "0_JNPC", jNPC);
                NuiSetBind (oPC, nToken, "npc_port_resref", JsonString (sResRef));
                NuiSetBind (oPC, nToken, "npc_port_id_label", JsonString (IntToString (nID)));
                NuiSetBind (oPC, nToken, "npc_port_image", JsonString (sResRef + "l"));
            }
        }
    }
    //**************************************************************************
    // DM server window events.
    else if (sWndId == "dmserverwin")
    {
        int nSelected;
        float fValue = 0.0;
        object oModule = GetModule ();
        object oLocationTarget = GetLocalObject (oPC, DM_TARGET_LOCATION);
        if (sEvent == "watch")
        {
            if (sElem == "x_value")
            {
                fValue = StringToFloat (JsonGetString (NuiGetBind (oPC, nToken, sElem)));
                SetServerDatabaseFloat (oModule, SERVER_TABLE, "windx", fValue);
                SetServerWind (fValue, -1.0, -1.0, -1.0, -1.0, -1.0);
            }
            else if (sElem == "y_value")
            {
                fValue = StringToFloat (JsonGetString (NuiGetBind (oPC, nToken, sElem)));
                SetServerDatabaseFloat (oModule, SERVER_TABLE, "windy", fValue);
                SetServerWind (-1.0, fValue, -1.0, -1.0, -1.0, -1.0);
            }
            else if (sElem == "z_value")
            {
                fValue = StringToFloat (JsonGetString (NuiGetBind (oPC, nToken, sElem)));
                SetServerDatabaseFloat (oModule, SERVER_TABLE, "windz", fValue);
                SetServerWind (-1.0, -1.0, fValue, -1.0, -1.0, -1.0);
            }
            else if (sElem == "magnitude_value")
            {
                fValue = StringToFloat (JsonGetString (NuiGetBind (oPC, nToken, sElem)));
                SetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude", fValue);
                SetServerWind (-1.0, -1.0, -1.0, fValue, -1.0, -1.0);
            }
            else if (sElem == "yaw_value")
            {
                fValue = StringToFloat (JsonGetString (NuiGetBind (oPC, nToken, sElem)));
                SetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw", fValue);
                SetServerWind (-1.0, -1.0, -1.0, -1.0, fValue, -1.0);
            }
            else if (sElem == "pitch_value")
            {
                fValue = StringToFloat (JsonGetString (NuiGetBind (oPC, nToken, sElem)));
                SetServerWind (-1.0, -1.0, -1.0, -1.0, -1.0, fValue);
                SetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch", fValue);
            }
            else if (sElem == "start_char_lvl_selected")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetServerDatabaseInt (oModule, SERVER_TABLE, "startlevel", nSelected);
            }
            else if (sElem == "change_time_selected")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                if (nSelected == 1) SetTime (6, 0, 0, 0); // Dawn
                else if (nSelected == 2) SetTime (12, 0, 0, 0); // Midday
                else if (nSelected == 3) SetTime (18, 0, 0, 0); // Dusk
                else if (nSelected == 4) SetTime (0, 0, 0, 0); // Night
                NuiSetBind (oPC, nToken, sElem, JsonInt (0));
            }
            else if (sElem == "temperature_selected")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetServerDatabaseInt (oModule, SERVER_TABLE, "temperature", nSelected * 5);
            }
            else if (sElem == "precipitation_selected")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetLocalInt (oModule, "0_DMWeather", nSelected);
                if (nSelected == 0) SetPrecipitation (WEATHER_CLEAR, FALSE, 0);
                else if (nSelected == 1) SetPrecipitation (WEATHER_CLEAR, FALSE, 0);
                else if (nSelected == 2) SetPrecipitation (WEATHER_RAIN, FALSE, 0);
                else if (nSelected == 3) SetPrecipitation (WEATHER_SNOW, FALSE, 0);
                else if (nSelected == 4)
                {
                    SetPrecipitation (WEATHER_RAIN, TRUE, 100);
                    float fMagnitude = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude");
                    NuiSetBind (oPC, nToken, "magnitude_value", JsonString (FloatToString (fMagnitude, 0, 1)));
                }
            }
            else if(sElem == "xp_slider_value")
            {
                nSelected = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                SetServerDatabaseInt(oModule, SERVER_TABLE, "xpslider", nSelected);
                SetLocalInt(oModule, "0_XP_SLIDER", nSelected);
                NuiSetBind(oPC, nToken, "xp_title_label", JsonString ("Experience " + IntToString (nSelected + 100) + "%"));
                //SendMessages(GetName (oPC) + " has changed the XP Slider to " + IntToString (nSelected + 100), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
            else if(sElem == "treasure_slider_value")
            {
                nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetServerDatabaseInt (oModule, SERVER_TABLE, "treasureslider", nSelected);
                SetLocalInt(oModule, "0_TREASURE_SLIDER", nSelected);
                NuiSetBind(oPC, nToken, "treasure_title_label", JsonString ("Treasure " + IntToString (nSelected + 100) + "%"));
                //SendMessages(GetName(oPC) + " has changed the Treasure Slider to " + IntToString (nSelected + 100), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
            else if(sElem == "villain_slider_value")
            {
                nSelected = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                SetServerDatabaseInt(oModule, SERVER_TABLE, "villainchance", nSelected);
                SetLocalInt(oModule, "0_VILLAIN_CHANCE", nSelected);
                NuiSetBind(oPC, nToken, "villain_title_label", JsonString ("Villain Chance " + IntToString(nSelected) + "%"));
                //SendMessages(GetName(oPC) + " has changed the Villain chance to " + IntToString(nSelected), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
            else if(sElem == "unique_slider_value")
            {
                nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                SetServerDatabaseInt(oModule, SERVER_TABLE, "uniquechance", nSelected);
                SetLocalInt(oModule, "0_UNIQUE_CHANCE", nSelected);
                NuiSetBind(oPC, nToken, "unique_title_label", JsonString("Unique Item Chance " + IntToString(nSelected) + "%"));
                //SendMessages(GetName(oPC) + " has changed the Unique item chance to " + IntToString(nSelected), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
        }
        else if(sEvent == "click")
        {
            if (sElem == "btn_rest")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, "btn_rest")))
                {
                    SetServerDatabaseInt (oModule, SERVER_TABLE, "restrictrest", 1);
                }
                else
                {
                    SetServerDatabaseInt (oModule, SERVER_TABLE, "restrictrest", 0);
                }
            }
            else if (sElem == "btn_restart")
            {
                if (JsonGetInt (NuiGetBind (oPC, nToken, "btn_restart")))
                {
                    SpeakString ("NOTICE: " + GetName (oPC) + " has begun a server shut down! Please log off now!", TALKVOLUME_SHOUT);
                    SetLocalInt (oModule, "0_SHUT_DOWN_TIMER", 4);
                    DelayCommand (5.0f, ServerShutDown (oPC));
                }
                else
                {
                    SpeakString ("NOTICE: Server shut down has been stopped by " + GetName (oPC) + " !", TALKVOLUME_SHOUT);
                    SetLocalInt (oModule, "0_SHUT_DOWN_TIMER", -1);
                }
            }
        }
        else if(sEvent == "mousescroll")
        {
            float fMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem + "_value"));
            nSelected += FloatToInt(fMouseScroll);
            if(nSelected < -100 || nSelected > 100) return;
            NuiSetBind(oPC, nToken, sElem + "_value", JsonInt(nSelected));
            if(sElem == "xp_slider")
            {
                SetServerDatabaseInt(oModule, SERVER_TABLE, "xpslider", nSelected);
                SetLocalInt(oModule, "0_XP_SLIDER", nSelected);
                NuiSetBind(oPC, nToken, "xp_title_label", JsonString("Experience " + IntToString(nSelected + 100) + "%"));
                //SendMessages(GetName(oPC) + " has changed the XP Slider to " + IntToString(nSelected + 100), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
            else if(sElem == "treasure_slider")
            {
                SetServerDatabaseInt(oModule, SERVER_TABLE, "treasureslider", nSelected);
                SetLocalInt(oModule, "0_TREASURE_SLIDER", nSelected);
                NuiSetBind(oPC, nToken, "treasure_title_label", JsonString("Treasure " + IntToString(nSelected + 100) + "%"));
                //SendMessages(GetName(oPC) + " has changed the Treasure Slider to " + IntToString(nSelected + 100), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
            else if(sElem == "villain_slider")
            {
                SetServerDatabaseInt(oModule, SERVER_TABLE, "villainchance", nSelected);
                SetLocalInt(oModule, "0_VILLAIN_CHANCE", nSelected);
                NuiSetBind(oPC, nToken, "villain_title_label", JsonString ("Villain Chance " + IntToString(nSelected) + "%"));
                //SendMessages(GetName(oPC) + " has changed the Villain chance to " + IntToString(nSelected), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
            else if(sElem == "unique_slider")
            {
                SetServerDatabaseInt(oModule, SERVER_TABLE, "uniquechance", nSelected);
                SetLocalInt(oModule, "0_UNIQUE_CHANCE", nSelected);
                NuiSetBind(oPC, nToken, "unique_title_label", JsonString("Unique Item Chance " + IntToString(nSelected) + "%"));
                //SendMessages(GetName(oPC) + " has changed the Unique item chance to " + IntToString(nSelected), COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            }
        }
    }
    //**************************************************************************
    // Transition events.
    else if (sWndId == "dmtransitionswin")
    {
        if (sEvent == "click")
        {
            string sResRef = "";
            if (sElem == "btn_overland") sResRef = "dm_overland";
            if (sElem == "btn_ladder") sResRef = "dm_ladder";
            if (sElem == "btn_w_door") sResRef = "dm_door";
            if (sElem == "btn_s_door") sResRef = "dm_stonedoor";
            if (sElem == "btn_grate") sResRef = "dm_grate";
            if (sElem == "btn_hole") sResRef = "dm_hole";
            if (sElem == "btn_y_portal") sResRef = "dm_yportal";
            if (sElem == "btn_p_portal") sResRef = "dm_pportal";
            if (sElem == "btn_g_portal") sResRef = "dm_gportal";
            if (sElem == "btn_r_portal") sResRef = "dm_rportal";
            if (sElem == "btn_w_portal") sResRef = "dm_wportal";
            if (sElem == "btn_clear") sResRef = "dm_clear_trans";
            if (sResRef != "")
            {
                SetLocalString (oPC, "0_Trans_ResRef", sResRef);
                SetLocalString (oPC, "0_Target_Mode", "0_DM_TRANSITION_LOCATION");
                EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOACTION);
            }
        }
    }
    //**************************************************************************
    // Factions events.
    else if (sWndId == "dmfactionswin")
    {
        if (sEvent == "click")
        {
            string sResRef = "";
            if (sElem == "btn_show_c_factions")
            {
                int nFaction, nCount = 1;
                string sText;
                object oArea = GetArea (oPC);
                object oCreature = GetObjectInArea (oArea, nCount, OBJECT_TYPE_CREATURE);
                while (oCreature != OBJECT_INVALID)
                {
                    nFaction = NWNX_Creature_GetFaction (oCreature) - 1;
                    sText = GetFactionName (nFaction);
                    if (sText == "Hostile")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Hostile", COLOR_RED));
                    if (sText == "Commoner")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Commoner", COLOR_GRAY));
                    if (sText == "Merchant")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Merchant", COLOR_YELLOW));
                    if (sText == "Defender")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Defender", COLOR_DARK_BLUE));
                    if (sText == "Neutral")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Neutral", COLOR_WHITE));
                    nCount ++;
                    oCreature = GetObjectInArea (oArea, nCount, OBJECT_TYPE_CREATURE);
                }
            }
            else if (sElem == "btn_show_p_factions")
            {
                int nFaction, nCount = 1;
                string sText;
                object oArea = GetArea (oPC);
                object oCreature = GetObjectInArea (oArea, nCount, OBJECT_TYPE_CREATURE);
                while (oCreature != OBJECT_INVALID)
                {
                    nFaction = GetLocalInt (oCreature, "0_PermanentFaction");
                    sText = GetFactionName (nFaction);
                    if (sText == "Hostile")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Hostile", COLOR_RED));
                    if (sText == "Commoner")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Commoner", COLOR_GRAY));
                    if (sText == "Merchant")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Merchant", COLOR_YELLOW));
                    if (sText == "Defender")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Defender", COLOR_DARK_BLUE));
                    if (sText == "Neutral")
                       NWNX_Player_FloatingTextStringOnCreature (oPC, oCreature, AddColorToText ("Neutral", COLOR_WHITE));
                    nCount ++;
                    oCreature = GetObjectInArea (oArea, nCount, OBJECT_TYPE_CREATURE);
                }
            }
        }
        if (sEvent == "watch")
        {
            object oTarget = GetLocalObject (oPC, DM_TARGET_CREATURE);
            if(sElem == "c_faction_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                object oNeutralFaction = GetObjectByTag("neutral_faction");
                if(JsonGetInt(NuiGetBind(oPC, nToken, "targets_value")) == 0)
                {
                    if(nSelected == 4)
                    {
                        ChangeFaction(oTarget, oNeutralFaction);
                    }
                    else ChangeToStandardFaction(oTarget, nSelected);
                }
                else
                {
                    object oArea = GetArea(oPC);
                    object oCreature = GetFirstObjectInArea (oArea);
                    while (oCreature != OBJECT_INVALID)
                    {
                        if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE
                         && !GetIsPC (oCreature)
                         && GetLocalInt (oCreature, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_NONE
                         && !GetLocalInt (oCreature, "0_Summon_ID")
                         && !GetIsDMPossessed (oCreature))
                        {
                            if (nSelected == 4) ChangeFaction (oCreature, oNeutralFaction);
                            else ChangeToStandardFaction (oCreature, nSelected);
                            SetLocalInt (oCreature, "0_CurrentFaction", nSelected);
                        }
                        oCreature = GetNextObjectInArea (oArea);
                    }
                }
                string sFaction = GetFactionName (nSelected);
                int nNewToken = NuiFindWindow (oPC, "dmcreaturewin");
                if (nNewToken != 0) NuiSetBind (oPC, nNewToken, "c_faction_value_label", JsonString (sFaction));
            }
            else if (sElem == "p_faction_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                if (JsonGetInt (NuiGetBind (oPC, nToken, "targets_value")) == 0)
                {
                    SetLocalInt (oTarget, "0_PermanentFaction", nSelected);
                }
                else
                {
                    object oArea = GetArea (oPC);
                    object oCreature = GetFirstObjectInArea (oArea);
                    while (oCreature != OBJECT_INVALID)
                    {
                        if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE
                         && !GetIsPC (oCreature)
                         && GetLocalInt (oCreature, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_NONE
                         && !GetLocalInt (oCreature, "0_Summon_ID")
                         && !GetIsDMPossessed (oCreature))
                        {
                            SetLocalInt (oCreature, "0_PermanentFaction", nSelected);
                        }
                        oCreature = GetNextObjectInArea (oArea);
                    }
                }
                string sFaction = GetFactionName (nSelected);
                int nNewToken = NuiFindWindow (oPC, "dmcreaturewin");
                if (nNewToken != 0) NuiSetBind (oPC, nNewToken, "p_faction_value_label", JsonString (sFaction));
            }
        }
    }
    //**************************************************************************
    // Adventure load events.
    else if (sWndId == "dmadvloadwin")
    {
        if (sEvent == "click")
        {
            if (sElem == "btn_load")
            {
               NuiDestroy (oPC, nToken);
               PopUpDMAdventureGUIPanel (oPC, nIndex + 1);
            }
        }
    }
    //**************************************************************************
    // Adventure manage events.
    else if (sWndId == "dmadventurewin")
    {
        if (sEvent == "click")
        {
            string sDBTag, sAreaTag, sName;
            object oArea;
            // Get the adventure slot we are are using.
            int nSlot = GetLocalInt (oPC, "0_Adventure_Num");
            // If they select an area then save the index for other button uses.
            if (sElem == "btn_area")
            {
                SetLocalInt (oPC, "0_Area_Index", nIndex);
                sDBTag = "Slot" + IntToString (nSlot) + "_Area" + IntToString (nIndex + 1);
                sAreaTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
                //  If they have selected an empty area button use the current area.
                if (sAreaTag == "")
                {
                    oArea = GetArea (oPC);
                    NuiSetBind (oPC, nToken, "btn_load_area_event", JsonBool (FALSE));
                    NuiSetBind (oPC, nToken, "btn_remove_area_event", JsonBool (FALSE));
                    NuiSetBind (oPC, nToken, "area_selected_label", JsonString (GetName (oArea)));
                }
                else
                {
                    oArea = GetObjectByTag(sAreaTag);
                    NuiSetBind(oPC, nToken, "btn_load_area_event", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_remove_area_event", JsonBool(TRUE));
                    sName = GetServerDatabaseString (oPC, AREA_TABLE, "areaname", sDBTag);
                    NuiSetBind(oPC, nToken, "area_selected_label", JsonString(sName));
                }
                // Area must be loaded for these buttons to be active.
                if(oArea == OBJECT_INVALID)
                {
                    NuiSetBind(oPC, nToken, "btn_save_area_event", JsonBool(FALSE));
                    NuiSetBind(oPC, nToken, "btn_open_area_event", JsonBool(FALSE));
                    NuiSetBind(oPC, nToken, "btn_jump_area_event", JsonBool(FALSE));
                }
                else
                {
                    NuiSetBind(oPC, nToken, "btn_save_area_event", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_open_area_event", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_jump_area_event", JsonBool(TRUE));
                    SetDMTargetNUI(oPC, oArea);
                }
            }
            // They didn't select an area so lets get last index saved.
            else
            {
                // Offset nIndex by one since buttons start at 0 and we start saving at 1.
                nIndex = GetLocalInt (oPC, "0_Area_Index") + 1;
                // If it is greater than 0 then we have selected an area.
                if (nIndex > 0)
                {
                    sDBTag = "Slot" + IntToString (nSlot) + "_Area" + IntToString (nIndex);
                    sAreaTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
                    oArea = GetObjectByTag (sAreaTag);
                }
                if (sAreaTag == "") oArea = GetArea (oPC);
                if (sElem == "btn_save_adv") SaveAdventure (oPC, nSlot, JsonGetString (NuiGetBind (oPC, nToken, "name_value")));
                else if (sElem == "btn_load_adv") LoadAdventure (oPC, nSlot);
                else if (sElem == "btn_clear_adv")
                {
                    EraseAdventure (oPC, nSlot);
                    NuiDestroy (oPC, nToken);
                }
                else if (sElem == "btn_save_area")
                {
                    SaveAreaToAdventure (oPC, nSlot, oArea, nIndex);
                    NuiDestroy (oPC, nToken);
                    PopUpDMAdventureGUIPanel (oPC, nSlot, oArea);
                }
                else if (sElem == "btn_load_area") LoadAreaFromDB (oPC, sDBTag);
                else if (sElem == "btn_remove_area")
                {
                    RemoveAreaFromAdventure (oPC, nSlot, oArea, nIndex);
                    NuiDestroy (oPC, nToken);
                    PopUpDMAdventureGUIPanel (oPC, nSlot);
                }
                else if (sElem == "btn_open_area") PopUpDMAreaGUIPanel (oPC, oArea);
                else if (sElem == "btn_jump_area")
                {
                    object oWaypoint = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
                    if (oWaypoint == OBJECT_INVALID) oWaypoint = GetFirstObjectInArea (oArea);
                    AssignCommand (oPC, JumpToObject (oWaypoint));
                }
            }
        }
    }
    //**************************************************************************
    // Password window events.
    else if (sWndId == "plpasswordwin")
    {
        if (sEvent == "click")
        {
            if (sElem == "btn_ok")
            {
                string sPassword = JsonGetString (NuiGetBind (oPC, nToken, "password_value"));
                string sDBPassword = GetServerDatabaseString  (oPC, PLAYER_TABLE, "password");
                //Debug ("0e_window", "3172", "sPassword: " + sPassword + " sDBPassword: " + sDBPassword);
                if (sPassword == sDBPassword)
                {
                    SetLocalInt (oPC, "0_Password", TRUE);
                    NuiDestroy (oPC, nToken);
                    SetCommandable (TRUE, oPC);
                }
                else
                {
                    NuiDestroy (oPC, nToken);
                    BootPC (oPC, "Invalid password!");
                }
            }
        }
    }
}
// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId (object oPC)
{
    float fScale = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0f;
    json jPayload = NuiGetEventPayload ();
    json jMousePosition = JsonObjectGet (jPayload, "mouse_pos");
    json jX = JsonObjectGet (jMousePosition, "x");
    json jY = JsonObjectGet (jMousePosition, "y");
    float fX = StringToFloat (JsonDump (jX));
    float fY = StringToFloat (JsonDump (jY));
    float fCellSize = 16.0f * fScale;
    int nCellX = FloatToInt (fX / fCellSize);
    int nCellY = FloatToInt (fY / fCellSize);
    if (nCellX < 0) nCellX = 0;
    else if (nCellX > 16) nCellX = 16;
    if (nCellY < 0) nCellY = 0;
    else if (nCellY > 11) nCellY = 11;
    return nCellX + nCellY * 16;
}


// Locks/Unlocks specific buttons when an item has been changed.
void LockItemInCraftingWindow (object oPC, object oItem, int nToken)
{
    NuiSetBind (oPC, nToken, "btn_copy", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_copy_event", JsonBool (FALSE));
    SetLocalInt (oPC, "0_COPY_ITEM", FALSE);
    NuiSetBind (oPC, nToken, "item_combo_event", JsonBool (FALSE));
    SetLocalInt (oItem, "0_EQUIP_LOCKED", TRUE);
    NuiSetBind (oPC, nToken, "btn_cancel_label", JsonString ("Cancel"));
    // Check to see if the players has enough ranks.
    int nRanks = GetSkillRank (SKILL_CRAFTING, oPC, TRUE);
    int nRanksRequired = GetLocalInt (oPC, "0_RANKS_REQUIRED");
    if (nRanksRequired > nRanks) NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (FALSE));
    else NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (TRUE));
}

// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow (object oPC, object oItem, int nToken)
{
    NuiSetBind (oPC, nToken, "btn_copy_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_paste_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "item_combo_event", JsonBool (TRUE));
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    NuiSetBind (oPC, nToken, "btn_cancel_label", JsonString ("Exit"));
}

// Change the button or item based on this buttons special function.
void DoSpecialButton (object oPC, object oItem, int nToken)
{
     int nItemSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
     int nSpecial = GetLocalInt (oPC, "0_MODEL_SPECIAL") + 1;
     // Change button for armor (Left/Right/Linked).
     if (nItemSelected == 0)
     {
         if (nSpecial > 2) nSpecial = 0;
         if (nSpecial == 0) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left/Right Linked"));
         else if (nSpecial == 1) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Right Model"));
         else NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left Model"));
         SetLocalInt (oPC, "0_MODEL_SPECIAL", nSpecial);
         //NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (TRUE));
    }
    // Change button for cloak/helmets.
    else if (nItemSelected == 1 || nItemSelected == 2)
    {
        // Get the item to be visible/hidden.
        // Get the items state and set.
        int nHidden = GetHiddenWhenEquipped (oItem);
        if (nHidden)
        {
            SetLocalInt (oPC, "0_MODEL_SPECIAL", 3);
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Visible"));
            SetHiddenWhenEquipped (oItem, FALSE);
        }
        else
        {
            SetLocalInt (oPC, "0_MODEL_SPECIAL", 4);
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Hidden"));
            SetHiddenWhenEquipped (oItem, TRUE);
        }
        LockItemInCraftingWindow (oPC, oItem, nToken);
        //NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (TRUE));
    }
}

// Saves the crafted item for the player removing the original.
void SaveCraftedItem (object oPC, object oTarget, int nToken)
{
    int nItemSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    object oItem = GetSelectedItem (oTarget, nItemSelected);
    ClearItemInCraftingWindow (oPC, oItem, nToken);
    DestroyObject (GetLocalObject (oPC, "0_ORIGINAL_CRAFT_ITEM"));
    DeleteLocalObject (oPC, "0_ORIGINAL_CRAFT_ITEM");
    DeleteLocalInt (oPC, "0_RANKS_REQUIRED");
}

// Can hide or unhide text while crafting.
void HideFeedbackForCraftText (object oPC, int bHidden)
{
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, bHidden, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_LOST, bHidden, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_EQUIP_SKILL_SPELL_MODIFIERS, bHidden, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_EQUIP_ONE_HANDED_WEAPON, bHidden, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_EQUIP_TWO_HANDED_WEAPON, bHidden, oPC);
}

void CheckDeityInDatabase (object oPC, object oTarget)
{
    // Lets not check when we first put the deity name in the field.
    if (!GetLocalInt (oPC, "0_No_Win_Save"))
    {
        int iDeityMaxRows, iRow, iMatch;
        string sDeityField, sDeityName;
        sDeityField = GetDeity (oTarget);
        sDeityField = GetStringLowerCase (sDeityField);
        iDeityMaxRows = StringToInt (Get2DAString ("deities", "Deity", 0));
        iRow = 1;
        while (iRow <= iDeityMaxRows && iMatch == 0)
        {
            sDeityName = GetStringLowerCase (Get2DAString ("deities", "Deity", iRow));
            if (sDeityField == sDeityName) iMatch = iRow;
            iRow++;
        }
        if (iMatch > 0)
        {
            SendMessages ("Deity name is valid!", COLOR_GREEN, oTarget);
            SendMessages ("Deity name is valid!", COLOR_GREEN, oPC);
            // Save the Deity 2da line in the database.
            if (GetIsCharacter(oTarget)) SetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "deity", iMatch);
        }
    }
}

void CheckForDMButtonClick (object oPC, int nToken, string sElem)
{
    if (sElem == "btn_options")
    {
        if (IsWindowClosed (oPC, "ploptionwin")) PopUpDMOptionsGUIPanel (oPC);
    }
    else if (sElem == "btn_password")
    {
        if (JsonDump (NuiGetBind (oPC, nToken, "btn_password")) == "true")
        {
            SetServerDatabaseInt (GetModule (), SERVER_TABLE, "password", 1);
        }
        else SetServerDatabaseInt (GetModule (), SERVER_TABLE, "password", 0);
    }
    else if (sElem == "btn_alerts")
    {
        if (JsonDump (NuiGetBind (oPC, nToken, "btn_alerts")) == "true")
        {
            string sOptions = GetServerDatabaseString (oPC, DM_TABLE, "options");
            sOptions = SetStringArray (sOptions, 0, "1");
            SetServerDatabaseString (oPC, DM_TABLE, "options", sOptions);
            NWNX_Player_PlaySound (oPC, "as_sw_x2gong3");
        }
        else
        {
            string sOptions = GetServerDatabaseString (oPC, DM_TABLE, "options");
            sOptions = SetStringArray (sOptions, 0, "0");
            SetServerDatabaseString (oPC, DM_TABLE, "options", sOptions);
        }
    }
    else if (sElem == "btn_discord")
    {
        string sOptions = GetServerDatabaseString (oPC, DM_TABLE, "options");
        if (JsonDump (NuiGetBind (oPC, nToken, "btn_discord")) == "true")
        {
            sOptions = SetStringArray (sOptions, 1, "1");
        }
        else
        {
            sOptions = SetStringArray (sOptions, 0, "0");
        }
        SetServerDatabaseString (oPC, DM_TABLE, "options", sOptions);
    }
    else if (sElem == "btn_str_combat") ExecuteScript ("0s_tool_str_cmbt", oPC);
    else if (sElem == "btn_stp_combat") ExecuteScript ("0s_tool_stp_cmbt", oPC);
    else if (sElem == "btn_server")
    {
        if (IsWindowClosed (oPC, "dmserverwin")) PopUpDMServerGUIPanel (oPC);
    }
    else if (sElem == "btn_adventure")
    {
        if(IsWindowClosed (oPC, "dmadventurewin")&&
            IsWindowClosed (oPC, "dmadvloadwin")) PopUpDMAdvLoadGUIPanel (oPC);
    }
    else if (sElem == "btn_area")
    {
        if(IsWindowClosed (oPC, "dmareawin")) 
        {
            object oArea = GetArea(oPC);
            SetDMTargetNUI(oPC, oArea, OBJECT_TYPE_TILE);
            PopUpDMAreaGUIPanel(oPC, oArea);
        }
    }
    else if (sElem == "btn_npc")
    {
        // Get location.
        SetLocalString (oPC, "0_Target_Mode", "0_DM_NPC_LOCATION");
        EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOACTION);
    }
    else if (sElem == "btn_transitions")
    {
        if (IsWindowClosed (oPC, "dmtransitionswin")) PopUpDMTransitionsGUIPanel (oPC);
    }
    else if (sElem == "btn_examine")
    {
        // Get Target.
        SetLocalString (oPC, "0_Target_Mode", "0_DM_EXAMINE_TARGET");
        EnterTargetingMode (oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
    }
    else if (sElem == "btn_craft")
    {
        SetLocalString (oPC, "0_Target_Mode", "0_DM_CRAFT_TARGET");
        EnterTargetingMode (oPC, OBJECT_TYPE_CREATURE);
    }
    else if (sElem == "btn_dm_chest")
    {
        string sTag = "chest1";
        // Get location to safely create creatures and objects.
        location lLocation = GetLocation (GetWaypointByTag (WP_CREATURE_SPAWN));
        object oChest = GetServerDatabaseObject (oPC, OBJECT_TABLE, lLocation, OBJECT_INVALID, sTag);
        if (oChest == OBJECT_INVALID) oChest = CreateObject (OBJECT_TYPE_PLACEABLE, "0_secure_chest", lLocation);
        SetLocalString (oChest, "0_Tag", sTag);
        NWNX_Player_ForcePlaceableInventoryWindow (oPC, oChest);
    }
    else if (sElem == "btn_dice")
    {
        if (IsWindowClosed (oPC, "pldicewin")) PopUpDiceGUIPanel (oPC);
    }
    else if (sElem == "btn_bug_report")
    {
        if (IsWindowClosed (oPC, "plbugwin")) PopUpBugReportGUIPanel (oPC);
    }
    else if (sElem == "btn_cynosure") AssignCommand (oPC, JumpToObject (GetWaypointByTag ("WP_Cynosure")));
    else if (sElem == "btn_pc_mode")
    {
        SendMessages ("You have removed DM status as a player.", COLOR_GRAY, oPC);
        SendMessages (GetName (oPC, TRUE) + " has removed DM status as a player.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
        NuiDestroy (oPC, NuiFindWindow (oPC, "ploptionwin"));
        NuiDestroy (oPC, NuiFindWindow (oPC, "plplayerwin"));
        NWNX_Player_ToggleDM (oPC, FALSE);
        //NuiDestroy(oPC, NuiFindWindow(oPC, "dm_widget"));
        //ExecuteScript("peps", oPC);
        PopUpSmallGUIPanel (oPC);
        //PopUpPlayerVerGUIPanel (oPC);
    }
}
