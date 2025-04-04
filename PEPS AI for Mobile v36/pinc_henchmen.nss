/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pinc_henchmen
////////////////////////////////////////////////////////////////////////////////
 Include file for Henchmen plug in scripts for Philos Module Extentions.

Database Info:
Slot 0 - henchname = the save slot 1 - 8.
Slots 1 - 8 define the selections:
            henchname = Saved character selected.
            image = Current character selected.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "nw_inc_gff"

const string HENCHMAN_DATABASE = "philos_henchman_db";
const string HENCHMAN_TABLE = "HENCHMAN_TABLE";
const string HENCHMAN_TO_EDIT = "HENCHMAN_TO_EDIT";

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
// Sets oHenchmans scripts to the current AI.
void SetHenchmanScripts(object oHenchman);
// Creates a menu to edit a characters information.
void CreateCharacterEditGUIPanel(object oPC, object oAssociate);
// Creates a character description menu.
void CreateCharacterDescriptionNUI(object oPC, string sName, string sIcon, string sDescription);

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
    if (SqlStep (sql))
    {
        json jHenchman = SqlGetJson(sql, 0);
        string sTag = JsonGetString(GffGetString(jHenchman, "Tag"));
        if(sTag == "") jHenchman = GffReplaceString(jHenchman, "Tag", "Hench_" + IntToString(Random(100)));
        return JsonToObject(jHenchman, lLocationToSpawn, OBJECT_INVALID, TRUE);
    }
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
    sClasses += " " + IntToString (GetLevelByPosition (nPosition, oCharacter));
    int nClass = GetClassByPosition(++nPosition, oCharacter);
    while(nClass != CLASS_TYPE_INVALID)
    {
        sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", nClass)));
        sClasses += " " + IntToString (GetLevelByPosition (nPosition, oCharacter));
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
void RemoveYourHenchman(object oPC, int nToken, string sParty)
{
    object oHenchman = GetSelectedHenchman(oPC, sParty);
    if(oHenchman == oPC) ai_SendMessages("You cannot remove the player from the party!", AI_COLOR_RED, oPC);
    else
    {
        RemoveHenchman(oPC, oHenchman);
        AssignCommand(oHenchman, SetIsDestroyable(TRUE, FALSE, FALSE));
        NuiDestroy(oPC, NuiFindWindow(oPC, ai_GetAssociateType(oPC, oHenchman) + AI_WIDGET_NUI));
        DestroyObject(oHenchman);
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
            AssignCommand(oHenchman, SetIsDestroyable(TRUE, FALSE, FALSE));
            NuiDestroy(oPC, NuiFindWindow(oPC, ai_GetAssociateType(oPC, oHenchman) + AI_WIDGET_NUI));
            DestroyObject(oHenchman);
        }
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, --nIndex);
    }
    ai_SendMessages("All of your henchman have been remove from the Party.", AI_COLOR_YELLOW, oPC);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_henchmen", oPC);
}
void SaveYourHenchman(object oPC, int nToken, string sParty)
{
    int bPC, nIndex, nClass, nPosition, nMaxHenchman = AI_MAX_HENCHMAN + 1;
    string sName, sIndex, sSlot, sStats, sClasses;
    object oHenchman = GetSelectedHenchman(oPC, sParty);
    if(oHenchman == oPC)
    {
        bPC = TRUE;
        oHenchman = CopyObject(oPC, GetLocation(oPC), OBJECT_INVALID, "hench_" + IntToString(Random(100)), TRUE);
        SetHenchmanScripts(oHenchman);
    }
    string sHenchmanName = GetName(oHenchman);
    while(nIndex < nMaxHenchman)
    {
        sIndex = IntToString(nIndex);
        sName = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
        if(sName == sHenchmanName || sName == "")
        {
            sSlot = sParty + sIndex;
            if(!bPC) RemoveHenchman(oPC, oHenchman);
            ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
            json jHenchman = ObjectToJson(oHenchman, TRUE);
            if(!bPC) AddHenchman(oPC, oHenchman);
            else DestroyObject(oHenchman);
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
            sClasses += " " + IntToString (GetLevelByPosition (nPosition, oHenchman));
            nClass = GetClassByPosition(++nPosition, oHenchman);
            while(nClass != CLASS_TYPE_INVALID)
            {
                sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oHenchman))));
                sClasses += " " + IntToString (GetLevelByPosition (nPosition, oHenchman));
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
json CreateOptionsClasses(object oHenchman)
{
    int nIndex = 1, nClass;
    string sClassName;
    json jClassNameList = JsonArray();
    while(nIndex < 5)
    {
        nClass = GetClassByPosition(nIndex, oHenchman);
        if(nClass == CLASS_TYPE_INVALID) sClassName = "Empty";
        else
        {
            sClassName = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
            sClassName += " " + IntToString(GetLevelByClass(nClass, oHenchman));
        }
        JsonArrayInsertInplace(jClassNameList, JsonString(sClassName));
        nIndex++;
    }
    return jClassNameList;
}
json jArrayInsertClasses()
{
    int nIndex, nClass, nMaxClass = Get2DARowCount("classes");
    string sClassName;
    json jClassNameCombo = JsonArray();
    while(nIndex < nMaxClass)
    {
        if(Get2DAString("classes", "PlayerClass", nIndex) == "1")
        {
            sClassName = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nIndex)));
            JsonArrayInsertInplace(jClassNameCombo, NuiComboEntry(sClassName, nClass));
            nClass++;
        }
        nIndex++;
    }
    return jClassNameCombo;
}
int GetSelectionByClass2DA(int nClass)
{
    int nIndex, nSelection, nMaxClass = Get2DARowCount("classes");
    while(nIndex < nMaxClass)
    {
        if(Get2DAString("classes", "PlayerClass", nIndex) == "1")
        {
            if(nClass == nIndex) return nSelection;
            nSelection++;
        }
        nIndex++;
    }
    return -1;
}
int GetClassBySelection2DA(int nSelection)
{
    int nIndex, nClass, nMaxClass = Get2DARowCount("classes");
    while(nClass < nMaxClass)
    {
        if(Get2DAString("classes", "PlayerClass", nClass) == "1")
        {
            if(nSelection == nIndex) return nClass;
            nIndex++;
        }
        nClass++;
    }
    return -1;
}
json jArrayInsertPackages(string sClass)
{
    int nIndex, nPackage, nMaxPackage = Get2DARowCount("packages");
    string sPackageName;
    json jPackageNameCombo = JsonArray();
    while(nIndex < nMaxPackage)
    {
        if(Get2DAString("packages", "ClassID", nIndex) == sClass)
        {
            sPackageName = GetStringByStrRef(StringToInt(Get2DAString("packages", "Name", nIndex)));
            JsonArrayInsertInplace(jPackageNameCombo, NuiComboEntry(sPackageName, nPackage));
            nPackage++;
        }
        nIndex++;
    }
    return jPackageNameCombo;
}
int GetSelectionByPackage2DA(string sClass, int nPackage)
{
    int nIndex, nSelection, nMaxPackage = Get2DARowCount("packages");
    while(nIndex < nMaxPackage)
    {
        if(Get2DAString("packages", "ClassID", nIndex) == sClass)
        {
            if(nPackage == nIndex) return nSelection;
            nSelection++;
        }
        nIndex++;
    }
    return -1;
}
int GetPackageBySelection2DA(string sClass, int nSelection)
{
    int nIndex, nPackage, nMaxPackage = Get2DARowCount("packages");
    while(nPackage < nMaxPackage)
    {
        if(Get2DAString("packages", "ClassID", nPackage) == sClass)
        {
            if(nSelection == nIndex) return nPackage;
            nIndex++;
        }
        nPackage++;
    }
    return -1;
}
json jArrayInsertSoundSets(object oHenchman)
{
    int nIndex, nSoundSet, nSoundSetType, nMaxSets = Get2DARowCount("soundset");
    string sGender = IntToString(GetGender(oHenchman));
    string sSoundSetName;
    json jSoundSetNameCombo = JsonArray();
    while(nIndex < nMaxSets)
    {
        if(Get2DAString("soundset", "GENDER", nIndex) == sGender)
        {
            nSoundSetType = StringToInt(Get2DAString("soundset", "TYPE", nIndex));
            if(nSoundSetType < 4)
            {
                sSoundSetName = GetStringByStrRef(StringToInt(Get2DAString("soundset", "STRREF", nIndex)));
                JsonArrayInsertInplace(jSoundSetNameCombo, NuiComboEntry(sSoundSetName, nSoundSet));
                nSoundSet++;
            }
        }
        nIndex++;
    }
    return jSoundSetNameCombo;
}
int GetSelectionBySoundSet2DA(object oHenchman, int nSoundSet)
{
    int nIndex, nSelection, nSoundSetType, nMaxSoundSet = Get2DARowCount("soundset");
    string sGender = IntToString(GetGender(oHenchman));
    while(nIndex < nMaxSoundSet)
    {
        if(Get2DAString("soundset", "GENDER", nIndex) == sGender)
        {
            nSoundSetType = StringToInt(Get2DAString("soundset", "TYPE", nIndex));
            if(nSoundSetType < 4)
            {
                if(nSoundSet == nIndex) return nSelection;
                nSelection++;
            }
        }
        nIndex++;
    }
    return -1;
}
int GetSoundSetBySelection2DA(object oHenchman, int nSelection)
{
    int nIndex, nSoundSet, nSoundSetType, nMaxSoundSet = Get2DARowCount("soundset");
    string sGender = IntToString(GetGender(oHenchman));
    while(nSoundSet < nMaxSoundSet)
    {
        if(Get2DAString("soundset", "GENDER", nSoundSet) == sGender)
        {
            nSoundSetType = StringToInt(Get2DAString("soundset", "TYPE", nSoundSet));
            if(nSoundSetType < 4)
            {
                if(nSelection == nIndex) return nSoundSet;
                nIndex++;
            }
        }
        nSoundSet++;
    }
    return -1;
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
// ********* New Henchman windows **********
void CreateCharacterEditGUIPanel(object oPC, object oHenchman)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Group 1 (Portrait)******************************************************* 151 / 73
    // Group 1 Row 1 *********************************************************** 350 / 91
    json jRow = JsonArray();
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox (jGroupRow, "name_placeholder", "char_name", 15, FALSE, 140.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 1 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox (jGroupRow, "port_placeholder", "port_name", 15, FALSE, 140.0, 20.0, "port_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 2 *********************************************************** 350 / 259
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateImage(jGroupRow, "", "port_resref", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 140.0f, 160.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 3 *********************************************************** 350 / 292
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton (jGroupRow, "<", "btn_portrait_prev", 42.0f, 25.0f);
    CreateButton (jGroupRow, "Set", "btn_portrait_ok", 44.0f, 25.0f);
    CreateButton (jGroupRow, ">", "btn_portrait_next", 42.0f, 25.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 4 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateLabel(jGroupRow, "Sound Set", "lbl_sound_set", 140.0, 10.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 5 *********************************************************** 350 / 325
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateCombo(jGroupRow, jArrayInsertSoundSets(oHenchman), "cmb_soundset", 140.0, 25.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Group 2 (Stats)********************************************************** 151 / 73
    // Group 2 Row 1 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    jGroupCol = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateLabel(jGroupRow, "", "lbl_stats", 150.0, 15.0, 0, NUI_VALIGN_BOTTOM, 0.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 2 *********************************************************** 350 / 243
    jGroupRow = JsonArray();
    json jClasses = CreateOptionsClasses(oHenchman);
    CreateOptions(jGroupRow, "opt_classes", NUI_DIRECTION_VERTICAL, jClasses, 150.0, 144.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 3 *********************************************************** 350 / 276
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton (jGroupRow, "Level Up", "btn_level_up", 150.0f, 25.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 4 *********************************************************** 350 / 309
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton (jGroupRow, "Level Down", "btn_level_down", 150.0f, 25.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 5 *********************************************************** 350 / 342
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateCombo(jGroupRow, jArrayInsertClasses(), "cmb_class", 150.0, 25.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 6 *********************************************************** 350 / 375
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    int nClassOption = GetLocalInt(oHenchman, "CLASS_OPTION_POSITION");
    int nClass = GetClassByPosition(nClassOption + 1, oHenchman);
    int bNoClass = FALSE;
    if(nClass == CLASS_TYPE_INVALID)
    {
        nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nClassOption + 1));
        bNoClass = TRUE;
    }
    string sClass = IntToString(nClass);
    CreateCombo(jGroupRow, jArrayInsertPackages(sClass), "cmb_package", 150.0, 25.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 (text edit box)**************************************************** 350 / 518
    jRow = JsonArray();
    CreateTextEditBox (jRow, "desc_placeholder", "desc_value", 1000, TRUE, 350.0, 150.0, "desc_tooltip");
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow (jRow));
    // Row 6 (button)*********************************************************** 350/ 546
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton (jRow, "Save Description", "btn_desc_save", 150.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow (jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    CheckHenchmanDataAndInitialize(oPC, "0");
    json jData = GetHenchmanDbJson(oPC, "henchman", "0");
    json jGeometry = JsonObjectGet(jData, "henchman_edit_nui");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    if(fX == 0.0 && fY == 0.0)
    {
        fX = -1.0;
        fY = -1.0;
    }
    string sName = GetName(oHenchman);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow (oPC, jLayout, "henchman_edit_nui", sName + " Character editor",
                            fX, fY, 380.0, 588.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_henchmen");
    // Set all binds, events, and watches.
    int nID = GetPortraitId (oPC);
    NuiSetUserData(oPC, nToken, JsonInt(nID));
    string sResRef = GetPortraitResRef(oHenchman);
    NuiSetBind(oPC, nToken, "char_name_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_name", JsonString(GetName(oHenchman)));
    NuiSetBindWatch(oPC, nToken, "char_name", TRUE);
    NuiSetBind(oPC, nToken, "port_name_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "port_name", TRUE);
    NuiSetBind(oPC, nToken, "port_name", JsonString(sResRef));
    NuiSetBind(oPC, nToken, "port_resref_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "port_resref_image", JsonString(sResRef + "l"));
    NuiSetBind(oPC, nToken, "port_tooltip", JsonString ("  You may also type the portrait file name."));
    // Set buttons active.
    NuiSetBind(oPC, nToken, "btn_portrait_prev_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_next_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "cmb_soundset_event", JsonBool(TRUE));
    int nSelection = GetSelectionBySoundSet2DA(oHenchman, GetSoundset(oHenchman));
    NuiSetBind(oPC, nToken, "cmb_soundset_selected", JsonBool(nSelection));
    NuiSetBindWatch(oPC, nToken, "cmb_soundset_selected", TRUE);
    NuiSetBind(oPC, nToken, "btn_desc_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_ok_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "desc_tooltip", JsonString("  You can use color codes!"));
    string sDescription = GetDescription(oHenchman);
    NuiSetBind(oPC, nToken, "desc_value_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "desc_value", JsonString (sDescription));
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Setup the henchman window.
    string sStats = GetAlignText(oHenchman) + " ";
    if(GetGender(oHenchman) == GENDER_MALE) sStats += "Male ";
    else sStats += "Female ";
    sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oHenchman))));
    NuiSetBind(oPC, nToken, "lbl_stats_label", JsonString(sStats));
    json jHenchman = ObjectToJson(oHenchman);
    json jLvlStatList = JsonObjectGet(jHenchman, "LvlStatList");
    int bLevelUp = JsonGetType(jLvlStatList) != JSON_TYPE_NULL;
    NuiSetBind(oPC, nToken, "opt_classes_event", JsonBool(bLevelUp));
    NuiSetBind(oPC, nToken, "opt_classes_value", JsonInt(nClassOption));
    NuiSetBind(oPC, nToken, "btn_level_up_event", JsonBool(bLevelUp));
    NuiSetBind(oPC, nToken, "btn_level_down_event", JsonBool(bLevelUp));
    NuiSetBind(oPC, nToken, "cmb_class_event", JsonBool(bNoClass));
    NuiSetBindWatch(oPC, nToken, "cmb_class_selected", bNoClass);
    nSelection = GetSelectionByClass2DA(nClass);
    NuiSetBind(oPC, nToken, "cmb_class_selected", JsonInt(nSelection));
    NuiSetBind(oPC, nToken, "cmb_package_event", JsonBool(bNoClass));
    NuiSetBindWatch(oPC, nToken, "cmb_package_selected", bNoClass);
    int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1));
    if(nPackage == 0)
    {
        if(GetClassByPosition(1, oHenchman) == nClass) nPackage = GetCreatureStartingPackage(oHenchman);
        else nPackage = GetPackageBySelection2DA(sClass, 0);
        SetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1), nPackage);
    }
    NuiSetBind(oPC, nToken, "cmb_package_selected", JsonInt(GetSelectionByPackage2DA(sClass, nPackage)));
}
void CreateCharacterDescriptionNUI(object oPC, string sName, string sIcon, string sDescription)
{
    json jRow = JsonArray();
    json jCol = JsonArray();
    // Row 1 ******************************************************************* 500 / 469
    CreateImage(jRow, "", "char_icon", NUI_ASPECT_FIT, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 40.0, 40.0);
    CreateTextBox(jRow, "char_text", 380.0, 400.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 522
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "OK", "btn_ok", 150.0f, 45.0f);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "char_description_nui", sName,
                             -1.0, -1.0, 460.0f, 537.0 + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_henchmen");
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Row 1
    NuiSetBind(oPC, nToken, "char_icon_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_icon_image", JsonString(sIcon));
    NuiSetBind(oPC, nToken, "char_text_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_text", JsonString(sDescription));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_ok_event", JsonBool(TRUE));
}

