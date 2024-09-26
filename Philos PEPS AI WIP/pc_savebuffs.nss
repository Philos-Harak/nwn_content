/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pc_savebuffs
////////////////////////////////////////////////////////////////////////////////
 Used with ai_crafting to run the crafting plugin for
 Philos Single Player Enhancements.

Note: If a spell saves incorrectly check the spell script to see if the correct
spell is being passed through the SignalEvent correctly.
Known error in Shield of Faith spell as the below code in the shield of faith
script sends Camoflage instead!
"SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, 421, FALSE));"
*///////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag = "");
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag = "");
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetBuffDatabaseJson(object oPlayer, string sDataField, json jData, string sTag = "");
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetBuffDatabaseJson(object oPlayer, string sDataField, string sTag = "");
// Strips the color codes from sText
string StripColorCodes(string sText);
void main()
{
    if(GetLastSpellHarmful()) return;
    object oCaster = GetLastSpellCaster();
    object oTarget = OBJECT_SELF;
    int nClass = GetLastSpellCastClass();
    int nLevel = GetLastSpellLevel();
    int nSpell = GetLastSpell();
    int nDomain;
    int nMetaMagic = GetMetaMagicFeat();
    string sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    //ai_Debug("pc_savebuffs", "32", "oCaster: " + GetName(oCaster) + " oTarget: " + GetName(oTarget) +
    //         " Spell: " + sName + " nClass: " + IntToString(nClass) +
    //         " nLevel: " + IntToString(nLevel) + " nMetaMagic: " + IntToString(nMetaMagic));
    if(nMetaMagic > 0)
    {
        // We must add the level of the metamagic to the spells level to get the spells correct level.
        if (nMetaMagic == METAMAGIC_EMPOWER) { sName += " (Empowered)"; nLevel += 2; }
        else if (nMetaMagic == METAMAGIC_EXTEND) { sName += " (Extended)"; nLevel += 1; }
        else if (nMetaMagic == METAMAGIC_MAXIMIZE) { sName += " (Maximized)"; nLevel += 3; }
        else if (nMetaMagic == METAMAGIC_QUICKEN) { sName += " (Quickened)"; nLevel += 4; }
        else if (nMetaMagic == METAMAGIC_SILENT) { sName += " (Silent)"; nLevel += 1; }
        else if (nMetaMagic == METAMAGIC_STILL) { sName += " (Still)"; nLevel += 1; }
    }
    string sList = "list" + GetBuffDatabaseString(oCaster, "spells", "list");
    json jSpells = GetBuffDatabaseJson(oCaster, "spells", sList);
    json jSpell = JsonArray();
    JsonArrayInsertInplace(jSpell, JsonInt(nSpell));
    JsonArrayInsertInplace(jSpell, JsonInt(nClass));
    JsonArrayInsertInplace(jSpell, JsonInt(nLevel));
    JsonArrayInsertInplace(jSpell, JsonInt(nMetaMagic));
    JsonArrayInsertInplace(jSpell, JsonInt(nDomain));
    string sTargetName = StripColorCodes(GetName(oTarget));
    JsonArrayInsertInplace(jSpell, JsonString(sTargetName));
    JsonArrayInsertInplace(jSpells, jSpell);
    SetBuffDatabaseJson(oCaster, "spells", jSpells, sList);
    ai_Debug("pc_savebuffs", "58", "jSpells: " + JsonDump(jSpells, 1));
    SendMessageToPC(oCaster, sName + " has been saved for fast buffing on " + sTargetName + ".");
    ExecuteScript("pi_buffing", oCaster);
}
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag = "")
{
    string sName = GetName(oPlayer, TRUE);
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
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
    SqlStep (sql);
}
void SetBuffDatabaseJson (object oPlayer, string sDataField, json jData, string sTag = "")
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}
json GetBuffDatabaseJson (object oPlayer, string sDataField, string sTag = "")
{
    string sName = GetName (oPlayer, TRUE);
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@name", sName);
    if (sTag != "") SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
string StripColorCodes(string sText)
{
    string sColorCode, sChar;
    int nStringLength = GetStringLength(sText);
    int i = FindSubString(sText, "<c", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength - (i + 6));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "<c", i);
    }
    i = FindSubString(sText, "</", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength - (i + 4));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "</", i);
    }
    return sText;
}

