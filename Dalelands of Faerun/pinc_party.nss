/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pinc_paarty
////////////////////////////////////////////////////////////////////////////////
 Include file for Party manager plug in scripts for Philos Module Extentions.

Database Info:
Slot data - henchname = the save slot 1 - 8.
Slots 1 - 8 these hold the saveselection and party selection for each group.
Slots ## each party group with each henchman using the first digit for each
         henchman and the 10's digit as the party group number.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_window"
#include "0i_character"
#include "0i_henchmen"
#include "nw_inc_gff"

//******************************************************************************
// Constant values that can be changed to adjust the Henchman menu functionality.
//******************************************************************************
// If you want to restrict the types of creatures that are henchman in your mod
// Then you need to turn this to TRUE and save a variable on each henchman.
// Save an INT of ASSOCIATE_TYPE_HENCHMAN or (1) to "0_PCAssociate" on any
// henchman you would like them to be able to save in the henchman plug in.
const int RESTRICT_HENCHMAN_TYPES = TRUE;
const string PC_ASSOCIATE = "0_PCAssociate";

// Constant values that should NOT be changed.
const string PARTY_DATABASE = "philos_party_db";
const string PARTY_TABLE = "PARTY_TABLE";
const string HENCHMAN_TO_EDIT = "HENCHMAN_TO_EDIT";
//******************************************************************************
// Have the associate speak a random voice from VOICE_CHAT_*.
// nRoll is the number to roll. If nRoll is 0 then it will SpeakString(sVoiceChatArray);
// sVoiceChatArray is an array of VOICE_CHAT_* numbers over nRoll.
// example(4, ":3:4:8:7:") will roll a d4() picking from 3,4,8,7 of VOICE_CHAT_*.
// if nRoll is higher than the number of VOICE_CHAT_* then it will not speak.
void HaveCreatureSpeak(object oCreature, int nRoll, string sVoiceChatArray, int bImportant = FALSE);
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
// Setup the options for the henchman plugin if they are not already set.
json SetHenchmanOptions(object oPC);
// Returns TRUE if the henchman with sName can join.
int GetJoinButtonActive(object oPC, string sName);
// Returns a two letter alignment string.
string GetAlignText(object oHenchman);
// Populates the Saved character group.
void AddSavedCharacterInfo(object oPC, int nToken, string sParty);
// Populates the Current character group.
void AddCurrentCharacterInfo(object oPC, int nToken, string sParty);
// Saves a henchman in your party to the saved party #.
int MoveCurrentHenchman(object oPC, int nToken, string sParty);
// Saves the whole party to the saved party #.
void MoveWholeParty(object oPC, int nToken, string sParty);
// Saves the players current party to party #.
void SavedPartyJoin(object oPC, int nToken, string sParty);
// Saves a character in the players party to party #.
void SavedCharacterJoin(object oPC, int nToken, string sParty);
// Sets oHenchmans scripts to the current AI.
void SetHenchmanScripts(object oHenchman);
// If a henchman does not have a LvlStatList this will create one for them.
// nLevels allows the creation of x levels for LvlStatList using the 1st class.
// 0 on nLevels makes the function build it based on current levels.
json CreateLevelStatList(json jHenchman, object oHenchman, object oPC, int nLevels = 0);
// Resets the character to level one in the first class.
object ResetCharacter(object oPC, object oHenchman, int nToken);
// Creates a menu to edit a characters information.
void CreateCharacterEditGUIPanel(object oPC, object oAssociate);
// Creates a character description menu.
void CreateCharacterDescriptionNUI(object oPC, string sName, string sIcon, string sDescription);

void HaveCreatureSpeak(object oCreature, int nRoll, string sVoiceChatArray, int bImportant = FALSE)
{
    if(nRoll == 0)
    {
        // Some races shouldn't talk.
        int nRacialType = GetRacialType(oCreature);
        if(nRacialType == RACIAL_TYPE_ANIMAL || nRacialType == RACIAL_TYPE_BEAST ||
           nRacialType == RACIAL_TYPE_MAGICAL_BEAST || nRacialType == RACIAL_TYPE_OOZE ||
           nRacialType == RACIAL_TYPE_UNDEAD || nRacialType == RACIAL_TYPE_VERMIN) return;
        SpeakString(sVoiceChatArray);
        return;
    }
    nRoll = Random(nRoll);
    string sVoice = GetStringArray(sVoiceChatArray, nRoll);
    if(sVoice != "") PlayVoiceChat(StringToInt(sVoice), oCreature);
}
void CreateHenchmanDataTable ()
{
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE,
        "CREATE TABLE IF NOT EXISTS " + PARTY_TABLE + " (" +
        "player         TEXT, " +
        "character      TEXT, " +
        "slot           TEXT, " +
        "saveselection  TEXT, " +
        "partyselection TEXT, " +
        "henchname      TEXT, " +
        "image          TEXT, " +
        "stats          TEXT, " +
        "classes        TEXT, " +
        "henchman       TEXT, " +
        "PRIMARY KEY(character, slot));");
    SqlStep (sql);
}
void CheckHenchmanDataAndInitialize(object oPC, string sSlot)
{
    string sPCName;
    if(GetIsPC(oPC)) sPCName = RemoveIllegalCharacters(GetPCPlayerName(oPC));
    else sPCName = RemoveIllegalCharacters(GetName(oPC));
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@tableName", PARTY_TABLE);
    if(!SqlStep (sql)) CreateHenchmanDataTable();
    sQuery = "SELECT slot FROM " + PARTY_TABLE + " Where character = @character AND slot = @slot;";
    sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    if(!SqlStep(sql))
    {
        sQuery = "INSERT INTO " + PARTY_TABLE + "(player, character, slot, saveselection, " +
        "partyselection, henchname, image, stats, classes, henchman) " +
        "VALUES (@player, @character, @slot, @saveselection, @partyselection, " +
        "@henchname, @image, @stats, @classes, @henchman);";
        sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
        SqlBindString(sql, "@player", sPCName);
        SqlBindString(sql, "@character", sCharName);
        SqlBindString(sql, "@slot", sSlot);
        SqlBindString(sql, "@saveselection", "");
        SqlBindString(sql, "@partyselection", "");
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
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "DELETE FROM " + PARTY_TABLE + " WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
void SetHenchmanDbInt(object oPC, string sDataField, int nData, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "UPDATE " + PARTY_TABLE + " SET " + sDataField + " = @data WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindInt(sql, "@data", nData);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
int GetHenchmanDbInt(object oPC, string sDataField, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "SELECT " + sDataField + " FROM " + PARTY_TABLE + " WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    if(SqlStep (sql)) return SqlGetInt(sql, 0);
    else return 0;
}
void SetHenchmanDbString(object oPC, string sDataField, string sData, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "UPDATE " + PARTY_TABLE + " SET " + sDataField + " = @data WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
string GetHenchmanDbString(object oPC, string sDataField, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "SELECT " + sDataField + " FROM " + PARTY_TABLE + " WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    if(SqlStep (sql)) return SqlGetString(sql, 0);
    else return "";
}
void SetHenchmanDbJson(object oPC, string sDataField, json jData, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "UPDATE " + PARTY_TABLE + " SET " + sDataField +
                    " = @data WHERE character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString (sql, "@slot", sSlot);
    SqlStep (sql);
}
json GetHenchmanDbJson(object oPC, string sDataField, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "SELECT " + sDataField + " FROM " + PARTY_TABLE + " WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString (sql, "@slot", sSlot);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
void SetHenchmanDbObject(object oPC, object oHenchman, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "UPDATE " + PARTY_TABLE + " SET henchman = @henchman WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindObject(sql, "@henchman", oHenchman);
    SqlBindString(sql, "@character", sCharName);
    SqlBindString(sql, "@slot", sSlot);
    SqlStep(sql);
}
object GetHenchmanDbObject(object oPC, location lLocationToSpawn, string sSlot)
{
    string sCharName = RemoveIllegalCharacters(GetName(oPC));
    string sQuery = "SELECT henchman FROM " + PARTY_TABLE + " WHERE " +
                    "character = @character AND slot = @slot;";
    sqlquery sql = SqlPrepareQueryCampaign(PARTY_DATABASE, sQuery);
    SqlBindString(sql, "@character", sCharName);
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
json SetPartyOptions()
{
    json jData = JsonObject();
    jData = JsonObjectSet(jData, "Max_Party_Size", JsonInt(6));
    jData = JsonObjectSet(jData, "Level_Limit", JsonInt(-2));
    SetHenchmanDbJson(GetModule(), "classes", jData, "Data");
    return jData;
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
    string sHenchman = GetHenchmanDbString(oPC, "saveselection", sParty);
    // Add Henchman information.
    if(sHenchman != "")
    {
        // Setup the henchman window.
        string sName = GetHenchmanDbString(oPC, "henchname", sParty + sHenchman);
        if(sName == "")
        {
            NuiSetBind (oPC, nToken, "btn_join_party", JsonBool (FALSE));
            NuiSetBind (oPC, nToken, "btn_join_party_event", JsonBool (FALSE));
            NuiSetBind(oPC, nToken, "lbl_save_char_name_label", JsonString("Empty Party"));
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_join_party", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_join_party_event", JsonBool (TRUE));
            string sText = "  Moves characters from party " + sParty + " to your current party.";
            NuiSetBind(oPC, nToken, "btn_join_party_tooltip", JsonString(sText));
            NuiSetBind(oPC, nToken, "lbl_save_char_name_label", JsonString(sName));
        }
        NuiSetBind(oPC, nToken, "img_saved_portrait_event", JsonBool(TRUE));
        string sImage = GetHenchmanDbString(oPC, "image", sParty + sHenchman);
        if(sImage == "")
        {
            NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString("po_hu_m_99_l"));
            NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(""));
            NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_saved_join_label", JsonString(""));
        }
        else
        {
            NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString(sImage + "l"));
            string sStats = GetHenchmanDbString(oPC, "stats", sParty + sHenchman);
            string sClasses = GetHenchmanDbString(oPC, "classes", sParty + sHenchman);
            NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(sStats));
            NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(sClasses));
            NuiSetBind(oPC, nToken, "btn_saved_join_label", JsonString("Join"));
            NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(TRUE));
        }
    }
    else
    {
        NuiSetBind(oPC, nToken, "lbl_save_char_name_label", JsonString("Empty Party"));
        NuiSetBind (oPC, nToken, "btn_join_party", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_join_party_event", JsonBool (FALSE));
        // Setup the henchman window.
        NuiSetBind(oPC, nToken, "img_saved_portrait_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString("po_hu_m_99_l"));
        NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(""));
        NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_saved_join_label", JsonString(""));
    }
}
void AddCurrentCharacterInfo(object oPC, int nToken, string sParty)
{
    string sHenchman = GetHenchmanDbString(oPC, "partyselection", sParty);
    if(sHenchman == "")
    {
        CheckHenchmanDataAndInitialize(oPC, sParty);
        SetHenchmanDbString(oPC, "partyselection", "0", sParty);
        sHenchman = "0";
    }
    int nHenchman = StringToInt(sHenchman);
    int nCounter = 1, nIndex = 1;
    string sText;
    object oCharacter = oPC;
    if(nHenchman != 0)
    {
        while(nIndex < SERVER_MAX_HENCHMAN)
        {
            oCharacter = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
            if(oCharacter == OBJECT_INVALID)
            {
                nIndex = 0;
                oCharacter = oPC;
                break;
            }
            else if(!RESTRICT_HENCHMAN_TYPES || (RESTRICT_HENCHMAN_TYPES &&
                    GetLocalInt(oCharacter, PC_ASSOCIATE) == 1))

            {
                if(nHenchman == nCounter) break;
                nCounter++;
            }
            nIndex++;
        }
    }
    // Adjust the party buttons.
    NuiSetBind(oPC, nToken, "btn_move_party_event", JsonBool(TRUE));
    sText = "  Moves all henchman from your current party to party " + sParty + ".";
    NuiSetBind(oPC, nToken, "btn_move_party_tooltip", JsonString(sText));
    int bParty = (GetAssociateType(oCharacter) == ASSOCIATE_TYPE_HENCHMAN);
    NuiSetBind(oPC, nToken, "btn_cur_move_event", JsonBool(bParty));
    if(GetIsCharacter(oCharacter)) bParty = TRUE;
    NuiSetBind(oPC, nToken, "btn_cur_edit_event", JsonBool(bParty));
    if(bParty)
    {
        sText = "  Moves the henchman from your current party to party " + sParty + ".";
        NuiSetBind(oPC, nToken, "btn_cur_move_tooltip", JsonString(sText));
    }
    // Setup the henchman window.
    string sName = GetName(oCharacter);
    string sImage = GetPortraitResRef(oCharacter);
    string sGender = GetAlignText(oCharacter) + " ";
    if(GetGender(oCharacter) == GENDER_MALE) sGender += "Male ";
    else sGender += "Female ";
    int nPosition = 1;
    string sRace = GetSubRace(oCharacter);
    if(sRace == "") sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oCharacter))));
    string sClasses = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oCharacter))));
    sClasses += " " + IntToString (GetLevelByPosition (nPosition, oCharacter));
    int nClass = GetClassByPosition(++nPosition, oCharacter);
    while(nClass != CLASS_TYPE_INVALID)
    {
        sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", nClass)));
        sClasses += " " + IntToString (GetLevelByPosition (nPosition, oCharacter));
        nClass = GetClassByPosition(++nPosition, oCharacter);
    }
    NuiSetBind(oPC, nToken, "lbl_cur_char_name_label", JsonString(sName));
    NuiSetBind(oPC, nToken, "img_cur_portrait_event", JsonBool(TRUE));
    if(ResManGetAliasFor(sImage, RESTYPE_TGA) != "") NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage));
    else if(ResManGetAliasFor(sImage, RESTYPE_DDS) != "") NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage));
    else if(ResManGetAliasFor(sImage + "l", RESTYPE_TGA) != "") NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage + "l"));
    else if(ResManGetAliasFor(sImage + "l", RESTYPE_DDS) != "") NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage + "l"));
    NuiSetBind(oPC, nToken, "lbl_cur_gender_label", JsonString(sGender));
    NuiSetBind(oPC, nToken, "lbl_cur_race_label", JsonString(sRace));
    NuiSetBind(oPC, nToken, "lbl_cur_classes_label", JsonString(sClasses));
}
object GetCurrentSelectedHenchman(object oPC, string sParty)
{
    string sHenchman = GetHenchmanDbString(oPC, "partyselection", sParty);
    if(sHenchman == "0") return oPC;
    if(sHenchman == "")
    {
        CheckHenchmanDataAndInitialize(oPC, sParty);
        SetHenchmanDbString(oPC, "partyselection", "1", sParty);
        sHenchman = "1";
    }
    int nCount, nIndex = 1, nHenchman = StringToInt(sHenchman);
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(oHenchman != OBJECT_INVALID)
    {
        if(RESTRICT_HENCHMAN_TYPES)
        {
            if(GetLocalInt(oHenchman, PC_ASSOCIATE) == 1) nCount++;
        }
        else nCount++;
        if(nCount == nHenchman) break;
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }
    return oHenchman;
}
int MoveCurrentHenchman(object oPC, int nToken, string sParty)
{
    int nIndex, nClass, nPosition, nNumOfHenchman;
    string sName, sIndex, sSlot, sStats, sClasses;
    object oHenchman = GetCurrentSelectedHenchman(oPC, sParty);
    json jData = GetHenchmanDbJson(GetModule(), "classes", "Data");
    int nMaxPartySize = JsonGetInt(JsonObjectGet(jData, "Max_Party_Size"));
    string sHenchmanName = GetName(oHenchman);
    while(nIndex <= 10)
    {
        sIndex = IntToString(nIndex);
        sName = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
        if(sName == "")
        {
            sSlot = sParty + sIndex;
            RemoveHenchman(oPC, oHenchman);
            ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
            json jHenchman = ObjectToJson(oHenchman, TRUE);
            SetIsDestroyable(TRUE, FALSE, FALSE, oHenchman);
            DestroyObject(oHenchman);
            // Remove them from the server database...
            RemoveHenchmanFromDatabase(oPC, oHenchman);
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
            SendMessages(sHenchmanName + " has been moved to the party " + sParty + ".", COLOR_GREEN, oPC);
            SetHenchmanDbString(oPC, "saveselection", "0", sParty);
            return TRUE;
        }
        nIndex++;
        if(GetLocalInt(oHenchman, "0_PCAssociate") == ASSOCIATE_TYPE_HENCHMAN &&
           RESTRICT_HENCHMAN_TYPES)
        {
            if(++nNumOfHenchman >= 10)
            {
                SendMessages("This party is full!", COLOR_RED, oPC);
                return FALSE;
            }
        }
    }
    return TRUE;
}
void MoveWholeParty(object oPC, int nToken, string sParty)
{
    json jData = GetHenchmanDbJson(GetModule(), "classes", "Data");
    int nSaved, nNumberSaved;
    int nMaxParty = JsonGetInt(JsonObjectGet(jData, "Max_Party_Size"));
    int nIndex = nMaxParty;
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(nIndex > 0)
    {
        if(oHenchman != OBJECT_INVALID &&
          (GetLocalInt(oHenchman, "0_PCAssociate") == ASSOCIATE_TYPE_HENCHMAN ||
           !RESTRICT_HENCHMAN_TYPES))
        {
            SetHenchmanDbString(oPC, "partyselection", IntToString(nIndex), sParty);
            nSaved = MoveCurrentHenchman(oPC, nToken, sParty);
            if(!nSaved)
            {
                SetHenchmanDbString(oPC, "partyselection", "0", sParty);
                break;
            }
            nNumberSaved++;
        }
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, --nIndex);
    }
    if(nNumberSaved < nMaxParty) SendMessages(IntToString(nNumberSaved) + " henchman have been moved to Party " + sParty + ".", COLOR_YELLOW, oPC);
    else SendMessages("All of your henchman have been moved to Party " + sParty + ".", COLOR_YELLOW, oPC);
    SetHenchmanDbString(oPC, "partyselection", "0", sParty);
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_party", oPC);
}
void SavedCharacterJoin(object oPC, int nToken, string sParty)
{
    int nIndex, bFound, nNumOfHenchman;
    json jHenchman, jData = GetHenchmanDbJson(GetModule(), "classes", "Data");
    int nMaxPartySize = JsonGetInt(JsonObjectGet(jData, "Max_Party_Size"));
    object oHenchman, oLoadedHenchman;
    string sHenchman = GetHenchmanDbString(oPC, "saveselection", sParty);
    string sName = GetHenchmanDbString(oPC, "henchname", sParty + sHenchman);
    nIndex = 1;
    oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(oHenchman != OBJECT_INVALID)
    {
        if(GetLocalInt(oHenchman, "0_PCAssociate") == ASSOCIATE_TYPE_HENCHMAN &&
           RESTRICT_HENCHMAN_TYPES)
        {
            ++nNumOfHenchman;
        }
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }
    if(nNumOfHenchman >= nMaxPartySize)
    {
        SendMessages("Your party is at the maximum number of henchman!", COLOR_RED, oPC);
    }
    else
    {
        SendMessages(sName + " has joined your party!", COLOR_GREEN, oPC);
        jHenchman = GetHenchmanDbJson(oPC, "henchman", sParty + sHenchman);
        oLoadedHenchman = JsonToObject(jHenchman, GetLocation(oPC), OBJECT_INVALID, TRUE);
        // Need to add code to save them to the server database.
        SetUpHenchman(oPC, oLoadedHenchman);
        AddHenchman(oPC, oLoadedHenchman);
        RemoveHenchmanDb(oPC, sParty + sHenchman);
    }
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_party", oPC);
}
void SavedPartyJoin(object oPC, int nToken, string sParty)
{
    int bFound, nIndex, nNumOfHenchman, nDBHenchman = 0;
    json jHenchman, jData = GetHenchmanDbJson(GetModule(), "classes", "Data");
    int nMaxPartySize = JsonGetInt(JsonObjectGet(jData, "Max_Party_Size"));
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
            if(GetLocalInt(oHenchman, "0_PCAssociate") == ASSOCIATE_TYPE_HENCHMAN ||
               !RESTRICT_HENCHMAN_TYPES)
            {
                ++nNumOfHenchman;
            }
            oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
        }
        if(nNumOfHenchman > nMaxPartySize)
        {
            SendMessages("Your party is at the maximum number of henchman!", COLOR_RED, oPC);
            break;
        }
        SendMessages(sName + " has joined your party.", COLOR_GREEN, oPC);
        jHenchman = GetHenchmanDbJson(oPC, "henchman", sParty + sDBHenchman);
        // Need to add code to save them to the server database.

        oLoadedHenchman = JsonToObject(jHenchman, GetLocation(oPC), OBJECT_INVALID, TRUE);
        AddHenchman(oPC, oLoadedHenchman);
        RemoveHenchmanDb(oPC, sParty + sDBHenchman);
        sDBHenchman = IntToString(++nDBHenchman);
        sName = GetHenchmanDbString(oPC, "henchname", sParty + sDBHenchman);
    }
    NuiDestroy(oPC, nToken);
    ExecuteScript("pi_party", oPC);
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
object party_AddHenchman(object oPC, json jHenchman, location lLocation, int nFamiliar, int nCompanion)
{
    jHenchman = GffReplaceResRef(jHenchman, "ScriptSpawn", "");
    object oHenchman = JsonToObject(jHenchman, lLocation, OBJECT_INVALID, TRUE);
    AddHenchman(oPC, oHenchman);
    DeleteLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE");
    //string sAssociateType = GetAssociateType(oPC, oHenchman);
    //NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
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
    //WriteTimestampedLogEntry("pinc_party, 813, Creating LvlStatList for " + GetName(oHenchman));
    return GffAddList(jHenchman, "LvlStatList", jLevelArray);
}
int GetHasJFeat(int nFeat, json jFeatList)
{
    int nIndex, nJFeat, nMaxFeats = JsonGetLength(jFeatList);
    json jFeat;
    //WriteTimestampedLogEntry("pinc_party, 831, nFeat: " + IntToString(nFeat) + " nMaxFeats: " + IntToString(nMaxFeats) + ".");
    while(nIndex < nMaxFeats)
    {
        jFeat = JsonArrayGet(jFeatList, nIndex);
        nJFeat = JsonGetInt(GffGetWord(jFeat, "Feat"));
        //WriteTimestampedLogEntry("pinc_party, 831, nJFeat: " + IntToString(nJFeat) + ".");
        if(nJFeat == nFeat) return TRUE;
        nIndex++;
    }
    return FALSE;
}
int CanSelectFeat(json jCreature, object oCreature, int nClass, int nLevel, int nFeat, json jFeats, int bClassBonusFeat = FALSE)
{
    // Check if we already have this feat.
    if(GetHasJFeat(nFeat, jFeats)) return FALSE;
    // Check if all classes can use.
    int n2DAStat = StringToInt(Get2DAString("feat", "ALLCLASSESCANUSE", nFeat));
    if(n2DAStat == 0)
    {
        // Check if the class can use the feat.
        int bPass, nClassFeat, nRow, nFeatList;
        string sClsFeat2DAName = Get2DAString("classes", "FeatsTable", nClass);
        int nMaxRow = Get2DARowCount(sClsFeat2DAName);
        while(nRow < nMaxRow)
        {
            nClassFeat = StringToInt(Get2DAString(sClsFeat2DAName, "FeatIndex", nRow));
            if(nClassFeat == nFeat)
            {
                nFeatList = StringToInt(Get2DAString(sClsFeat2DAName, "List", nRow));
                if(nFeatList == 0 || nFeatList == 1 || (nFeatList == 2 && bClassBonusFeat))
                {
                    bPass = TRUE;
                    break;
                }
            }
            nRow++;
        }
        if(!bPass) return FALSE;
    }
    // Check if the creature meets the minimum requirements for the feat in Attack Bonus, 
    // Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma, and Spell Level.
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
    int nSpellLevel = 0;
    string s2DAName = Get2DAString("classes", "SpellGainTable", nClass);
    if(s2DAName != "")
    {
        nSpellLevel = StringToInt(Get2DAString(s2DAName, "NumSpellLevels", nLevel - 1)) - 1;
        if(nSpellLevel < 0) nSpellLevel = 0;
    }
    if(nSpellLevel < n2DAStat) return FALSE;
    n2DAStat = StringToInt(Get2DAString("feat", "PREREQFEAT1", nFeat));
    // Check prerequisite feats.
    if(n2DAStat > 0 && GetHasJFeat(n2DAStat, jFeats))
    {
        n2DAStat = StringToInt(Get2DAString("feat", "PREREQFEAT2", nFeat));
        if(n2DAStat > 0 && !GetHasJFeat(n2DAStat, jFeats)) return FALSE;
    }
    int nIndex;
    while(nIndex < 5)
    {
        n2DAStat = StringToInt(Get2DAString("feat", "OrReqFeat" + IntToString(nIndex), nFeat));
        if(nIndex == 0 && n2DAStat == 0) break;
        if(n2DAStat > 0)
        {
            if(GetHasJFeat(n2DAStat, jFeats)) break;
        }
        else return FALSE;
        ++nIndex;
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
        while(nClassPosition < MAX_NUMBER_OF_CLASSES)
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
json ResetFeats(json jHenchman, object oHenchman, int nClass, int nPackage, int nLevel)
{
    json jFeatList = JsonArray();
    json jFeat;
    // Note it is very hard to get a new race for henchman. 
    // right now I'm using the resref as it is m_## or f_## where ## is the race number.
    int nRace = StringToInt(GetStringRight(GetResRef(oHenchman), 2));
    //int nRace = GetNPCRaceType(oHenchman);
    string sRace2DAName = Get2DAString("racialtypes", "FeatsTable", nRace);
    // Give racial feats.
    //WriteTimestampedLogEntry("pinc_party, 1046, Adding race feats from " + sRace2DAName + ".");
    int nRaceRow, nRaceFeat;
    int nRaceMaxRow = Get2DARowCount(sRace2DAName);
    while(nRaceRow < nRaceMaxRow)
    {
        nRaceFeat = StringToInt(Get2DAString(sRace2DAName, "FeatIndex", nRaceRow));
        jFeat = JsonObject();
        jFeat = GffAddWord(jFeat, "Feat", nRaceFeat);
        jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
        jFeatList = JsonArrayInsert(jFeatList, jFeat);
        //WriteTimestampedLogEntry("pinc_party, 1056, Adding racial feat: " +
        //              Get2DAString("feat", "LABEL", nRaceFeat));
        nRaceRow++;
    }
    // Give class feats.
    string sGranted, sList;
    string sClsFeat2DAName = Get2DAString("classes", "FeatsTable", nClass);
    //WriteTimestampedLogEntry("pinc_party, 1061, Adding class feats from " + sClsFeat2DAName + ".");
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
                //WriteTimestampedLogEntry("pinc_party, 1022, Adding class feat: " +
                //          Get2DAString("feat", "LABEL", nClassFeat));
            }
        }
        nClassRow++;
    }
    // Give any bonus feats from package.
    int nPackageFeat, nPackageRow;
    string sBonusFeat2DAName = Get2DAString("classes", "BonusFeatsTable", nClass);
    int nNumOfFeats = StringToInt(Get2DAString(sBonusFeat2DAName, "Bonus", nLevel - 1));
    string sPackage2DAName = Get2DAString("packages", "FeatPref2DA", nPackage);
    //WriteTimestampedLogEntry("pinc_party, 1092, Select " + IntToString(nNumOfFeats) + " class bonus feats from " + sPackage2DAName + ".");
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
                    if((sList == "1" || sList == "2") && CanSelectFeat(jHenchman, oHenchman, nClass, 1, nClassFeat, jFeatList, TRUE))
                    {
                        jFeat = JsonObject();
                        jFeat = GffAddWord(jFeat, "Feat", nClassFeat);
                        jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
                        jFeatList = JsonArrayInsert(jFeatList, jFeat);
                        //WriteTimestampedLogEntry("pinc_party, 1111, Adding class bonus feat: " +
                        //                          Get2DAString("feat", "LABEL", nPackageFeat));
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
    //WriteTimestampedLogEntry("pinc_party, 1069, Select " + IntToString(nNumOfFeats) + " feats for character from " + sPackage2DAName + ".");
    nPackageRow = 0;
    while(nPackageRow < nPackageMaxRow)
    {
        nClassRow = 0;
        nPackageFeat = StringToInt(Get2DAString(sPackage2DAName, "FeatIndex", nPackageRow));
        //WriteTimestampedLogEntry("pinc_party, 1075, nPackageFeat: " + Get2DAString("feat", "LABEL", nPackageFeat) + ".");
        if(CanSelectFeat(jHenchman, oHenchman, nClass, 1, nPackageFeat, jFeatList))
        {
            jFeat = JsonObject();
            jFeat = GffAddWord(jFeat, "Feat", nPackageFeat);
            jFeat = JsonObjectSet(jFeat, "__struct_id", JsonInt(1));
            jFeatList = JsonArrayInsert(jFeatList, jFeat);
            //WriteTimestampedLogEntry("pinc_party, 1138, Selecting character feat: " +
            //              Get2DAString("feat", "LABEL", nPackageFeat));
            nNumOfFeats--;
        }
        if(nNumOfFeats < 1) break;
        nPackageRow++;
    }
    //WriteTimestampedLogEntry("pinc_party, 1145, Finished selecting feats.");
    jHenchman = GffReplaceList(jHenchman, "FeatList", jFeatList);
    return jHenchman;
}
json ResetSkills(json jHenchman, object oHenchman, int nClass, int nLevel)
{
    // We remake the Skill List if the character doesn't have a level list!
    int nSkillPoints, nIntMod = GetAbilityModifier(ABILITY_INTELLIGENCE, oHenchman);
    if(nIntMod > 0) nSkillPoints = nIntMod;
    if(GetRacialType(oHenchman) == RACIAL_TYPE_HUMAN) nSkillPoints += 1;
    nSkillPoints += StringToInt(Get2DAString("classes", "SkillPointBase", nClass));
    nSkillPoints = nSkillPoints * (nLevel + 3);
    int nMaxRanks = 3 + nLevel;
    json jSkillList = JsonArray();
    json jSkill;
    // Setup the Skill List.
    //WriteTimestampedLogEntry("pinc_party, 1112, Generating skill list.");
    int nIndex, nSkillMaxRow = Get2DARowCount("skills");
    for(nIndex = 0; nIndex < nSkillMaxRow; nIndex++)
    {
        jSkill = JsonObject();
        jSkill = GffAddByte(jSkill, "Rank", 0);
        jSkill = JsonObjectSet(jSkill, "__struct_id", JsonInt(0));
        jSkillList = JsonArrayInsert(jSkillList, jSkill);
    }
    // Give skill points based on the package.
    //WriteTimestampedLogEntry("pinc_party, 1116, Gets " + IntToString(nSkillPoints) + " skill points.");
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
            //WriteTimestampedLogEntry("pinc_party, 1145, Adding " + IntToString(nNewRanks) +
            //       " ranks to " + Get2DAString("skills", "Label", nPackageSkill) +
            //       " CrossClass: " + IntToString(bCrossClass));
            nSkillPoints -= nNewRanks;
        }
        nPackageRow++;
    }
    jHenchman = GffReplaceList(jHenchman, "SkillList", jSkillList);
    return jHenchman;
}
json ResetSpellsKnown(json jClass, object oHenchman, int nClass, int nLevel, int nPackage)
{
    if(Get2DAString("classes", "SpellCaster", nClass) == "0") return jClass;
    // We remake the Known spell list if the character doesn't have a level list!
    json jKnownList, jMemorizedList;
    json jSpell, jSpellsPerDayList;
    int bMemorizesSpells = StringToInt(Get2DAString("classes", "MemorizesSpells", nClass));
    int bSpellBookRestricted = StringToInt(Get2DAString("classes", "SpellBookRestricted", nClass));
    string sSpellKnown2DAName = Get2DAString("classes", "SpellKnownTable", nClass);
    string sSpellGained2DAName = Get2DAString("classes", "SpellGainTable", nClass);
    string sSpellTableColumn = Get2DAString("classes", "SpellTableColumn", nClass);
    string sSpellPackage2DAName = Get2DAString("packages", "SpellPref2DA", nPackage);
    int nPackageSpell, nPackageRow;
    int nPackageMaxRow = Get2DARowCount(sSpellPackage2DAName);
    int nKnownSpellIndex, nSpellsKnown, nSpellsGained, nAbility, nSpellLevel = 0;
    string sKnownListName, sSpellLevel, sPackageSpellLevel, sAbility;
    // Cycle through all spell levels and reset.
    while(nSpellLevel < 10)
    {
        sSpellLevel = IntToString(nSpellLevel);
        //WriteTimestampedLogEntry("pinc_party, 1143, Checking Spell Level: " + sSpellLevel);
        // Recreate the 0th and 1st level based on the package.
        if(nSpellLevel < 2 && bSpellBookRestricted)
        {
            // Classes that are spell book restricted but don't have a SpellKnownTable
            // get 3 spells + Ability Modifier worth of spells like a wizard.
            if(sSpellKnown2DAName == "")
            {
                sAbility = Get2DAString("classes", "SpellCastingAbil", nClass);
                if(sAbility == "INT") nAbility = ABILITY_INTELLIGENCE;
                else if(sAbility == "WIS") nAbility = ABILITY_WISDOM;
                else if(sAbility == "CHA") nAbility = ABILITY_CHARISMA;
                if(nSpellLevel == 0) nSpellsKnown = 7;
                else nSpellsKnown = 3 + GetAbilityModifier(nAbility, oHenchman);
            }
            else
            {
                nSpellsKnown = StringToInt(Get2DAString(sSpellKnown2DAName, "SpellLevel" + sSpellLevel, nLevel - 1));
            }
            //WriteTimestampedLogEntry("pinc_party, 1201, nSpellsKnown: " + IntToString(nSpellsKnown));
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
                    //WriteTimestampedLogEntry("pinc_party, 1178, Adding known spell: " +
                    //          Get2DAString("spells", "LABEL", nPackageSpell));
                    nSpellsKnown--;
                }
                nPackageRow++;
            }
            if(JsonGetLength(jKnownList) == 0)
            {
                jClass = GffRemoveList(jClass, "KnownList" + sSpellLevel);
            }
            else if(JsonGetType(GffGetList(jClass, "KnownList" + sSpellLevel)) != JSON_TYPE_NULL)
            {
                jClass = GffReplaceList(jClass, "KnownList" + sSpellLevel, jKnownList);
            }
            else jClass = GffAddList(jClass, "KnownList" + sSpellLevel, jKnownList);
        }
        // Remove all other known spell levels and memorized levels.
        else
        {
            jKnownList = GffGetList(jClass, "KnownList" + sSpellLevel);
            if(JsonGetType(jKnownList) != JSON_TYPE_NULL)
            {
                jClass = GffRemoveList(jClass, "KnownList" + sSpellLevel);
                //WriteTimestampedLogEntry("pinc_party, 1239, Removing KnownList" + sSpellLevel);
            }
        }
        if(bMemorizesSpells)
        {
            jMemorizedList = GffGetList(jClass, "MemorizedList" + sSpellLevel);
            if(JsonGetType(jMemorizedList) != JSON_TYPE_NULL)
            {
                jClass = GffRemoveList(jClass, "MemorizedList" + sSpellLevel);
                //WriteTimestampedLogEntry("pinc_party, 1248, Removing MemorizedList" + sSpellLevel);
            }
        }
        else
        {
            jSpellsPerDayList = GffGetList(jClass, "SpellsPerDayList");
            if(JsonGetType(jSpellsPerDayList) == JSON_TYPE_NULL)
            {
                jSpellsPerDayList = JsonArray();
                jClass = GffAddList(jClass, "SpellsPerDayList", jSpellsPerDayList);
            }
            nSpellsGained = StringToInt(Get2DAString(sSpellGained2DAName, "SpellLevel"+ sSpellLevel, nLevel - 1));
            jSpell = JsonArrayGet(jSpellsPerDayList, nSpellLevel);
            if(JsonGetType(jSpell) == JSON_TYPE_NULL)
            {
                jSpell = GffAddByte(JsonObject(), "NumSpellsLeft", nSpellsGained);
                jSpell = JsonObjectSet(jSpell, "__struct_id", JsonInt(17767));
                jSpellsPerDayList = JsonArrayInsert(jSpellsPerDayList, jSpell);
            }
            else
            {
                jSpell = GffReplaceByte(jSpell, "NumSpellsLeft", nSpellsGained);
                jSpellsPerDayList = JsonArraySet(jSpellsPerDayList, nSpellLevel, jSpell);
            }
            jClass = GffReplaceList(jClass, "SpellsPerDayList", jSpellsPerDayList);
            //WriteTimestampedLogEntry("pinc_party, 1259, Setting SpellsPerDay to " +
            //              IntToString(nSpellsGained));
        }
        nSpellLevel++;
    }
    //WriteTimestampedLogEntry("pinc_party, 1309, jClass: " + JsonDump(jClass, 2));
    return jClass;
}
object ResetCharacter(object oPC, object oHenchman, int nToken)
{
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    RemoveHenchman(oPC, oHenchman);
    ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
    json jHenchman = ObjectToJson(oHenchman, TRUE);
    json jClassList = GffGetList(jHenchman, "ClassList");
    json jClass = JsonArrayGet(jClassList, 0);
    // Set the Class list to the first class only and put at level 1.
    //int nClass = JsonGetInt(GffGetInt(jClass, "Class"));
    jClass = GffReplaceShort(jClass, "ClassLevel", 1);
    // Delete extra classes.
    int nClassIndex = JsonGetLength(jClassList) - 1;
    while(nClassIndex > 0)
    {
        jClassList = JsonArrayDel(jClassList, nClassIndex--);
    }
    jHenchman = GffReplaceDword(jHenchman, "Experience", 0);
    jHenchman = GffReplaceFloat(jHenchman, "ChallengeRating", 1.0);
    // Get the class selected for the reset.
    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_class_selected"));
    int nClass = GetClassBySelection2DA(nSelection);
    jClass = GffReplaceInt(jClass, "Class", nClass);
    // Get the package selected for the reset.
    nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_package_selected"));
    int nPackage = GetPackageBySelection2DA(IntToString(nClass), nSelection);
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
        //WriteTimestampedLogEntry("pinc_party 1300, jLvlStatList: " + JsonDump(jLvlStatList, 4));
        int nLevel = 1, nLevelTrack = 1;
        int nAbilityStatIncrease, nAbility;
        string sAbility;
        json jAbility;
        json jLevel = JsonArrayGet(jLvlStatList, nLevel);
        while(JsonGetType(jLevel) != JSON_TYPE_NULL)
        {
            //WriteTimestampedLogEntry("inc_party, 1308, Checking level " + IntToString(nLevelTrack));
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
                //WriteTimestampedLogEntry("pinc_party, 1314, Removing " + sAbility + " level bonus ability score point.");
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
    int nHitPoints = StringToInt(Get2DAString("classes", "HitDie", nClass));
    int nConstitution = JsonGetInt(GffGetByte(jHenchman, "Con"));
    int nRace = JsonGetInt(GffGetByte(jHenchman, "Race"));
    nConstitution += StringToInt(Get2DAString("racialtypes", "ConAdjust", nRace));
    if(nConstitution > 9) nHitPoints += (nConstitution - 10) / 2;
    else nHitPoints += (nConstitution - 11) / 2;
    jHenchman = GffReplaceShort(jHenchman, "CurrentHitPoints", nHitPoints);
    jHenchman = GffReplaceShort(jHenchman, "HitPoints", nHitPoints);
    jHenchman = GffReplaceShort(jHenchman, "MaxHitPoints", nHitPoints);
    jHenchman = ResetSkills(jHenchman, oHenchman, nClass, 1);
    jHenchman = ResetFeats(jHenchman, oHenchman, nClass, nPackage, 1);
    jClass = ResetSpellsKnown(jClass, oHenchman, nClass, 1, nPackage);
    jClassList = JsonArraySet(jClassList, 0, jClass);
    jHenchman = GffReplaceList(jHenchman, "ClassList", jClassList);
    //WriteTimestampedLogEntry("pinc_party, 1348, jHenchman: " + JsonDump(jHenchman, 4));
    location lLocation = GetLocation(oHenchman);
    int nFamiliar, nCompanion;
    object oCompanion = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oHenchman);
    if(oCompanion != OBJECT_INVALID) nFamiliar = TRUE;
    oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oHenchman);
    if(oCompanion != OBJECT_INVALID) nCompanion = TRUE;
    SetIsDestroyable(TRUE, FALSE, FALSE, oHenchman);
    DestroyObject(oHenchman);
    oHenchman = party_AddHenchman(oPC, jHenchman, lLocation, nFamiliar, nCompanion);
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
    jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "char_name", 50, FALSE, 140.0, 20.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    // Group 1 Row 1 *********************************************************** 350 / 91
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateTextEditBox (jGroupRow, "port_placeholder", "port_name", 16, FALSE, 140.0, 20.0, "port_tooltip");
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
    jGroupRow = CreateLabel(jGroupRow, "Sound Set", "lbl_sound_set", 140.0, 10.0f, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_BOTTOM);
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
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_stats", 150.0, 15.0, -1.0, 0, NUI_VALIGN_BOTTOM);
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
    jGroupRow = CreateOption(JsonArray(), "opt_classes", NUI_DIRECTION_VERTICAL, jClasses, 150.0, 144.0);
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
    //int nClass = GetClassByPosition(nClassOption + 1, oHenchman);
    //int bNoClass = FALSE;
    //if(nClass == CLASS_TYPE_INVALID)
    //{
    //    nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nClassOption + 1));
    //    bNoClass = TRUE;
    //}
    int nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nClassOption + 1));
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
                            fX, fY, 380.0, 588.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_party");
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
    int bPC = GetIsCharacter(oHenchman);
    string sStats = GetAlignText(oHenchman) + " ";
    if(GetGender(oHenchman) == GENDER_MALE) sStats += "Male ";
    else sStats += "Female ";
    sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oHenchman))));
    NuiSetBind(oPC, nToken, "lbl_stats_label", JsonString(sStats));
    json jHenchman = ObjectToJson(oHenchman);
    NuiSetBind(oPC, nToken, "opt_classes_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "opt_classes_value", JsonInt(nClassOption));
    int nHenchmanLevel = GetCharacterLevels(oHenchman);
    int nPCLevel = GetCharacterLevels(oPC);
    if(nHenchmanLevel < nPCLevel && !bPC) NuiSetBind(oPC, nToken, "btn_level_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_up_tooltip", JsonString("  Levels the character up by one level in selected class."));
    int bPrestigeClass = (Get2DAString("classes", "PreReqTable", nClass) == "");
    if(bPC || !bPrestigeClass) NuiSetBind(oPC, nToken, "btn_reset_event", JsonBool(FALSE));
    else
    {
        NuiSetBind(oPC, nToken, "btn_reset_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_reset_tooltip", JsonString("  Resets the character to level 1."));
    }
    nSelection = GetSelectionByClass2DA(nClass);
    NuiSetBind(oPC, nToken, "cmb_class_selected", JsonInt(nSelection));
    NuiSetBindWatch(oPC, nToken, "cmb_class_selected", TRUE);
    if(!bPC)NuiSetBind(oPC, nToken, "cmb_class_event", JsonBool(TRUE));
    int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1));
    //SendMessageToPC(oPC, "nPackage: " + IntToString(nPackage) + " nSelection: " + IntToString(GetSelectionByPackage2DA(sClass, nPackage)));
    if(nPackage == 0)
    {
        nPackage = GetPackageBySelection2DA(sClass, 0);
        SetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1), nPackage);
    }
    //SendMessageToPC(oPC, "nPackage: " + IntToString(nPackage) + " sClass: " + sClass);
    NuiSetBind(oPC, nToken, "cmb_package_selected", JsonInt(GetSelectionByPackage2DA(sClass, nPackage)));
    NuiSetBindWatch(oPC, nToken, "cmb_package_selected", TRUE);
    if(!bPC) NuiSetBind(oPC, nToken, "cmb_package_event", JsonBool(TRUE));
}
void CreateCharacterDescriptionNUI(object oPC, string sName, string sIcon, string sDescription)
{
    // Row 1 ******************************************************************* 500 / 469
    json jRow = CreateImage(JsonArray(), "", "char_icon", NUI_ASPECT_FIT, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 40.0, 40.0);
    jRow = CreateTextBox(jRow, "char_text", 380.0, 400.0);
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 522
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "OK", "btn_ok", 150.0f, 45.0f);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 522
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "char_description_nui", sName,
                             -1.0, -1.0, 460.0f, 537.0 + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_party");
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
void CreateHenchmanOptionsGUIPanel(object oPC)
{
    // Row 1 *******************************************************************
    json jRow = CreateLabel(JsonArray(), "Maximum number of henchman in party (1-10):", "lbl_max_per_party", 320.0, 20.0);
    jRow = CreateTextEditBox(jRow, "", "txt_max_party", 2, FALSE, 40.0, 20.0);
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 *******************************************************************
    jRow = CreateLabel(JsonArray(), "Max Levels allowed from players level (-5/+5):", "lbl_level_limit", 320.0, 20.0);
    jRow = CreateTextEditBox(jRow, "", "txt_level_limit", 2, FALSE, 40.0, 20.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "party_options_nui", "Party Manager Options",
                             -1.0, -1.0, 400.0f, 537.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_party");
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    jData = GetHenchmanDbJson(GetModule(), "classes", "Data");
    // Row 1
    NuiSetBind(oPC, nToken, "txt_max_party_event", JsonBool(TRUE));
    int nMaxPartySize = JsonGetInt(JsonObjectGet(jData, "Max_Party_Size"));
    NuiSetBind(oPC, nToken, "txt_max_party", JsonString(IntToString(nMaxPartySize)));
    NuiSetBindWatch(oPC, nToken, "txt_max_party", TRUE);
    // Row 2
    NuiSetBind(oPC, nToken, "txt_level_limit_event", JsonBool(TRUE));
    int nLevelLimit = JsonGetInt(JsonObjectGet(jData, "Level_Limit"));
    NuiSetBind(oPC, nToken, "txt_level_limit", JsonString(IntToString(nLevelLimit)));
    NuiSetBindWatch(oPC, nToken, "txt_level_limit", TRUE);
}
