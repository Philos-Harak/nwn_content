/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_henchman
////////////////////////////////////////////////////////////////////////////////
 Used with pe_henchman to run the npc plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "pinc_henchman"
#include "x0_i0_henchman"
// Sets oHenchmans scripts to the current AI.
void SetHenchmanScripts(object oHenchman);
// Creates the Henchman widget.
void PopupWidgetHenchmanGUIPanel(object oPC);
// Returns a two letter alignment string.
string GetAlignText(object oHenchman);
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
    //**************************************************************************
    if(sWndId == "henchman_nui")
    {
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(GetLocalInt(oPC, "AI_NO_NUI_SAVE")) return;
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
            json jData = GetHenchmanDbJson(oPC, "data", "0");
            JsonArraySetInplace(jData, 0, jGeometry);
            SetHenchmanDbJson(oPC, "data", jData, "0");
        }
    }
    //**************************************************************************
    // Henchman menu.
    if(sWndId == "henchman_nui")
    {
        if(sEvent == "click")
        {
            string sParty = GetHenchmanDbString("name", "0");
            // Change to a different party.
            if(GetStringLeft(sElem, 9) == "btn_party")
            {
                sParty = GetStringRight(sElem, 1);
                SetHenchmanDbString("name", sParty, "0");
                ExecuteScript("pi_henchman", oPC);
            }
            else if(GetStringLeft(sElem, 8) == "btn_save")
            {
                string sButton = GetStringRight(sElem, 1);
                object oHenchman;
                if(sButton == "c")
                {
                    oHenchman = CopyObject(oPC, GetLocation(oPC), OBJECT_INVALID, "Hench_" + GetName(oPC, TRUE));
                    SetHenchmanScripts(oHenchman);
                }
                else oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, StringToInt(sButton));
                string sName = GetName(oHenchman);
                int nIndex = 1;
                string sIndex, sSlot;
                // Get empty slot index.
                while(nIndex < 7)
                {
                    sIndex = IntToString(nIndex);
                    sSlot = GetHenchmanDbString("name", sParty + sIndex);
                    if(sSlot == "" || sName == sSlot) break;
                    nIndex++;
                }
                if(nIndex < 7)
                {
                    FireHenchman(oPC, oHenchman);
                    sSlot = sParty + sIndex;
                    CheckHenchmanDataAndInitialize(sSlot);
                    SetHenchmanDbString("image", GetPortraitResRef(oHenchman), sSlot);
                    SetHenchmanDbString("name", sName, sSlot);
                    string sStats = GetAlignText(oHenchman) + " ";
                    if(GetGender(oHenchman) == GENDER_MALE) sStats += "Male ";
                    else sStats += "Female ";
                    int nPosition = 1;
                    sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oHenchman))));
                    string sClasses = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oHenchman))));
                    sClasses += IntToString (GetLevelByPosition (nPosition, oHenchman));
                    int nClass = GetClassByPosition(++nPosition, oHenchman);
                    while(nClass != CLASS_TYPE_INVALID)
                    {
                        sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oHenchman))));
                        nClass = GetClassByPosition(++nPosition, oHenchman);
                    }
                    SetHenchmanDbString("stats", sStats, sSlot);
                    SetHenchmanDbString("classes", sClasses, sSlot);
                    SetHenchmanDbObject(oHenchman, sSlot);
                    NuiDestroy(oPC, nToken);
                    ExecuteScript("pi_henchman", oPC);
                    if(sButton == "c")
                    {
                        SetIsDestroyable(TRUE, FALSE, FALSE, oHenchman);
                        DestroyObject(oHenchman);
                    }
                    else
                    {
                        HireHenchman(oPC, oHenchman, FALSE);
                        AddHenchman(oPC, oHenchman);
                    }
                }
                else ai_SendMessages("This party is full!", AI_COLOR_RED, oPC);
            }
            // Show saved party member.
            if(sElem == "btns_saved_char")
            {
                string sIndex = IntToString(++nIndex);
                if(AI_DEBUG) ai_Debug("pe_henchman", "113", "sParty: " + sParty + " nIndex: " + sIndex);
                string sName = GetHenchmanDbString("name", sParty + sIndex);
                string sImage = GetHenchmanDbString("image", sParty + sIndex);
                string sStats = GetHenchmanDbString("stats", sParty + sIndex);
                string sClasses = GetHenchmanDbString("classes", sParty + sIndex);
                NuiSetBind(oPC, nToken, "lbl_saved_name_label", JsonString(sName));
                NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString(sImage + "l"));
                NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(sStats));
                NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(sClasses));
                NuiSetBind(oPC, nToken, "btn_saved_remove_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(GetJoinButtonActive(oPC, sName)));
                // Save the saved party member selected.
                json jSelected = NuiGetUserData(oPC, nToken);
                JsonArraySetInplace(jSelected, 0, JsonString(sIndex));
                NuiSetUserData(oPC, nToken, jSelected);
            }
            // Show current party member.
            if(sElem == "btns_cur_char")
            {
                string sButtonName = JsonGetString(NuiGetBind(oPC, nToken, "btns_cur_char"));
                object oPartyMember;
                int nIndex = 1;
                string sName;
                while(nIndex < 8)
                {
                    if(nIndex == 7) oPartyMember = oPC;
                    oPartyMember = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    sName = GetName(oPartyMember);
                    if(sName == sButtonName) break;
                    nIndex++;
                }
                string sImage = GetPortraitResRef(oPartyMember);
                string sStats = GetAlignText(oPartyMember) + " ";
                if(GetGender(oPartyMember) == GENDER_MALE) sStats += "Male ";
                else sStats += "Female ";
                int nPosition = 1;
                sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oPartyMember))));
                string sClasses = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oPartyMember))));
                sClasses += IntToString (GetLevelByPosition (nPosition, oPartyMember));
                int nClass = GetClassByPosition(++nPosition, oPartyMember);
                while(nClass != CLASS_TYPE_INVALID)
                {
                    sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oPartyMember))));
                    nClass = GetClassByPosition(++nPosition, oPartyMember);
                }
                NuiSetBind(oPC, nToken, "lbl_cur_name_label", JsonString(sName));
                NuiSetBind(oPC, nToken, "img_cur_portrait_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage + "l"));
                NuiSetBind(oPC, nToken, "lbl_cur_stats_label", JsonString(sStats));
                NuiSetBind(oPC, nToken, "lbl_cur_classes_label", JsonString(sClasses));
                // Save the saved party member selected.
                json jSelected = NuiGetUserData(oPC, nToken);
                JsonArraySetInplace(jSelected, 1, JsonString(IntToString(++nIndex)));
                NuiSetUserData(oPC, nToken, jSelected);
            }
            // Have any henchman not in the party join.
            else if(sElem == "btn_party_join")
            {
                int bFound, nIndex, nDBHenchman = 1;
                object oHenchman, oLoadedHenchman;
                string sDBHenchman = IntToString(nDBHenchman);
                string sName = GetHenchmanDbString("name", sParty + sDBHenchman);
                while(sName != "")
                {
                    bFound = FALSE;
                    nIndex = 1;
                    oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    while(oHenchman != OBJECT_INVALID)
                    {
                        if(sName == GetName(oPC) || GetName(oHenchman) == sName)
                        {
                            bFound = TRUE;
                            break;
                        }
                        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
                    }
                    if(!bFound)
                    {
                        ai_SendMessages(sName + " has joined your party!", AI_COLOR_GREEN, oPC);
                        oLoadedHenchman = GetHenchmanDbObject(GetLocation(oPC), sParty + sDBHenchman);
                        HireHenchman(oPC, oLoadedHenchman, FALSE);
                        AddHenchman(oPC, oLoadedHenchman);
                    }
                    sDBHenchman = IntToString(++nDBHenchman);
                    sName = GetHenchmanDbString("name", sParty + sDBHenchman);
                }
            }
            else if(sElem == "btn_join")
            {
                string sIndex = JsonGetString(NuiGetUserData(oPC, nToken));
                object oHenchman = GetHenchmanDbObject(GetLocation(oPC), sParty + sIndex);
                AddHenchman(oPC, oHenchman);
            }
            else if(sElem == "btn_remove")
            {
                string sIndex = JsonGetString(NuiGetUserData(oPC, nToken));
                SetHenchmanDbString("name", sParty + sIndex, "");
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_henchman", oPC);
            }
            else if(sElem == "btn_level_up")
            {
            }
        }
        else if(sEvent == "watch")
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
            SetHenchmanDbString ("name", sParty, "0");
        }
    }
}
void SetHenchmanScripts(object oHenchman)
{
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac6");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_ch_ac7");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "nw_ch_ac9");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_aca");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
    SetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
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
string GetAlignText(object oHenchman)
{
    string sAlign1, sAlign2;
    switch (GetAlignmentLawChaos(oHenchman))
    {
        case ALIGNMENT_LAWFUL : sAlign1 = "L"; break;
        case ALIGNMENT_NEUTRAL : sAlign1 = "N"; break;
        case ALIGNMENT_CHAOTIC : sAlign1 = "C"; break;
    }
    switch (GetAlignmentGoodEvil(oHenchman))
    {
        case ALIGNMENT_GOOD : sAlign2 = "G"; break;
        case ALIGNMENT_NEUTRAL : sAlign2 = "N"; break;
        case ALIGNMENT_EVIL : sAlign2 = "E"; break;
    }
    string sAlign = sAlign1 + sAlign2;
    if (sAlign == "NN") sAlign = "TN";
    return sAlign;
}

