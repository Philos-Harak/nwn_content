/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_buffing
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions.

 UI to save a players buff spells to be cast after resting.
*///////////////////////////////////////////////////////////////////////////////

// Creates the table and initializes if it needs to.
void CheckBuffDataAndInitialize(object oPlayer, string sTag = "");
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag = "");
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag = "");
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetBuffDatabaseJson(object oPlayer, string sDataField, string sTag = "");
#include "0i_nui"
void main()
{
    object oPC = OBJECT_SELF;
    // Row 1 (Buttons) ********************************************************* 45
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Save", "btn_save", 80.0f, 25.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Clear", "btn_clear", 80.0f, 25.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Buff", "btn_buff", 80.0f, 25.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 (Buttons) ********************************************************* 78
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "List 1", "btn_list1", 80.0f, 25.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "List 2", "btn_list2", 80.0f, 25.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "List 3", "btn_list3", 80.0f, 25.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "List 4", "btn_list4", 80.0f, 25.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 (Widget)********************************************************** 111
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateCheckBox(jRow, "Fast Buff Widget", "buff_widget", 150.0, 20.0f);
    CreateCheckBox(jRow, "Lock", "lock_buff_widget", 50.0, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 (List of Spells) ************************************************** 129
    // Create the button template for the List.
    jRow = JsonArray();
    json jButton = NuiId (NuiButton (NuiBind ("btns_spell")), "btn_spell");
    json jList = JsonArrayInsert (JsonArray (), NuiListTemplateCell (jButton, 300.0, TRUE));
    // Create the list with the template.
    CreateList(jRow, jList, "btns_spell", 25.0, 431.0, 300.0);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 257.0);
    int nToken = SetWindow (oPC, jLayout, "plbuffwin", "Fast Buffing Spells",
                            0.0, fY, 456.0, 441.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_buffing");
    // Set the elements to show events.
    int nSelected = GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT) == "pc_savebuffs";
    NuiSetBind (oPC, nToken, "btn_save", JsonBool (nSelected));
    NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_event", JsonBool (TRUE));
    CheckBuffDataAndInitialize(oPC, "list");
    string sList = GetBuffDatabaseString(oPC, "spells", "list");
    if(sList == "[]")
    {
        SetBuffDatabaseString(oPC, "spells", "1", "list");
        sList = "1";
    }
    //ai_Debug("pi_buffing", "84", "sList: " + sList);
    if (sList == "1") NuiSetBind (oPC, nToken, "btn_list1", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list1", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list1_event", JsonBool (TRUE));
    if (sList == "2") NuiSetBind (oPC, nToken, "btn_list2", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list2", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list2_event", JsonBool (TRUE));
    if (sList == "3") NuiSetBind (oPC, nToken, "btn_list3", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list3", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list3_event", JsonBool (TRUE));
    if (sList == "4") NuiSetBind (oPC, nToken, "btn_list4", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list4", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list4_event", JsonBool (TRUE));
    int nValue;
    if(NuiFindWindow(oPC, "widgetbuffwin")) nValue = TRUE;
    NuiSetBind (oPC, nToken, "buff_widget_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "buff_widget_check", TRUE);
    nValue = GetLocalInt(oPC, "AI_WIDGET_BUFF_LOCK");
    NuiSetBind (oPC, nToken, "lock_buff_widget_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "lock_buff_widget_check", TRUE);
    // Create buttons with spells listed.
    json jButtons = JsonArray();
    int nSpell, nClass, nLevel, nMetamagic, nDomain, nCntr;
    string sName, sTargetName;
    json jSpells, jSpell;
    sList = "list" + sList;
    while (nCntr <= 50)
    {
        jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
        jSpell = JsonArrayGet(jSpells, nCntr);
        if(JsonGetType(jSpell) != JSON_TYPE_NULL)
        {
            nSpell = JsonGetInt(JsonArrayGet (jSpell, 0));
            nClass = JsonGetInt(JsonArrayGet (jSpell, 1));
            nLevel = JsonGetInt(JsonArrayGet (jSpell, 2));
            nMetamagic = JsonGetInt(JsonArrayGet(jSpell, 3));
            nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
            sTargetName = JsonGetString(JsonArrayGet(jSpell, 5));
            sName = GetStringByStrRef(StringToInt(Get2DAString ("spells", "Name", nSpell)));
            sName += " (" + GetStringByStrRef(StringToInt(Get2DAString("classes", "Short", nClass)));
            sName += " / " + IntToString (nLevel);
            if (nMetamagic > 0)
            {
                if (nMetamagic == METAMAGIC_EMPOWER) sName += " / Empowered";
                else if (nMetamagic == METAMAGIC_EXTEND) sName += " / Extended";
                else if (nMetamagic == METAMAGIC_MAXIMIZE) sName += " / Maximized";
                else if (nMetamagic == METAMAGIC_QUICKEN) sName += " / Quickened";
                else if (nMetamagic == METAMAGIC_SILENT) sName += " / Silent";
                else if (nMetamagic == METAMAGIC_STILL) sName += " / Still";
            }
            if (nDomain > 0) sName += " / Domain";
            sName += ") " + sTargetName;
            JsonArrayInsertInplace(jButtons, JsonString(sName));
        }
        nCntr++;
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "btns_spell", jButtons);
}
void CreateBuffDataTable (object oPlayer)
{
    //ai_Debug("pi_buffing", "145", GetName(oPlayer) + " is creating a Buff Table.");
    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "CREATE TABLE IF NOT EXISTS BUFF_TABLE (" +
        "name           TEXT,  " +
        "tag            TEXT, " +
        "spells         TEXT, " +
        "PRIMARY KEY(name, tag));");
    SqlStep (sql);
}
void CheckBuffDataAndInitialize(object oPlayer, string sTag = "")
{
    //ai_Debug("pi_buffing", "156", GetName(oPlayer) + " is checking Buff Data.");
    string sName = GetName(oPlayer, TRUE);
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@tableName", "BUFF_TABLE");
    if(!SqlStep (sql)) CreateBuffDataTable(oPlayer);
    sQuery = "SELECT name FROM BUFF_TABLE Where name = @name AND tag = @tag;";
    sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if(!SqlStep(sql))
    {
        //ai_Debug("pi_buffing", "168", GetName(oPlayer) + " is initializing Buff Data.");
        string sQuery;
        sqlquery sql;
        int nIndex;
        while(nIndex < 5)
        {
            //ai_Debug("pi_buffing", "174", GetName(oPlayer) + " is setting Buff Data" +
            //         " name: " + sName + " tag: " + sTag + ".");
            sQuery = "INSERT INTO BUFF_TABLE(name, tag, spells) VALUES (@name, @tag, @spells);";
            sql = SqlPrepareQueryObject(oPlayer, sQuery);
            SqlBindString(sql, "@name", sName);
            SqlBindString(sql, "@tag", sTag);
            SqlBindJson(sql, "@spells", JsonArray ());
            SqlStep(sql);
            sTag = "list" + IntToString(++nIndex);
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
    if (SqlStep (sql)) return SqlGetString(sql, 0);
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
    SqlStep(sql);
}
json GetBuffDatabaseJson (object oPlayer, string sDataField, string sTag = "")
{
    string sName = GetName(oPlayer, TRUE);
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@name", sName);
    if(sTag != "") SqlBindString (sql, "@tag", sTag);
    if(SqlStep(sql)) return SqlGetJson(sql, 0);
    else return JsonArray();
}

