/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_buffing
////////////////////////////////////////////////////////////////////////////////
 Used with ai_crafting to run the crafting plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag = "");
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag = "");
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetBuffDatabaseJson(object oPlayer, string sDataField, json jData, string sTag = "");
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetBuffDatabaseJson(object oPlayer, string sDataField, string sTag = "");
// Casts all buff spells saved to the widget button.
void CastSavedBuffSpells(object oPC);
// Will check and make sure the spell is memorized and/or ready.
// Returns TRUE if memorized and ready, FALSE if memorized but not ready,
// and -1 if not memorized for classes that memorize.
// nSpell is the spell to find.
// nClass that cast the spell.
// nLevel the level of the spell.
// nMetamagic is if it has metamagic on it.
// nDomain is if it is a domain spell.
int GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain);
// Creates the Buffing widget.
void PopupWidgetBuffGUIPanel(object oPC);
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
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(!GetLocalInt (oPC, "AI_NO_NUI_SAVE"))
        {
            // Get the height, width, x, and y of the window.
            json jGeom = NuiGetBind(oPC, nToken, "window_geometry");
            // Save on the player using the sWndId.
            SetLocalFloat(oPC, "Buff_widget_X", JsonGetFloat (JsonObjectGet (jGeom, "x")));
            SetLocalFloat(oPC, "Buff_widget_Y", JsonGetFloat (JsonObjectGet (jGeom, "y")));
        }
        return;
    }
   //**************************************************************************
    // Spell Buffing.
    if(sWndId == "plbuffwin")
    {
        if(sEvent == "click")
        {
            string sList;
            if(sElem == "btn_spell")
            {
                sList = "list" + GetBuffDatabaseString(oPC, "spells", "list");
                json jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
                jSpells = JsonArrayDel(jSpells, nIndex);
                SetBuffDatabaseJson(oPC, "spells", jSpells, sList);
                ExecuteScript("pi_buffing", oPC);
            }
            else if(sElem == "btn_save")
            {
                string sScript;
                object oCreature;
                if(JsonGetInt(NuiGetBind (oPC, nToken, "btn_save")))
                {
                    sScript = GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
                    SetLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT", sScript);
                    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "pc_savebuffs");
                    SendMessageToPC(oPC, "Cast spells on yourself to save them to the widget.");
                }
                else
                {
                    sScript = GetLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
                    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
                    DeleteLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
                    SendMessageToPC(oPC, "Saving spells to the widget has been turned off.");
                }
            }
            else if(sElem == "btn_clear")
            {
                sList = "list" + GetBuffDatabaseString (oPC, "spells", "list");
                SetBuffDatabaseJson(oPC, "spells", JsonArray(), sList);
                ExecuteScript("pi_buffing", oPC);
            }
            else if(sElem == "btn_buff") CastSavedBuffSpells(oPC);
            // Runs all the List 1-4 buttons.
            if(GetStringLeft(sElem, 8) == "btn_list")
            {
                sList = GetStringRight(sElem, 1);
                SetBuffDatabaseString(oPC, "spells", sList, "list");
                ExecuteScript("pi_buffing", oPC);
            }
        }
        else if(sEvent == "watch")
        {
            if(sElem == "buff_widget_check")
            {
                int bBuffWidget = JsonGetInt(NuiGetBind(oPC, nToken, "buff_widget_check"));
                SetLocalInt(oPC, "AI_WIDGET_BUFF", bBuffWidget);
                if(bBuffWidget) PopupWidgetBuffGUIPanel(oPC);
                else NuiDestroy(oPC, NuiFindWindow(oPC, "widgetbuffwin"));
            }
            if(sElem == "lock_buff_widget_check")
            {
                int bBuffLockWidget = JsonGetInt(NuiGetBind(oPC, nToken, "lock_buff_widget_check"));
                SetLocalInt(oPC, "AI_WIDGET_BUFF_LOCK", bBuffLockWidget);
                SetLocalInt(oPC, "AI_WIDGET_BUFF", TRUE);
                NuiSetBind(oPC, nToken, "buff_widget_check", JsonBool(TRUE));
                PopupWidgetBuffGUIPanel(oPC);
            }
        }
    }
    //**************************************************************************
    // Spell Buffing.
    else if (sWndId == "widgetbuffwin")
    {
        if (sEvent == "click")
        {
            string sList;
            if (sElem == "btn_one") sList = "1";
            if (sElem == "btn_two") sList = "2";
            if (sElem == "btn_three") sList = "3";
            if (sElem == "btn_four") sList = "4";
            SetBuffDatabaseString (oPC, "spells", sList, "list");
            CastSavedBuffSpells(oPC);
        }
    }
}
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag = "")
{
    string sName = GetName(oPlayer, TRUE);
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
    else return "";
}
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag = "")
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    SqlStep (sql);
}
void SetBuffDatabaseJson (object oPlayer, string sDataField, json jData, string sTag = "")
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}
json GetBuffDatabaseJson (object oPlayer, string sDataField, string sTag = "")
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
void CastBuffSpell (object oPC, object oTarget, int nSpell, int nClass, int nMetamagic, int nDomain, string sList, string sName)
{
    //ai_Debug("pe_buffing", "191", GetName(oPC) + " is casting spell on " + GetName(oTarget) +
    //         " nSpell: " + IntToString(nSpell) + " nClass: " + IntToString(nClass) +
    //         " nMetamagic: " + IntToString(nMetamagic) + " nDomain: " + IntToString(nDomain));
    string sTargetName;
    if(oPC == oTarget) sTargetName = "myself.";
    else sTargetName = GetName(oTarget);
    SendMessageToPC(oPC, "Quick Buffing: " + sName + " on " + sTargetName);
    AssignCommand(oPC, ActionCastSpellAtObject(nSpell, oTarget, nMetamagic, FALSE, nDomain, 0, TRUE, nClass));
}
string StripColorCodes(string sText)
{
    string sColorCode, sChar;
    int nStringLength = GetStringLength(sText);
    int i = FindSubString(sText, "<c", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength - (i + 6));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "<c", i);
    }
    i = FindSubString(sText, "</", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength - (i + 4));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "</", i);
    }
    return sText;
}
void CastSavedBuffSpells(object oPC)
{
    // Lets make sure the save button is off!
    if(GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT) == "pc_savebuffs")
    {
        string sScript = GetLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
        SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
        DeleteLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
        SendMessageToPC(oPC, "Saving spells to the widget has been turned off.");
    }
    // Check for monsters! We cannot let them buff if they are close to the enemy!
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oPC);
    float fDistance = GetDistanceBetween(oPC, oEnemy);
    if (fDistance > 30.0f || fDistance == 0.0)
    {
        string sName;
        float fDelay = 0.1f;
        int nSpell, nClass, nLevel, nMetamagic, nDomain, nSpellReady, nIndex = 0;
        string sList = "list" + GetBuffDatabaseString(oPC, "spells", "list");
        json jSpell, jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
        while (nIndex <= 50)
        {
            jSpell = JsonArrayGet(jSpells, nIndex);
            if (JsonGetType(jSpell) != JSON_TYPE_NULL)
            {
                nSpell = JsonGetInt(JsonArrayGet (jSpell, 0));
                nClass = JsonGetInt(JsonArrayGet (jSpell, 1));
                nLevel = JsonGetInt(JsonArrayGet (jSpell, 2));
                nMetamagic = JsonGetInt(JsonArrayGet (jSpell, 3));
                nDomain = JsonGetInt(JsonArrayGet (jSpell, 4));
                // We save the target's name then look them up by it.
                string sTargetName = JsonGetString(JsonArrayGet(jSpell, 5));
                object oTarget;
                location lLocation = GetLocation(oPC);
                if (sTargetName == "" || sTargetName == StripColorCodes(GetName (oPC))) oTarget = oPC;
                else
                {
                    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lLocation, TRUE);
                    while (oTarget != OBJECT_INVALID)
                    {
                        if (sTargetName == StripColorCodes(GetName(oTarget))) break;
                        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lLocation, TRUE);
                    }
                }
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                if(oTarget == OBJECT_INVALID)
                {
                    DelayCommand(fDelay, SendMessageToPC(oPC, "Cannot quick cast " + sName + " because the " + sTargetName + " is not here!"));
                }
                else
                {
                    if(nMetamagic > 0)
                    {
                        if (nMetamagic == METAMAGIC_EMPOWER) sName += " (Empowered)";
                        else if (nMetamagic == METAMAGIC_EXTEND) sName += " (Extended)";
                        else if (nMetamagic == METAMAGIC_MAXIMIZE) sName += " (Maximized)";
                        else if (nMetamagic == METAMAGIC_QUICKEN) sName += " (Quickened)";
                        else if (nMetamagic == METAMAGIC_SILENT) sName += " (Silent)";
                        else if (nMetamagic == METAMAGIC_STILL) sName += " (Still)";
                    }
                    nSpellReady = GetSpellReady(oPC, nSpell, nClass, nLevel, nMetamagic, nDomain);
                    if(nSpellReady > -1)
                    {
                        // Right now we cannot save the domain status. So we just assume
                        // the domain status of the spell that has the same ID.
                        // This is returned in GetSpellReady.
                        nDomain = nSpellReady;
                        DelayCommand(fDelay, CastBuffSpell(oPC, oTarget, nSpell, nClass, nMetamagic, nDomain, sList, sName));
                    }
                    else if(nSpellReady == -1)
                    {
                        DelayCommand(fDelay, SendMessageToPC(oPC, "Cannot quick cast " + sName + " because it is not ready to cast!"));
                    }
                    else if(nSpellReady == -2)
                    {
                        DelayCommand (fDelay, SendMessageToPC (oPC, "Cannot quick cast " + sName + " because it is not memorized!"));
                    }
                    fDelay += 0.1f;
                }
            }
            else break;
            nIndex ++;
        }
        if(nIndex == 0 && !NuiFindWindow(oPC, "plbuffwin")) ExecuteScript("pi_buffing", oPC);
    }
    else SendMessageToPC(oPC, "Enemies are too close for you to cast all your buff spells!");
}
int GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain)
{
    int nIndex, nMaxIndex, nMSpell, nMmSpell, nDSpell;
    if (StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
    {
        nMaxIndex = GetMemorizedSpellCountByLevel(oCaster, nClass, nLevel);
        while(nIndex < nMaxIndex)
        {
            nMSpell = GetMemorizedSpellId(oCaster, nClass, nLevel, nIndex);
            if (nSpell == nMSpell)
            {
                nMmSpell = GetMemorizedSpellMetaMagic(oCaster, nClass, nLevel, nIndex);
                nDSpell = GetMemorizedSpellIsDomainSpell(oCaster, nClass, nLevel, nIndex);
                //ai_Debug("pe_buffing", "308", "nMmSpell: " + IntToString(nMmSpell) +
                //         " nMetamagic: " + IntToString(nMetamagic) +
                //         " nDomain: " + IntToString(nDomain) +
                //         " nDSpell: " + IntToString(nDSpell));
                // Cannot save the domain status so we just use the first spell ID.
                // Then return the domain statusl.
                //if(nMmSpell == nMetamagic &&
                //  ((nDomain > 0 && nDSpell == TRUE) || nDomain == 0 && nDSpell == FALSE))
                if(nMmSpell == nMetamagic)
                {
                    if(GetMemorizedSpellReady(oCaster, nClass, nLevel, nIndex))
                    {
                        if(nDSpell) return nLevel;
                        return 0;
                    }
                }
            }
            nIndex ++;
        }
        return -2;
    }
    else
    {
        nMaxIndex = GetKnownSpellCount(oCaster, nClass, nLevel);
        while (nIndex < nMaxIndex)
        {
            nMSpell = GetKnownSpellId(oCaster, nClass, nLevel, nIndex);
            if (nSpell == nMSpell)
            {
                if(GetSpellUsesLeft(oCaster, nClass, nSpell)) return 0;
            }
            nIndex ++;
        }
        return -2;
    }
    return -1;
}
void PopupWidgetBuffGUIPanel(object oPC)
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
    int bAIBuffWidgetLock = GetLocalInt(oPC, "AI_WIDGET_BUFF_LOCK");
    // Get the window location to restore it from the database.
    float fX = GetLocalFloat(oPC, "Buff_widget_X");
    float fY = GetLocalFloat(oPC, "Buff_widget_Y");
    if(fX == 0.0f && fY == 0.0f)
    {
        fX = 10.0f;
        fY = 10.0f;
    }
    if(bAIBuffWidgetLock)
    {
        fX = fX + 4.0f;
        fY = fY + 45.0f;
    }
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken;
    if(bAIBuffWidgetLock) nToken = SetWindow (oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 160.0, 62.0, FALSE, FALSE, FALSE, TRUE, FALSE, "pe_buffing");
    else nToken = SetWindow (oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 160.0, 95.0, FALSE, FALSE, FALSE, TRUE, TRUE, "pe_buffing");
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

