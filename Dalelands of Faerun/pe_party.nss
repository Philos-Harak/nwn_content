/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_party
////////////////////////////////////////////////////////////////////////////////
 Used with pe_party to run the party manager plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "pinc_party"
//#include "x0_i0_henchman"
//#include "0i_module"
// Creates the Henchman widget.
void PopupWidgetHenchmanGUIPanel(object oPC);
void ResetHenchmanWindows(object oPC, int nToken, object oHenchman)
{
    NuiDestroy(oPC, NuiFindWindow(oPC, "party_nui"));
    ExecuteScript("pi_party", oPC);
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
    string sTargetMode = GetLocalString(oPC, "AI_TARGET_MODE");
    if(oPC == OBJECT_SELF && sTargetMode != "")
    {
        // Get the targeting mode data
        object oTarget = GetTargetingModeSelectedObject();
        vector vTarget = GetTargetingModeSelectedPosition();
        location lLocation = Location(GetArea(oPC), vTarget, GetFacing(oPC));
        object oObject = GetLocalObject(oPC, "AI_TARGET_OBJECT");
        DeleteLocalString(oPC, "AI_TARGET_MODE");
        // If the user manually exited targeting mode without selecting a target, return
        if(!GetIsObjectValid(oTarget) && vTarget == Vector())
        {
            return;
        }
        // Targeting code here.
        if(sTargetMode == "")
        {
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
        //SendMessageToPC(oPC, "pe_party , 26 sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
        //                " nToken: " + IntToString(nToken) + " nIndex: " + IntToString(nIndex) +
        //                " oPC: " + GetName(oPC));
        //**********************************************************************
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(GetLocalInt(oPC, "AI_NO_NUI_SAVE")) return;
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
            json jData = GetHenchmanDbJson(oPC, "henchman", "Data");
            if(JsonGetType(jData) == JSON_TYPE_NULL) jData = JsonObject();
            jData = JsonObjectSet(jData, sWndId, jGeometry);
            SetHenchmanDbJson(oPC, "henchman", jData, "Data");
        }
        else if(sWndId == "party_options_nui")
        {
            //if(sEvent == "click")
            //{
            //}
            //else
            if(sEvent == "watch")
            {
                if(sElem == "txt_max_party")
                {
                    int nMax = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                    if(nMax < 1) nMax = 1;
                    else if(nMax > 10) nMax = 10;
                    object oModule = GetModule();
                    json jData = GetHenchmanDbJson(oModule, "classes", "Data");
                    jData = JsonObjectSet(jData, "Max_Party_Size", JsonInt(nMax));
                    SetHenchmanDbJson(oModule, "classes", jData, "Data");
                }
                else if(sElem == "txt_level_limit")
                {
                    int nMax = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                    if(nMax < -5) nMax = -5;
                    else if(nMax > 5) nMax = 5;
                    object oModule = GetModule();
                    json jData = GetHenchmanDbJson(oModule, "classes", "Data");
                    jData = JsonObjectSet(jData, "Level_Limit", JsonInt(nMax));
                    SetHenchmanDbJson(oModule, "classes", jData, "Data");
                }
            }
        }
        else if(sWndId == "party_nui")
        {
            //**********************************************************************
            // Henchman menu.
            if(sEvent == "click")
            {
                string sParty = GetHenchmanDbString(oPC, "henchname", "Data");
                // Change to a different saved party #.
                if(GetStringLeft(sElem, 9) == "btn_party")
                {
                    sParty = GetStringRight(sElem, 1);
                    SetHenchmanDbString(oPC, "henchname", sParty, "Data");
                    NuiDestroy(oPC, nToken);
                    ExecuteScript("pi_party", oPC);
                }
                // ******************* Saved Character buttons *********************
                // Show saved party member selected.
                else if(sElem == "btn_saved_char")
                {
                    string sIndex = IntToString(nIndex);
                    SetHenchmanDbString(oPC, "saveselection", sIndex, sParty);
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
                // ******************* Current Character buttons *********************
                // Show current party member selected.
                else if(sElem == "btn_cur_char")
                {
                    string sIndex = IntToString(nIndex);
                    SetHenchmanDbString(oPC, "partyselection", sIndex, sParty);
                    AddCurrentCharacterInfo(oPC, nToken, sParty);
                }
                // The edit button: Change portrait, sound, level up!
                else if(sElem == "btn_cur_edit")
                {
                    object oHenchman = GetCurrentSelectedHenchman(oPC, sParty);
                    SetLocalObject(oPC, HENCHMAN_TO_EDIT, oHenchman);
                    CreateCharacterEditGUIPanel(oPC, oHenchman);
                }
                else if(sElem == "btn_cur_move")
                {
                    MoveCurrentHenchman(oPC, nToken, sParty);
                    SetHenchmanDbString(oPC, "partyselection", "0", sParty);
                    NuiDestroy(oPC, nToken);
                    ExecuteScript("pi_party", oPC);
                }
                else if(sElem == "btn_move_party")
                {
                    MoveWholeParty(oPC, nToken, sParty);
                }
                else if(sElem == "btn_options") CreateHenchmanOptionsGUIPanel(oPC);
            }
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
                    }
                    else NuiSetUserData(oPC, nToken, JsonInt(-1));
                    sResRef = JsonGetString(NuiGetBind(oPC, nToken, "port_name"));
                    if(ResManGetAliasFor(sResRef + "l", RESTYPE_TGA) == "" &&
                       ResManGetAliasFor(sResRef + "l", RESTYPE_DDS) == "" &&
                       ResManGetAliasFor(sResRef, RESTYPE_TGA) == "" &&
                       ResManGetAliasFor(sResRef, RESTYPE_DDS) == "")
                    {
                        if(GetGender(oHenchman)) sResRef = "po_hu_f_99_";
                        else sResRef = "po_hu_m_99_";
                    }
                    if(ResManGetAliasFor(sResRef, RESTYPE_TGA) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef));
                    else if(ResManGetAliasFor(sResRef, RESTYPE_DDS) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef));
                    else if(ResManGetAliasFor(sResRef + "l", RESTYPE_TGA) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "l"));
                    else if(ResManGetAliasFor(sResRef + "l", RESTYPE_DDS) != "") NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "l"));
                }
                else if(sElem == "cmb_class_selected")
                {
                    int nPosition = JsonGetInt(NuiGetBind(oPC, nToken, "opt_classes_value")) + 1;
                    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_class_selected"));
                    int nClass = GetClassBySelection2DA(nSelection);
                    SetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nPosition), nClass);
                    SetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nPosition), nClass);
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
                        DelayCommand(0.5, HaveCreatureSpeak(oHenchman, 11, ":1:2:3:22:34:35:41:42:44:45:46:"));
                    }
                    else if(GetStringLeft(sResRef, 4) == "vs_n")
                    {
                        DelayCommand(0.5, HaveCreatureSpeak(oHenchman, 10, ":1:2:3:34:35:36:40:42:44:45:"));
                    }
                    else
                    {
                        DelayCommand(0.5, HaveCreatureSpeak(oHenchman, 7, ":1:2:3:11:12:13:33:"));
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
                                SendMessages(GetName(oHenchman) + " already has this class in a different slot! You can only level up this class in its original slot.", COLOR_RED, oPC);
                                return;
                            }
                            nIndex++;
                        }
                    }
                    int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nPosition));
                    if(nPackage == 0) nPackage = GetPackageBySelection2DA(IntToString(nClass), 0);
                    else if(nPackage == -1)
                    {
                        SendMessages("There is not a valid package for this class!", COLOR_RED, oPC);
                        return;
                    }
                    string sLevel = IntToString(GetLevelByClass(nClass, oHenchman) + 1);
                    json jHenchman = ObjectToJson(oHenchman, TRUE);
                    //WriteTimestampedLogEntry("pe_party, 271, Level: " + IntToString(GetHitDice(oHenchman))+ 
                    //                          " jHenchman: " + JsonDump(jHenchman, 4));
                    // Check to see if this character has a LvlStatList that is required to level.
                    json jLvlStatList = JsonObjectGet(jHenchman, "LvlStatList");
                    //WriteTimestampedLogEntry("pe_party, 321, jLvlStatList: " + JsonDump(jLvlStatList, 4));
                    if(JsonGetType(jLvlStatList) == JSON_TYPE_NULL)
                    {
                        RemoveHenchman(oPC, oHenchman);
                        ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
                        // Make sure to get a clean faction version of the henchman here.
                        jHenchman = ObjectToJson(oHenchman, TRUE);
                        jHenchman = CreateLevelStatList(jHenchman, oHenchman, oPC);
                        location lLocation = GetLocation(oHenchman);
                        int nFamiliar, nCompanion;
                        object oCompanion = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oHenchman);
                        if(oCompanion != OBJECT_INVALID) nFamiliar = TRUE;
                        oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oHenchman);
                        if(oCompanion != OBJECT_INVALID) nCompanion = TRUE;
                        AssignCommand(oHenchman, SetIsDestroyable(TRUE, FALSE, FALSE));
                        DestroyObject(oHenchman);
                        oHenchman = party_AddHenchman(oPC, jHenchman, lLocation, nFamiliar, nCompanion);
                        SetLocalObject(oPC, HENCHMAN_TO_EDIT, oHenchman);
                        // We need to move party button list index to the last one since
                        // the henchman will move to the last henchman slot.
                        int nIndex = 1;
                        object oHench = GetHenchman(oPC, nIndex);
                        while(oHench != OBJECT_INVALID)
                        {
                            oHench = GetHenchman(oPC, ++nIndex);
                            //SendMessageToPC(oPC, "oHench: " + GetName(oHench) + " nIndex: " + IntToString(nIndex));
                        }
                        string sParty = GetHenchmanDbString(oPC, "henchname", "0");
                        SetHenchmanDbString(oPC, "image", IntToString(nIndex - 1), sParty);
                    }
                    int nLeveled = LevelUpHenchman(oHenchman, nClass, TRUE, nPackage);
                    //SendMessageToPC(oPC, "pe_party, 282, nClass: " + IntToString(nClass) +
                    //             " nPackage: " + IntToString(nPackage) + " nPosition: " + IntToString(nPosition) +
                    //             " nLeveled: " + IntToString(nLeveled));
                    string sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                    if(!nLeveled)
                    {
                        //WriteTimestampedLogEntry("pe_party, 306, jLvlStatList: " + JsonDump(jLvlStatList, 1));
                        SendMessages(GetName(oHenchman) + " could not level " + sClass + " to level " + sLevel + "!", COLOR_RED, oPC);
                    }
                    else
                    {
                        SendMessages(GetName(oHenchman) + " has leveled " + sClass + " to " + sLevel + " level!", COLOR_GREEN, oPC);
                        ResetHenchmanWindows(oPC, nToken, oHenchman);
                    }
                    return;
                }
                else if(sElem == "btn_reset")
                {
                    oHenchman = ResetCharacter(oPC, oHenchman, nToken);
                    SetLocalObject(oPC, HENCHMAN_TO_EDIT, oHenchman);
                    SendMessages(GetName(oHenchman) + " has been reset to level 1!", COLOR_GREEN, oPC);
                    // We need to move party button list index to the last one since
                    // the henchman will move to the last henchman slot.
                    int nIndex = 1;
                    object oHench = GetHenchman(oPC, nIndex);
                    while(oHench != OBJECT_INVALID)
                    {
                        oHench = GetHenchman(oPC, ++nIndex);
                    }
                    string sParty = GetHenchmanDbString(oPC, "henchname", "0");
                    SetHenchmanDbString(oPC, "image", IntToString(nIndex - 1), sParty);
                    ResetHenchmanWindows(oPC, nToken, oHenchman);
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
                           ResManGetAliasFor(sResRef + "l", RESTYPE_DDS) == "" &&
                           ResManGetAliasFor(sResRef, RESTYPE_TGA) == "" &&
                           ResManGetAliasFor(sResRef, RESTYPE_DDS) == "")
                        {
                            if(GetGender(oHenchman)) sResRef = "po_hu_f_99_";
                            else sResRef = "po_hu_m_99_";
                        }
                        SetPortraitResRef(oHenchman, sResRef);
                    }
                    int nHenchToken = NuiFindWindow(oPC, "party_nui");
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
                    int nRace = GetRaceType(oHenchman, TRUE);
                    string sPRace = Get2DAString("portraits", "Race", nID);
                    if(sPRace != "") nPRace = StringToInt(sPRace);
                    else nPRace = -1;
                    string sResRef, sPGender = Get2DAString("portraits", "Sex", nID);
                    if(sPGender != "") nPGender = StringToInt(sPGender);
                    else nPGender = -1;
                    //WriteTimestampedLogEntry("pe_party, 367, nGender: " + IntToString(nGender) +
                    //                         " nPGender: " + IntToString(nPGender) +
                    //                         " nRace: " + IntToString(nRace) + " nPRace: " + IntToString(nPRace) +
                    //                         " nID: " + IntToString(nID));
                    while((nRace != nPRace &&
                          (nRace != RACIAL_TYPE_HALFELF ||
                          (nPRace != RACIAL_TYPE_ELF || nPRace != RACIAL_TYPE_HUMAN))) ||
                           nGender != nPGender && nPGender != 4)
                    {
                        nID += nChange;
                        //WriteTimestampedLogEntry("pe_party, 382, nCounter: " + IntToString(nCounter) +
                        //                         " nMax2DARow: " + IntToString(nMax2DARow));
                        if (nID > 5000) nID = 1;
                        if (nID < 1) nID = 5000;
                        sPRace = Get2DAString("portraits", "Race", nID);
                        if(sPRace != "") nPRace = StringToInt(sPRace);
                        else nPRace = -1;
                        sPGender = Get2DAString("portraits", "Sex", nID);
                        if(sPGender != "") nPGender = StringToInt(sPGender);
                        else nPGender = -1;
                        //WriteTimestampedLogEntry("pe_party, 385, nGender: " + IntToString(nGender) +
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
                            DelayCommand(0.1, HaveCreatureSpeak(oHenchman, 11, ":1:2:3:22:34:35:41:42:44:45:46:"));
                        }
                        else if(GetStringLeft(sResRef, 4) == "vs_n")
                        {
                            DelayCommand(0.1, HaveCreatureSpeak(oHenchman, 10, ":1:2:3:34:35:36:40:42:44:45:"));
                        }
                        else
                        {
                            DelayCommand(0.1, HaveCreatureSpeak(oHenchman, 7, ":1:2:3:11:12:13:33:"));
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
