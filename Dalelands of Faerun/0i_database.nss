/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 ScriptName: 0i_dbcalls
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Handles all database functions for the server.
 This script is using the in game database to manage persistance.

 Server data is saved into the SERVER_DATABASE, SERVER_TABLE see 0i_constants.
 Player data is saved into the SERVER_DATABASE, PLAYER_TABLE see 0i_constants.
 DM data is saved into the SERVER_DATABASE, DM_TABLE see 0i_constants.
 NPC data is saved into the SERVER_DATABASE, NPC_TABLE see 0i_constants.
 Object data is saved into the SERVER_DATABASE, OBJECT_TABLE see 0i_constants.
 Adventure data is saved into the SERVER_DATABASE, ADVENTURE_TABLE see 0i_constants.
 Area data is saved into the SERVER_DATABASE, AREA_TABLE see 0i_constants.
 Adventure Object data is saved into the SERVER_DATABASE, ADV_OBJ_TABLE see 0i_constants.

 Character data is saved onto the character object with CHARACTER_TABLE.
    summons: 0)Henchman 1 - 9)Summon Monster 1-9 10)Create Undead 11)Create Greater Undead
            12)Lesser Planar Portal 13)Planar Portal 14)Greater Planar Portal
            15)Gate 16-19)Empty 20)Minor Creation
    teleport: 0)Altar respawn point 1)Preset Quick teleport 2-9)Preset locations.
    appearance: 0)Eye glow 1)Legs 2)Claws 3) Sleep animation
    polymorph: 0) Empty 1) Polymorph Self 2) Spiderform
 DM data:
    options: 0) Get Alerts 1) Alert Discord 2)
 Quest data is saved onto the character object with QUEST_TABLE.
 Pin data is saved onto the character object with PIN_Table.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_server_const"
#include "nwnx_object"
#include "nwnx_rename"
#include "0i_s_message"
// Used to fix any database changes on characters/players.
void FixCharacterDatabase (object oPC);

void IncreaseServerDatabaseCounter (object oPlayer, string sTableName, string sDataField);

void IncreaseObjectDatabaseCounter (object oPlayer, string sTableName, string sDataField);

void DecreaseServerDatabaseCounter (object oPlayer, string sTableName, string sDataField);

void DecreaseObjectDatabaseCounter (object oPlayer, string sTableName, string sDataField);

// Defined sTableName constants: *_TABLE.
void CheckServerDataTableAndCreateTable (string sTableName);

// Defined sTableName constants: *_TABLE.
// Returns TRUE if data is initialized, false if the data alread exists.
int CheckServerDataAndInitialize(object oObject, string sTableName, string sTag = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
void SetServerDatabaseInt(object oObject, string sTableName, string sDataField, int nData, string sTag = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
int GetServerDatabaseInt(object oObject, string sTableName, string sDataField, string sTag = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// fData is the float data to be saved.
void SetServerDatabaseFloat(object oObject, string sTableName, string sDataField, float fData, string sTag = "");

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
float GetServerDatabaseFloat(object oObject, string sTableName, string sDataField, string sTag = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetServerDatabaseString(object oObject, string sTableName, string sDataField, string sData, string sTag = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetServerDatabaseString(object oObject, string sTableName, string sDataField, string sTag = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetServerDatabaseJson(object oObject, string sTableName, string sDataField, json jData, string sTag = "");

// oObject is the character/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetServerDatabaseJson(object oObject, string sTableName, string sDataField, string sTag = "");

// oObject is the character/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// oData is the object data to be saved.
void SetServerDatabaseObject(object oObject, string sTableName, object oData, string sTag);

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// lLocationToSpawn will spawn the object at that location.
// oInventory will spawn the object in that objects inventory.
object GetServerDatabaseObject(object oObject, string sTableName, location lLocationToSpawn, object oInventory = OBJECT_INVALID, string sTag = "");

// Returns the Status of oPC based on the CDKey being used.
int GetServerDatabaseStatusByCDKey(object oPC);

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
void DeleteServerDatabaseObject(object oObject, string sTableName, string sTag);

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE, DM_TABLE, NPC_TABLE.
void DeleteServerDatabase(object oObject, string sTableName);

// Object must be a player character.
// Defined sTableName constants: *_TABLE.
void CheckObjectDataTableAndCreateTable(object oObject, string sTableName);

// Defined sTableName constants: *_TABLE.
// Must add a quest name if initializing a quest table.
void CheckObjectDataAndInitialize(object oObject, string sTableName, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseInt(object oObject, string sTableName, string sDataField, int iData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a integer of the data stored.
int GetObjectDatabaseInt(object oObject, string sTableName, string sDataField, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseString(object oObject, string sTableName, string sDataField, string sData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a string of the data stored.
string GetObjectDatabaseString(object oObject, string sTableName, string sDataField, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// sDataName is the name of the quest if we are saveing a quest.
// jData is the json data to be saved.
void SetObjectDatabaseJson(object oObject, string sTableName, string sDataField, json jData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns the json of the data stored.
json GetObjectDatabaseJson(object oObject, string sTableName, string sDataField, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the float data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseFloat(object oObject, string sTableName, string sDataField, float fData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a float of the data stored.
float GetObjectDatabaseFloat(object oObject, string sTableName, string sDataField, string sDataName = "");

// Saves a characters pin to the character (object) database.
void SavePinData(object oPC, string sTableName, string sDataName, string sentry, float fxpos, float fypos, string sareatag);

// oObject is the player the data is for.
// sTable is the table to use: *_TABLE.
// sDataName is the name of the data to delete.
void DeleteObjectDatabaseName(object oObject, string sTableName, string sDataName = "");

// oObject is the player the data is for.
// sTable is the table to use: *_TABLE.
// sDataName is the name of the quest if we are saveing a quest.
void DeleteObjectDatabase(object oObject, string sTableName);

// Used to fix any database changes on characters/players.
void FixCharacterDatabase(object oPC)
{
    // Fix Player database "teleport" change from my text arrays to json.
    // so we can add locations to it. 06/13/23
    json jTeleportArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
    if (JsonGetType (jTeleportArray) == JSON_TYPE_NULL)
    {
        string sTArray = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "teleport");
        string sWP = GetStringArray (sTArray, 0);
        json jTArray = CreateJsonArrayWithString ("", 21);
        jTArray = JsonArraySet (jTArray, 0, JsonString (sWP));
        SetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport", jTArray);
    }
}

void IncreaseServerDatabaseCounter (object oPlayer, string sTableName, string sDataField)
{
    int iData = GetServerDatabaseInt (oPlayer, sTableName, sDataField);
    iData ++;
    SetServerDatabaseInt (oPlayer, sTableName, sDataField, iData);
}

void IncreaseObjectDatabaseCounter (object oPlayer, string sTableName, string sDataField)
{
    int iData = GetObjectDatabaseInt (oPlayer, sTableName, sDataField);
    iData ++;
    SetObjectDatabaseInt (oPlayer, sTableName, sDataField, iData);
}

void DecreaseServerDatabaseCounter (object oPlayer, string sTableName, string sDataField)
{
    int iData = GetServerDatabaseInt (oPlayer, sTableName, sDataField);
    iData --;
    SetServerDatabaseInt (oPlayer, sTableName, sDataField, iData);
}

void DecreaseObjectDatabaseCounter (object oPlayer, string sTableName, string sDataField)
{
    int iData = GetObjectDatabaseInt (oPlayer, sTableName, sDataField);
    iData --;
    SetObjectDatabaseInt (oPlayer, sTableName, sDataField, iData);
}

// Defined sTableName constants: *_TABLE.
void CreateServerDataTable (string sTableName)
{
    if (sTableName == SERVER_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT, " +
            "tag            TEXT, " +
            "year           INTEGER, " +
            "month          INTEGER, " +
            "day            INTEGER, " +
            "hour           INTEGER, " +
            "password       INTEGER, " +
            "startlevel     INTEGER, " +
            "restrictrest   INTEGER, " +
            "xpslider       INTEGER, " +
            "treasureslider INTEGER, " +
            "villainchance  INTEGER, " +
            "uniquechance   INTEGER, " +
            "temperature    INTEGER, " +
            "precipitation  INTEGER, " +
            "storm          INTEGER, " +
            "windx          FLOAT, " +
            "windy          FLOAT, " +
            "windz          FLOAT, " +
            "windmagnitude  FLOAT, " +
            "windyaw        FLOAT, " +
            "windpitch      FLOAT, " +
            "PRIMARY KEY(name, tag));");
        SqlStep (sql);
    }
    else if (sTableName == PLAYER_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name            TEXT, " +
            "password        TEXT, " +
            "status          INTEGER,  " +
            "watched         INTEGER,  " +
            "characters      INTEGER,  " +
            "highestlevel    INTEGER,  " +
            "rests           INTEGER,  " +
            "bleeds          INTEGER,  " +
            "respawns        INTEGER,  " +
            "deaths          INTEGER,  " +
            "kills           INTEGER,  " +
            "henchmenkills   INTEGER,  " +
            "familiarkills   INTEGER,  " +
            "companionkills  INTEGER,  " +
            "summonskills    INTEGER,  " +
            "sidequests      INTEGER,  " +
            "mainquests      INTEGER,  " +
            "cynosurejumps   INTEGER,  " +
            "dmlogins        INTEGER,  " +
            "logins          INTEGER,  " +
            "lastlogin       INTEGER, " +
            "plcreditwin     TEXT, " +
            "pldicewin       TEXT, " +
            "plbugwin        TEXT, " +
            "plcraftwin      TEXT, " +
            "playerwindows   TEXT, " +
            "ploptionwin     TEXT, " +
            "plstatswin      TEXT, " +
            "pcdescwin       TEXT, " +
            "pcmagicwin      TEXT, " +
            "pclangwin       TEXT, " +
            "dmserverwin     TEXT, " +
            "dmadventurewin  TEXT, " +
            "dmareawin       TEXT, " +
            "dmobjectwin     TEXT, " +
            "dmcreaturewin   TEXT, " +
            "dmnpcwin        TEXT, " +
            "dminventorywin  TEXT, " +
            "dmmainquestswin TEXT, " +
            "dmquestswin     TEXT, " +
            "widgetbuffwin   TEXT, " +
            "creationdate    INTEGER, " +
            "publiccdkey     TEXT, " +
            "lastipaddress   TEXT, " +
            "PRIMARY KEY(name, publiccdkey));");
        SqlStep (sql);
    }
    else if (sTableName == OBJECT_TABLE || sTableName == ADV_OBJ_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name          TEXT, " +
            "playername    TEXT, " +
            "tag           TEXT, " +
            "location      TEXT, " +
            "object        TEXT, " +
            "objecttag     TEXT, " +
            "vartype0      INTEGER, " +
            "varname0      TEXT, " +
            "var0          TEXT, " +
            "vartype1      INTEGER, " +
            "varname1      TEXT, " +
            "var1          TEXT, " +
            "vartype2      INTEGER, " +
            "varname2      TEXT, " +
            "var2          TEXT, " +
            "vartype3      INTEGER, " +
            "varname3      TEXT, " +
            "var3          TEXT, " +
            "vartype4      INTEGER, " +
            "varname4      TEXT, " +
            "var4          TEXT, " +
            "vartype5      INTEGER, " +
            "varname5      TEXT, " +
            "var5         TEXT, " +
            "vartype6      INTEGER, " +
            "varname6      TEXT, " +
            "var6          TEXT, " +
            "vartype7      INTEGER, " +
            "varname7      TEXT, " +
            "var7          TEXT, " +
            "vartype8      INTEGER, " +
            "varname8      TEXT, " +
            "var8          TEXT, " +
            "vartype9      INTEGER, " +
            "varname9      TEXT, " +
            "var9          TEXT, " +
            "creationdate  INTEGER, " +
            "PRIMARY KEY(name, tag));");
        SqlStep (sql);
    }
    else if (sTableName == DM_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name            TEXT, " +
            "location        TEXT,  " +
            "options         TEXT,  " +
            "languageusing   INTEGER,  " +
            "slot1           TEXT,  " +
            "slot2           TEXT,  " +
            "slot3           TEXT,  " +
            "slot4           TEXT,  " +
            "slot5           TEXT,  " +
            "slot6           TEXT,  " +
            "slot7           TEXT,  " +
            "slot8           TEXT,  " +
            "slot9           TEXT,  " +
            "slot10          TEXT,  " +
            "PRIMARY KEY(name));");
        SqlStep (sql);
    }
    else if (sTableName == ADVENTURE_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT,  " +
            "tag            TEXT,  " +
            "startlevel     TEXT,  " +
            "restrictrest   INTEGER, " +
            "xpslider       INTEGER, " +
            "treasureslider INTEGER, " +
            "temperature    INTEGER, " +
            "precipitation  INTEGER, " +
            "storm          INTEGER, " +
            "windx          FLOAT, " +
            "windy          FLOAT, " +
            "windz          FLOAT, " +
            "windmagnitude  FLOAT, " +
            "windyaw        FLOAT, " +
            "windpitch      FLOAT, " +
            "PRIMARY KEY(name, tag));");
        SqlStep (sql);
    }
    else if (sTableName == AREA_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT,  " +
            "tag            TEXT,  " +
            "resref         TEXT,  " +
            "areaname       TEXT,  " +
            "areatag        TEXT,  " +
            "level          INTEGER,  " +
            "lootstate      INTEGER,  " +
            "xpstate        INTEGER,  " +
            "spellstate     INTEGER,  " +
            "areastate      INTEGER,  " +
            "populatestate  INTEGER,  " +
            "cleanstate     INTEGER,  " +
            "reststate      INTEGER,  " +
            "encchance      INTEGER,  " +
            "enctable       TEXT,  " +
            "animations     INTEGER,  " +
            "mainlight1     INTEGER,  " +
            "mainlight2     INTEGER,  " +
            "sourcelight1   INTEGER,  " +
            "sourcelight2   INTEGER,  " +
            "moonambient    INTEGER,  " +
            "moondiffuse    INTEGER,  " +
            "sunambient     INTEGER,  " +
            "sundiffuse     INTEGER,  " +
            "fogmooncolor   INTEGER,  " +
            "fogsuncolor    INTEGER,  " +
            "fogdistance    FLOAT,  " +
            "PRIMARY KEY(name, tag));");
        SqlStep (sql);
    }
    else if (sTableName == QUEST_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT,  " +
            "playername     TEXT,  " +
            "tag            TEXT,  " +
            "description    TEXT,  " +
            "quest          TEXT,  " +
            "strref         TEXT,  " +
            "plot           TEXT,  " +
            "start          TEXT,  " +
            "giver          TEXT,  " +
            "area           TEXT,  " +
            "npc            TEXT,  " +
            "villain        TEXT,  " +
            "creatures      TEXT,  " +
            "allies         TEXT,  " +
            "followers      TEXT,  " +
            "enemies        TEXT,  " +
            "giveitem       TEXT,  " +
            "item           TEXT,  " +
            "placeable      TEXT,  " +
            "fplaceable     TEXT,  " +
            "finish         TEXT,  " +
            "finisher       TEXT,  " +
            "rewards        TEXT,  " +
            "state          TEXT,  " +
            "PRIMARY KEY(name, tag));");
        SqlStep (sql);
    }
    else if (sTableName == BUFF_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT,  " +
            "tag            TEXT, " +
            "spells        TEXT, " +
            "PRIMARY KEY(name, tag));");
        SqlStep (sql);
    }
}

// Defined sTableName constants: *_TABLE.
void CheckServerDataTableAndCreateTable (string sTableName)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@tableName", sTableName);
    if (!SqlStep (sql)) CreateServerDataTable (sTableName);
}

void InitializeServerData (string sTableName)
{
    object oModule = GetModule ();
    string sName = GetName (oModule);
    string sTag = GetTag (oModule);
    string sQuery = "INSERT INTO " + sTableName + " (name, tag, year, month, day, " +
        "hour, password, startlevel, restrictrest, xpslider, treasureslider, villainchance, " +
        "uniquechance, temperature, precipitation, storm, windx, windy, windz, " +
        "windmagnitude, windyaw, windpitch) " +
        "VALUES (@name, @tag, @year, @month, @day, @hour, @password, @startlevel, @restrictrest, " +
        "@xpslider, @treasureslider, @villainchance, @uniquechance, @temperature, " +
        "@precipitation, @storm, @windx, @windy, @windz, @windmagnitude, @windyaw, @windpitch);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlBindInt (sql, "@year", STARTING_YEAR);
    SqlBindInt (sql, "@month", 1);
    SqlBindInt (sql, "@day", 1);
    SqlBindInt (sql, "@hour", 18);
    SqlBindInt (sql, "@password", 0);
    SqlBindInt (sql, "@startlevel", STARTING_CHARACTER_LEVEL);
    SqlBindInt (sql, "@restrictrest", RESTRICT_REST);
    SqlBindInt (sql, "@xpslider", STARTING_EXPERIENCE_SLIDER);
    SqlBindInt (sql, "@treasureslider", STARTING_TREASURE_SLIDER);
    SqlBindInt (sql, "@villainchance", STARTING_VILLAIN_CHANCE);
    SqlBindInt (sql, "@uniquechance", STARTING_UNIQUE_CHANCE);
    SqlBindInt (sql, "@temperature", 80);
    SqlBindInt (sql, "@precipitation", 0);
    SqlBindInt (sql, "@storm", 0);
    SqlBindFloat (sql, "@windx", 0.0f);
    SqlBindFloat (sql, "@windy", 0.0f);
    SqlBindFloat (sql, "@windz", 0.0f);
    SqlBindFloat (sql, "@windmagnitude", 0.0f);
    SqlBindFloat (sql, "@windyaw", 0.0f);
    SqlBindFloat (sql, "@windpitch", 0.0f);
    SqlStep (sql);
}

void InitializePlayerData (object oPlayer, string sTableName)
{
    string sName = GetPCPlayerName (oPlayer);
    string sQuery = "INSERT INTO " + sTableName + "(name, password, status, watched, " +
        "characters, highestlevel, rests, bleeds, respawns, deaths, kills, " +
        "henchmenkills, familiarkills, companionkills, summonskills, " +
        "sidequests, mainquests, cynosurejumps, dmlogins, logins, lastlogin, " +
        "plcreditwin, pldicewin, plbugwin, plcraftwin, playerwindows, ploptionwin, " +
        "plstatswin, pcdescwin, pcmagicwin, pclangwin, dmserverwin, dmadventurewin, " +
        "dmareawin, dmobjectwin, dmcreaturewin, dmnpcwin, dminventorywin, " +
        "dmmainquestswin, dmquestswin, widgetbuffwin, creationdate, publiccdkey, lastipaddress) " +
        "VALUES (@name, @password, @status, @watched, @characters, @highestlevel, @rests, " +
        "@bleeds, @respawns, @deaths, @kills, @henchmenkills, @familiarkills, " +
        "@companionkills, @summonskills, @sidequests, @mainquests, " +
        "@cynosurejumps, @dmlogins, @logins, @lastlogin, " +
        "@plcreditwin, @pldicewin, @plbugwin, @plcraftwin, @playerwindows, @ploptionwin, " +
        "@plstatswin, @pcdescwin, @pcmagicwin, @pclangwin, @dmserverwin, " +
        "@dmadventurewin, @dmareawin, @dmobjectwin, @dmcreaturewin, @dmnpcwin, " +
        "@dminventorywin, @dmmainquestswin, @dmquestswin, @widgetbuffwin, " +
        "@creationdate, @publiccdkey, @lastipaddress);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@password", "");
    SqlBindInt (sql, "@status", 0);
    SqlBindInt (sql, "@watched", 0);
    SqlBindInt (sql, "@characters", 0);
    SqlBindInt (sql, "@highestlevel", 1);
    SqlBindInt (sql, "@rests", 0);
    SqlBindInt (sql, "@bleeds", 0);
    SqlBindInt (sql, "@respawns", 0);
    SqlBindInt (sql, "@deaths", 0);
    SqlBindInt (sql, "@kills", 0);
    SqlBindInt (sql, "@henchmenkills", 0);
    SqlBindInt (sql, "@familiarkills", 0);
    SqlBindInt (sql, "@companionkills", 0);
    SqlBindInt (sql, "@summonskills", 0);
    SqlBindInt (sql, "@sidequests", 0);
    SqlBindInt (sql, "@mainquests", 0);
    SqlBindInt (sql, "@cynosurejumps", 0);
    SqlBindInt (sql, "@dmlogins", 0);
    SqlBindInt (sql, "@logins", 0);
    SqlBindInt (sql, "@lastlogin", 0);
    SqlBindString (sql, "@plcreditwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@pldicewin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@plbugwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@plcraftwin", ":0:-1.0:0.0:");
    SqlBindJson (sql, "@playerwindows", JsonObject());
    SqlBindString (sql, "@ploptionwin", ":0:-1.0:0.0:0:0:");
    SqlBindString (sql, "@plstatswin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@pcdescwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@pcmagicwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@pclangwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmserverwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmadventurewin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmareawin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmobjectwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmcreaturewin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmnpcwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dminventorywin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmmainquestswin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@dmquestswin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@widgetbuffwin", ":0:-1.0:0.0:");
    SqlBindString (sql, "@creationdate", "strftime('%m-%d-%Y (%H:%M)','now', '-5 hours')");
    SqlBindString (sql, "@publiccdkey", GetPCPublicCDKey (oPlayer));
    SqlBindString (sql, "@lastipaddress", "");
    SqlStep (sql);
}

void InitializeObjectData (object oPlayer, string sTableName, string sTag)
{
    string sName = GetName (oPlayer, TRUE);
    string sPlayerName = GetPCPlayerName (oPlayer);
    string sQuery = "INSERT INTO " + sTableName + "(name, playername, tag, location, " +
        "object, creationdate) VALUES (@name, @playername, @tag, @location, @object, " +
        "strftime('%m-%d-%Y (%H:%M)','now', '-5 hours'));";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@playername", sPlayerName);
    SqlBindString (sql, "@tag", sTag);
    SqlBindString (sql, "@location", "");
    SqlBindString (sql, "@object", "");
    SqlStep (sql);
}

void InitializeAdventureObjectData (object oPlayer, string sTableName, string sTag)
{
    string sName = GetName (oPlayer, TRUE);
    string sPlayerName = GetPCPlayerName (oPlayer);
    string sQuery = "INSERT INTO " + sTableName + "(name, playername, tag, location, " +
        "object, objecttag, vartype0, varname0, var0, vartype1, varname1, var1, vartype2, " +
        "varname2, var2, vartype3, varname3, var3, vartype4, varname4, var4, vartype5, " +
        "varname5, var5, vartype6, varname6, var6, vartype7, varname7, var7, vartype8, " +
        "varname8, var8, vartype9, varname9, var9, creationdate) VALUES (@name, " +
        "@playername, @tag, @location, @object, @objecttag, @vartype0, @varname0, " +
        "@var0, @vartype1, @varname1, @var1, @vartype2, @varname2, @var2, @vartype3, " +
        "@varname3, @var3, @vartype4, @varname4, @var4, @vartype5, @varname5, @var5, " +
        "@vartype6, @varname6, @var6, @vartype7, @varname7, @var7, @vartype8, @varname8, " +
        "@var8, @vartype9, @varname9, @var9, strftime('%m-%d-%Y (%H:%M)','now', '-5 hours'));";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@playername", sPlayerName);
    SqlBindString (sql, "@tag", sTag);
    SqlBindString (sql, "@location", "");
    SqlBindString (sql, "@object", "");
    SqlBindString (sql, "@objecttag", "");
    SqlBindInt (sql, "@vartype0", 0);
    SqlBindString (sql, "@varname0", "");
    SqlBindString (sql, "@var0", "");
    SqlBindInt (sql, "@vartype1", 0);
    SqlBindString (sql, "@varname1", "");
    SqlBindString (sql, "@var1", "");
    SqlBindInt (sql, "@vartype2", 0);
    SqlBindString (sql, "@varname2", "");
    SqlBindString (sql, "@var2", "");
    SqlBindInt (sql, "@vartype3", 0);
    SqlBindString (sql, "@varname3", "");
    SqlBindString (sql, "@var3", "");
    SqlBindInt (sql, "@vartype4", 0);
    SqlBindString (sql, "@varname4", "");
    SqlBindString (sql, "@var4", "");
    SqlBindInt (sql, "@vartype5", 0);
    SqlBindString (sql, "@varname5", "");
    SqlBindString (sql, "@var5", "");
    SqlBindInt (sql, "@vartype6", 0);
    SqlBindString (sql, "@varname6", "");
    SqlBindString (sql, "@var6", "");
    SqlBindInt (sql, "@vartype7", 0);
    SqlBindString (sql, "@varname7", "");
    SqlBindString (sql, "@var7", "");
    SqlBindInt (sql, "@vartype8", 0);
    SqlBindString (sql, "@varname8", "");
    SqlBindString (sql, "@var8", "");
    SqlBindInt (sql, "@vartype9", 0);
    SqlBindString (sql, "@varname9", "");
    SqlBindString (sql, "@var9", "");
    SqlStep (sql);
}

void InitializeDMData (object oPlayer, string sTableName)
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "INSERT INTO " + sTableName + "(name, location, options, " +
        "languageusing, slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, " +
        "slot9, slot10) VALUES (@name, @location, @options, @languageusing, " +
        "@slot1, @slot2, @slot3, @slot4, @slot5, @slot6, @slot7, @slot8, " +
        "@slot9, @slot10);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@location", "");
    SqlBindString (sql, "@options", ":0:0:0:0:");
    SqlBindInt (sql, "@languageusing", 0);
    SqlBindString (sql, "@slot1", "Empty");
    SqlBindString (sql, "@slot2", "Empty");
    SqlBindString (sql, "@slot3", "Empty");
    SqlBindString (sql, "@slot4", "Empty");
    SqlBindString (sql, "@slot5", "Empty");
    SqlBindString (sql, "@slot6", "Empty");
    SqlBindString (sql, "@slot7", "Empty");
    SqlBindString (sql, "@slot8", "Empty");
    SqlBindString (sql, "@slot9", "Empty");
    SqlBindString (sql, "@slot10", "Empty");
    SqlStep (sql);
}

void InitializeAdventureData (object oDM, string sTableName, string sTag)
{
    string sName = GetName (oDM, TRUE);
    string sQuery = "INSERT INTO " + sTableName + " (name, tag, startlevel, " +
        "restrictrest, xpslider, treasureslider, temperature, precipitation, storm, " +
        "windx, windy, windz, windmagnitude, windyaw, windpitch) " +
        "VALUES (@name, @tag, @startlevel, @restrictrest, @xpslider, " +
        "@treasureslider, @temperature, @precipitation, @storm, @windx, " +
        "@windy, @windz, @windmagnitude, @windyaw, @windpitch);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlBindInt (sql, "@startlevel", STARTING_CHARACTER_LEVEL);
    SqlBindInt (sql, "@restrictrest", RESTRICT_REST);
    SqlBindInt (sql, "@xpslider", STARTING_EXPERIENCE_SLIDER);
    SqlBindInt (sql, "@treasureslider", STARTING_TREASURE_SLIDER);
    SqlBindInt (sql, "@temperature", 80);
    SqlBindInt (sql, "@precipitation", 0);
    SqlBindInt (sql, "@storm", 0);
    SqlBindFloat (sql, "@windx", 0.0f);
    SqlBindFloat (sql, "@windy", 0.0f);
    SqlBindFloat (sql, "@windz", 0.0f);
    SqlBindFloat (sql, "@windmagnitude", 0.0f);
    SqlBindFloat (sql, "@windyaw", 0.0f);
    SqlBindFloat (sql, "@windpitch", 0.0f);
    SqlStep (sql);
}

void InitializeAreaData (object oPlayer, string sTableName, string sTag)
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "INSERT INTO " + AREA_TABLE + "(name, tag, resref, areaname, " +
        "areatag, level, lootstate, xpstate, spellstate, areastate, populatestate, cleanstate, " +
        "reststate, encchance, enctable, animations, mainlight1, mainlight2, sourcelight1, " +
        "sourcelight2, moonambient, moondiffuse, sunambient, sundiffuse, fogmooncolor, " +
        "fogsuncolor, fogdistance) VALUES (@name, @tag, @resref, @areaname, " +
        "@areatag, @level, @lootstate, @xpstate, @spellstate, @areastate, @populatestate, @cleanstate, " +
        "@reststate, @encchance, @enctable, @animations, @mainlight1, @mainlight2, @sourcelight1, " +
        "@sourcelight2, @moonambient, @moondiffuse, @sunambient, @sundiffuse, " +
        "@fogmooncolor, @fogsuncolor, @fogdistance);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlBindString (sql, "@resref", "");
    SqlBindString (sql, "@areaname", "");
    SqlBindString (sql, "@areatag", "");
    SqlBindInt (sql, "@level", 0);
    SqlBindInt (sql, "@lootstate", 0);
    SqlBindInt (sql, "@xpstate", 0);
    SqlBindInt (sql, "@spellstate", 0);
    SqlBindInt (sql, "@areastate", 0);
    SqlBindInt (sql, "@populatestate", 0);
    SqlBindInt (sql, "@cleanstate", 0);
    SqlBindInt (sql, "@reststate", 0);
    SqlBindInt (sql, "@encchance", 0);
    SqlBindString (sql, "@enctable", "");
    SqlBindInt (sql, "@animations", 0);
    SqlBindInt (sql, "@mainlight1", 0);
    SqlBindInt (sql, "@mainlight2", 0);
    SqlBindInt (sql, "@sourcelight1", 0);
    SqlBindInt (sql, "@sourcelight2", 0);
    SqlBindInt (sql, "@moonambient", 0);
    SqlBindInt (sql, "@moondiffuse", 0);
    SqlBindInt (sql, "@sunambient", 0);
    SqlBindInt (sql, "@sundiffuse", 0);
    SqlBindInt (sql, "@fogmooncolor", 0);
    SqlBindInt (sql, "@fogsuncolor", 0);
    SqlBindFloat (sql, "@fogdistance", 90.0f);
    SqlStep (sql);
}

void InitializeQuestData(object oPlayer, string sTableName, string sID)
{
    string sName = GetName (oPlayer, TRUE);
    string sPlayerName = GetPCPlayerName (oPlayer);
    string sQuery = "INSERT INTO " + sTableName + "(name, playername, tag, " +
        "description, quest, strref, plot, start, giver, area, npc, villain, " +
        "creatures, allies, followers, enemies, giveitem, item, placeable, " +
        "fplaceable, finish, finisher, rewards, state) VALUES (@name, @playername, " +
        "@tag, @description, @quest, @strref, @plot, @start, @giver, @area, @npc, " +
        "@villain, @creatures, @allies, @followers, @enemies, @giveitem, @item, " +
        "@placeable, @fplaceable, @finish, @finisher, @rewards, @state);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@playername", sPlayerName);
    SqlBindString (sql, "@tag", sID);
    SqlBindString (sql, "@description", "");
    SqlBindString (sql, "@quest", "");
    SqlBindString (sql, "@strref", "");
    SqlBindString (sql, "@plot", "");
    SqlBindString (sql, "@start", "");
    SqlBindString (sql, "@giver", "");
    SqlBindString (sql, "@area", "");
    SqlBindString (sql, "@npc", "");
    SqlBindString (sql, "@villain", "");
    SqlBindString (sql, "@creatures", "");
    SqlBindString (sql, "@allies", "");
    SqlBindString (sql, "@followers", "");
    SqlBindString (sql, "@enemies", "");
    SqlBindString (sql, "@giveitem", "");
    SqlBindString (sql, "@item", "");
    SqlBindString (sql, "@placeable", "");
    SqlBindString (sql, "@fplaceable", "");
    SqlBindString (sql, "@finish", "");
    SqlBindString (sql, "@finisher", "");
    SqlBindString (sql, "@rewards", "");
    SqlBindString (sql, "@state", "");
    SqlStep (sql);
}

void InitializeSpellData (object oPlayer, string sTableName, string sTag)
{
    string sName = GetName (oPlayer, TRUE);
    string sPlayerName = GetPCPlayerName (oPlayer);
    string sQuery = "INSERT INTO " + sTableName + "(name, tag, spells) VALUES (@name, @tag, @spells);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlBindJson (sql, "@spells", JsonArray ());
    SqlStep (sql);
}

int CheckServerDataAndInitialize(object oObject, string sTableName, string sTag = "")
{
    if(!GetIsObjectValid(oObject)) return FALSE;
    string sQuery, sName;
    sqlquery sql;
    if(sTableName == PLAYER_TABLE) sName = GetPCPlayerName(oObject);
    else sName = GetName (oObject, TRUE);
    if(sTag != "")
    {
        sQuery = "SELECT name FROM " + sTableName + " Where name = @name AND tag = @tag;";
        sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
        SqlBindString(sql, "@name", sName);
        SqlBindString(sql, "@tag", sTag);
    }
    else
    {
        sQuery = "SELECT name FROM " + sTableName + " Where name = @name;";
        sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
        SqlBindString(sql, "@name", sName);
    }
    if(!SqlStep(sql))
    {
        if(sTableName == SERVER_TABLE) InitializeServerData(sTableName);
        else if(sTableName == PLAYER_TABLE) InitializePlayerData(oObject, sTableName);
        else if(sTableName == OBJECT_TABLE) InitializeObjectData(oObject, sTableName, sTag);
        else if(sTableName == QUEST_TABLE) InitializeQuestData(oObject, sTableName, sTag);
        else if(sTableName == DM_TABLE) InitializeDMData(oObject, sTableName);
        else if(sTableName == ADVENTURE_TABLE) InitializeAdventureData(oObject, sTableName, sTag);
        else if(sTableName == AREA_TABLE) InitializeAreaData(oObject, sTableName, sTag);
        else if(sTableName == ADV_OBJ_TABLE) InitializeAdventureObjectData(oObject, sTableName, sTag);
        else if(sTableName == BUFF_TABLE) InitializeSpellData(oObject, sTableName, sTag);
        //else if(sTableName == DMPIN_TABLE) InitializeDMPinData(oObject, sTableName);
        return TRUE;
    }
    return FALSE;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
void SetServerDatabaseInt (object oObject, string sTableName, string sDataField, int nData, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    else sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindInt (sql, "@data", nData);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
int GetServerDatabaseInt (object oObject, string sTableName, string sDataField, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    else sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetInt (sql, 0);
    else return 0;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// fData is the float data to be saved.
void SetServerDatabaseFloat (object oObject, string sTableName, string sDataField, float fData, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    else sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindFloat (sql, "@data", fData);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
float GetServerDatabaseFloat (object oObject, string sTableName, string sDataField, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    else sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetFloat (sql, 0);
    else return 0.0f;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetServerDatabaseString (object oObject, string sTableName, string sDataField, string sData, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    else sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@data", sData);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// oObject is the character/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetServerDatabaseString (object oObject, string sTableName, string sDataField, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    else sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
    else return "";
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetServerDatabaseJson (object oObject, string sTableName, string sDataField, json jData, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    else sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// oObject is the character/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetServerDatabaseJson (object oObject, string sTableName, string sDataField, string sTag = "")
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    if (sTag != "") sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    else sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}

// oObject is the character/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// oData is the object data to be saved.
void SetServerDatabaseObject (object oObject, string sTableName, object oData, string sTag)
{
    string sName = GetName (oObject, TRUE);
    string sQuery = "UPDATE " + sTableName + " SET object = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindObject (sql, "@data", oData, TRUE);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// lLocationToSpawn will spawn the object at that location.
// oInventory will spawn the object in that objects inventory.
object GetServerDatabaseObject(object oObject, string sTableName, location lLocationToSpawn, object oInventory = OBJECT_INVALID, string sTag = "")
{
    string sName = GetName(oObject, TRUE);
    string sQuery = "SELECT object FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if(SqlStep(sql)) return SqlGetObject(sql, 0, lLocationToSpawn, oInventory);
    return OBJECT_INVALID;
}

int GetServerDatabaseStatusByCDKey(object oPC)
{
    string sQuery = "SELECT status FROM " + PLAYER_TABLE + " WHERE publiccdkey = @publiccdkey;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@publiccdkey", GetPCPublicCDKey(oPC));
    if(SqlStep(sql)) return SqlGetInt(sql, 0);
    return 0;
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE, DM_TABLE, NPC_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
void DeleteServerDatabaseObject(object oObject, string sTableName, string sTag)
{
    string sName = GetName(oObject, TRUE);
    string sQuery = "DELETE FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    SqlStep(sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE, DM_TABLE, NPC_TABLE.
void DeleteServerDatabase (object oObject, string sTableName)
{
    string sName = GetName (oObject, TRUE);
    string sQuery = "DELETE FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
void SetServerDatabaseTime (object oObject, string sTableName, string sDataField)
{
    string sName;
    if (sTableName == SERVER_TABLE) sName = GetName (oObject, TRUE);
    else sName = GetPCPlayerName (oObject);
    string sQuery = "UPDATE " + sTableName + " SET " +
           sDataField + " = strftime('%m-%d-%Y (%H:%M)','now', '-5 hours') WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    //SqlBindInt (sql, "@data", iData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// Object must be a player character.
// Defined sTableName constants: CHARACTER_TABLE, QUEST_TABLE, PIN_TABLE.
void CreateObjectDataTable (object oObject, string sTableName)
{
    if (sTableName == CHARACTER_TABLE)
    {
        sqlquery sql = SqlPrepareQueryObject (oObject,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT, " +
            "playername     TEXT, " +
            "status         INTEGER, " +
            "location       TEXT, " +
            "fame           INTEGER, " +
            "infamy         INTEGER, " +
            "hitpoints      INTEGER, " +
            "luck           INTEGER, " +
            "racialxp       FLOAT,  " +
            "lastrested     INTEGER, " +
            "languageusing  INTEGER, " +
            "deity          INTEGER, " +
            "polymorph      TEXT, " +
            "summons        TEXT, " +
            "teleport       TEXT, " +
            "appearance     TEXT, " +
            "rests          INTEGER, " +
            "bleeds         INTEGER, " +
            "respawns       INTEGER, " +
            "deaths         INTEGER, " +
            "kills          INTEGER, " +
            "sidequests     INTEGER, " +
            "mainquests     INTEGER, " +
            "cynosurejumps  INTEGER, " +
            "lastlogin      INTEGER, " +
            "creationdate   INTEGER, " +
            "PRIMARY KEY(name, playername));");
        SqlStep (sql);
    }
    else if (sTableName == QUEST_TABLE)
    {
        sqlquery sql = SqlPrepareQueryObject (oObject,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT , " +
            "questpointer   INTEGER,  " +
            "journalid      INTEGER,  " +
            "PRIMARY KEY(name));");
        SqlStep (sql);
    }
    else if (sTableName == PIN_TABLE)
    {
        sqlquery sql = SqlPrepareQueryObject (oObject,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT , " +
            "areatag        TEXT,  " +
            "xpos           FLOAT,  " +
            "ypos           FLOAT,  " +
            "entry          TEXT,  " +
            "PRIMARY KEY(name));");
        SqlStep (sql);
    }
}

// Object must be a player character.
// Defined sTableName constants: *_TABLE.
void CheckObjectDataTableAndCreateTable (object oObject, string sTableName)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@tableName", sTableName);
    if (!SqlStep (sql)) CreateObjectDataTable (oObject, sTableName);
}

void InitializeCharacterData (object oPC, string sTableName)
{
    string sName = GetName (oPC, TRUE);
    string sPlayerName = GetPCPlayerName (oPC);
    string sQuery = "INSERT INTO " + sTableName + "(name, playername, status, " +
        "location, fame, infamy, hitpoints, luck, racialxp, lastrested, " +
        "languageusing, deity, polymorph, summons, teleport, appearance, " +
        "rests, bleeds, respawns, deaths, kills, " +
        "sidequests, mainquests, cynosurejumps, lastlogin, creationdate) " +
        "VALUES (@name, @playername, @status, @location, @fame, @infamy, " +
        "@hitpoints, @luck, @racialxp, @lastrested, @languageusing, @deity, " +
        "@polymorph, @summons, @teleport, @appearance, @rests, @bleeds, " +
        "@respawns, @deaths, @kills, @sidequests, @mainquests, @cynosurejumps, " +
        "@lastlogin, strftime('%m-%d-%Y (%H:%M)','now', '-5 hours'));";
    sqlquery sql = SqlPrepareQueryObject (oPC, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@playername", sPlayerName);
    SqlBindInt (sql, "@status", 1);
    SqlBindString (sql, "@location", "");
    SqlBindInt (sql, "@fame", 0);
    SqlBindInt (sql, "@infamy", 0);
    SqlBindInt (sql, "@hitpoints", 0);
    SqlBindInt (sql, "@luck", 0);
    SqlBindFloat (sql, "@racialxp", 0.0);
    SqlBindString (sql, "@lastrested", "");
    SqlBindInt (sql, "@languageusing", 0);
    SqlBindInt (sql, "@deity", 0);
    SqlBindString (sql, "@polymorph", "::::::::::::::::::::::");
    SqlBindString (sql, "@summons", ":--0-0-0-0-0-0-0-0-0-0-0-:::::::::::::::::::::");
    json jTArray = CreateJsonArrayWithString ("", 21);
    jTArray = JsonArraySet (jTArray, 0, JsonString ("WP_Default_Respawn"));
    SqlBindJson (sql, "@teleport", jTArray);
    SqlBindString (sql, "@appearance", "::::::::::::::::::::::");
    SqlBindInt (sql, "@rests", 0);
    SqlBindInt (sql, "@bleeds", 0);
    SqlBindInt (sql, "@respawns", 0);
    SqlBindInt (sql, "@deaths", 0);
    SqlBindInt (sql, "@kills", 0);
    SqlBindInt (sql, "@sidequests", 0);
    SqlBindInt (sql, "@mainquests", 0);
    SqlBindInt (sql, "@cynosurejumps", 0);
    SqlBindInt (sql, "@lastlogin", 0);
    SqlStep (sql);
}

// sDataName is the quest name of the quest to save.
void InitializeJournalData (object oPC, string sTableName, string sDataName)
{
    string sQuery = "INSERT INTO " + sTableName + "(name, questpointer, journalid) " +
        "VALUES (@name, @questpointer, @journalid);";
    sqlquery sql = SqlPrepareQueryObject (oPC, sQuery);
    SqlBindString (sql, "@name", sDataName);
    SqlBindInt (sql, "@questpointer", 0);
    SqlBindInt (sql, "@journalid", 0);
    SqlStep (sql);
}

// Defined sTableName constants: *_TABLE.
void CheckObjectDataAndInitialize (object oObject, string sTableName, string sDataName = "")
{
    CheckObjectDataTableAndCreateTable (oObject, sTableName);
    if (oObject == OBJECT_INVALID) return;
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT name FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (!SqlStep (sql))
    {
        if (sTableName == CHARACTER_TABLE) InitializeCharacterData (oObject, sTableName);
        else if (sTableName == QUEST_TABLE) InitializeJournalData (oObject, sTableName, sDataName);
    }
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseInt (object oObject, string sTableName, string sDataField, int iData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindInt (sql, "@data", iData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a integer of the data stored.
int GetObjectDatabaseInt (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetInt (sql, 0);
    else return 0;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// sDataName is the name of the quest if we are saveing a quest.
// fData is the float data to be saved.
void SetObjectDatabaseFloat (object oObject, string sTableName, string sDataField, float fData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindFloat (sql, "@data", fData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a float of the data stored.
float GetObjectDatabaseFloat (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetFloat (sql, 0);
    else return 0.0f;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// sDataName is the name of the quest if we are saveing a quest.
// sData is the string data to be saved.
void SetObjectDatabaseString (object oObject, string sTableName, string sDataField, string sData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@data", sData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a string of the data stored.
string GetObjectDatabaseString (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
    else return "";
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// sDataName is the name of the quest if we are saveing a quest.
// jData is the json data to be saved.
void SetObjectDatabaseJson (object oObject, string sTableName, string sDataField, json jData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns the json of the data stored.
json GetObjectDatabaseJson (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonNull ();
}

void DeleteObjectDatabaseName(object oObject, string sTableName, string sName)
{
    string sQuery = "DELETE FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlStep(sql);
}
void DeleteObjectDatabase(object oObject, string sTableName)
{
    string sQuery = "DELETE FROM " + sTableName + ";";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlStep (sql);
}

// sDataName is the number of the pin to save.
void SavePinData (object oPC, string sTableName, string sDataName, string sAreaTag, float fXpos, float fYpos, string sEntry)
{
    string sQuery = "INSERT INTO " + sTableName + "(name, areatag, xpos, ypos, entry) " +
        "VALUES (@name, @areatag, @xpos, @ypos, @entry);";
    sqlquery sql = SqlPrepareQueryObject (oPC, sQuery);
    SqlBindString (sql, "@name", sDataName);
    SqlBindString (sql, "@areatag", sAreaTag);
    SqlBindFloat (sql, "@xpos", fXpos);
    SqlBindFloat (sql, "@ypos", fYpos);
    SqlBindString (sql, "@entry", sEntry);
    SqlStep (sql);
}

/*/ Initialize any database tables that do not exist.
void InitializeDB ()
{
    string moddata = "module (" +
        "name           varchar(128) NOT NULL DEFAULT 'Battledale', " +
        "tag            varchar(128) NOT NULL DEFAULT '0_module', " +
        "year           int          NOT NULL DEFAULT " + STARTING_YEAR + ", " +
        "month          int          NOT NULL DEFAULT 1, " +
        "day            int          NOT NULL DEFAULT 1, " +
        "hour           int          NOT NULL DEFAULT 18, " +
        "startlevel     int          NOT NULL DEFAULT " + STARTING_CHARACTER_LEVEL + ", " +
        "restrictrest   int          NOT NULL DEFAULT " + RESTRICT_REST + ", " +
        "xpslider       int          NOT NULL DEFAULT " + STARTING_EXPERIENCE_SLIDER + ", " +
        "treasureslider int          NOT NULL DEFAULT " + STARTING_TREASURE_SLIDER + ", " +
        "temp           int          NOT NULL DEFAULT 80, " +
        "precipitation  int          NOT NULL DEFAULT 0, " +
        "storm          int          NOT NULL DEFAULT 0" +
        ")";

    string playerdata = "player (" +
        "name           varchar(128) NOT NULL DEFAULT '', " +
        "status         int          NOT NULL DEFAULT 0,  " +
        "watched        int          NOT NULL DEFAULT 0,  " +
        "unlocks        varchar(128) NOT NULL DEFAULT ':::::::::::', " +
        "charactercount int          NOT NULL DEFAULT 0,  " +
        "highestlevel   int          NOT NULL DEFAULT 1,  " +
        "restcount      int          NOT NULL DEFAULT 0,  " +
        "bleedcount     int          NOT NULL DEFAULT 0,  " +
        "respawncount   int          NOT NULL DEFAULT 0,  " +
        "deathcount     int          NOT NULL DEFAULT 0,  " +
        "killcount      int          NOT NULL DEFAULT 0,  " +
        "sidequestcount int          NOT NULL DEFAULT 0,  " +
        "mainquestcount int          NOT NULL DEFAULT 0,  " +
        "cynosurejumps  int          NOT NULL DEFAULT 0,  " +
        "dmlogincount   int          NOT NULL DEFAULT 0,  " +
        "logincount     int          NOT NULL DEFAULT 0,  " +
        "lastlogon      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
        "creationdate   timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
        "publiccdkey    varchar(16)  NOT NULL DEFAULT '', " +
        "lastipaddress  varchar(20)  NOT NULL DEFAULT ''" +
        ")";

    string characterdata = "character (" +
        "name           varchar(128) NOT NULL DEFAULT '', " +
        "playername     varchar(128) NOT NULL DEFAULT '', " +
        "location       varchar(128) NOT NULL DEFAULT '', " +
        "status         int          NOT NULL DEFAULT 0,  " +
        "fame           int          NOT NULL DEFAULT 0,  " +
        "infamy         int          NOT NULL DEFAULT 0,  " +
        "hitpoints      int          NOT NULL DEFAULT 0,  " +
        "luck           int          NOT NULL DEFAULT 0,  " +
        "racialxp       float        NOT NULL DEFAULT 0.0,  " +
        "lastrested     varchar(128) NOT NULL DEFAULT '', " +
        "languageusing  int          NOT NULL DEFAULT 0,  " +
        "deity          int          NOT NULL DEFAULT 0,  " +
        "polymorph      varchar(128) NOT NULL DEFAULT ':::::::::::', " +
        "summons        varchar(128) NOT NULL DEFAULT ':::::::::::::::::::::::::::', " +
        "teleport       varchar(128) NOT NULL DEFAULT ':WP_Default_Respawn::::::::::', " +
        "appearance     varchar(128) NOT NULL DEFAULT ':::::::::::', " +
        "restcount      int          NOT NULL DEFAULT 0,  " +
        "bleedcount     int          NOT NULL DEFAULT 0,  " +
        "respawncount   int          NOT NULL DEFAULT 0,  " +
        "deathcount     int          NOT NULL DEFAULT 0,  " +
        "killcount      int          NOT NULL DEFAULT 0,  " +
        "sidequestcount int          NOT NULL DEFAULT 0,  " +
        "mainquestcount int          NOT NULL DEFAULT 0,  " +
        "cynosurejumps  int          NOT NULL DEFAULT 0,  " +
        "lastlogon      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
        "creationdate   timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP" +
        ")";

    string questdata = "quest (" +
        "name           varchar(128) NOT NULL DEFAULT '', " +
        "questname      varchar(128) NOT NULL DEFAULT '', " +
        "questpointer   int          NOT NULL DEFAULT 1,  " +
        "journalid      int          NOT NULL DEFAULT 0,  " +
        "time           timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP" +
       ")";

    string areadata = "area (" +
        "name            varchar(128) NOT NULL DEFAULT '', " +
        "areaname        varchar(128) NOT NULL DEFAULT '', " +
        "areatag         varchar(32)  NOT NULL DEFAULT '', " +
        "arealevel       int          NOT NULL DEFAULT 0,  " +
        "lootstate       int          NOT NULL DEFAULT 0,  " +
        "xpstate         int          NOT NULL DEFAULT 0,  " +
        "spellstate      int          NOT NULL DEFAULT 0,  " +
        "cleanstate      int          NOT NULL DEFAULT 0,  " +
        "reststate       int          NOT NULL DEFAULT 0,  " +
        "encounterchance int          NOT NULL DEFAULT 0,  " +
        "encountertable  varchar(128) NOT NULL DEFAULT '', " +
        "time            timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP" +
        ")";

    string containerdata = "container (" +
        "name           varchar(128) NOT NULL DEFAULT '', " +
        "containername  varchar(128) NOT NULL DEFAULT '', " +
        "containertag   varchar(32)  NOT NULL DEFAULT '', " +
        "itemindex      int          NOT NULL DEFAULT 0,  " +
        "itemname       varchar(128) NOT NULL DEFAULT '', " +
        "item           TEXT         NOT NULL DEFAULT '', "  +
        "time           timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP" +
        ")";

    string creaturedata = "creature (" +
        "name            varchar(128) NOT NULL DEFAULT '', " +
        "areaname        varchar(128) NOT NULL DEFAULT '', " +
        "areatag         varchar(32)  NOT NULL DEFAULT '', " +
        "creatureindex   int          NOT NULL DEFAULT 0,  " +
        "creaturename    varchar(128) NOT NULL DEFAULT '', " +
        "location        varchar(128) NOT NULL DEFAULT '', " +
        "creature        TEXT         NOT NULL DEFAULT '', " +
        "time            timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP" +
        ")";

    string placeabledata = "placeable (" +
        "name            varchar(128) NOT NULL DEFAULT '', " +
        "areaname        varchar(128) NOT NULL DEFAULT '', " +
        "areatag         varchar(32)  NOT NULL DEFAULT '', " +
        "placeableindex  int          NOT NULL DEFAULT 0,  " +
        "placeablename   varchar(128) NOT NULL DEFAULT '', " +
        "location        varchar(128) NOT NULL DEFAULT '', " +
        "placeable       TEXT         NOT NULL DEFAULT '', " +
        "time            timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP" +
        ")";
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + moddata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + playerdata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + characterdata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + questdata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + containerdata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + areadata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + creaturedata);
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS " + placeabledata);

    // Check to see if the Module DB has been set.
    object oModule = GetModule ();
    string sName = GetStringData (oModule, "module", "name");
    if (sName == "")
    {
        sName = GetName (oModule);
        string query = "INSERT INTO module(name) VALUES(?)";
        if (!NWNX_SQL_PrepareQuery (query)) SetModuleError ("DATABASE", "0i_database", "319", "Failed to prepare query for Module Data [" + sName + "].");
        NWNX_SQL_PreparedString (0, sName);
        if (!NWNX_SQL_ExecutePreparedQuery ()) SetModuleError ("DATABASE", "0i_database", "321", "Failed to Execute query for Module Data [" + sName + "].");
    }
}


// Saves to the Database the current calendar date.
void SaveServerCalendar ()
{
    int iYear, iMonth, iDay, iHour;
    string sYear, sMonth, sDay, sHour;
    // Get Module.
    object oModule = GetModule ();
    // Get the current data and time.
    iYear = GetCalendarYear();
    sYear = IntToString (iYear);
    iMonth = GetCalendarMonth ();
    sMonth = IntToString (iMonth);
    iDay = GetCalendarDay ();
    sDay = IntToString (iDay);
    iHour = GetTimeHour ();
    sHour = IntToString (iHour);
    // Save to the module db.
    SetIntData (oModule, "module", "year", iYear);
    SetIntData (oModule, "module", "month", iMonth);
    SetIntData (oModule, "module", "day", iDay);
    SetIntData (oModule, "module", "hour", iHour);
    SendMessages ("(SaveServerCalendar) Saving the current calendar [" + sYear + ":" + sMonth + ":" + sDay + ":" + sHour + "].", COLOR_GREY, OBJECT_INVALID, FALSE, TRUE);
}

// Gets the Database time and sets the server calendar.
// retrieved from the module database.
void SetServerCalendar ()
{
    int iYear, iMonth, iDay, iHour;
    string sYear, sMonth, sDay, sHour;
    // Get Module.
    object oModule = GetModule ();
    // Get database year.
    iYear = GetIntData (oModule, "module", "year");
    // Get database month.
    iMonth = GetIntData (oModule, "module", "month");
    // Get database day.
    iDay = GetIntData (oModule, "module", "day");
    // Get database hour.
    iHour = GetIntData (oModule, "module", "hour");
    // Set the game to the data base time.
    SetCalendar (iYear, iMonth, iDay);
    SetTime (iHour, 6, 0, 0);
    SendMessages ("Setting the current calendar [" + IntToString (iYear) + ":" + IntToString (iMonth) + ":" + IntToString (iDay) + ":" + IntToString (iHour) + "].", COLOR_GREY, OBJECT_INVALID, FALSE);
}
// Sets a new players database fields.
int SetPlayerData (object oPC)
{
    string sName = GetPCPlayerName (oPC);
    string query = "INSERT INTO player(name, publiccdkey, lastipaddress, creationdate) VALUES(?,?,?,CURRENT_TIMESTAMP)";
    if (!NWNX_SQL_PrepareQuery (query))
    {
        SetModuleError ("DATABASE", "0i_database", "360", "Failed to prepare query for SetPlayerData [" + sName + "].");
        return -1;
    }
    NWNX_SQL_PreparedString (0, sName);
    NWNX_SQL_PreparedString (1, GetPCPublicCDKey (oPC));
    NWNX_SQL_PreparedString (2, GetPCIPAddress (oPC));
    if (!NWNX_SQL_ExecutePreparedQuery ())
    {
        SetModuleError ("DATABASE", "0i_database", "368", "Failed to execute query for SetPlayerData [" + sName + "].");
        return -1;
    }
    NWNX_SQL_ExecuteQuery ("SELECT name FROM player");
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return -1;
}
// Sets a new characters database fields.
int SetCharacterData (object oPC)
{
    string sName = GetName (oPC, TRUE);
    string query = "INSERT INTO character(name, playername, hitpoints, creationdate) VALUES(?,?,?,CURRENT_TIMESTAMP)";
    if (!NWNX_SQL_PrepareQuery (query))
    {
        SetModuleError ("DATABASE", "0i_database", "386", "Failed to prepare query for SetCharacterData [" + sName + "].");
        return -1;
    }
    NWNX_SQL_PreparedString (0, sName);
    NWNX_SQL_PreparedString (1, GetPCPlayerName (oPC));
    NWNX_SQL_PreparedInt (2, GetCurrentHitPoints (oPC));
    if (!NWNX_SQL_ExecutePreparedQuery ())
    {
        SetModuleError ("DATABASE", "0i_database", "394", "Failed to execute query for SetCharacterData [" + sName + "].");
        return -1;
    }
    NWNX_SQL_ExecuteQuery ("SELECT name FROM character");
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return -1;
}

// Sets data from a player's database about this character's quests.
// oPC is the PC's data to set.
// sQuestName is the name of the journal.
// iPointer is the pointer to the quest in the quest_list.2da
int SetQuestData (object oPC, string sQuestName, int iPointer)
{
    string query = "INSERT INTO quest(name, questname, questpointer) VALUES(?,?,?)";
    if (!NWNX_SQL_PrepareQuery (query))
    {
        SetModuleError ("DATABASE", "0i_database", "414", "Failed to prepare query for SetQuestData [" + sQuestName + "].");
        return -1;
    }
    NWNX_SQL_PreparedString (0, GetName (oPC, TRUE));
    NWNX_SQL_PreparedString (1, sQuestName);
    NWNX_SQL_PreparedInt (2, iPointer);
    if (!NWNX_SQL_ExecutePreparedQuery ())
    {
        SetModuleError ("DATABASE", "0i_database", "422", "Failed to execute query for SetQuestData [" + sQuestName + "].");
        return -1;
    }
    NWNX_SQL_ExecuteQuery ("SELECT name FROM character");
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return -1;
}

// Sets float data to the database.
// oObject is the player/module the data is being saved for.
// sTable is the table to use: module, player, character.
// sDataName should be one of the data fields for the table.
// fData is the float data to be saved.
void SetFloatData (object oObject, string sTable, string sDataName, float fData)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "448", "(SetFloatData) Invalid table: " + sTable);
        return;
    }
    string query = "UPDATE " + sTable + " SET " + sDataName + "=? WHERE Name=?";
    NWNX_SQL_PrepareQuery (query);
    NWNX_SQL_PreparedFloat (0, fData);
    NWNX_SQL_PreparedString (1, sName);
    NWNX_SQL_ExecutePreparedQuery ();
}

// Gets float data from the database.
// oObject is the player/module the data is for.
// sTable is the table to use: module, player, character.
// sDataName should be one of the data fields for the table.
// Returns a float of the data stored.
float GetFloatData (object oObject, string sTable, string sDataName)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "472", "(GetFloatData) Invalid table: " + sTable);
        return 0.0f;
    }
    NWNX_SQL_PrepareQuery ("SELECT " + sDataName + " FROM " + sTable + " WHERE Name=?");
    NWNX_SQL_PreparedString (0, sName);
    NWNX_SQL_ExecutePreparedQuery ();
    if (NWNX_SQL_ReadyToReadNextRow ())
    {
        NWNX_SQL_ReadNextRow ();
        return StringToFloat (NWNX_SQL_ReadDataInActiveRow());
    }
    return 0.0f;
}

// Sets integer data to the database.
// oObject is the player/module the data is being saved for.
// sTable is the table to use: module, player, character, quest.
// sDataName should be one of the data fields for the table.
// sParam1 is used in specific tables (Quest: QuestName)
// iData is the integer data to be saved.
void SetIntData (object oObject, string sTable, string sDataName, int iData, string sParam1 = "")
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character" || sTable == "quest") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "501", "(SetIntData) Invalid table: " + sTable);
        return;
    }
    if (sTable == "quest")
    {
        string query = "UPDATE " + sTable + " SET " + sDataName + "=? WHERE name=? AND questname=?";
        NWNX_SQL_PrepareQuery (query);
        NWNX_SQL_PreparedInt (0, iData);
        NWNX_SQL_PreparedString (1, sName);
        NWNX_SQL_PreparedString (2, sParam1);
    }
    else
    {
        string query = "UPDATE " + sTable + " SET " + sDataName + "=? WHERE name=?";
        NWNX_SQL_PrepareQuery (query);
        NWNX_SQL_PreparedInt (0, iData);
        NWNX_SQL_PreparedString (1, sName);
    }
    NWNX_SQL_ExecutePreparedQuery ();
}

// Gets integer data from the database.
// oObject is the player/module the data is for.
// sTable is the table to use: module, player, character, quest.
// sDataName should be one of the data fields for the table.
// sParam1 is used in specific tables (Quest: QuestName)
// Returns a integer of the data stored.
int GetIntData (object oObject, string sTable, string sDataName, string sParam1 = "")
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character" || sTable == "quest") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "537", "(GetIntData) Invalid table: " + sTable);
        return 0;
    }
    if (sTable == "quest")
    {
        NWNX_SQL_PrepareQuery ("SELECT " + sDataName + " FROM " + sTable + " WHERE name=? AND questname=?");
        NWNX_SQL_PreparedString (0, sName);
        NWNX_SQL_PreparedString (1, sParam1);
    }
    else
    {
        NWNX_SQL_PrepareQuery ("SELECT " + sDataName + " FROM " + sTable + " WHERE name=?");
        NWNX_SQL_PreparedString (0, sName);
    }
    NWNX_SQL_ExecutePreparedQuery ();
    if (NWNX_SQL_ReadyToReadNextRow ())
    {
        NWNX_SQL_ReadNextRow ();
        return StringToInt (NWNX_SQL_ReadDataInActiveRow());
    }
    return 0;
}

// Sets string data to the database.
// oObject is the player/module the data is being saved for.
// sTable is the table to use: module, player, character.
// sDataName should be one of the data fields for the table.
// sData is the string data to be saved.
void SetStringData (object oObject, string sTable, string sDataName, string sData)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "574", "(SetStringData) Invalid table: " + sTable);
        return;
    }
    string query = "UPDATE " + sTable + " SET " + sDataName + "=? WHERE name=?";
    NWNX_SQL_PrepareQuery (query);
    NWNX_SQL_PreparedString (0, sData);
    NWNX_SQL_PreparedString (1, sName);
    NWNX_SQL_ExecutePreparedQuery ();
}

// Gets string data from the database.
// oObject is the player/module the data is for.
// sTable is the table to use: module, player, character.
// sDataName should be one of the data fields for the table.
// Returns a string of the data stored.
string GetStringData (object oObject, string sTable, string sDataName)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "598", "(GetStringData) Invalid table: " + sTable);
        return "";
    }
    NWNX_SQL_PrepareQuery ("SELECT " + sDataName + " FROM " + sTable + " WHERE name=?");
    NWNX_SQL_PreparedString (0, sName);
    NWNX_SQL_ExecutePreparedQuery ();
    if (NWNX_SQL_ReadyToReadNextRow ())
    {
        NWNX_SQL_ReadNextRow ();
        return NWNX_SQL_ReadDataInActiveRow();
    }
    return "";
}

// Sets location data to the database.
// oObject is the player/object the data is being saved for.
// sTable is the table to use: module, player, character.
// sDataName should be one of the data fields for the table usually location.
// sData is the location data to be saved.
void SetLocationData (object oObject, string sTable, string sDataName, location lData)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "626", "(SetLocationData) Invalid table: " + sTable);
        return;
    }
    string query = "UPDATE " + sTable + " SET " + sDataName + "=? WHERE name=?";
    NWNX_SQL_PrepareQuery (query);
    NWNX_SQL_PreparedString (0, LocationToStringArray (lData));
    NWNX_SQL_PreparedString (1, sName);
    NWNX_SQL_ExecutePreparedQuery ();
}

// Gets location data from the database.
// oObject is the player/object the data is for.
// sTable is the table to use: module, player, character.
// sDataName should be one of the data fields for the table usually location.
// Returns a string of the data stored.
string GetLocationData (object oObject, string sTable, string sDataName)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "650", "(GetLocationData) Invalid table: " + sTable);
        return "";
    }
    NWNX_SQL_PrepareQuery ("SELECT " + sDataName + " FROM " + sTable + " WHERE name=?");
    NWNX_SQL_PreparedString (0, sName);
    NWNX_SQL_ExecutePreparedQuery ();
    if (NWNX_SQL_ReadyToReadNextRow ())
    {
        NWNX_SQL_ReadNextRow ();
        return NWNX_SQL_ReadDataInActiveRow();
    }
    return "";
}

// Set the timestamp to the current time.
// Used to set last login times.
void SetTimeStamp (object oObject, string sTable)
{
    string sName;
    // Check which table we are using then set the Name for query.
    if (sTable == "module" || sTable == "character") sName = GetName (oObject, TRUE);
    else if (sTable == "player") sName = GetPCPlayerName (oObject);
    // This is not a valid table so exit with error.
    else
    {
        SetModuleError ("DATABASE", "0i_database", "675", "(SetTimeStamp) Invalid table: " + sTable);
        return;
    }
    string query = "UPDATE " + sTable + " SET lastlogon=CURRENT_TIMESTAMP WHERE name=?";
    NWNX_SQL_PrepareQuery (query);
    NWNX_SQL_PreparedString (0, sName);
    NWNX_SQL_ExecutePreparedQuery ();
}

// Links all items in oObject to oPC in the database.
// oPC is the PC to link the items to.
// oContainer is the container to set the items from.
// This function will remove the items from the game.
// There can be multiple object saves, but this will
// increase the data base significantly! Use sparingly.
void SetPersistantContainer (object oPC, object oContainer)
{
    int iCount = 1;
    string sPCName, sContainerName, sContainerTag;
    sPCName = GetName (oPC, TRUE);
    sContainerName = GetName (oContainer);
    sContainerTag = GetTag (oContainer);
    // Get the first item.
    object oItem = GetFirstItemInInventory (oContainer);
    while (iCount <= MAX_PERSISTANT_ITEMS)
    {
        // Save object to the database.
        NWNX_SQL_PrepareQuery ("INSERT INTO container(charactername, containername, containertag, itemindex, itemname, item) VALUES(?,?,?,?,?,?)");
        NWNX_SQL_PreparedString (0, sPCName);
        NWNX_SQL_PreparedString (1, sContainerName);
        NWNX_SQL_PreparedString (2, sContainerTag);
        NWNX_SQL_PreparedInt (3, iCount);
        NWNX_SQL_PreparedString (4, GetName(oItem));
        NWNX_SQL_PreparedObjectFull (5, oItem);
        NWNX_SQL_ExecutePreparedQuery ();
        // Remove it from the object.
        DestroyObject (oItem);
        // Get the next item.
        oItem = GetNextItemInInventory (oContainer);
        iCount ++;
    }
}

// Gets items from a player's database container.
// oPC is the PC to get the items for.
// oContainer is the object to put the items into.
// This function adds items to the game!
void GetPersistantContainer (object oPC, object oContainer)
{
    int iCount = 1;
    string sPCName, sContainerTag;
    object oItem;
    sPCName = GetName (oPC, TRUE);
    sContainerTag = GetTag (oContainer);
    while (iCount <= MAX_PERSISTANT_ITEMS)
    {
        NWNX_SQL_PrepareQuery ("SELECT ID, item FROM container WHERE characername=? AND containertag=? AND itemindex=?");
        NWNX_SQL_PreparedString (0, sPCName);
        NWNX_SQL_PreparedString (1, sContainerTag);
        NWNX_SQL_PreparedInt (2, iCount);
        NWNX_SQL_ExecutePreparedQuery ();
        while (NWNX_SQL_ReadyToReadNextRow ())
        {
            NWNX_SQL_ReadNextRow();
            int id = StringToInt (NWNX_SQL_ReadDataInActiveRow (0));
            oItem = NWNX_SQL_ReadFullObjectInActiveRow (1, oContainer);
        }
        // If the item was retrieved then mark it as deleted in the database.
        if (GetIsObjectValid (oItem))
        {
            NWNX_SQL_PrepareQuery ("DELETE FROM container WHERE charactername=? AND containertag=? AND itemindex=?");
            NWNX_SQL_PreparedString (0, GetName (oPC, TRUE));
            NWNX_SQL_PreparedString (1, GetTag (oContainer));
            NWNX_SQL_PreparedInt (2, iCount);
            NWNX_SQL_ExecutePreparedQuery ();
            if (NWNX_SQL_GetAffectedRows() == 0)
            {
                SetModuleError ("DATABASE", "0i_database", "775", "Container: " + GetName(oContainer) + "(" + GetTag(oContainer) + ") not found in database.");
            }
        }
        iCount ++;
    }
}


// Sets areas persistant settings to a player's database for this DM character.
// oPC = The player saving the settings.
// oArea = the area to save.
void SetPersistentAreaSettings (object oPC, object oArea)
{
    string sSettings, sIndex, sText, sDataName;
    object oWaypoint;
    // If the area is invalid then delete the settings.
    if (!GetIsObjectValid (oArea))
    {
        NWNX_SQL_PrepareQuery ("DELETE FROM area WHERE charactername=? AND areatag=?");
        NWNX_SQL_PreparedString (0, GetName (oPC, TRUE));
        NWNX_SQL_PreparedString (1, GetTag (oArea));
        NWNX_SQL_ExecutePreparedQuery ();
        if (NWNX_SQL_GetAffectedRows() == 0)
        {
            SetModuleError ("DATABASE", "0i_database", "799", "Area: " + GetName(oArea) + "(" + GetTag(oArea) + ") not found in database.");
        }
    }
    else
    {
        NWNX_SQL_PrepareQuery ("INSERT INTO area(charactername, areaname, areatag, arealevel, " +
                               "lootstate, xpstate, spellstate, cleanstate, reststate, " +
                               "encounterchance, encountertable) VALUES(?,?,?,?,?,?)");
        NWNX_SQL_PreparedString (0, GetName(oPC, TRUE));
        NWNX_SQL_PreparedString (1, GetName(oArea));
        NWNX_SQL_PreparedString (2, GetTag(oArea));
        NWNX_SQL_PreparedInt (3, GetLocalInt (oArea, "0_Area_Level"));
        NWNX_SQL_PreparedInt (4, GetLocalInt (oArea, "0_LootOFF"));
        NWNX_SQL_PreparedInt (5, GetLocalInt (oArea, "0_XPOFF"));
        NWNX_SQL_PreparedInt (6, GetLocalInt (oArea, "0_NoSpells"));
        NWNX_SQL_PreparedInt (7, GetLocalInt (oArea, "0_CleanOFF"));
        // Set area to Rest/No Rest.
        object oWaypoint = GetNearestObjectByTag ("ip_no_rest", oPC);
        if (GetIsObjectValid (oWaypoint)) NWNX_SQL_PreparedInt (8, 1);
        else NWNX_SQL_PreparedInt (8, 0);
        // Save area specific encounter.
        oWaypoint = GetNearestObjectByTag ("ip_area_level", oPC);
        NWNX_SQL_PreparedString (9, GetLocalString (oWaypoint, "0_Encounter_2da"));
        NWNX_SQL_ExecutePreparedQuery ();
    }
}

// Gets areas persistant settings to a player's database for this DM character.
// oPC = Player loading the setttings.
string GetPersistentAreaSettings (object oPC)
{
   return "";
}

// Saves all non-player creatures in oPC's area.
// oPC player saving the creatures in the current area.
void SetPersistentCreatures (object oPC)
{
    int iCount = 1;
    string sPCName, sAreaName, sAreaTag;
    object oCreature, oArea;
    sPCName = GetName (oPC, TRUE);
    oArea = GetArea (oPC);
    sAreaName = GetName (oArea);
    sAreaTag = GetTag (oArea);
    // Get the first creature.
    oCreature = GetNearestObject (OBJECT_TYPE_CREATURE, oPC, iCount);
    while (iCount <= 20)
    {
        if (!GetIsPC (oCreature))
        {
            // Save object to the database.
            NWNX_SQL_PrepareQuery ("INSERT INTO creature(charactername, areaname, areatag, creatureindex, creaturename, location, creature) VALUES(?,?,?,?,?,?,?)");
            NWNX_SQL_PreparedString (0, sPCName);
            NWNX_SQL_PreparedString (1, sAreaName);
            NWNX_SQL_PreparedString (2, sAreaTag);
            NWNX_SQL_PreparedInt (3, iCount);
            NWNX_SQL_PreparedString (4, GetName(oCreature));
            NWNX_SQL_PreparedString (5, LocationToStringArray (GetLocation (oCreature)));
            NWNX_SQL_PreparedObjectFull (6, oCreature);
            NWNX_SQL_ExecutePreparedQuery ();
        }
        iCount ++;
        // Get the next creature.
        oCreature = GetNearestObject (OBJECT_TYPE_CREATURE, oPC, iCount);
    }
}

// Gets all creatures in the db for oPC and places in current area.
// oPC The PC used to load all creatures to this area.
void GetPersistentCreatures (object oPC)
{
    int iCount = 1;
    string sPCName, sAreaTag;
    object oCreature, oArea;
    location lLocation;
    vector vVector;
    oArea = GetArea (oPC);
    sPCName = GetName (oPC, TRUE);
    sAreaTag = GetTag (oArea);
    while (iCount <= 20)
    {
        // Get the creatures location.
        NWNX_SQL_PrepareQuery ("SELECT location FROM creatur WHERE characername=? AND areatag=? AND itemindex=?");
        NWNX_SQL_PreparedString (0, sPCName);
        NWNX_SQL_PreparedString (1, sAreaTag);
        NWNX_SQL_PreparedInt (2, iCount);
        NWNX_SQL_ExecutePreparedQuery ();
        if (NWNX_SQL_ReadyToReadNextRow ())
        {
            NWNX_SQL_ReadNextRow ();
            lLocation = StringArrayToLocation (NWNX_SQL_ReadDataInActiveRow());
            vVector = GetPositionFromLocation (lLocation);
        }
        NWNX_SQL_PrepareQuery ("SELECT ID, creature FROM creature WHERE characername=? AND areatag=? AND itemindex=?");
        NWNX_SQL_PreparedString (0, sPCName);
        NWNX_SQL_PreparedString (1, sAreaTag);
        NWNX_SQL_PreparedInt (2, iCount);
        NWNX_SQL_ExecutePreparedQuery ();
        while (NWNX_SQL_ReadyToReadNextRow ())
        {
            NWNX_SQL_ReadNextRow();
            int id = StringToInt (NWNX_SQL_ReadDataInActiveRow (0));
            oCreature = NWNX_SQL_ReadFullObjectInActiveRow (1, oArea, vVector.x, vVector.y, vVector.x);
        }
        iCount ++;
    }
}

// Sets a placeable to a player's database for this DM character.
// oOwner = the Player that is saving it (Used to log in DB).
// iIndex = An index used to log in the DB.
// iSlot = Slot to be saved in.
// oObject = the placeable to be saved.
// Array values are;
// :ResRef(0):Name(1):Tag(2):Location(3):LockUnlockDC(4):TrapDetectDC(5):TrapDisarmDC(6):
void SetPersistentPlaceable (object oPC, int iSlot, int iIndex, object oObject)
{
    string sArray, sDataName;
    location lLocation = GetLocation (oObject);
    string sLocation = LocationToStringArray (lLocation);
    // Get the player's name and character's name to save to the player database file.
    string sPlayer = SQLEncodeSpecialChars (GetPCPlayerName (oPC));
    string sPCName = SQLEncodeSpecialChars (GetName (oPC));
    // Create placeable array to save.
    // Set ResRef in array slot 0.
    sArray = ":" + GetResRef (oObject);
    // Set Name in array slot 1.
    sArray = sArray + ":" + GetName (oObject);
    // Set the Tag in array slot 2.
    sArray = sArray + ":" + GetTag (oObject);
    // Set the location in array slot 3.
    sArray = sArray + ":" + sLocation;
    // Check to see if it is locked.
    if (GetLocked (oObject)) sArray = sArray + ":" + IntToString (GetLockUnlockDC (oObject));
    else sArray = sArray + ":0";
    // Check to see if it is Trapped.
    if (GetIsTrapped (oObject))
    {
        sArray = sArray + ":" + IntToString (GetTrapDetectDC (oObject));
        sArray = sArray + ":" + IntToString (GetTrapDisarmDC (oObject));
    }
    else sArray = sArray + ":0:0";
    // Put end array tag.
    sArray = sArray + ":";
    sDataName = sPCName + "_P_" + IntToString (iSlot) + "_" + IntToString (iIndex);
    if (GetStringLength (sDataName) > 32) sDataName = GetStringLeft (sDataName, 24) + "_P_" + IntToString (iSlot) + "_" + IntToString (iIndex);
    SetCampaignString (sPlayer, sDataName, sArray, oPC);
}

// Get a placeable from a player's database for this DM character.
// oOwner = the Player that is loading it (Used to log in DB).
// iSlot = the slot to load from.
// iIndex = An index used to log in the DB.
// Returns the object loaded.
object GetPersistentPlaceable (object oPC, int iSlot, int iIndex)
{
    int iCounter, iUnlockDC, iTrapDisarmDC, iTrapDetectDC;
    string sArray, sResRef, sTag, sDataName;
    location lLocation;
    // Get the player's name and character's name to save to the player database file.
    string sPlayer = SQLEncodeSpecialChars (GetPCPlayerName (oPC));
    string sPCName = SQLEncodeSpecialChars (GetName (oPC));
    // Get the creatures location.
    sDataName = sPCName + "_P_" + IntToString (iSlot) + "_" + IntToString (iIndex);
    if (GetStringLength (sDataName) > 32) sDataName = GetStringLeft (sDataName, 24) + "_P_" + IntToString (iSlot) + "_" + IntToString (iIndex);
    sArray = GetCampaignString (sPlayer, sDataName, oPC);
    sResRef = GetStringArray (sArray, 0);
    sTag = GetStringArray (sArray, 2);
    lLocation = StringArrayToLocation (GetStringArray (sArray, 3));
    // Create the placeable at the location.
    object oObject = CreateObject (OBJECT_TYPE_PLACEABLE, sResRef, lLocation, FALSE, sTag);
    // Name the placeable.
    SetName (oObject, GetStringArray (sArray, 1));
    // Set to locked if required.
    iUnlockDC = StringToInt (GetStringArray (sArray, 4));
    if (iUnlockDC > 0)
    {
        SetLocked (oObject, TRUE);
        SetLockUnlockDC (oObject, iUnlockDC);
    }
    // Set to Trapped if required.
    iTrapDetectDC = StringToInt (GetStringArray (sArray, 5));
    if (iTrapDetectDC > 0)
    {
        SetTrapActive (oObject);
        SetTrapDetectable (oObject);
        SetTrapDetectDC (oObject, iTrapDetectDC);
        SetTrapDisarmable (oObject);
        SetTrapDisarmDC (oObject, StringToInt (GetStringArray (sArray, 6)));
    }
    return oObject;
}

// Gets data from the database on a characters house.
// oPC is the PC who owns the house.
// sAreaTag is the area tag of the house.
// sDataName should be one of the following only;
// housetype, location, upkeep, components,
// servants, unlocked, lastdatepaid, creationdate
// Returns a string of the data stored in sDataName.
string GetHouseData (object oPC, string sAreaTag, string sDataName)
{
   string sPlayer = SQLEncodeSpecialChars(GetPCPlayerName (oPC));
   string sCharacter = SQLEncodeSpecialChars(GetName (oPC));
   string sSQL = "SELECT " + sDataName + " FROM housedata WHERE player='" + sPlayer +
                 "' AND character='" + sCharacter +
                 "' AND areatag='" + sAreaTag + "'";
   SQLExecDirect(sSQL);
   if (SQLFetch() == SQL_SUCCESS) return SQLGetData(1);
   else
   {
      SetModuleError ("SQL", "0i_sqcalls", "649", "Player: " + sPlayer + " Character: " + sCharacter + " Area Tag: " + sAreaTag +
                      " Variable:[" + sDataName + "] could not be retrieved from the Database!");
      return "";
   }
}

// Sets Housedata to the database for a character.
// oPC is the pc's house data to save.
// sAreaTag is the area tag of the house.
// sDataName should be one of the following only;
// housetype, location, upkeep, components,
// servants, unlocked, lastdatepaid, creationdate
// sData is the data to save.
int SetHouseData (object oPC, string sAreaTag, string sDataName, string sData)
{
   string sPlayer = SQLEncodeSpecialChars(GetPCPlayerName (oPC));
   string sCharacter = SQLEncodeSpecialChars(GetName (oPC));
   // Pole the Database to see if the character is in the DB. If not then send error message.
   string sSQL = "SELECT " + sDataName + " FROM housedata WHERE player='" + sPlayer +
                 "' AND character='" + sCharacter +
                 "' AND areatag='" + sAreaTag + "'";
   SQLExecDirect(sSQL);
   if (SQLFetch() == SQL_SUCCESS)
   {
      // Row exists.
      sSQL = "UPDATE housedata SET " + sDataName + "='" + sData + "',expire=0 WHERE player='" + sPlayer +
             "' AND character='" + sCharacter +
             "' AND areatag='" + sAreaTag + "'";
      SQLExecDirect(sSQL);
      ShouldWeSaveToDisk ();
   }
   // Row doesn't exist.
   else
   {
      SendMessages ("Error:Your house data could not be saved to the Database!", COLOR_RED, oPC, FALSE, FALSE);
      SetModuleError ("SQL", "0i_sqcalls", "649", "Player: " + sPlayer + " Character: " + sCharacter + " Area Tag: " + sAreaTag +
                      " Variable:[" + sDataName + "] data:(" + sData + ") could not be saved to the Database!");
      return FALSE;
   }
   return TRUE;
}               */


