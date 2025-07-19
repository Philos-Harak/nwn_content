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
// If a henchman does not have a LvlStatList this will create one for them.
// nLevels allows the creation of x levels for LvlStatList using the 1st class.
// 0 on nLevels makes the function build it based on current levels.
json CreateLevelStatList(json jHenchman, object oHenchman, object oPC, int nLevels = 0);
// Resets the character to level one in the first class.
object ResetCharacter(object oPC, object oHenchman);
// Creates a menu to edit a characters information.
void CreateCharacterEditGUIPanel(object oPC, object oAssociate);
// Creates a character description menu.
void CreateCharacterDescriptionNUI(object oPC, string sName, string sIcon, string sDescription);

void CreateHenchmanDataTable ()
{
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
        string sText = "  Clears all characters from party " + sParty + "'s list!";
        NuiSetBind(oPC, nToken, "btn_clear_party_tooltip", JsonString(sText));
        NuiSetBind(oPC, nToken, "btn_join_party", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_join_party_event", JsonBool (TRUE));
        sText = "  Saved characters from party " + sParty + " enter the game and join you.";
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
        string sText = "  Saves all henchman from your current party to party " + sParty + ".";
        NuiSetBind(oPC, nToken, "btn_save_party_tooltip", JsonString(sText));
        sText = "  Removes all henchman from your current party!";
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
            // Special check for Infinite Dungeon plot givers to be changed into henchman.
            if(GetStringLeft(GetLocalString(oHenchman, "sConversation"), 8) == "id1_plot")
            {
                DeleteLocalString(oHenchman, "sConversation");
            }
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
json CreateOptionsAlignment(object oHenchman, int nAlignType)
{
    json jAlignNameList = JsonArray();
    if(nAlignType == 0)
    {
        jAlignNameList = JsonArrayInsert(jAlignNameList, JsonString("Lawful"));
        jAlignNameList = JsonArrayInsert(jAlignNameList, JsonString("Neutral"));
        jAlignNameList = JsonArrayInsert(jAlignNameList, JsonString("Chaotic"));
    }
    else
    {
        jAlignNameList = JsonArrayInsert(jAlignNameList, JsonString("Good"));
        jAlignNameList = JsonArrayInsert(jAlignNameList, JsonString("Neutral"));
        jAlignNameList = JsonArrayInsert(jAlignNameList, JsonString("Evil"));
    }
    return jAlignNameList;
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
        jClassNameList = JsonArrayInsert(jClassNameList, JsonString(sClassName));
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
            jClassNameCombo = JsonArrayInsert(jClassNameCombo, NuiComboEntry(sClassName, nClass));
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
json ArrayInsertPackages(string sClass)
{
    int nIndex, nPackage, nMaxPackage = Get2DARowCount("packages");
    string sPackageName;
    json jPackageNameCombo = JsonArray();
    while(nIndex < nMaxPackage)
    {
        if(Get2DAString("packages", "ClassID", nIndex) == sClass)
        {
            sPackageName = Get2DAString("packages", "Label", nIndex);
            //GetStringByStrRef(StringToInt(Get2DAString("packages", "Name", nIndex)));
            if(sPackageName != "Bad Strref" && sPackageName != "")
            {
                jPackageNameCombo = JsonArrayInsert(jPackageNameCombo, NuiComboEntry(sPackageName, nPackage));
                nPackage++;
            }
        }
        nIndex++;
    }
    return jPackageNameCombo;
}
int GetSelectionByPackage2DA(string sClass, int nPackage)
{
    int nIndex, nSelection, nMaxPackage = Get2DARowCount("packages");
    string sPackageName;
    while(nIndex < nMaxPackage)
    {
        if(Get2DAString("packages", "ClassID", nIndex) == sClass)
        {
            sPackageName = GetStringByStrRef(StringToInt(Get2DAString("packages", "Name", nIndex)));
            if(sPackageName != "Bad Strref" && sPackageName != "")
            {
                if(nPackage == nIndex) return nSelection;
                nSelection++;
            }
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
json ArrayInsertSoundSets(object oHenchman)
{
    int nIndex, nSoundSet, nSoundSetType, nMaxSets = Get2DARowCount("soundset");
    string sGender = IntToString(GetGender(oHenchman));
    string sSoundSetName, sResRef;
    json jSoundSetNameCombo = JsonArray();
    while(nIndex < nMaxSets)
    {
        if(Get2DAString("soundset", "GENDER", nIndex) == sGender)
        {
            nSoundSetType = StringToInt(Get2DAString("soundset", "TYPE", nIndex));
            if(nSoundSetType < 5)
            {
                sSoundSetName = GetStringByStrRef(StringToInt(Get2DAString("soundset", "STRREF", nIndex)));
                sResRef = GetStringLowerCase(Get2DAString("soundset", "RESREF", nIndex));
                if(GetStringLeft(sResRef, 4) == "vs_f") sSoundSetName += " (Full)";
                else if(GetStringLeft(sResRef, 4) == "vs_n") sSoundSetName += " (Part)";
                jSoundSetNameCombo = JsonArrayInsert(jSoundSetNameCombo, NuiComboEntry(sSoundSetName, nSoundSet));
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
            if(nSoundSetType < 5)
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
            if(nSoundSetType < 5)
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
object ai_AddHenchman(object oPC, json jHenchman, location lLocation, int nFamiliar, int nCompanion)
{
    jHenchman = GffReplaceResRef(jHenchman, "ScriptSpawn", "");
    object oHenchman = JsonToObject(jHenchman, lLocation, OBJECT_INVALID, TRUE);
    AddHenchman(oPC, oHenchman);
    DeleteLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE");
    string sAssociateType = ai_GetAssociateType(oPC, oHenchman);
    NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
    if(nFamiliar) SummonFamiliar(oHenchman);
    if(nCompanion) SummonAnimalCompanion(oHenchman);
    return oHenchman;
}
json CreateLevelStatList(json jHenchman, object oHenchman, object oPC, int nLevels = 0)
{
    int nClass = GetClassByPosition(1, oHenchman);
    int nHitDie = StringToInt(Get2DAString("classes", "HitDie", nClass));
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    json jSkill = JsonObject();
    jSkill = GffAddByte(jSkill, "Rank", 0);
    jSkill = JsonObjectSet(jSkill, "__struct_id", JsonInt(0));
    json jSkillArray = JsonArray();
    int nNumOfSkills;
    for(nNumOfSkills = Get2DARowCount("skills"); nNumOfSkills > 0; nNumOfSkills--)
    {
        jSkillArray = JsonArrayInsert(jSkillArray, jSkill);
    }
    json jLevel = JsonObject();
    jLevel = GffAddByte(jLevel, "EpicLevel", 0);
    jLevel = GffAddList(jLevel, "FeatList", JsonArray());
    jLevel = GffAddByte(jLevel, "LvlStatClass", nClass);
    jLevel = GffAddByte(jLevel, "LvlStatHitDie", nHitDie);
    jLevel = GffAddList(jLevel, "SkillList", jSkillArray);
    jLevel = GffAddWord(jLevel, "SkillPoints", 0);
    jLevel = JsonObjectSet(jLevel, "__struct_id", JsonInt(0));
    json jLevelArray = JsonArray();
    if(nLevels == 0) nLevels = GetLevelByPosition(1, oHenchman);
    for(nLevels; nLevels > 0; nLevels--)
    {
        jLevelArray = JsonArrayInsert(jLevelArray, jLevel);
    }
    WriteTimestampedLogEntry("pinc_henchmen, 813, Adding LvlStatList to " + GetName(oHenchman));
    return GffAddList(jHenchman, "LvlStatList", jLevelArray);
}
int CanSelectFeat(json jCreature, object oCreature, int nFeat, int nPosition = 1)
{
    // Check if all classes can use.
    int n2DAStat = StringToInt(Get2DAString("feat", "ALLCLASSESCANUSE", nFeat));
    if(n2DAStat == 0)
    {
        int bPass, nClassFeat, nRow, nClass = GetClassByPosition(nPosition, oCreature);
        string sClsFeat2DAName = Get2DAString("classes", "FeatsTable", nClass);
        int nMaxRow = Get2DARowCount(sClsFeat2DAName);
        while(nRow < nMaxRow)
        {
            nClassFeat = StringToInt(Get2DAString(sClsFeat2DAName, "FeatIndex", nRow));
            if(nClassFeat == nFeat)
            {
                bPass = TRUE;
                break;
            }
            nRow++;
        }
        if(!bPass) return FALSE;
    }
    n2DAStat = StringToInt(Get2DAString("feat", "MINATTACKBONUS", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "BaseAttackBonus")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MINSTR", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "Str")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MINDEX", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "Dex")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MINCON", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "Con")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MININT", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "Int")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MINWIS", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "Wis")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MINCHA", nFeat));
    if(JsonGetInt(GffGetByte(jCreature, "Cha")) < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "MINSPELLLVL", nFeat));
    int nSpellLevel = 0, nClass = GetClassByPosition(nPosition, oCreature);
    string s2DAName = Get2DAString("classes", "SpellGainTable", nClass);
    int nLevel = GetLevelByPosition(nPosition, oCreature);
    if(s2DAName != "")
    {
        nSpellLevel = StringToInt(Get2DAString(s2DAName, "NumSpellLevels", nLevel - 1)) - 1;
    }
    if(nSpellLevel < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "PREREQFEAT1", nFeat));
    if(n2DAStat > 0)
    {
        // ************************************** Add code to search jCreature's feats!
        if(!GetHasFeat(n2DAStat, oCreature)) return FALSE;
        n2DAStat = StringToInt(Get2DAString("feat", "PREREQFEAT2", nFeat));
        if(!GetHasFeat(n2DAStat, oCreature)) return FALSE;
    }
    int nIndex;
    while(nIndex < 5)
    {
        n2DAStat = StringToInt(Get2DAString("feat", "OrReqFeat" + IntToString(nIndex), nFeat));
        if(nIndex == 0 && n2DAStat == 0) break;
        if(GetHasFeat(n2DAStat, oCreature)) break;
        nIndex++;
        if(nIndex == 5) return FALSE;
    }
    string s2DAStat = Get2DAString("feat", "REQSKILL", nFeat);
    if(s2DAStat != "")
    {
        n2DAStat = StringToInt(s2DAStat);
        int bCanUse;
        if(Get2DAString("skills", "AllClassesCanUse", n2DAStat) == "1") bCanUse = TRUE;
        else
        {
            string sClsSkill2DA = Get2DAString("classes", "SkillsTable", nClass);
            int bPass, nClassSkill, nRow, nMaxRow = Get2DARowCount(sClsSkill2DA);
            while(nRow < nMaxRow)
            {
                nClassSkill = StringToInt(Get2DAString(sClsSkill2DA, "SkillIndex", nRow));
                if(nClassSkill == n2DAStat)
                {
                    bCanUse = TRUE;
                    break;
                }
                nRow++;
            }
        }
        if(bCanUse)
        {
            int nSkillReq = StringToInt(Get2DAString("feat", "ReqSkillMinRanks", n2DAStat));
            // ************************** Add code to check jCreatures skills.
            if(GetSkillRank(n2DAStat, oCreature, TRUE) < nSkillReq) return FALSE;
        }
        else return FALSE;
    }
    s2DAStat = Get2DAString("feat", "REQSKILL2", nFeat);
    if(s2DAStat != "")
    {
        n2DAStat = StringToInt(s2DAStat);
        int bCanUse;
        if(Get2DAString("skills", "AllClassesCanUse", n2DAStat) == "1") bCanUse = TRUE;
        else
        {
            string sClsSkill2DA = Get2DAString("classes", "SkillsTable", nClass);
            int bPass, nClassSkill, nRow, nMaxRow = Get2DARowCount(sClsSkill2DA);
            while(nRow < nMaxRow)
            {
                nClassSkill = StringToInt(Get2DAString(sClsSkill2DA, "SkillIndex", nRow));
                if(nClassSkill == n2DAStat)
                {
                    bCanUse = TRUE;
                    break;
                }
                nRow++;
            }
        }
        if(bCanUse)
        {
            int nSkillReq = StringToInt(Get2DAString("feat", "ReqSkillMinRanks2", n2DAStat));
            if(GetSkillRank(n2DAStat, oCreature, TRUE) < nSkillReq) return FALSE;
        }
        else return FALSE;
    }
    n2DAStat = StringToInt(Get2DAString("feat", "MinLevel", nFeat));
    if(n2DAStat > 0)
    {
        int bPass, nClassPosition, nPositionClass, nPositionLevel;
        int nClassRequired = StringToInt(Get2DAString("feat", "MinLevelClass", nFeat));
        while(nClassPosition < AI_MAX_CLASSES_PER_CHARACTER)
        {
            // ***************************** Rework to check jCreature class list instead.
            nPositionClass = GetClassByPosition(nClassPosition, oCreature);
            if(nPositionClass == nClassRequired)
            {
                nPositionLevel = GetLevelByPosition(nClassPosition, oCreature);
                if(nPositionLevel < n2DAStat) return FALSE;
                else bPass = TRUE;
            }
            nClassPosition++;
        }
        if(!bPass) return FALSE;
    }
    n2DAStat = StringToInt(Get2DAString("feat", "MinFortSave", nFeat));
    if(JsonGetInt(GffGetChar(jCreature, "FortSaveThrow")) < n2DAStat) return FALSE;
    s2DAStat = Get2DAString("feat", "PreReqEpic", nFeat);
    if(s2DAStat == "1") return FALSE;
    return TRUE;
}
json ResetFeats(json jHenchman, object oHenchman)
{
    int nLevel = 0;
    // We remake the Feat list if the character doesn't have a level list!
    json jFeatList = JsonArray();
    json jFeat;
    int nRace = GetRacialType(oHenchman);
    string sRace2DAName = Get2DAString("racialtypes", "FeatsTable", nRace);
    // Give racial feats.
    int nRaceRow, nRaceFeat;
    int nRaceMaxRow = Get2DARowCount(sRace2DAName);
    while(nRaceRow < nRaceMaxRow)
    {
        nRaceFeat = StringToInt(Get2DAString(sRace2DAName, "FeatIndex", nRaceRow));
        jFeat = JsonObject();
        jFeat = GffAddWord(jFeat, "Feat", nRaceFeat);
        jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
        jFeatList = JsonArrayInsert(jFeatList, jFeat);
        WriteTimestampedLogEntry("pinc_henchmen, 973, Adding racial feat: " +
                      Get2DAString("feat", "LABEL", nRaceFeat));
        nRaceRow++;
    }
    // Give class feats.
    int nClass = GetClassByPosition(1, oHenchman);
    string sGranted, sList;
    string sClsFeat2DAName = Get2DAString("classes", "FeatsTable", nClass);
    int nClassRow, nClassFeat, nClassMaxRow = Get2DARowCount(sClsFeat2DAName);
    while(nClassRow < nClassMaxRow)
    {
        sGranted = Get2DAString(sClsFeat2DAName, "GrantedOnLevel", nClassRow);
        if(sGranted == "1")
        {
            sList = Get2DAString(sClsFeat2DAName, "List", nClassRow);
            if(sList == "3")
            {
                nClassFeat = StringToInt(Get2DAString(sClsFeat2DAName, "FeatIndex", nClassRow));
                jFeat = JsonObject();
                jFeat = GffAddWord(jFeat, "Feat", nClassFeat);
                jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
                jFeatList = JsonArrayInsert(jFeatList, jFeat);
                WriteTimestampedLogEntry("pinc_henchmen, 995, Adding class feat: " +
                           Get2DAString("feat", "LABEL", nClassFeat));
            }
        }
        nClassRow++;
    }
    // Give any bonus feats from package.
    int nPackageFeat, nPackageRow;
    string sBonusFeat2DAName = Get2DAString("classes", "BonusFeatsTable", nClass);
    int nNumOfFeats = StringToInt(Get2DAString(sBonusFeat2DAName, "Bonus", nLevel));
    string sPackage2DAName = Get2DAString("packages", "FeatPref2DA", nClass);
    int nPackageMaxRow = Get2DARowCount(sPackage2DAName);
    // Give bonus feats based on the package.
    nPackageRow = 0;
    if(nNumOfFeats > 0)
    {
        while(nPackageRow < nPackageMaxRow)
        {
            nPackageFeat = StringToInt(Get2DAString(sPackage2DAName, "FeatIndex", nPackageRow));
            nClassRow = 0;
            while(nClassRow < nClassMaxRow)
            {
                nClassFeat = StringToInt(Get2DAString(sClsFeat2DAName, "FeatIndex", nClassRow));
                if(nClassFeat == nPackageFeat)
                {
                    sList = Get2DAString(sClsFeat2DAName, "List", nClassRow);
                    if((sList == "1" || sList == "2") && CanSelectFeat(jHenchman, oHenchman, nClassFeat))
                    {
                        jFeat = JsonObject();
                        jFeat = GffAddWord(jFeat, "Feat", nClassFeat);
                        jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
                        jFeatList = JsonArrayInsert(jFeatList, jFeat);
                        WriteTimestampedLogEntry("pinc_henchmen, 1028, Adding class bonus feat: " +
                                  Get2DAString("feat", "LABEL", nPackageFeat));
                        nNumOfFeats--;
                    }
                }
                nClassRow++;
            }
            if(nNumOfFeats < 1) break;
            nPackageRow++;
        }
    }
    // Give picked feats from package.
    nNumOfFeats = 1;
    if(GetHasFeat(FEAT_QUICK_TO_MASTER, oHenchman)) nNumOfFeats++;
    nPackageRow = 0;
    while(nPackageRow < nPackageMaxRow)
    {
        nClassRow = 0;
        nPackageFeat = StringToInt(Get2DAString(sPackage2DAName, "FeatIndex", nPackageRow));
        if(CanSelectFeat(jHenchman, oHenchman, nPackageFeat))
        {
            jFeat = JsonObject();
            jFeat = GffAddWord(jFeat, "Feat", nPackageFeat);
            jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
            jFeatList = JsonArrayInsert(jFeatList, jFeat);
            WriteTimestampedLogEntry("pinc_henchmen, 1053, Adding character bonus feat: " +
                          Get2DAString("feat", "LABEL", nPackageFeat));
            nNumOfFeats--;
        }
        if(nNumOfFeats < 1) break;
        nPackageRow++;
    }
    jHenchman = GffReplaceList(jHenchman, "FeatList", jFeatList);
    return jHenchman;
}
json ResetSkills(json jHenchman, object oHenchman)
{
    // We remake the Skill List if the character doesn't have a level list!
    int nClass = GetClassByPosition(1, oHenchman);
    int nSkillPoints, nIntMod = GetAbilityModifier(ABILITY_INTELLIGENCE, oHenchman);
    if(nIntMod > 0) nSkillPoints = nIntMod * 4;
    if(GetRacialType(oHenchman) == RACIAL_TYPE_HUMAN) nSkillPoints += 4;
    nSkillPoints += StringToInt(Get2DAString("classes", "SkillPointBase", nClass)) * 4;
    int nMaxRanks = 5;
    json jSkillList = JsonArray();
    json jSkill;
    // Setup the Skill List.
    int nIndex, nSkillMaxRow = Get2DARowCount("skills");
    for(nIndex = 0; nIndex < nSkillMaxRow; nIndex++)
    {
        jSkill = JsonObject();
        jSkill = GffAddByte(jSkill, "Rank", 0);
        jSkill = JsonObjectSet(jSkill, "__struct_id", JsonInt(0));
        jSkillList = JsonArrayInsert(jSkillList, jSkill);
    }
    // Give skill points based on the package.
    int nPackageSkill, nPackageRow, nCurrentRanks, bCrossClass, nClassRow, nNewRanks;
    string sPackage2DAName = Get2DAString("packages", "SkillPref2DA", nClass);
    int nPackageMaxRow = Get2DARowCount(sPackage2DAName);
    string sClass2DAName = Get2DAString("classes", "SkillsTable", nClass);
    int nClassMaxRow = Get2DARowCount(sClass2DAName);
    nPackageRow = 0;
    while(nPackageRow < nPackageMaxRow && nSkillPoints > 0)
    {
        nPackageSkill = StringToInt(Get2DAString(sPackage2DAName, "SkillIndex", nPackageRow));
        jSkill = JsonArrayGet(jSkillList, nPackageSkill);
        nCurrentRanks = JsonGetInt(GffGetByte(jSkill, "Rank"));
        nClassRow = 0;
        while(nClassRow < nClassMaxRow)
        {
            if(nPackageSkill == StringToInt(Get2DAString(sClass2DAName, "SkillIndex", nClassRow)))
            {
                bCrossClass = Get2DAString(sClass2DAName, "ClassSkill", nClassRow) == "0";
                break;
            }
            nClassRow++;
        }
        if(bCrossClass) nNewRanks = (nMaxRanks / 2) - nCurrentRanks;
        else nNewRanks = nMaxRanks - nCurrentRanks;
        if(nNewRanks > nSkillPoints) nNewRanks = nSkillPoints;
        if(nNewRanks > 0)
        {
            jSkill = GffReplaceByte(jSkill, "Rank", nCurrentRanks + nNewRanks);
            jSkillList = JsonArraySet(jSkillList, nPackageSkill, jSkill);
            WriteTimestampedLogEntry("pinc_henchmen, 1110, Adding " + IntToString(nNewRanks) +
                   " ranks to " + Get2DAString("skills", "Label", nPackageSkill));
            nSkillPoints -= nNewRanks;
        }
        nPackageRow++;
    }
    jHenchman = GffReplaceList(jHenchman, "SkillList", jSkillList);
    return jHenchman;
}
json ResetSpellsKnown(json jClass, object oHenchman)
{
    int nClass = GetClassByPosition(1, oHenchman);
    if(Get2DAString("classes", "SpellCaster", nClass) == "0") return jClass;
    int nLevel = 0;
    // We remake the Known spell list if the character doesn't have a level list!
    json jKnownList, jMemorizedList;
    json jSpell, jSpellsPerDayList;
    int bMemorizesSpells = StringToInt(Get2DAString("classes", "MemorizesSpells", nClass));
    int bSpellBookRestricted = StringToInt(Get2DAString("classes", "SpellBookRestricted", nClass));
    string sSpellKnown2DAName = Get2DAString("classes", "SpellKnownTable", nClass);
    string sSpellGained2DAName = Get2DAString("classes", "SpellGainTable", nClass);
    string sSpellTableColumn = Get2DAString("classes", "SpellTableColumn", nClass);
    string sSpellPackage2DAName = Get2DAString("packages", "SpellPref2DA", nClass);
    int nPackageSpell, nPackageRow;
    int nPackageMaxRow = Get2DARowCount(sSpellPackage2DAName);
    int nKnownSpellIndex, nSpellsKnown, nAbility, nSpellLevel = 0;
    string sKnownListName, sSpellLevel, sPackageSpellLevel, sAbility;
    // Cycle through all spell levels and reset.
    while(nSpellLevel < 10)
    {
        sSpellLevel = IntToString(nSpellLevel);
        WriteTimestampedLogEntry("pinc_henchmen, 1143, Checking Spell Level: " + sSpellLevel);
        // Recreate the 0th and 1st level based on the package.
        if(nSpellLevel < 2 && bSpellBookRestricted)
        {
            // Spellbook restricted that don't have a SpellsKnown2DAName
            // get to keep all 0th level spells so we skip them. Example:Wizard
            if(nSpellLevel != 0 || sSpellKnown2DAName != "")
            {
                // Classes that are spell book restricted but don't have a SpellKnownTable
                // get 3 spells + Ability Modifier worth of spells like a wizard.
                if(sSpellKnown2DAName == "")
                {
                    sAbility = Get2DAString("classes", "SpellCastingAbil", nClass);
                    if(sAbility == "INT") nAbility = ABILITY_INTELLIGENCE;
                    else if(sAbility == "WIS") nAbility = ABILITY_WISDOM;
                    else if(sAbility == "CHA") nAbility = ABILITY_CHARISMA;
                    nSpellsKnown = 3 + GetAbilityModifier(nAbility, oHenchman);
                }
                else
                {
                    nSpellsKnown = StringToInt(Get2DAString(sSpellKnown2DAName, "SpellLevel" + sSpellLevel, nLevel));
                }
                WriteTimestampedLogEntry("pinc_henchmen, 1165, nSpellsKnown: " + IntToString(nSpellsKnown));
                jKnownList = JsonArray();
                nPackageRow = 0;
                while(nPackageRow < nPackageMaxRow && nSpellsKnown > 0)
                {
                    nPackageSpell = StringToInt(Get2DAString(sSpellPackage2DAName, "SpellIndex", nPackageRow));
                    sPackageSpellLevel = Get2DAString("spells", sSpellTableColumn, nPackageSpell);
                    if(sPackageSpellLevel == sSpellLevel)
                    {
                        jSpell = JsonObject();
                        jSpell = GffAddWord(jSpell, "Spell", nPackageSpell);
                        jSpell = JsonObjectSet(jSpell, "__struct_id", JsonInt(3));
                        jKnownList = JsonArrayInsert(jKnownList, jSpell);
                        WriteTimestampedLogEntry("pinc_henchmen, 1178, Adding known spell: " +
                                  Get2DAString("spells", "LABEL", nPackageSpell));
                        nSpellsKnown--;
                    }
                    nPackageRow++;
                }
                if(JsonGetLength(jKnownList) == 0)
                {
                    jClass = GffRemoveList(jClass, "KnownList" + sSpellLevel);
                    WriteTimestampedLogEntry("pinc_henchmen, 1187, Removing KnownList" + sSpellLevel);
                }
                else if(JsonGetType(GffGetList(jClass, "KnownList" + sSpellLevel)) != JSON_TYPE_NULL)
                {
                    jClass = GffReplaceList(jClass, "KnownList" + sSpellLevel, jKnownList);
                }
                else jClass = GffAddList(jClass, "KnownList" + sSpellLevel, jKnownList);
            }
        }
        // Remove all other known spell levels and memorized levels.
        else
        {
            jKnownList = GffGetList(jClass, "KnownList" + sSpellLevel);
            if(JsonGetType(jKnownList) != JSON_TYPE_NULL)
            {
                jClass = GffRemoveList(jClass, "KnownList" + sSpellLevel);
                WriteTimestampedLogEntry("pinc_henchmen, 1203, Removing KnownList" + sSpellLevel);
            }
        }
        if(bMemorizesSpells)
        {
            jMemorizedList = GffGetList(jClass, "MemorizedList" + sSpellLevel);
            if(JsonGetType(jMemorizedList) != JSON_TYPE_NULL)
            {
                jClass = GffRemoveList(jClass, "MemorizedList" + sSpellLevel);
                WriteTimestampedLogEntry("pinc_henchmen, 1210, Removing MemorizedList" + sSpellLevel);
            }
        }
        else
        {
            jSpellsPerDayList = GffGetList(jClass, "SpellsPerDayList");
            nSpellsKnown = StringToInt(Get2DAString(sSpellGained2DAName, "SpellLevel"+ sSpellLevel, nLevel));
            jSpell = JsonArrayGet(jSpellsPerDayList, nSpellLevel);
            jSpell = GffReplaceByte(jSpell, "NumSpellsLeft", nSpellsKnown);
            jSpellsPerDayList = JsonArraySet(jSpellsPerDayList, nSpellLevel, jSpell);
            jClass = GffReplaceList(jClass, "SpellsPerDayList", jSpellsPerDayList);
            WriteTimestampedLogEntry("pinc_henchmen, 1223, Setting SpellsPerDay to " +
                          IntToString(nSpellsKnown));
        }
        nSpellLevel++;
    }
    return jClass;
}
object ResetCharacter(object oPC, object oHenchman)
{
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    RemoveHenchman(oPC, oHenchman);
    json jHenchman = ObjectToJson(oHenchman, TRUE);
    json jClassList = GffGetList(jHenchman, "ClassList");
    json jClass = JsonArrayGet(jClassList, 0);
    // Set the Class list to the first class only and put at level 1.
    int nClass = JsonGetInt(JsonObjectGet(jClass, "Class"));
    jClass = GffReplaceShort(jClass, "ClassLevel", 1);
    // Delete extra classes.
    int nClassIndex = JsonGetLength(jClassList) - 1;
    while(nClassIndex > 0)
    {
        jClassList = JsonArrayDel(jClassList, nClassIndex--);
    }
    int nHitPoints = StringToInt(Get2DAString("classes", "HitDie", nClass));
    int nMod = JsonGetInt(GffGetByte(jHenchman, "Con"));
    if(nMod > 9) nHitPoints += (nMod - 10) / 2;
    else nHitPoints += (nMod - 11) / 2;
    jHenchman = GffReplaceShort(jHenchman, "CurrentHitPoints", nHitPoints);
    jHenchman = GffReplaceShort(jHenchman, "HitPoints", nHitPoints);
    jHenchman = GffReplaceShort(jHenchman, "MaxHitPoints", nHitPoints);
    jHenchman = GffReplaceDword(jHenchman, "Experience", 0);
    jHenchman = GffReplaceFloat(jHenchman, "ChallengeRating", 1.0);
    string s2DA = Get2DAString("classes", "AttackBonusTable", nClass);
    int nAtk = StringToInt(Get2DAString(s2DA, "BAB", 0));
    jHenchman = GffReplaceByte(jHenchman, "BaseAttackBonus", nAtk);
    s2DA = Get2DAString("classes", "SavingThrowTable", nClass);
    int nSave = StringToInt(Get2DAString(s2DA, "FortSave", 0));
    jHenchman =  GffReplaceChar(jHenchman, "FortSaveThrow", nSave);
    nSave = StringToInt(Get2DAString(s2DA, "RefSave", 0));
    jHenchman =  GffReplaceChar(jHenchman, "RefSaveThrow", nSave);
    nSave = StringToInt(Get2DAString(s2DA, "WillSave", 0));
    jHenchman =  GffReplaceChar(jHenchman, "WillSaveThrow", nSave);
    json jLvlStatList = GffGetList(jHenchman, "LvlStatList");
    if(JsonGetType(jLvlStatList) != JSON_TYPE_NULL)
    {
        WriteTimestampedLogEntry("pinc_henchmen 1275, jLvlStatList: " + JsonDump(jLvlStatList, 4));
        int nLevel = 1, nLevelTrack = 1;
        int nAbilityStatIncrease, nAbility;
        string sAbility;
        json jAbility;
        json jLevel = JsonArrayGet(jLvlStatList, nLevel);
        while(JsonGetType(jLevel) != JSON_TYPE_NULL)
        {
            WriteTimestampedLogEntry("inc_henchmen, 1297, Checking level " + IntToString(nLevelTrack));
            // Remove all Ability score increases for each level from ability scores.
            jAbility = GffGetByte(jLevel, "LvlStatAbility");
            if(JsonGetType(jAbility) != JSON_TYPE_NULL)
            {
                nAbilityStatIncrease = JsonGetInt(jAbility);
                if(nAbilityStatIncrease == ABILITY_STRENGTH) sAbility = "Str";
                if(nAbilityStatIncrease == ABILITY_DEXTERITY) sAbility = "Dex";
                if(nAbilityStatIncrease == ABILITY_CONSTITUTION) sAbility = "Con";
                if(nAbilityStatIncrease == ABILITY_INTELLIGENCE) sAbility = "Int";
                if(nAbilityStatIncrease == ABILITY_WISDOM) sAbility = "Wis";
                if(nAbilityStatIncrease == ABILITY_CHARISMA) sAbility = "Cha";
                nAbility = JsonGetInt(GffGetByte(jHenchman, sAbility)) - 1;
                jHenchman = GffReplaceByte(jHenchman, sAbility, nAbility);
                WriteTimestampedLogEntry("pinc_henchmen, 1314, Removing " + sAbility + " level bonus ability score point.");
            }
            jLvlStatList = JsonArrayDel(jLvlStatList, nLevel);
            // Note: nLevel is not incremented since we are removing the previous level.
            //       there for when we get the same level again its the next level!
            jLevel = JsonArrayGet(jLvlStatList, nLevel);
            //SendMessageToPC(oPC, "jLvlStatList: " + JsonDump(jLvlStatList, 4));
            nLevelTrack++;
        }
        jHenchman = GffRemoveList(jHenchman, "LvlStatList");
    }
    jHenchman = CreateLevelStatList(jHenchman, oHenchman, oPC, 1);
    jHenchman = ResetSkills(jHenchman, oHenchman);
    jHenchman = ResetFeats(jHenchman, oHenchman);
    jClass = ResetSpellsKnown(jClass, oHenchman);
    jClassList = JsonArraySet(jClassList, 0, jClass);
    jHenchman = GffReplaceList(jHenchman, "ClassList", jClassList);
    //WriteTimestampedLogEntry("pinc_henchmen 1397, jHenchman: " + JsonDump(jHenchman, 4));
    location lLocation = GetLocation(oHenchman);
    int nFamiliar, nCompanion;
    object oCompanion = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oHenchman);
    if(oCompanion != OBJECT_INVALID) nFamiliar = TRUE;
    oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oHenchman);
    if(oCompanion != OBJECT_INVALID) nCompanion = TRUE;
    AssignCommand(oHenchman, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(oHenchman);
    oHenchman = ai_AddHenchman(oPC, jHenchman, lLocation, nFamiliar, nCompanion);
    return oHenchman;
}
// ********* New Henchman windows **********
void CreateCharacterEditGUIPanel(object oPC, object oHenchman)
{
    // Set window to not save until it has been created.
    SetLocalInt(oPC, "0_No_Win_Save", TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Group 1 (Portrait)******************************************************* 151 / 73
    // Group 1 Row 1 *********************************************************** 350 / 91
    json jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "char_name", 15, FALSE, 140.0, 20.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    // Group 1 Row 1 *********************************************************** 350 / 91
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateTextEditBox (jGroupRow, "port_placeholder", "port_name", 15, FALSE, 140.0, 20.0, "port_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 2 *********************************************************** 350 / 259
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateImage(jGroupRow, "", "port_resref", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 140.0f, 160.0f);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 3 *********************************************************** 350 / 292
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateButton (jGroupRow, "<", "btn_portrait_prev", 42.0f, 25.0f);
    jGroupRow = CreateButton (jGroupRow, "Set", "btn_portrait_ok", 44.0f, 25.0f);
    jGroupRow = CreateButton (jGroupRow, ">", "btn_portrait_next", 42.0f, 25.0f);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 4 *********************************************************** 350 / 91
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateLabel(jGroupRow, "Sound Set", "lbl_sound_set", 140.0, 10.0f, NUI_HALIGN_CENTER, NUI_VALIGN_BOTTOM);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 5 *********************************************************** 350 / 325
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateCombo(jGroupRow, ArrayInsertSoundSets(oHenchman), "cmb_soundset", 140.0, 25.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    json jRow = JsonArrayInsert(JsonArray(), NuiGroup(NuiCol(jGroupCol)));
    // Group 2 (Stats)********************************************************** 151 / 73
    // Group 2 Row 1 *********************************************************** 350 / 91
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_stats", 150.0, 15.0, 0, NUI_VALIGN_BOTTOM, 0.0);
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));

    // Group 2 Row 2 *********************************************************** 350 / 243
    //json jAlign = CreateOptionsAlignment(oHenchman, 0);
    //jGroupRow = CreateOptions(JsonArray(), "opt_lawchaos", NUI_DIRECTION_HORIZONTAL, jAlign, 60.0, 35.0);
    // Add group row to the group column.
    //jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 3 *********************************************************** 350 / 243
    //jAlign = CreateOptionsAlignment(oHenchman, 1);
    //jGroupRow = CreateOptions(JsonArray(), "opt_goodevil", NUI_DIRECTION_HORIZONTAL, jAlign, 60.0, 35.0);
    //jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    //jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 2 *********************************************************** 350 / 243
    json jClasses = CreateOptionsClasses(oHenchman);
    jGroupRow = CreateOptions(JsonArray(), "opt_classes", NUI_DIRECTION_VERTICAL, jClasses, 150.0, 144.0);
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 3 *********************************************************** 350 / 276
    jGroupRow = CreateButton(JsonArray(), "Level Up", "btn_level_up", 150.0f, 25.0f, -1.0, "btn_level_up_tooltip");
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 4 *********************************************************** 350 / 309
    jGroupRow = CreateButton (JsonArray(), "Reset Character", "btn_reset", 150.0f, 25.0f, -1.0, "btn_reset_tooltip");
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 5 *********************************************************** 350 / 342
    jGroupRow = CreateCombo(JsonArray(), jArrayInsertClasses(), "cmb_class", 150.0, 25.0);
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 6 *********************************************************** 350 / 375
    int nClassOption = GetLocalInt(oHenchman, "CLASS_OPTION_POSITION");
    int nClass = GetClassByPosition(nClassOption + 1, oHenchman);
    int bNoClass = FALSE;
    if(nClass == CLASS_TYPE_INVALID)
    {
        nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nClassOption + 1));
        bNoClass = TRUE;
    }
    string sClass = IntToString(nClass);
    jGroupRow = CreateCombo(JsonArray(), ArrayInsertPackages(sClass), "cmb_package", 150.0, 25.0);
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jRow = JsonArrayInsert(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add the row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 5 (text edit box)**************************************************** 350 / 518
    jRow = CreateTextEditBox(JsonArray(), "desc_placeholder", "desc_value", 1000, TRUE, 350.0, 150.0, "desc_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow (jRow));
    // Row 6 (button)*********************************************************** 350/ 546
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton (jRow, "Save Description", "btn_desc_save", 150.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow (jRow));
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
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "char_name", JsonString(GetName(oHenchman)));
    NuiSetBindWatch(oPC, nToken, "char_name", TRUE);
    NuiSetBind(oPC, nToken, "char_name_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "port_name", JsonString(sResRef));
    NuiSetBindWatch(oPC, nToken, "port_name", TRUE);
    NuiSetBind(oPC, nToken, "port_name_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "port_resref_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "port_resref_image", JsonString(sResRef + "l"));
    NuiSetBind(oPC, nToken, "port_tooltip", JsonString ("  You may also type the portrait file name."));
    // Set buttons active.
    NuiSetBind(oPC, nToken, "btn_portrait_prev_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_next_event", JsonBool(TRUE));
    int nSelection = GetSelectionBySoundSet2DA(oHenchman, GetSoundset(oHenchman));
    NuiSetBind(oPC, nToken, "cmb_soundset_selected", JsonInt(nSelection));
    NuiSetBindWatch(oPC, nToken, "cmb_soundset_selected", TRUE);
    NuiSetBind(oPC, nToken, "cmb_soundset_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_desc_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_ok_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "desc_tooltip", JsonString("  You can use color codes!"));
    string sDescription = GetDescription(oHenchman);
    NuiSetBind(oPC, nToken, "desc_value_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "desc_value", JsonString (sDescription));
    // Setup the henchman window.
    string sStats = GetAlignText(oHenchman) + " ";
    if(GetGender(oHenchman) == GENDER_MALE) sStats += "Male ";
    else sStats += "Female ";
    sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oHenchman))));
    NuiSetBind(oPC, nToken, "lbl_stats_label", JsonString(sStats));
    json jHenchman = ObjectToJson(oHenchman);
    NuiSetBind(oPC, nToken, "opt_classes_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "opt_classes_value", JsonInt(nClassOption));
    NuiSetBind(oPC, nToken, "btn_level_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_up_tooltip", JsonString("  Levels the character up by one level in selected class."));
    if(ai_GetIsCharacter(oHenchman)) NuiSetBind(oPC, nToken, "btn_reset_event", JsonBool(FALSE));
    else NuiSetBind(oPC, nToken, "btn_reset_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_reset_tooltip", JsonString("  Resets the character to level 1."));
    nSelection = GetSelectionByClass2DA(nClass);
    NuiSetBind(oPC, nToken, "cmb_class_selected", JsonInt(nSelection));
    NuiSetBindWatch(oPC, nToken, "cmb_class_selected", bNoClass);
    NuiSetBind(oPC, nToken, "cmb_class_event", JsonBool(bNoClass));
    int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1));
    if(nPackage == 0)
    {
        nPackage = GetPackageBySelection2DA(sClass, 0);
        SetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1), nPackage);
    }
    NuiSetBind(oPC, nToken, "cmb_package_selected", JsonInt(GetSelectionByPackage2DA(sClass, nPackage)));
    NuiSetBindWatch(oPC, nToken, "cmb_package_selected", bNoClass);
    NuiSetBind(oPC, nToken, "cmb_package_event", JsonBool(bNoClass));
}
void CreateCharacterDescriptionNUI(object oPC, string sName, string sIcon, string sDescription)
{
    // Row 1 ******************************************************************* 500 / 469
    json jRow = CreateImage(JsonArray(), "", "char_icon", NUI_ASPECT_FIT, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 40.0, 40.0);
    jRow = CreateTextBox(jRow, "char_text", 380.0, 400.0);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 522
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "OK", "btn_ok", 150.0f, 45.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "char_description_nui", sName,
                             -1.0, -1.0, 460.0f, 537.0 + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_henchmen");
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Row 1
    NuiSetBind(oPC, nToken, "char_icon_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_icon_image", JsonString(sIcon));
    NuiSetBind(oPC, nToken, "char_text_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_text", JsonString(sDescription));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_ok_event", JsonBool(TRUE));
}

