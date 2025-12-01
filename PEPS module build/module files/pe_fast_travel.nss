/*//////////////////////////////////////////////////////////////////////////////
 Script Name: pe_fast_travel
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    PEPS Plugin to allow fast travel.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
const string FAST_TRAVEL_DATABASE = "philos_fasttravel_db";
const string FAST_TRAVEL_TABLE = "FAST_TRAVEL_TABLE";
void PopUpYesNoPanel(object oPC, string sTitle, string sMessage, float fTextBoxX, float fTextBoxY, string sSlot);
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
void RemoveFastTravelDb(string sSlot, string sModuleName = "")
{
    if(sModuleName == "") sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "DELETE FROM " + FAST_TRAVEL_TABLE + " WHERE " +
                    "modulename = @modulename AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@modulename", sModuleName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
void SetFastTravelDbString(string sDataField, string sData, string sSlot, string sModuleName = "")
{
    if(sModuleName == "") sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "UPDATE " + FAST_TRAVEL_TABLE + " SET " + sDataField + " = @data WHERE " +
                    "modulename = @modulename AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@modulename", sModuleName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
void SetFastTravelDbJson(string sDataField, json jData, string sSlot, string sModuleName = "")
{
    if(sModuleName == "") sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
    string sQuery = "UPDATE " + FAST_TRAVEL_TABLE + " SET " + sDataField +
                    " = @data WHERE modulename = @modulename AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString(sql, "@modulename", sModuleName);
    SqlBindString (sql, "@slot", sSlot);
    SqlStep (sql);
}
json LocationToJson (location lLocation)
{
    object oArea = GetAreaFromLocation(lLocation);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fFacing = GetFacingFromLocation(lLocation);
    json jLocation = JsonArray();
    jLocation = JsonArrayInsert(jLocation, JsonString(GetTag (oArea)));
    jLocation = JsonArrayInsert(jLocation, JsonFloat(vPosition.x));
    jLocation = JsonArrayInsert(jLocation, JsonFloat(vPosition.y));
    jLocation = JsonArrayInsert(jLocation, JsonFloat(vPosition.z));
    return JsonArrayInsert(jLocation, JsonFloat(fFacing));
}
location JsonToLocation(json jLocation)
{
    object oArea = GetObjectByTag(JsonGetString(JsonArrayGet(jLocation, 0)));
    float fX = JsonGetFloat(JsonArrayGet(jLocation, 1));
    float fY = JsonGetFloat(JsonArrayGet(jLocation, 2));
    float fZ = JsonGetFloat(JsonArrayGet(jLocation, 3));
    vector vPosition = Vector(fX, fY, fZ);
    float fFacing = JsonGetFloat(JsonArrayGet(jLocation, 4));
    return Location(oArea, vPosition, fFacing);
}
void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken  = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem  = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nToken);
    //**********************************************************************
    //SendMessageToPC(oPC, "sEvent: " + sEvent + " sElem: " + sElem);
    if(sWndId == "pi_fast_travel")
    {
        // Watch to see if the window moves and save.
        if(sEvent == "watch")
        {
            if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
            if(sElem == "window_geometry")
            {
                json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
                json jLocation = GetFastTravelDbJson("location", "0", "window_information");
                if(JsonGetType(jLocation) == JSON_TYPE_NULL) jLocation = JsonObject();
                SetFastTravelDbJson("location", jGeometry, "0", "window_information");
            }
            else if(sElem == "chkbx_close_check")
            {
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                SetFastTravelDbString("areaname", IntToString(bCheck), "0", "window_information");
            }
        }
        else if(sEvent == "click")
        {
            if(sElem == "btn_save")
            {
                int nSlot = 1;
                string sSlot = "1";
                string sAreaName = GetFastTravelDbString("areaname", "1");
                while(sAreaName != "")
                {
                    sSlot = IntToString(++nSlot);
                    sAreaName = GetFastTravelDbString("areaname", sSlot);
                }
                string sIndex = IntToString(nIndex);
                json jLocation = LocationToJson(GetLocation(oPC));
                CheckFastTravelDataAndInitialize(sSlot);
                sAreaName = GetName(GetArea(oPC));
                SetFastTravelDbString("areaname", sAreaName, sSlot);
                SetFastTravelDbJson("location", jLocation, sSlot);
                ai_SendMessages(sAreaName + " has been added to the fast travel widget.", AI_COLOR_GREEN, oPC);
                ExecuteScript("pi_fast_travel", oPC);
            }
            else if(sElem == "btn_delete_all")
            {
                PopUpYesNoPanel(oPC, "Clear all Fast Travel Locations?",
                    "Do you want to delete fast travel saves for all locations?", 500.0, 25.0, "0");
            }
            if(sElem == "btn_area")
            {
                json jSlots = NuiGetUserData(oPC, nToken);
                string sSlot = JsonGetString(JsonArrayGet(jSlots, nIndex));
                json jLocation = GetFastTravelDbJson("location", sSlot);
                location lLocation = JsonToLocation(jLocation);
                AssignCommand(oPC, JumpToLocation(lLocation));
                string sAreaName = GetFastTravelDbString("areaname", sSlot);
                ai_SendMessages("You have jumped to " + sAreaName + ".", AI_COLOR_GREEN, oPC);
                int bCheck = StringToInt(GetFastTravelDbString("areaname", "0", "window_information"));
                if(bCheck) NuiDestroy(oPC, nToken);
            }
            else if(sElem == "btn_delete_area")
            {
                json jSlots = NuiGetUserData(oPC, nToken);
                string sSlot = JsonGetString(JsonArrayGet(jSlots, nIndex));
                string sAreaName = GetFastTravelDbString("areaname", sSlot);
                PopUpYesNoPanel(oPC, "Delete Fast Travel Location?",
                    "Do you want to delete fast travel save for " + sAreaName + "?", 700.0, 25.0, sSlot);
            }
        }
    }
    else if(sWndId == "plyesnowin")
    {
        if (sEvent == "click")
        {
            if (sElem == "btn_no")
            {
                NuiDestroy(oPC, nToken);
                return;
            }
            if (sElem == "btn_yes")
            {
                json jSlot = NuiGetUserData(oPC, nToken);
                string sSlot = JsonGetString(jSlot);
                if(sSlot == "0")
                {
                    // Get the saved locations for this module.
                    string sAreaName;
                    string sModuleName = ai_RemoveIllegalCharacters(GetModuleName());
                    string sQuery = "SELECT areaname, slot FROM " + FAST_TRAVEL_TABLE + " WHERE " +
                                    "modulename = @modulename;";
                    sqlquery sql = SqlPrepareQueryCampaign(FAST_TRAVEL_DATABASE, sQuery);
                    SqlBindString(sql, "@modulename", sModuleName);
                    if(SqlStep(sql)) sAreaName = SqlGetString(sql, 0);
                    else sAreaName = "";
                    while(sAreaName != "")
                    {
                        sSlot = SqlGetString(sql, 1);
                        RemoveFastTravelDb(sSlot, sModuleName);
                        if(SqlStep(sql)) sAreaName = SqlGetString(sql, 0);
                        else sAreaName = "";
                    }
                    ai_SendMessages("All area locations have been removed from the fast travel widget.", AI_COLOR_RED, oPC);
                }
                else
                {
                    string sAreaName = GetFastTravelDbString("areaname", sSlot);
                    RemoveFastTravelDb(sSlot);
                    ai_SendMessages(sAreaName + " has been removed from the fast travel widget.", AI_COLOR_RED, oPC);
                }
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_fast_travel", oPC);
            }
        }
    }
}
void PopUpYesNoPanel (object oPC, string sTitle, string sMessage, float fTextBoxX, float fTextBoxY, string sSlot)
{
    // Row 1 (Message)********************************************************** 45
    json jRow = CreateTextBox(JsonArray (), "message_text", fTextBoxX, fTextBoxY, TRUE, NUI_SCROLLBARS_NONE);
    // Add the row to the column.
    json jCol = JsonArrayInsert(JsonArray (), NuiRow(jRow));
    // Row 2 (buttons)********************************************************** 153
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer ());
    jRow = CreateButton(jRow, "Yes", "btn_yes", 50.0f, 25.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer ());
    jRow = CreateButton(jRow, "No", "btn_no", 50.0f, 25.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "plyesnowin", sTitle, -1.0, -1.0, fTextBoxX + 24.0, fTextBoxY + 90, FALSE, FALSE, FALSE, FALSE, TRUE, "pe_fast_travel");
    // Set the buttons to show events to 0e_window.
    NuiSetBind(oPC, nToken, "message_text", JsonString(sMessage));
    NuiSetBind(oPC, nToken, "message_text_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_yes_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_no_event", JsonBool(TRUE));
    json jSlot = JsonString(sSlot);
    NuiSetUserData(oPC, nToken, jSlot);
}


