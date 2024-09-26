/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pinc_henchman
////////////////////////////////////////////////////////////////////////////////
 Include file for Henchman plug in scripts for Philos Module Extentions.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
// Creates the table and initializes if it needs to.
void CheckHenchmanDataAndInitialize(string sSlot);
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetHenchmanDbString(string sDataField, string sData, string sSlot);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetHenchmanDbString(string sDataField, string sSlot);
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetHenchmanDbJson(object oPlayer, string sDataField, json jData, string sSlot);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetHenchmanDbJson(object oPlayer, string sDataField, string sSlot);
// sSlot is the slot to define this object in the database for this Slot## (# Party button and #1-6).
// oHenchman is the PC/Henchman to be saved.
void SetHenchmanDbObject(object oHenchman, string sSlot);
// sSlot is the slot to define this object in the database for this Slot## (# Party button and #1-6).
// lLocationToSpawn will spawn the object at that location.
object GetHenchmanDbObject(location lLocationToSpawn, string sSlot);
// Will load all Henchman from the current party list.
void LoadAllHenchman(object oPC);
// Returns TRUE if the henchman with sName can join.
int GetJoinButtonActive(object oPC, string sName);

void CreateHenchmanDataTable ()
{
    //ai_Debug("pi_buffing", "120", Creating a Henchman Table for Philos_NPC_DB.");
    sqlquery sql = SqlPrepareQueryCampaign("Philos_Henchman_DB",
        "CREATE TABLE IF NOT EXISTS HENCHMAN_TABLE (" +
        "slot          TEXT, " +
        "name          TEXT, " +
        "image         TEXT, " +
        "stats         TEXT, " +
        "classes       TEXT, " +
        "henchman      TEXT, " +
        "data          TEXT, " +
        "PRIMARY KEY(slot));");
    SqlStep (sql);
}
void CheckHenchmanDataAndInitialize(string sSlot)
{
    //ai_Debug("pi_buffing", "131", "Checking Henchman Data.");
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
    SqlBindString(sql, "@tableName", "HENCHMAN_TABLE");
    if(!SqlStep (sql)) CreateHenchmanDataTable();
    sQuery = "SELECT slot FROM HENCHMAN_TABLE Where slot = @slot;";
    sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
    SqlBindString(sql, "@slot", sSlot);
    if(!SqlStep(sql))
    {
        //ai_Debug("pi_buffing", "167", Initializing Henchman Data.");
        sQuery = "INSERT INTO HENCHMAN_TABLE(slot, name, image, stats, classes " +
        ", henchman, data) VALUES (@slot, @name, @image, @stats, @classes, @henchman, @data);";
        sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
        SqlBindString(sql, "@slot", sSlot);
        SqlBindString(sql, "@name", "");
        SqlBindString(sql, "@image", "");
        SqlBindString(sql, "@stats", "");
        SqlBindString(sql, "@classes", "");
        SqlBindJson(sql, "@henchman", JsonObject());
        SqlBindJson(sql, "@data", JsonArray());
        SqlStep(sql);
    }
}
void SetHenchmanDbString(string sDataField, string sData, string sSlot)
{
    string sQuery = "UPDATE HENCHMAN_TABLE SET " + sDataField + " = @data WHERE slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
string GetHenchmanDbString(string sDataField, string sSlot)
{
    string sQuery = "SELECT " + sDataField + " FROM HENCHMAN_TABLE WHERE slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
    SqlBindString(sql, "@slot", sSlot);
    if(SqlStep (sql)) return SqlGetString(sql, 0);
    else return "";
}
void SetHenchmanDbJson(object oPlayer, string sDataField, json jData, string sSlot)
{
    string sQuery = "UPDATE HENCHMAN_TABLE SET " + sDataField +
                    " = @data WHERE slot = @slot;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@slot", sSlot);
    SqlStep (sql);
}
json GetHenchmanDbJson(object oPlayer, string sDataField, string sSlot)
{
    string sQuery = "SELECT " + sDataField + " FROM HENCHMAN_TABLE WHERE slot = @slot;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@slot", sSlot);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
void SetHenchmanDbObject(object oHenchman, string sSlot)
{
    string sQuery = "UPDATE HENCHMAN_TABLE SET henchman = @henchman WHERE slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
    SqlBindObject(sql, "@henchman", oHenchman);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
object GetHenchmanDbObject(location lLocationToSpawn, string sSlot)
{
    string sQuery = "SELECT henchman FROM HENCHMAN_TABLE WHERE slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign("Philos_Henchman_DB", sQuery);
    SqlBindString (sql, "@slot", sSlot);
    ai_Debug("pe_henchman", "262", "sSlot: " + sSlot);
    if (SqlStep (sql)) return SqlGetObject(sql, 0, lLocationToSpawn, OBJECT_INVALID, TRUE);
    return OBJECT_INVALID;
}
int GetJoinButtonActive(object oPC, string sName)
{
    if(sName == GetName(oPC)) return FALSE;
    // Look for a free henchman slot, and if this henchman is already joined!
    int nIndex = 1;
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(oHenchman != OBJECT_INVALID)
    {
        if(GetName(oHenchman) == sName) return FALSE;
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }
    return TRUE;
}

