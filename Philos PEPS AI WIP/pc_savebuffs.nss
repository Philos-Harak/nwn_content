/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pc_savebuffs
////////////////////////////////////////////////////////////////////////////////
 Used with pi_buffing to run the buffing plugin for
 Philos Single Player Enhancements.

Note: If a spell saves incorrectly check the spell script to see if the correct
spell is being passed through the SignalEvent correctly.
Known error in Shield of Faith spell as the below code in the shield of faith
script sends Camoflage instead!
"SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, 421, FALSE));"
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
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
// We do some crazy hack to get all the correct information when casting spells.
// GetLastSpellCastClass() will only give the class if this script is running
//                         on the actual caster, i.e. our PC.
// GetLastSpellLevel() will only give the level if this script is running on
//                     the actual caster, i.e. our PC.
// So for this to work we run this scrip in the event OnSpellCastAt of our
// target, then we ExecuteScript this script again with the Caster (oPC)
// as OBJECT_SELF for this script on its second pass. This allows us to get the
// information from the above functions! Neat!
void main()
{
    object oTarget = OBJECT_SELF;
    // The first pass we get oCaster via GetLastSpellCaster() fails in ExecuteScript!
    // The second pass we get oCaster via the variable "AI_BUFF_CASTER".
    object oCaster = GetLocalObject(oTarget, "AI_BUFF_CASTER");
    if(oCaster == OBJECT_INVALID) oCaster = GetLastSpellCaster();
    // We setting up the save spells button we saved the PC to itself.
    // Here we get the PC to make sure the caster of this spell is our saving PC.
    object oPC = GetLocalObject(oCaster, "AI_BUFF_PC");
    // The first pass we get nspell via GetLastSpell() fails in ExecuteScript!
    // The second pass we get nSpell via the variable "AI_BUFF_SPELL".
    int nSpell = GetLocalInt(oTarget, "AI_BUFF_SPELL");
    if(nSpell == 0) nSpell = GetLastSpell();
    // If this is a harful spell or The caster does not equal our saving PC then
    // we need to fix the targets scripts back and run the correct OnSpellCastAt script.
    if(GetLastSpellHarmful() || oPC != oCaster)
    {
        string sScript = GetLocalString(oTarget, "AI_BUFF_CAST_AT_SCRIPT");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
        ExecuteScript(sScript, oTarget);
        return;
    }
    // If the oTarget != oCaster then we are casting a spell on one of our
    // associates. We must make a second pass to get the correct information.
    // We do this by saving the Target, Caster, and Spell so we can get them
    // in the second pass as Execute Script makes them impossible to get on a
    // second pass.
    if(oTarget != oCaster)
    {
        SetLocalObject(oPC, "AI_BUFF_TARGET", oTarget);
        SetLocalObject(oPC, "AI_BUFF_CASTER", oCaster);
        SetLocalInt(oPC, "AI_BUFF_SPELL", nSpell);
        ExecuteScript("pc_savebuffs", oPC);
        return;
    }
    // If this is the first pass and we get here then oCaster is casting a spell
    // on themselves. So oTarget will be invalid and we should use oPC.
    // If this is the second pass and we get here then we have saved oTarget
    // to oPC and this will get them so we can save the target to the spell!
    oTarget = GetLocalObject(oPC, "AI_BUFF_TARGET");
    if(oTarget == OBJECT_INVALID) oTarget = oPC;
    // We need to clean up this mess!
    DeleteLocalObject(oPC, "AI_BUFF_TARGET");
    DeleteLocalObject(oPC, "AI_BUFF_CASTER");
    DeleteLocalInt(oPC, "AI_BUFF_SPELL");
    // This blocks one spell from saving multiple times due to being an AOE.
    if(GetLocalInt(oPC, "AI_ONLY_ONE")) return;
    SetLocalInt(oPC, "AI_ONLY_ONE", TRUE);
    // We delay this for just less than half a round due to haste.
    DelayCommand(2.5, DeleteLocalInt(oPC, "AI_ONLY_ONE"));
    // Here is the whole problem and why we must do a second pass if the target
    // is not the caster. These only work if this script is run by the caster.
    int nClass = GetLastSpellCastClass();
    int nLevel = GetLastSpellLevel();
    // Everything below saves the spell to the database with all our now correct info.
    int nDomain;
    int nMetaMagic = GetMetaMagicFeat();
    string sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    //ai_Debug("pc_savebuffs", "32", "oCaster: " + GetName(oCaster) + " oTarget: " + GetName(oTarget) +
    //         " Spell: " + sName + " nClass: " + IntToString(nClass) +
    //         " nLevel: " + IntToString(nLevel) + " nMetaMagic: " + IntToString(nMetaMagic));
    if(nMetaMagic > 0)
    {
        // We must add the level of the metamagic to the spells level to get the spells correct level.
        if(nMetaMagic == METAMAGIC_EMPOWER) { sName += " (Empowered)"; nLevel += 2; }
        else if(nMetaMagic == METAMAGIC_EXTEND) { sName += " (Extended)"; nLevel += 1; }
        else if(nMetaMagic == METAMAGIC_MAXIMIZE) { sName += " (Maximized)"; nLevel += 3; }
        else if(nMetaMagic == METAMAGIC_QUICKEN) { sName += " (Quickened)"; nLevel += 4; }
        else if(nMetaMagic == METAMAGIC_SILENT) { sName += " (Silent)"; nLevel += 1; }
        else if(nMetaMagic == METAMAGIC_STILL) { sName += " (Still)"; nLevel += 1; }
    }
    json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
    string sList = JsonGetString(JsonArrayGet(jMenuData, 0));
    json jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
    json jSpell = JsonArray();
    JsonArrayInsertInplace(jSpell, JsonInt(nSpell));
    JsonArrayInsertInplace(jSpell, JsonInt(nClass));
    JsonArrayInsertInplace(jSpell, JsonInt(nLevel));
    JsonArrayInsertInplace(jSpell, JsonInt(nMetaMagic));
    JsonArrayInsertInplace(jSpell, JsonInt(nDomain));
    string sTargetName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oTarget, TRUE)));
    JsonArrayInsertInplace(jSpell, JsonString(sTargetName));
    JsonArrayInsertInplace(jSpells, jSpell);
    SetBuffDatabaseJson(oPC, "spells", jSpells, sList);
    SendMessageToPC(oPC, sName + " has been saved for fast buffing on " + sTargetName + ".");
    ExecuteScript("pi_buffing", oPC);
}
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
    else return "";
}
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@data", sData);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    SqlStep (sql);
}
void SetBuffDatabaseJson (object oPlayer, string sDataField, json jData, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "UPDATE BUFF_TABLE SET " + sDataField + " = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}
json GetBuffDatabaseJson (object oPlayer, string sDataField, string sTag)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPlayer, TRUE)));
    string sQuery = "SELECT " + sDataField + " FROM BUFF_TABLE WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
