/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pinc_henchmen
////////////////////////////////////////////////////////////////////////////////
 Include file for Henchmen plug in scripts for Philos Module Extentions.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"

const string HENCHMAN_DATABASE = "philos_henchman_db";
const string HENCHMAN_TABLE = "HENCHMAN_TABLE";

// Creates the table and initializes if it needs to.
void CheckHenchmanDataAndInitialize(object oPC, string sSlot);
// Removes a henchan from the current slot.
void RemoveHenchmanDb(object oPC, string sSlot);
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetHenchmanDbString(object oPC, string sDataField, string sData, string sSlot);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetHenchmanDbString(object oPC, string sDataField, string sSlot);
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetHenchmanDbJson(object oPC, string sDataField, json jData, string sSlot);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetHenchmanDbJson(object oPC, string sDataField, string sSlot);
// sSlot is the slot to define this object in the database for this Slot## (# Party button and #1-6).
// oHenchman is the PC/Henchman to be saved.
void SetHenchmanDbObject(object oPC, object oHenchman, string sSlot);
// sSlot is the slot to define this object in the database for this Slot## (# Party button and #1-6).
// lLocationToSpawn will spawn the object at that location.
object GetHenchmanDbObject(object oPC, location lLocationToSpawn, string sSlot);
// Returns TRUE if the henchman with sName can join.
int GetJoinButtonActive(object oPC, string sName);
// Returns a two letter alignment string.
string GetAlignText(object oHenchman);
// Populates the Saved character group.
void AddSavedCharacterInfo(object oPC, int nToken, string sParty);
// Populates the Current character group.
void AddCurrentCharacterInfo(object oPC, int nToken, string sParty);
// Levels up the currently selected henchman.
void LevelUpYourHenchman(object oPC, int nToken, string sParty);
// Removes a henchman from your party.
void RemoveYourHenchman(object oPC, int nToken, string sParty);
// Removes all henchman from the party.
void RemoveWholeParty(object oPC, int nToken, string sParty);
// Saves a henchman in your party to the saved party #.
void SaveYourHenchman(object oPC, int nToken, string sParty);
// Saves the whole party to the saved party #.
void SaveWholeParty(object oPC, int nToken, string sParty);
// Saves the players current party to party #.
void SavedPartyJoin(object oPC, int nToken, string sParty);
// Saves a character in the players party to party #.
void SavedCharacterJoin(object oPC, int nToken, string sParty);
// Clears the players saved party #.
void SavedPartyCleared(object oPC, int nToken, string sParty);

void CreateHenchmanDataTable ()
{
    //ai_Debug("pi_buffing", "120", Creating a Henchman Table for Philos_NPC_DB.");
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE,
        "CREATE TABLE IF NOT EXISTS " + HENCHMAN_TABLE + " (" +
        "name        TEXT, " +
        "slot          TEXT, " +
        "henchname          TEXT, " +
        "image         TEXT, " +
        "stats         TEXT, " +
        "classes       TEXT, " +
        "henchman      TEXT, " +
        "PRIMARY KEY(slot));");
    SqlStep (sql);
}
void CheckHenchmanDataAndInitialize(object oPC, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindString(sql, "@tableName", HENCHMAN_TABLE);
    if(!SqlStep (sql)) CreateHenchmanDataTable();
    sQuery = "SELECT slot FROM " + HENCHMAN_TABLE + " Where name = @name AND slot = @slot;";
    sql = SqlPrepareQueryCampaign("philos_henchman_db", sQuery);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString(sql, "@slot", sSlot);
    if(!SqlStep(sql))
    {
        //ai_Debug("pi_buffing", "167", Initializing Henchman Data.");
        sQuery = "INSERT INTO " + HENCHMAN_TABLE + "(name, slot, henchname, image, stats, classes " +
        ", henchman) VALUES (@name, @slot, @henchname, @image, @stats, @classes, @henchman);";
        sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
        SqlBindString(sql, "@name", sPCName);
        SqlBindString(sql, "@slot", sSlot);
        SqlBindString(sql, "@henchname", "");
        SqlBindString(sql, "@image", "");
        SqlBindString(sql, "@stats", "");
        SqlBindString(sql, "@classes", "");
        SqlBindJson(sql, "@henchman", JsonObject());
        SqlStep(sql);
    }
}
void RemoveHenchmanDb(object oPC, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "DELETE FROM " + HENCHMAN_TABLE + " WHERE " +
                    "name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
void SetHenchmanDbString(object oPC, string sDataField, string sData, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "UPDATE " + HENCHMAN_TABLE + " SET " + sDataField + " = @data WHERE " +
                    "name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
string GetHenchmanDbString(object oPC, string sDataField, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "SELECT " + sDataField + " FROM " + HENCHMAN_TABLE + " WHERE " +
                    "name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString(sql, "@slot", sSlot);
    if(SqlStep (sql)) return SqlGetString(sql, 0);
    else return "";
}
void SetHenchmanDbJson(object oPC, string sDataField, json jData, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "UPDATE " + HENCHMAN_TABLE + " SET " + sDataField +
                    " = @data WHERE name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString (sql, "@slot", sSlot);
    SqlStep (sql);
}
json GetHenchmanDbJson(object oPC, string sDataField, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "SELECT " + sDataField + " FROM " + HENCHMAN_TABLE + " WHERE " +
                    "name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString (sql, "@slot", sSlot);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
void SetHenchmanDbObject(object oPC, object oHenchman, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "UPDATE " + HENCHMAN_TABLE + " SET henchman = @henchman WHERE " +
                    "name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindObject(sql, "@henchman", oHenchman);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
object GetHenchmanDbObject(object oPC, location lLocationToSpawn, string sSlot)
{
    string sPCName = ai_RemoveIllegalCharacters(GetPCPlayerName(oPC));
    string sQuery = "SELECT henchman FROM " + HENCHMAN_TABLE + " WHERE " +
                    "name = @name AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(HENCHMAN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sPCName);
    SqlBindString (sql, "@slot", sSlot);
    if(AI_DEBUG) ai_Debug("pe_henchman", "262", "sSlot: " + sSlot);
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
void AddSavedCharacterInfo(object oPC, int nToken, string sParty)
{
    string sHenchman = GetHenchmanDbString(oPC, "henchname", sParty);
    // Add Henchman information.
    if(sHenchman != "")
    {
        NuiSetBind (oPC, nToken, "btn_clear_party_event", JsonBool (TRUE));
        string sText = "  Clears Party " + sParty + "'s entire list!";
        NuiSetBind(oPC, nToken, "btn_clear_party_tooltip", JsonString(sText));
        NuiSetBind(oPC, nToken, "btn_join_party", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_join_party_event", JsonBool (TRUE));
        sText = "  Saved party enters the game and joins you!";
        NuiSetBind(oPC, nToken, "btn_join_party_tooltip", JsonString(sText));
        // Setup the henchman window.
        string sName = GetHenchmanDbString(oPC, "henchname", sParty + sHenchman);
        string sImage = GetHenchmanDbString(oPC, "image", sParty + sHenchman);
        string sStats = GetHenchmanDbString(oPC, "stats", sParty + sHenchman);
        string sClasses = GetHenchmanDbString(oPC, "classes", sParty + sHenchman);
        NuiSetBind(oPC, nToken, "lbl_save_char_label", JsonString(sName));
        NuiSetBind(oPC, nToken, "img_saved_portrait_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString(sImage + "l"));
        NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(sStats));
        NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(sClasses));
        NuiSetBind(oPC, nToken, "btn_saved_join_label", JsonString("Join"));
        NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_saved_remove_event", JsonBool(TRUE));
        //NuiSetBind(oPC, nToken, "btn_saved_edit_event", JsonBool(TRUE));
    }
    else
    {
        NuiSetBind(oPC, nToken, "lbl_save_char_label", JsonString("Empty Party"));
        NuiSetBind (oPC, nToken, "btn_clear_party_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_join_party", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_join_party_event", JsonBool (FALSE));
        // Setup the henchman window.
        NuiSetBind(oPC, nToken, "img_saved_portrait_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString("po_hu_m_99_l"));
        NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(""));
        NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_saved_join_label", JsonString("Join"));
        NuiSetBind(oPC, nToken, "btn_saved_remove_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_saved_edit_event", JsonBool(FALSE));
    }
}
void AddCurrentCharacterInfo(object oPC, int nToken, string sParty)
{
    string sHenchman = GetHenchmanDbString(oPC, "image", sParty);
    if(sHenchman == "")
    {
        CheckHenchmanDataAndInitialize(oPC, sParty);
        SetHenchmanDbString(oPC, "image", "0", sParty);
    }
    int nHenchman = StringToInt(sHenchman);
    int nIndex = 0;
    object oCharacter;
    while(nIndex < AI_MAX_HENCHMAN)
    {
        if(nIndex == 0) oCharacter = oPC;
        else oCharacter = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oCharacter == OBJECT_INVALID)
        {
            nIndex = 0;
            oCharacter = oPC;
            break;
        }
        else if(nHenchman == nIndex) break;
        nIndex++;
    }
    // Adjust the party buttons.
    int bParty = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1) != OBJECT_INVALID;
    //NuiSetBind(oPC, nToken, "btn_save_party", JsonBool (bParty));
    NuiSetBind(oPC, nToken, "btn_save_party_event", JsonBool (bParty));
    //NuiSetBind(oPC, nToken, "btn_remove_party", JsonBool (bParty));
    NuiSetBind(oPC, nToken, "btn_remove_party_event", JsonBool (bParty));
    if(bParty)
    {
        string sText = "  Removes all henchman from your current party!";
        NuiSetBind(oPC, nToken, "btn_remove_party_tooltip", JsonString(sText));
    }
    // Setup the henchman window.
    string sName = GetName(oCharacter);
    string sImage = GetPortraitResRef(oCharacter);
    string sStats = GetAlignText(oCharacter) + " ";
    if(GetGender(oCharacter) == GENDER_MALE) sStats += "Male ";
    else sStats += "Female ";
    int nPosition = 1;
    sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oCharacter))));
    string sClasses = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oCharacter))));
    sClasses += IntToString (GetLevelByPosition (nPosition, oCharacter));
    int nClass = GetClassByPosition(++nPosition, oCharacter);
    while(nClass != CLASS_TYPE_INVALID)
    {
        sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oCharacter))));
        nClass = GetClassByPosition(++nPosition, oCharacter);
    }
    NuiSetBind(oPC, nToken, "lbl_game_char_label", JsonString(sName));
    NuiSetBind(oPC, nToken, "img_cur_portrait_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage + "l"));
    NuiSetBind(oPC, nToken, "lbl_cur_stats_label", JsonString(sStats));
    NuiSetBind(oPC, nToken, "lbl_cur_classes_label", JsonString(sClasses));
    NuiSetBind(oPC, nToken, "btn_cur_save_label", JsonString("Save"));
    NuiSetBind(oPC, nToken, "btn_cur_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cur_edit_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cur_remove_event", JsonBool(TRUE));
    //NuiSetBind(oPC, nToken, "btn_cur_edit_event", JsonBool(TRUE));
}
object GetSelectedHenchman(object oPC, string sParty)
{
    string sHenchman = GetHenchmanDbString(oPC, "image", sParty);
    if(sHenchman == "")
    {
        CheckHenchmanDataAndInitialize(oPC, sParty);
        SetHenchmanDbString(oPC, "image", "0", sParty);
    }
    int nHenchman = StringToInt(sHenchman);
    int nIndex = 0;
    object oCharacter;
    while(nIndex < AI_MAX_HENCHMAN)
    {
        if(nIndex == 0) oCharacter = oPC;
        else oCharacter = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oCharacter == OBJECT_INVALID)
        {
            nIndex = 0;
            oCharacter = oPC;
            break;
        }
        else if(nHenchman == nIndex) break;
        nIndex++;
    }
    return oCharacter;
}
void LevelUpYourHenchman(object oPC, int nToken, string sParty)
{
    object oCharacter = GetSelectedHenchman(oPC, sParty);
    if(oCharacter == oPC)
    {
        ai_SendMessages("You cannot level up your player!", AI_COLOR_RED, oPC);
        return;
    }
    int nClass = GetClassByPosition(1, oCharacter);
    int nPackage = GetCreatureStartingPackage(oCharacter);
    int nLevelUp = LevelUpHenchman(oCharacter, nClass, TRUE, nPackage);
    if(nLevelUp == 0) ai_SendMessages(GetName(oCharacter) + " could not level up!", AI_COLOR_RED, oPC);
    else ai_SendMessages(GetName(oCharacter) + " leveled up!", AI_COLOR_GREEN, oPC);
    AddCurrentCharacterInfo(oPC, nToken, sParty);
}
void DestroyYourHenchman(object oHenchman)
{
    SetIsDestroyable(TRUE);
    DestroyObject(oHenchman);
}
void RemoveYourHenchman(object oPC, int nToken, string sParty)
{
    object oHenchman = GetSelectedHenchman(oPC, sParty);
    if(oHenchman == oPC) ai_SendMessages("You cannot remove the player from the party!", AI_COLOR_RED, oPC);
    else
    {
        RemoveHenchman(oPC, oHenchman);
        NuiDestroy(oPC, NuiFindWindow(oPC, ai_GetAssociateType(oPC, oHenchman) + AI_WIDGET_NUI));
        AssignCommand(oHenchman, DestroyYourHenchman(oHenchman));
    }
    ai_SendMessages(GetName(oHenchman) + " has been removed from the party!", AI_COLOR_GREEN, oPC);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}
void RemoveWholeParty(object oPC, int nToken, string sParty)
{
    int nIndex = AI_MAX_HENCHMAN;
    object oHenchman;
    oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(nIndex > 0)
    {
        if(oHenchman != OBJECT_INVALID)
        {
            ai_SendMessages(GetName(oHenchman) + " has been remove from your Party.", AI_COLOR_YELLOW, oPC);
            RemoveHenchman(oPC, oHenchman);
            NuiDestroy(oPC, NuiFindWindow(oPC, ai_GetAssociateType(oPC, oHenchman) + AI_WIDGET_NUI));
            AssignCommand(oHenchman, DestroyYourHenchman(oHenchman));
        }
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, --nIndex);
    }
    ai_SendMessages("All of your henchman have been remove from the Party.", AI_COLOR_YELLOW, oPC);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}
void SaveYourHenchman(object oPC, int nToken, string sParty)
{
    int nIndex, nClass, nPosition, nMaxHenchman = AI_MAX_HENCHMAN + 1;
    string sName, sIndex, sSlot, sStats, sClasses;
    object oHenchman = GetSelectedHenchman(oPC, sParty);
    string sHenchmanName = GetName(oHenchman);
    while(nIndex < nMaxHenchman)
    {
        sIndex = IntToString(nIndex);
        sName = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
        if(sName == sHenchmanName || sName == "")
        {
            sSlot = sParty + sIndex;
            RemoveHenchman(oPC, oHenchman);
            ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
            json jHenchman = ObjectToJson(oHenchman, TRUE);
            AddHenchman(oPC, oHenchman);
            //string sPatch = "[{\"op\":\"replace\",\"path\":\"/FactionID/value\",\"value\":1}]";
            //json jPatch = JsonParse(sPatch);
            //jHenchman = JsonPatch(jHenchman, jPatch);
            CheckHenchmanDataAndInitialize(oPC, sSlot);
            SetHenchmanDbString(oPC, "image", GetPortraitResRef(oHenchman), sSlot);
            SetHenchmanDbString(oPC, "henchname", sHenchmanName, sSlot);
            sStats = GetAlignText(oHenchman) + " ";
            if(GetGender(oHenchman) == GENDER_MALE) sStats += "Male ";
            else sStats += "Female ";
            nPosition = 1;
            sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oHenchman))));
            sClasses = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oHenchman))));
            sClasses += IntToString (GetLevelByPosition (nPosition, oHenchman));
            nClass = GetClassByPosition(++nPosition, oHenchman);
            while(nClass != CLASS_TYPE_INVALID)
            {
                sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oHenchman))));
                nClass = GetClassByPosition(++nPosition, oHenchman);
            }
            SetHenchmanDbString(oPC, "stats", sStats, sSlot);
            SetHenchmanDbString(oPC, "classes", sClasses, sSlot);
            SetHenchmanDbJson(oPC, "henchman", jHenchman, sSlot);
            if(sName == "") ai_SendMessages(sHenchmanName + " has been saved to the party.", AI_COLOR_GREEN, oPC);
            else ai_SendMessages(sHenchmanName + " has replaced a copy of themselves in the party.", AI_COLOR_GREEN, oPC);
            break;
        }
        nIndex++;
    }
    if(nIndex == nMaxHenchman) ai_SendMessages("This party is full!", AI_COLOR_RED, oPC);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}
void SaveWholeParty(object oPC, int nToken, string sParty)
{
    int nIndex = AI_MAX_HENCHMAN;
    object oHenchman;
    while(nIndex > 0)
    {
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oHenchman != OBJECT_INVALID)
        {
            SetHenchmanDbString(oPC, "image", IntToString(nIndex), sParty);
            SaveYourHenchman(oPC, nToken, sParty);
        }
        nIndex--;
    }
    ai_SendMessages("All of your henchman have been saved to Party " + sParty + ".", AI_COLOR_YELLOW, oPC);
    SetHenchmanDbString(oPC, "henchname", "0", sParty);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}
void SavedPartyJoin(object oPC, int nToken, string sParty)
{
    int bFound, nIndex, nDBHenchman = 0;
    json jHenchman;
    object oHenchman, oLoadedHenchman;
    string sDBHenchman = IntToString(nDBHenchman);
    string sName = GetHenchmanDbString(oPC, "henchname", sParty + sDBHenchman);
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
            ai_SendMessages(sName + " has joined your party.", AI_COLOR_GREEN, oPC);
            jHenchman = GetHenchmanDbJson(oPC, "henchman", sParty + sDBHenchman);
            oLoadedHenchman = JsonToObject(jHenchman, GetLocation(oPC), OBJECT_INVALID, TRUE);
            AddHenchman(oPC, oLoadedHenchman);
        }
        else ai_SendMessages(sName + " is already in your party!", AI_COLOR_RED, oPC);
        sDBHenchman = IntToString(++nDBHenchman);
        sName = GetHenchmanDbString(oPC, "henchname", sParty + sDBHenchman);
    }
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}
void SavedCharacterJoin(object oPC, int nToken, string sParty)
{
    int nIndex, bFound;
    object oHenchman, oLoadedHenchman;
    string sHenchman = GetHenchmanDbString(oPC, "henchname", sParty);
    string sName = GetHenchmanDbString(oPC, "henchname", sParty + sHenchman);
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
        oLoadedHenchman = GetHenchmanDbObject(oPC, GetLocation(oPC), sParty + sHenchman);
        AddHenchman(oPC, oLoadedHenchman);
        NuiDestroy(oPC, nToken);
        ExecuteScript("pi_henchmen", oPC);
    }
    else ai_SendMessages(sName + " is already in your party!", AI_COLOR_RED, oPC);
}
void SavedPartyCleared(object oPC, int nToken, string sParty)
{
    int nIndex, nMaxHenchman = AI_MAX_HENCHMAN + 1;
    object oHenchman, oLoadedHenchman;
    string sIndex = IntToString(nIndex);
    string sName = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
    while(nIndex < nMaxHenchman)
    {
        if(sName != "")
        {
            RemoveHenchmanDb(oPC, sParty + sIndex);
            ai_SendMessages(sName + " has been cleared from the saved party " + sParty + ".", AI_COLOR_YELLOW, oPC);
        }
        sIndex = IntToString(++nIndex);
        sName = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
    }
    SetHenchmanDbString(oPC, "henchname", "", sParty);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}


