/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_henchmen
////////////////////////////////////////////////////////////////////////////////
 Used with pe_henchmen to run the npc plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "pinc_henchmen"
#include "x0_i0_henchman"
#include "0i_module"
// Sets oHenchmans scripts to the current AI.
void SetHenchmanScripts(object oHenchman);
// Creates the Henchman widget.
void PopupWidgetHenchmanGUIPanel(object oPC);
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
        if(sTargetMode == "MAKE_NPC_HENCHMAN")
        {
            if(GetMaster(oTarget) == oPC)
            {
                ai_SendMessages(GetName(oTarget) + " is already under your control!", AI_COLOR_RED, oPC);
                return;
            }
            oTarget = CopyObject(oTarget, GetLocation(oPC), OBJECT_INVALID, "", TRUE);
            AddHenchman(oPC, oTarget);
            DeleteLocalInt(oTarget, AI_ONSPAWN_EVENT);
            ai_ChangeEventScriptsForAssociate(oTarget);
            ExecuteScript("pi_henchmen", oPC);
        }
    }
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
                ai_SendMessages("Select an NPC to turn into a henchman.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL , MOUSECURSOR_CREATE, MOUSECURSOR_NOCREATE);
            }
            /*/ Save the current in game party to the party #.
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
                        sSlot = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
                        if(sSlot == "" || sName == sSlot) break;
                        nIndex++;
                    }
                    if(nIndex < 7)
                    {
                        FireHenchman(oPC, oHenchman);
                        sSlot = sParty + sIndex;
                        CheckHenchmanDataAndInitialize(oPC, sSlot);
                        SetHenchmanDbString(oPC, "image", GetPortraitResRef(oHenchman), sSlot);
                        SetHenchmanDbString(oPC, "henchname", sName, sSlot);
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
                        SetHenchmanDbString(oPC, "stats", sStats, sSlot);
                        SetHenchmanDbString(oPC, "classes", sClasses, sSlot);
                        SetHenchmanDbObject(oPC, oHenchman, sSlot);
                        NuiDestroy(oPC, nToken);
                        ExecuteScript("pi_henchmen", oPC);
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
                }*/
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
                NuiDestroy(oPC, nToken);
            }
            else if(sElem == "btn_saved_join")
            {
                SavedCharacterJoin(oPC, nToken, sParty);
            }
            else if(sElem == "btn_saved_remove")
            {
                string sIndex = GetHenchmanDbString(oPC, "henchname", sParty);
                RemoveHenchmanDb(oPC, sParty + sIndex);
                SetHenchmanDbString(oPC, "henchname", "0", sParty);
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_henchmen", oPC);
            }
            else if(sElem == "btn_clear_party")
            {
                SavedPartyCleared(oPC, nToken, sParty);
            }
            // ******************* Saved Character buttons *********************
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
                LevelUpYourHenchman(oPC, nToken, sParty);
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
