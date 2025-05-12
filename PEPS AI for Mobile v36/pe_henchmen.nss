/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_henchmen
////////////////////////////////////////////////////////////////////////////////
 Used with pe_henchmen to run the npc plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "pinc_henchmen"
#include "x0_i0_henchman"
#include "0i_module"
// Creates the Henchman widget.
void PopupWidgetHenchmanGUIPanel(object oPC);
void ResetHenchmanWindows(object oPC, int nToken, object oHenchman)
{
    int nIndex = 1;
    object oHench = GetHenchman(oPC, nIndex);
    while(oHench != OBJECT_INVALID)
    {
        oHench = GetHenchman(oPC, ++nIndex);
    }
    string sParty = GetHenchmanDbString(oPC, "henchname", "0");
    SetHenchmanDbString(oPC, "image", IntToString(nIndex - 1), sParty);
    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman_nui"));
    ExecuteScript("pi_henchmen", oPC);
    NuiDestroy(oPC, nToken);
    CreateCharacterEditGUIPanel(oPC, oHenchman);
}
void main()
{
    //**************************************************************************
    //********************** Henchmen Targeting Execution **********************
    //**************************************************************************
    // Get the last player to use targeting mode
    object oPC = GetLastPlayerToSelectTarget();
    if(GetLocalInt (oPC, "0_No_Win_Save")) return;
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
        if(sTargetMode == "MAKE_NPC_HENCHMAN")
        {
            if(GetAssociateType(oTarget) == ASSOCIATE_TYPE_HENCHMAN)
            {
                ai_SendMessages(GetName(oTarget) + " is already a henchman!", AI_COLOR_RED, oPC);
                return;
            }
            oTarget = CopyObject(oTarget, GetLocation(oPC), OBJECT_INVALID, "", TRUE);
            ai_ClearCombatState(oTarget);
            ChangeToStandardFaction(oTarget, STANDARD_FACTION_DEFENDER);
            DeleteLocalInt(oTarget, AI_ONSPAWN_EVENT);
            ai_ChangeEventScriptsForAssociate(oTarget);
            AddHenchman(oPC, oTarget);
            // Remove this variable so they may get a unique tag associate widget.
            DeleteLocalString(oTarget, AI_TAG);
            ai_SendMessages(GetName(oTarget) + " has been copied and is now in your party as a henchman.", AI_COLOR_GREEN, oPC);
            //ExecuteScript("pi_henchmen", oPC);
        }
    }
    //**************************************************************************
    //*********************** Henchmen Elements Execution **********************
    //**************************************************************************
    else
    {
        // Let the inspector handle what it wants.
        //HandleWindowInspectorEvent ();
        object oPC = NuiGetEventPlayer();
        int    nToken  = NuiGetEventWindow();
        string sEvent  = NuiGetEventType();
        string sElem   = NuiGetEventElement();
        int    nIndex  = NuiGetEventArrayIndex();
        string sWndId  = NuiGetWindowId (oPC, nToken);
        //SendMessageToPC(oPC, "pe_henchmen , 26 sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
        //                " nToken: " + IntToString(nToken) + " nIndex: " + IntToString(nIndex) +
        //                " oPC: " + GetName(oPC));
        //**********************************************************************
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(GetLocalInt(oPC, "AI_NO_NUI_SAVE")) return;
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
            json jData = GetHenchmanDbJson(oPC, "henchman", "0");
            if(JsonGetType(jData) == JSON_TYPE_NULL) jData = JsonObject();
            jData = JsonObjectSet(jData, sWndId, jGeometry);
            SetHenchmanDbJson(oPC, "henchman", jData, "0");
        }
        else if(sWndId == "henchman_nui")
        {
            //**********************************************************************
            // Henchman menu.
            if(sEvent == "click")
            {
                string sParty = GetHenchmanDbString(oPC, "henchname", "0");
                // Change to a different saved party #.
                if(GetStringLeft(sElem, 9) == "btn_party")
                {
                    sParty = GetStringRight(sElem, 1);
                    SetHenchmanDbString(oPC, "henchname", sParty, "0");
                    NuiDestroy(oPC, nToken);
                    ExecuteScript("pi_henchmen", oPC);
                }
                // Add an NPC in the game as a henchman.
                else if(sElem == "btn_npc_henchman")
                {
                    // Set this variable on the player so PEPS can run the targeting script for this plugin.
                    SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_henchmen");
                    // Set Targeting variables.
                    SetLocalString(oPC, AI_TARGET_MODE, "MAKE_NPC_HENCHMAN");
                    NuiDestroy(oPC, nToken);
                    ai_SendMessages("Select an NPC to copy and make your henchman.", AI_COLOR_YELLOW, oPC);
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL , MOUSECURSOR_CREATE, MOUSECURSOR_NOCREATE);
                }
                // ******************* Saved Character buttons *********************
                // Show saved party member.
                else if(sElem == "btn_saved_char")
                {
                    string sIndex = IntToString(nIndex);
                    SetHenchmanDbString(oPC, "henchname", sIndex, sParty);
                    AddSavedCharacterInfo(oPC, nToken, sParty);
                }
                // Have any saved henchman not in the party join.
                else if(sElem == "btn_join_party")
                {
                    SavedPartyJoin(oPC, nToken, sParty);
                }
                else if(sElem == "btn_saved_join")
                {
                    SavedCharacterJoin(oPC, nToken, sParty);
                }
                else if(sElem == "btn_saved_remove")
                {
                    string sIndex = GetHenchmanDbString(oPC, "henchname", sParty);
                    RemoveHenchmanDb(oPC, sParty + sIndex);
                    if(GetHenchmanDbString(oPC, "henchname", sParty + "0") == "")
                    {
                        SetHenchmanDbString(oPC, "henchname", "", sParty);
                    }
                    else SetHenchmanDbString(oPC, "henchname", "0", sParty);
                    NuiDestroy(oPC, nToken);
                    ExecuteScript("pi_henchmen", oPC);
                }
                else if(sElem == "btn_clear_party")
                {
                    SavedPartyCleared(oPC, nToken, sParty);
                }
                // ******************* Current Character buttons *********************
                // Show current party member.
                else if(sElem == "btn_cur_char")
                {
                    string sIndex = IntToString(nIndex);
                    SetHenchmanDbString(oPC, "image", sIndex, sParty);
                    AddCurrentCharacterInfo(oPC, nToken, sParty);
                }
                // The edit button, for now we are using it to level up!
                else if(sElem == "btn_cur_edit")
                {
                    object oHenchman = GetSelectedHenchman(oPC, sParty);
                    SetLocalObject(oPC, HENCHMAN_TO_EDIT, oHenchman);
                    CreateCharacterEditGUIPanel(oPC, oHenchman);
                }
                else if(sElem == "btn_cur_remove")
                {
                    RemoveYourHenchman(oPC, nToken, sParty);
                }
                else if(sElem == "btn_remove_party")
                {
                    RemoveWholeParty(oPC, nToken, sParty);
                }
                else if(sElem == "btn_cur_save")
                {
                    SaveYourHenchman(oPC, nToken, sParty);
                    SetHenchmanDbString(oPC, "henchname", "0", sParty);
                    NuiDestroy(oPC, nToken);
                    ExecuteScript("pi_henchmen", oPC);
                }
                else if(sElem == "btn_save_party")
                {
                    SaveWholeParty(oPC, nToken, sParty);
                }
            }
            /*else if(sEvent == "watch")
            {
                if(sElem == "henchman_widget_check")
                {
                    int bWidget = JsonGetInt(NuiGetBind(oPC, nToken, "henchman_widget_check"));
                    SetLocalInt(oPC, "AI_WIDGET_HENCHMAN", bWidget);
                    if(bWidget) PopupWidgetHenchmanGUIPanel(oPC);
                    else NuiDestroy(oPC, NuiFindWindow(oPC, "widgethenchmanwin"));
                }
                if(sElem == "lock_henchman_widget_check")
                {
                    int bBuffLockWidget = JsonGetInt(NuiGetBind(oPC, nToken, "lock_henchman_widget_check"));
                    SetLocalInt(oPC, "AI_WIDGET_HENCHMAN_LOCK", bBuffLockWidget);
                    SetLocalInt(oPC, "AI_WIDGET_HENCHMAN", TRUE);
                    NuiSetBind(oPC, nToken, "henchman_widget_check", JsonBool(TRUE));
                    PopupWidgetHenchmanGUIPanel(oPC);
                }
            }
            //**************************************************************************
            // Spell Buffing.
            else if (sWndId == "widget_henchman")
            {
                if (sEvent == "click")
                {
                    string sParty;
                    if (sElem == "btn_one") sParty = "1";
                    if (sElem == "btn_two") sParty = "2";
                    if (sElem == "btn_three") sParty = "3";
                    if (sElem == "btn_four") sParty = "4";
                    SetHenchmanDbString (oPC, "henchname", sParty, "0");
                    PopupWidgetHenchmanGUIPanel(oPC);
                }
            } */
        }
        else if(sWndId == "henchman_edit_nui")
        {
            int nChange = 0;
            int nID;
            string sResRef, sID, sPlot;
            object oHenchman = GetLocalObject(oPC, HENCHMAN_TO_EDIT);
            if(sEvent == "watch")
            {
                if(sElem == "char_name")
                {
                    string sName = JsonGetString(NuiGetBind(oPC, nToken, "char_name"));
                    SetName(oHenchman, sName);
                }
                if(sElem == "port_name")
                {
                    if(GetLocalInt(oPC, "AI_PORTRAIT_ID_SET"))
                    {
                        DeleteLocalInt(oPC, "AI_PORTRAIT_ID_SET");
                        //nID = JsonGetInt(NuiGetUserData(oPC, nToken));
                        //SetPortraitId(oHenchman, nID);
                    }
                    else NuiSetUserData(oPC, nToken, JsonInt(-1));
                    sResRef = JsonGetString (NuiGetBind(oPC, nToken, "port_name"));
                    if(ResManGetAliasFor(sResRef + "l", RESTYPE_TGA) == "" &&
                       ResManGetAliasFor(sResRef + "l", RESTYPE_DDS) == "")
                    {
                        if(GetGender(oHenchman)) sResRef = "po_hu_f_99_";
                        else sResRef = "po_hu_m_99_";
                    }
                    NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "l"));
                }
                else if(sElem == "cmb_class_selected")
                {
                    int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_class_selected"));
                    int nClass = GetClassBySelection2DA(nSelection);
                    SetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nPosition), nClass);
                    NuiDestroy(oPC, nToken);
                    CreateCharacterEditGUIPanel(oPC, oHenchman);
                }
                else if(sElem == "cmb_package_selected")
                {
                    int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                    string sClass = IntToString(GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nPosition)));
                    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_package_selected"));
                    int nPackage = GetPackageBySelection2DA(sClass, nSelection);
                    SetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nPosition), nPackage);
                }
                else if(sElem == "cmb_soundset_selected")
                {
                    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_soundset_selected"));
                    int nSoundSet = GetSoundSetBySelection2DA(oHenchman, nSelection);
                    SetSoundset(oHenchman, nSoundSet);
                    string sResRef = GetStringLowerCase(Get2DAString("soundset", "RESREF", nSoundSet));
                    if(GetStringLeft(sResRef, 4) == "vs_f")
                    {
                        DelayCommand(0.1, ai_HaveCreatureSpeak(oHenchman, 11, ":1:2:3:22:34:35:41:42:44:45:46:"));
                    }
                    else if(GetStringLeft(sResRef, 4) == "vs_n")
                    {
                        DelayCommand(0.1, ai_HaveCreatureSpeak(oHenchman, 10, ":1:2:3:34:35:36:40:42:44:45:"));
                    }
                    else
                    {
                        DelayCommand(0.1, ai_HaveCreatureSpeak(oHenchman, 7, ":1:2:3:11:12:13:33:"));
                    }
                }
            }
            if(sEvent == "click")
            {
                if (sElem == "btn_desc_save")
                {
                    string sDescription = JsonGetString(NuiGetBind(oPC, nToken, "desc_value"));
                    SetDescription(oHenchman, sDescription);
                    return;
                }
                else if(sElem == "btn_level_up")
                {
                    int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                    int nClass = GetClassByPosition(nPosition, oHenchman);
                    if(nClass == CLASS_TYPE_INVALID)
                    {
                        nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nPosition));
                        int nIndex = 1;
                        while(nIndex < 5)
                        {
                            if(nClass == GetClassByPosition(nIndex, oHenchman))
                            {
                                ai_SendMessages(GetName(oHenchman) + " already has this class in a different slot! You can only level up this class in its original slot.", AI_COLOR_RED, oPC);
                                return;
                            }
                            nIndex++;
                        }
                    }
                    int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nPosition));
                    if(nPackage == 0) nPackage = GetPackageBySelection2DA(IntToString(nClass), 0);
                    else if(nPackage == -1)
                    {
                        ai_SendMessages("There is not a valid package for this class!", AI_COLOR_RED, oPC);
                        return;
                    }
                    string sLevel = IntToString(GetLevelByClass(nClass, oHenchman) + 1);
                    json jHenchman = ObjectToJson(oHenchman);
                    // Check to see if this character has a LvlStatList that is required to level.
                    json jLvlStatList = JsonObjectGet(jHenchman, "LvlStatList");
                    //WriteTimestampedLogEntry("pe_henchmen, 313, jLvlStatList: " + JsonDump(jLvlStatList));
                    if(JsonGetType(jLvlStatList) == JSON_TYPE_NULL)
                    {
                        oHenchman = CreateLevelStatList(oPC, oHenchman);
                        SetLocalObject(oPC, HENCHMAN_TO_EDIT, oHenchman);
                        int nIndex = 1;
                        object oHench = GetHenchman(oPC, nIndex);
                        while(oHench != OBJECT_INVALID)
                        {
                            oHench = GetHenchman(oPC, ++nIndex);
                        }
                        string sParty = GetHenchmanDbString(oPC, "henchname", "0");
                        SetHenchmanDbString(oPC, "image", IntToString(nIndex - 1), sParty);
                    }
                    int nLeveled = LevelUpHenchman(oHenchman, nClass, TRUE, nPackage);
                    //SendMessageToPC(oPC, "pe_henchmen, 282, nClass: " + IntToString(nClass) +
                    //             " nPackage: " + IntToString(nPackage) + " nPosition: " + IntToString(nPosition) +
                    //             " nLeveled: " + IntToString(nLeveled));
                    string sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                    if(!nLeveled)
                    {
                        //WriteTimestampedLogEntry("pe_henchmen, 306, jLvlStatList: " + JsonDump(jLvlStatList, 1));
                        ai_SendMessages(GetName(oHenchman) + " could not level " + sClass + " to level " + sLevel + "!", AI_COLOR_RED, oPC);
                    }
                    else
                    {
                        ai_SendMessages(GetName(oHenchman) + " has leveled " + sClass + " to " + sLevel + " level!", AI_COLOR_GREEN, oPC);
                        ResetHenchmanWindows(oPC, nToken, oHenchman);
                    }
                    return;
                }
                else if(sElem == "btn_reset")
                {
                    oHenchman = ResetCharacter(oPC, oHenchman);
                    SetLocalObject(oPC, HENCHMAN_TO_EDIT, oHenchman);
                    ai_SendMessages(GetName(oHenchman) + " has been reset to level 1!", AI_COLOR_GREEN, oPC);
                    DelayCommand(0.2, ResetHenchmanWindows(oPC, nToken, oHenchman));
                }
                else if(sElem == "btn_portrait_next")
                {
                    nID = JsonGetInt(NuiGetUserData(oPC, nToken)) + 1;
                    nChange = 1;
                }
                else if(sElem == "btn_portrait_prev")
                {
                    nID = JsonGetInt(NuiGetUserData(oPC, nToken)) - 1;
                    nChange = -1;
                }
                else if(sElem == "btn_portrait_ok")
                {
                    nID = JsonGetInt(NuiGetUserData(oPC, nToken));
                    if(nID != -1) SetPortraitId(oHenchman, nID);
                    else
                    {
                        sResRef = JsonGetString (NuiGetBind (oPC, nToken, "port_name"));
                        if(ResManGetAliasFor(sResRef + "l", RESTYPE_TGA) == "" &&
                           ResManGetAliasFor(sResRef + "l", RESTYPE_DDS) == "")
                        {
                            if(GetGender(oHenchman)) sResRef = "po_hu_f_99_";
                            else sResRef = "po_hu_m_99_";
                            SetPortraitResRef(oHenchman, sResRef);
                        }
                    }
                    int nHenchToken = NuiFindWindow(oPC, "henchman_nui");
                    if(nHenchToken)
                    {
                        string sImage = GetPortraitResRef(oHenchman);
                        NuiSetBind(oPC, nHenchToken, "img_cur_portrait_image", JsonString(sImage + "l"));
                    }
                }
                if (nChange != 0)
                {
                    int nPRace, nPGender;
                    int nMax2DARow = Get2DARowCount("portraits") - 1;
                    if(nID > 5000) nID = 1;
                    if(nID < 0) nID = 5000;
                    int nGender = GetGender(oHenchman);
                    int nRace = GetRacialType(oHenchman);
                    string sPRace = Get2DAString("portraits", "Race", nID);
                    if(sPRace != "") nPRace = StringToInt(sPRace);
                    else nPRace = -1;
                    string sResRef, sPGender = Get2DAString("portraits", "Sex", nID);
                    if(sPGender != "") nPGender = StringToInt(sPGender);
                    else nPGender = -1;
                    //WriteTimestampedLogEntry("pe_henchmen, 367, nGender: " + IntToString(nGender) +
                    //                         " nPGender: " + IntToString(nPGender) +
                    //                         " nRace: " + IntToString(nRace) + " nPRace: " + IntToString(nPRace) +
                    //                         " nID: " + IntToString(nID));
                    while((nRace != nPRace &&
                          (nRace != RACIAL_TYPE_HALFELF ||
                          (nPRace != RACIAL_TYPE_ELF || nPRace != RACIAL_TYPE_HUMAN))) ||
                           nGender != nPGender && nPGender != 4)
                    {
                        nID += nChange;
                        //WriteTimestampedLogEntry("pe_henchmen, 382, nCounter: " + IntToString(nCounter) +
                        //                         " nMax2DARow: " + IntToString(nMax2DARow));
                        if (nID > 5000) nID = 1;
                        if (nID < 1) nID = 5000;
                        sPRace = Get2DAString("portraits", "Race", nID);
                        if(sPRace != "") nPRace = StringToInt(sPRace);
                        else nPRace = -1;
                        sPGender = Get2DAString("portraits", "Sex", nID);
                        if(sPGender != "") nPGender = StringToInt(sPGender);
                        else nPGender = -1;
                        //WriteTimestampedLogEntry("pe_henchmen, 385, nGender: " + IntToString(nGender) +
                        //                         " nPGender: " + IntToString(nPGender) +  " sPGender: " + sPGender +
                        //                         " nRace: " + IntToString(nRace) + " nPRace: " + IntToString(nPRace) +
                        //                         " sPRace: " + sPRace + " nID: " + IntToString(nID));
                        sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID) + "l";
                        if(ResManGetAliasFor(sResRef, RESTYPE_TGA) == "" &&
                           ResManGetAliasFor(sResRef, RESTYPE_DDS) == "") nPRace = 99;
                    }
                    sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID);
                    NuiSetUserData(oPC, nToken, JsonInt (nID));
                    // This is passed to the portrait name txt that actually sets
                    // the portrait information and tells it we picked an ID.
                    SetLocalInt(oPC, "AI_PORTRAIT_ID_SET", TRUE);
                    NuiSetBind(oPC, nToken, "port_name", JsonString (sResRef));
                }
            }
            if(sEvent == "mousedown")
            {
                int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
                if (sElem == "opt_classes" && nMouseButton == NUI_MOUSE_BUTTON_LEFT)
                {
                    int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value"));
                    SetLocalInt(oHenchman, "CLASS_OPTION_POSITION", nPosition);
                    NuiDestroy(oPC, nToken);
                    CreateCharacterEditGUIPanel(oPC, oHenchman);
                    return;
                }
                if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
                {
                    if(sElem == "cmb_class")
                    {
                        int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                        int nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nPosition));
                        string sName = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                        string sDescription = GetStringByStrRef(StringToInt(Get2DAString("classes", "Description", nClass)));
                        string sIcon = Get2DAString("classes", "Icon", nClass);
                        CreateCharacterDescriptionNUI(oPC, sName, sIcon, sDescription);
                    }
                    else if(sElem == "cmb_package")
                    {
                        int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                        int nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nPosition));
                        int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nPosition));
                        string sName = GetStringByStrRef(StringToInt(Get2DAString("packages", "Name", nPackage)));
                        string sDescription = GetStringByStrRef(StringToInt(Get2DAString("packages", "Description", nPackage)));
                        string sIcon = Get2DAString("classes", "Icon", nClass);
                        CreateCharacterDescriptionNUI(oPC, sName, sIcon, sDescription);
                    }
                    else if(sElem == "cmb_soundset")
                    {
                        int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_soundset_selected"));
                        int nSoundSet = GetSoundSetBySelection2DA(oHenchman, nSelection);
                        string sResRef = GetStringLowerCase(Get2DAString("soundset", "RESREF", nSoundSet));
                        if(GetStringLeft(sResRef, 4) == "vs_f")
                        {
                            DelayCommand(0.1, ai_HaveCreatureSpeak(oHenchman, 11, ":1:2:3:22:34:35:41:42:44:45:46:"));
                        }
                        else if(GetStringLeft(sResRef, 4) == "vs_n")
                        {
                            DelayCommand(0.1, ai_HaveCreatureSpeak(oHenchman, 10, ":1:2:3:34:35:36:40:42:44:45:"));
                        }
                        else
                        {
                            DelayCommand(0.1, ai_HaveCreatureSpeak(oHenchman, 7, ":1:2:3:11:12:13:33:"));
                        }
                    }
                    else if(sElem == "opt_classes")
                    {
                        int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                        int nClass = GetClassByPosition(nPosition, oHenchman);
                        if(nClass != CLASS_TYPE_INVALID)
                        {
                            string sName = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                            string sDescription = GetStringByStrRef(StringToInt(Get2DAString("classes", "Description", nClass)));
                            int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nPosition));
                            string sPackageName = GetStringByStrRef(StringToInt(Get2DAString("packages", "Name", nPackage)));
                            sDescription += "\n\nPACKAGE: \n" + sPackageName + "\n";
                            sDescription += GetStringByStrRef(StringToInt(Get2DAString("packages", "Description", nPackage)));
                            string sIcon = Get2DAString("classes", "Icon", nClass);
                            CreateCharacterDescriptionNUI(oPC, sName, sIcon, sDescription);
                        }
                    }
                }
            }
        }
        else if(sWndId == "char_description_nui")
        {
            if(sEvent == "click" && sElem == "btn_ok") NuiDestroy(oPC, nToken);
        }
    }
}
void PopupWidgetHenchmanGUIPanel(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "AI_NO_NUI_SAVE", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "AI_NO_NUI_SAVE"));
    // Row 1 (buttons)**********************************************************
    json jRow = JsonArray();
    CreateButtonImage(jRow, "ir_level1", "btn_one", 30.0f, 30.0f);
    CreateButtonImage(jRow, "ir_level2", "btn_two", 30.0f, 30.0f);
    CreateButtonImage(jRow, "ir_level3", "btn_three", 30.0f, 30.0f);
    CreateButtonImage(jRow, "ir_level4", "btn_four", 30.0f, 30.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    int bAINPCWidgetLock = GetLocalInt(oPC, "AI_WIDGET_HENCHMAN_LOCK");
    // Get the window location to restore it from the database.
    float fX = GetLocalFloat(oPC, "widget_henchman_X");
    float fY = GetLocalFloat(oPC, "widget_henchman_Y");
    if(fX == 0.0f && fY == 0.0f)
    {
        fX = 10.0f;
        fY = 10.0f;
    }
    if(bAINPCWidgetLock)
    {
        fX = fX + 4.0f;
        fY = fY + 45.0f;
    }
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken;
    if(bAINPCWidgetLock) nToken = SetWindow (oPC, jLayout, "widget_henchman", "Henchman Widget", fX, fY, 160.0, 62.0, FALSE, FALSE, FALSE, TRUE, FALSE, "pe_npc");
    else nToken = SetWindow (oPC, jLayout, "widget_henchman", "Henchman Widget", fX, fY, 160.0, 95.0, FALSE, FALSE, FALSE, TRUE, TRUE, "pe_npc");
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch (oPC, nToken, "collapsed", TRUE);
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    //NuiSetBind (oPC, nToken, "btn_one", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_one_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_two", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_two_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_three", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_three_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_four", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_four_event", JsonBool (TRUE));
}
