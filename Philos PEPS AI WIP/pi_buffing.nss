/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_buffing
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions.

 Database structure:
    Name(string) Tag(String) Spells(Json)
    Tag: Widget - 0 = x position, 1 = y position, 2 = On/Off, 3 = Locked
    Tag: List (string) set to the list number selected 1,2,3, or 4.
    Tag: List# is the list of spells for List number 1,2,3, or 4.

 UI to save a players buff spells to be cast after resting.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
const int BUFF_MAX_SPELLS = 50;
const string FB_NO_MONSTER_CHECK = "FB_NO_MONSTER_CHECK";

// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
// Creates the table and initializes if it needs to.
void CheckBuffDataAndInitialize(object oPlayer, string sTag);
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag);
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetBuffDatabaseJson(object oPlayer, string sDataField, json jData, string sTag);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetBuffDatabaseJson(object oPlayer, string sDataField, string sTag);
// Creates the widget for buffing.
void PopupWidgetBuffGUIPanel(object oPC);

void main()
{
    object oPC = OBJECT_SELF;
    // Check to make sure the database is setup before we do anything.
    CheckBuffDataAndInitialize(oPC, "menudata");
    json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
    if(JsonGetType(JsonArrayGet(jMenuData, 0)) == JSON_TYPE_NULL)
    {
        jMenuData = JsonArray();
        JsonArrayInsertInplace(jMenuData, JsonString("list1"));                       // 0 Spell List #
        JsonArrayInsertInplace(jMenuData, JsonFloat(0.0));                            // 1 Main menu X pos.
        JsonArrayInsertInplace(jMenuData, JsonFloat(GetGUIHeightMiddle(oPC, 257.0))); // 2 Main menu Y pos.
        JsonArrayInsertInplace(jMenuData, JsonBool(FALSE));                           // 3 Widget on/off
        JsonArrayInsertInplace(jMenuData, JsonBool(FALSE));                           // 4 Widget Locked
        JsonArrayInsertInplace(jMenuData, JsonFloat(10.0));                           // 5 Widget X pos.
        JsonArrayInsertInplace(jMenuData, JsonFloat(10.0));                           // 6 Widget Y pos.
        SetBuffDatabaseJson(oPC, "spells", jMenuData, "menudata");
    }
    if(StartingUp(oPC)) return;
    // Row 1 (Buttons) ********************************************************* 73
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Save", "btn_save", 60.0f, 20.0f, "btn_save_tooltip");
    CreateButton(jRow, "Clear", "btn_clear", 60.0f, 20.0f, -1.0, "btn_clear_tooltip");
    CreateButton(jRow, "Buff", "btn_buff", 60.0f, 20.0f, -1.0, "btn_buff_tooltip");
    CreateButtonSelect(jRow, "List 1", "btn_list1", 60.0f, 20.0f);
    CreateButtonSelect(jRow, "List 2", "btn_list2", 60.0f, 20.0f);
    CreateButtonSelect(jRow, "List 3", "btn_list3", 60.0f, 20.0f);
    CreateButtonSelect(jRow, "List 4", "btn_list4", 60.0f, 20.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 (Buttons) ********************************************************* 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateCheckBox(jRow, "Buff Widget", "buff_widget", 110.0, 20.0f, "buff_widget_tooltip");
    CreateCheckBox(jRow, "Lock Widget", "lock_buff_widget", 110.0, 20.0f, "lock_buff_widget_tooltip");
    if(!AI_SERVER)
    {
        CreateCheckBox(jRow, "Don't Check for Monsters", "chbx_no_monster_check", 200.0, 20.0f, "chbx_no_monster_check_tooltip");
    }
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 (List of Spells) ************************************************** 144
    // Create the button template for the List.
    jRow = JsonArray();
    string sList = JsonGetString(JsonArrayGet(jMenuData, 0));
    int nCntr, nIndex;
    string sCntr, sIndex;
    json jSpell;
    CheckBuffDataAndInitialize(oPC, sList);
    json jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
    while(nCntr <= BUFF_MAX_SPELLS)
    {
        jSpell = JsonArrayGet(jSpells, nCntr);
        if(JsonGetType(jSpell) != JSON_TYPE_NULL)
        {
            sIndex = IntToString(nIndex++);
            CreateButtonImage(jRow, "", "btn_spell_" + sIndex, 35.0, 35.0, 0.0, "btn_spell_" + sIndex + "_tooltip");
        }
        nCntr++;
    }
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fWidth = IntToFloat(nIndex) * 39;
    if(fWidth < 470.0) fWidth = 470.0;
    float fX = JsonGetFloat(JsonArrayGet(jMenuData, 1));
    float fY = JsonGetFloat(JsonArrayGet(jMenuData, 2));
    if(fX == 0.0f && fY == 0.0f)
    {
        fX = 0.0f;
        fY = GetGUIHeightMiddle(oPC, 257.0);
    }
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "plbuffwin", "Fast Buffing Spells",
                           fX, fY, fWidth, 144.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_buffing");
    // Set the elements to show events.
    int nSelected = GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT) == "pc_savebuffs";
    NuiSetBind(oPC, nToken, "btn_save", JsonBool(nSelected));
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_save_tooltip", JsonString("  Saves any spells cast on you or your associates."));
    NuiSetBind(oPC, nToken, "btn_clear", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_tooltip", JsonString("  Clears the current list of all saved spells."));
    NuiSetBind(oPC, nToken, "btn_buff", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_tooltip", JsonString("  Casts the current list of saved spells."));
    if(sList == "list1") NuiSetBind (oPC, nToken, "btn_list1", JsonBool (TRUE));
    else NuiSetBind(oPC, nToken, "btn_list1", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_list1_event", JsonBool(TRUE));
    if(sList == "list2") NuiSetBind (oPC, nToken, "btn_list2", JsonBool (TRUE));
    else NuiSetBind(oPC, nToken, "btn_list2", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_list2_event", JsonBool(TRUE));
    if(sList == "list3") NuiSetBind (oPC, nToken, "btn_list3", JsonBool (TRUE));
    else NuiSetBind(oPC, nToken, "btn_list3", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_list3_event", JsonBool(TRUE));
    if(sList == "list4") NuiSetBind (oPC, nToken, "btn_list4", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list4", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_list4_event", JsonBool(TRUE));
    int nValue = JsonGetInt(JsonArrayGet(jMenuData, 3));
    NuiSetBind(oPC, nToken, "buff_widget_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "buff_widget_check", JsonBool(nValue));
    NuiSetBindWatch(oPC, nToken, "buff_widget_check", TRUE);
    string sText = "  Creates a set of 4 buttons on the screen for quick buffing.";
    NuiSetBind(oPC, nToken, "buff_widget_tooltip", JsonString(sText));
    nValue = JsonGetInt(JsonArrayGet(jMenuData, 4));
    NuiSetBind(oPC, nToken, "lock_buff_widget_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "lock_buff_widget_check", JsonBool(nValue));
    NuiSetBindWatch(oPC, nToken, "lock_buff_widget_check", TRUE);
    sText = "  Locks the buffing widget in place reducing its size.";
    NuiSetBind(oPC, nToken, "lock_buff_widget_tooltip", JsonString(sText));
    if(!AI_SERVER)
    {
        NuiSetBind(oPC, nToken, "chbx_no_monster_check_event", JsonBool(TRUE));
        nValue = GetLocalInt(oPC, FB_NO_MONSTER_CHECK);
        NuiSetBind(oPC, nToken, "chbx_no_monster_check_check", JsonBool(nValue));
        NuiSetBindWatch(oPC, nToken, "chbx_no_monster_check_check", TRUE);
        sText = "  Turns on/off checks for nearby monsters.";
        NuiSetBind(oPC, nToken, "chbx_no_monster_check_tooltip", JsonString(sText));
    }
    // Create buttons with spells listed.
    int nSpell, nClass, nLevel, nMetamagic, nDomain;
    string sName, sTargetName, sResRef;
    nCntr = 0;
    nIndex = 0;
    while(nCntr <= BUFF_MAX_SPELLS)
    {
        jSpell = JsonArrayGet(jSpells, nCntr);
        if(JsonGetType(jSpell) != JSON_TYPE_NULL)
        {
            nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
            nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
            nLevel = JsonGetInt(JsonArrayGet(jSpell, 2));
            nMetamagic = JsonGetInt(JsonArrayGet(jSpell, 3));
            nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
            sTargetName = JsonGetString(JsonArrayGet(jSpell, 5));
            sResRef = Get2DAString("spells", "IconResRef", nSpell);
            sName = "  " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            sName += " (" + GetStringByStrRef(StringToInt(Get2DAString("classes", "Short", nClass)));
            sName += " / " + IntToString (nLevel);
            if(nMetamagic > 0)
            {
                if(nMetamagic == METAMAGIC_EMPOWER) sName += " / Empowered";
                else if(nMetamagic == METAMAGIC_EXTEND) sName += " / Extended";
                else if(nMetamagic == METAMAGIC_MAXIMIZE) sName += " / Maximized";
                else if(nMetamagic == METAMAGIC_QUICKEN) sName += " / Quickened";
                else if(nMetamagic == METAMAGIC_SILENT) sName += " / Silent";
                else if(nMetamagic == METAMAGIC_STILL) sName += " / Still";
            }
            if(nDomain > 0) sName += " / Domain";
            sName += ") " + sTargetName;
            sIndex = IntToString(nIndex++);
            NuiSetBind(oPC, nToken, "btn_spell_" + sIndex + "_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_spell_" + sIndex + "_image", JsonString(sResRef));
            NuiSetBind(oPC, nToken, "btn_spell_" + sIndex + "_tooltip", JsonString(sName));
        }
        nCntr++;
    }
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_buffing"));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Quick Buff"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("dm_appear"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
    int bWidgetOn = JsonGetInt(JsonArrayGet(jMenuData, 3));
    if(bWidgetOn)
    {
        PopupWidgetBuffGUIPanel(oPC);
        ai_SendMessages("Buffing widget has been created.", AI_COLOR_YELLOW, oPC);
    }
    return TRUE;
}
void CreateBuffDataTable(object oPlayer)
{
    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "CREATE TABLE IF NOT EXISTS BUFF_TABLE (" +
        "name           TEXT,  " +
        "tag            TEXT, " +
        "spells         TEXT, " +
        "PRIMARY KEY(name, tag));");
    SqlStep(sql);
}
void CheckBuffDataAndInitialize(object oPlayer, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
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
        sQuery = "INSERT INTO BUFF_TABLE(name, tag, spells) " +
                 "VALUES (@name, @tag, @spells);";
        sql = SqlPrepareQueryObject(oPlayer, sQuery);
        SqlBindString(sql, "@name", sName);
        SqlBindString(sql, "@tag", sTag);
        SqlBindJson(sql, "@spells", JsonArray());
        SqlStep(sql);
    }
}
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    SqlStep(sql);
}
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if(SqlStep(sql)) return SqlGetString(sql, 0);
    else return "";
}
void SetBuffDatabaseJson (object oPlayer, string sDataField, json jData, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson(sql, "@data", jData);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    SqlStep(sql);
}
json GetBuffDatabaseJson(object oPlayer, string sDataField, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if(SqlStep(sql)) return SqlGetJson(sql, 0);
    else return JsonArray();
}
void PopupWidgetBuffGUIPanel(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // Row 1 (buttons)**********************************************************
    json jRow = JsonArray();
    CreateButtonImage(jRow, "ir_level1", "btn_one", 30.0f, 30.0f, 0.0);
    CreateButtonImage(jRow, "ir_level2", "btn_two", 30.0f, 30.0f, 0.0);
    CreateButtonImage(jRow, "ir_level3", "btn_three", 30.0f, 30.0f, 0.0);
    CreateButtonImage(jRow, "ir_level4", "btn_four", 30.0f, 30.0f, 0.0);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    json jWidget = GetBuffDatabaseJson(oPC, "spells", "menudata");
    int bAIBuffWidgetLock = JsonGetInt(JsonArrayGet(jWidget, 4));
    // Get the window location to restore it from the database.
    float fX = JsonGetFloat(JsonArrayGet(jWidget, 5));
    float fY = JsonGetFloat(JsonArrayGet(jWidget, 6));
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
    if(bAIBuffWidgetLock) nToken = SetWindow(oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 160.0, 62.0, FALSE, FALSE, FALSE, TRUE, FALSE, "pe_buffing");
    else nToken = SetWindow(oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 160.0, 95.0, FALSE, FALSE, FALSE, TRUE, TRUE, "pe_buffing");
    // Set event watches for window inspector and save window location.
    //NuiSetBindWatch(oPC, nToken, "collapsed", TRUE);
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    //NuiSetBind (oPC, nToken, "btn_one", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_one_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_two", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_two_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_three", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_three_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_four", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_four_event", JsonBool(TRUE));
}

