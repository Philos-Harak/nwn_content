/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_fast_travel
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Plugin for allowing a player to save and teleport to locations quickly.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_player_target"
const string FAST_TRAVEL_DATABASE = "philos_fasttravel_db";
const string FAST_TRAVEL_TABLE = "FAST_TRAVEL_TABLE";
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void CreateFastTravelDataTable ()
{
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE,
        "CREATE TABLE IF NOT EXISTS " + FAST_TRAVEL_TABLE + " (" +
        "modulename    TEXT, " +
        "slot          TEXT, " +
        "areaname      TEXT, " +
        "location      TEXT, " +
        "PRIMARY KEY(modulename, slot));");
    SqlStep (sql);
}
void CheckFastTravelDataAndInitialize(string sSlot, string sModuleName = "")
{
    if(sModuleName == "") sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@tableName", FAST_TRAVEL_TABLE);
    if(!SqlStep (sql)) CreateFastTravelDataTable();
    sQuery = "SELECT slot FROM " + FAST_TRAVEL_TABLE + " WHERE modulename = @modulename AND slot = @slot;";
    sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@modulename", sModuleName);
    SqlBindString(sql, "@slot", sSlot);
    //SendMessageToPC(GetFirstPC(), " sModuleName: " + sModuleName + " sSlot: " + sSlot);
    if(!SqlStep(sql))
    {
        sQuery = "INSERT INTO " + FAST_TRAVEL_TABLE + "(modulename, slot, areaname, " +
        "location) VALUES (@modulename, @slot, @areaname, @location);";
        sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
        SqlBindString(sql, "@modulename", sModuleName);
        SqlBindString(sql, "@slot", sSlot);
        SqlBindString(sql, "@areaname", "");
        SqlBindString(sql, "@location", "");
        SqlStep(sql);
    }
}
string GetFastTravelDbString(string sDataField, string sSlot, string sModuleName = "")
{
    if(sModuleName == "") sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "SELECT " + sDataField + " FROM " + FAST_TRAVEL_TABLE + " WHERE " +
                    "modulename = @modulename AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@modulename", sModuleName);
    SqlBindString(sql, "@slot", sSlot);
    if(SqlStep (sql)) return SqlGetString(sql, 0);
    else return "";
}
json GetFastTravelDbJson(string sDataField, string sSlot, string sModuleName = "")
{
    if(sModuleName == "") sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "SELECT " + sDataField + " FROM " + FAST_TRAVEL_TABLE + " WHERE " +
                    "modulename = @modulename AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@modulename", sModuleName);
    SqlBindString (sql, "@slot", sSlot);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    // Set window to not save until it has been created.
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt(oPC, AI_NO_NUI_SAVE));
    // Row 1 (Module Name)****************************************************** 414 / 433
    string sModuleName = GetModuleName();
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, sModuleName, "txt_module_name", 375.0, 15.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 1 (Buttons)********************************************************** 414 / 433
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Save Location", "btn_save", 150.0, 25.0);
    jRow = CreateButton(jRow, "Delete All", "btn_delete_all", 150.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 2 (Close option)***************************************************** 414 / 433
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateCheckBox(jRow, "Close window after traveling", "chkbx_close", 210.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Fast Travel List)************************************************* 414 / 433
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("area_name"));
    jButton = NuiId(jButton, "btn_area");
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 335.0, FALSE));
    json jDelete = NuiButtonImage(JsonString("ir_tmp_spawn"));
    jDelete = NuiId(jDelete, "btn_delete_area");
    jDelete = NuiTooltip(jDelete, NuiBind("tooltip_delete"));
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jDelete, 30.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("area_button"), 30.0), 300.0));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    CheckFastTravelDataAndInitialize("0", "window_information");
    json jLocation = GetFastTravelDbJson("location", "0", "window_information");
    if(JsonGetType(jLocation) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocation, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocation, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "pi_fast_travel", "Fast Travel Menu.",
                            fX, fY, 400.0f, 475.0f, FALSE, TRUE, TRUE, FALSE, TRUE, "pe_fast_travel");
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_delete_all_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chkbx_close_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "chkbx_close_check", TRUE);
    int bCheck = StringToInt(GetFastTravelDbString("areaname", "0", "window_information"));
    NuiSetBind(oPC, nToken, "chkbx_close_check", JsonInt(bCheck));
    // Fill in button text for teleporting.
    string sAreaName, sSlot;
    json jAreaName = JsonArray(), jAreaSelected = JsonArray(), jSlots = JsonArray();
    json jBtnDelete = JsonArray(), jBtnDeleteTooltip = JsonArray();
    // Get the saved locations for this module.
    sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "SELECT slot, areaname FROM " + FAST_TRAVEL_TABLE + " WHERE " +
                    "modulename = @modulename;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@modulename", sModuleName);
    if(SqlStep(sql)) sSlot = SqlGetString(sql, 0);
    while(sSlot != "")
    {
        sAreaName = SqlGetString(sql, 1);
        if(sAreaName != "")
        {
            jAreaName = JsonArrayInsert(jAreaName, JsonString(sAreaName));
            jBtnDeleteTooltip = JsonArrayInsert(jBtnDeleteTooltip, JsonString("  Delete this location save"));
            jSlots = JsonArrayInsert(jSlots, JsonString(sSlot));
        }
        if(SqlStep(sql)) sSlot = SqlGetString(sql, 0);
        else sSlot = "";
    }
    NuiSetBind(oPC, nToken, "area_name", jAreaName);
    NuiSetBind(oPC, nToken, "tooltip_delete", jBtnDeleteTooltip);
    NuiSetBind(oPC, nToken, "area_button", jAreaName);
    NuiSetUserData(oPC, nToken, jSlots);
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_fast_travel"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Fast Travel Menu"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("ir_flee"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

