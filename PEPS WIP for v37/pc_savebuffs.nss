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
// Returns the level if this spell has a domain spell on nLevel, or 0.
int GetHasDomainSpell(object oCaster, int nClass, int nLevel, int nSpell);

void main()
{
    object oTarget = OBJECT_SELF;
    object oCaster = GetLastSpellCaster();
    // When setting up the save spells button we saved the PC to itself.
    // Here we get the PC from either our henchmen or ourselves.
    // We do this to make sure that this PC and henchmen are the ones saving spells.
    object oPC = GetLocalObject(ai_GetPlayerMaster(oCaster), "AI_BUFF_PC");
    // If this is a harmful spell or we couldn't find oPC then we need to fix
    // the targets scripts back and run the correct OnSpellCastAt script.
    if(GetLastSpellHarmful() || oPC == OBJECT_INVALID)
    {
        DeleteLocalObject(oPC, "AI_BUFF_PC");
        string sScript = GetLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
        SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
        DeleteLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
        // Cleanup your followers to allow spells to be reacted to as normal.
        int nAssociateType = 2;
        object oAssociate = GetAssociate(nAssociateType, oPC);
        while(nAssociateType < 5)
        {
            if(oAssociate != OBJECT_INVALID)
            {
               sScript = GetLocalString(oAssociate, "AI_BUFF_CAST_AT_SCRIPT");
               SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
               DeleteLocalString(oAssociate, "AI_BUFF_CAST_AT_SCRIPT");
            }
            oAssociate = GetAssociate(++nAssociateType, oPC);
        }
        int nIndex = 1;
        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        while(nIndex <= AI_MAX_HENCHMAN)
        {
            if(oAssociate != OBJECT_INVALID)
            {
               sScript = GetLocalString(oAssociate, "AI_BUFF_CAST_AT_SCRIPT");
               SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
               DeleteLocalString(oAssociate, "AI_BUFF_CAST_AT_SCRIPT");
            }
            oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
        }
        NuiSetBind(oPC, NuiFindWindow(oPC, "widgetbuffwin"), "btn_save", JsonBool(FALSE));
        ai_SendMessages("Saving spells to the list has been turned off.", AI_COLOR_YELLOW, oPC);
        ExecuteScript(sScript, oTarget);
        return;
    }
    // This blocks one spell from saving multiple times due to being an AOE.
    if(GetLocalInt(oPC, "AI_ONLY_ONE")) return;
    SetLocalInt(oPC, "AI_ONLY_ONE", TRUE);
    // We delay this for just less than half a round due to haste.
    DelayCommand(2.5, DeleteLocalInt(oPC, "AI_ONLY_ONE"));
    // If the oTarget != oCaster then we are casting a spell on one of our
    // associates. Some functions expect OBJECT_SELF to be the caster.
    // We get around that by doing some ExecuteScriptChunk shenanigans.
    int nClass, nLevel, nMetaMagic;
    if(oTarget != oCaster)
    {
        SetLocalObject(oCaster, "AI_BUFF_PC", oPC);
        // These functions need the caster to be OBJECT_SELF so lets do a HACK!
        ExecuteScriptChunk("SetLocalInt(GetLocalObject(OBJECT_SELF, \"AI_BUFF_PC\"), \"AI_BUFF_CASTCLASS\", GetLastSpellCastClass());", oCaster);
        ExecuteScriptChunk("SetLocalInt(GetLocalObject(OBJECT_SELF, \"AI_BUFF_PC\"), \"AI_BUFF_SPELLLEVEL\", GetLastSpellLevel());", oCaster);
        ExecuteScriptChunk("SetLocalInt(GetLocalObject(OBJECT_SELF, \"AI_BUFF_PC\"), \"AI_BUFF_METAMAGIC\", GetMetaMagicFeat());", oCaster);
        nClass = GetLocalInt(oPC, "AI_BUFF_CASTCLASS");
        nLevel = GetLocalInt(oPC, "AI_BUFF_SPELLLEVEL");
        nMetaMagic = GetLocalInt(oPC, "AI_METAMAGIC");
        DeleteLocalObject(oCaster, "AI_BUFF_PC");
        DeleteLocalInt(oPC, "AI_BUFF_CASTCLASS");
        DeleteLocalInt(oPC, "AI_BUFF_SPELLLEVEL");
        DeleteLocalInt(oPC, "AI_BUFF_METAMAGIC");
    }
    else
    {
        nClass = GetLastSpellCastClass();
        nLevel = GetLastSpellLevel();
        nMetaMagic = GetMetaMagicFeat();
    }
    int nSpell = GetLastSpell();
    int nDomain = GetHasDomainSpell(oCaster, nClass, nLevel, nSpell);
    string sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    if(nDomain) sName += " [Domain]";
    if(nMetaMagic > 0 && StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
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
    jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
    jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
    jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
    jSpell = JsonArrayInsert(jSpell, JsonInt(nMetaMagic));
    jSpell = JsonArrayInsert(jSpell, JsonInt(nDomain));
    string sCasterName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oCaster)));
    jSpell = JsonArrayInsert(jSpell, JsonString(sCasterName));
    string sTargetName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oTarget)));
    jSpell = JsonArrayInsert(jSpell, JsonString(sTargetName));
    jSpells = JsonArrayInsert(jSpells, jSpell);
    SetBuffDatabaseJson(oPC, "spells", jSpells, sList);
    SendMessageToPC(oPC, sCasterName + " has cast " + sName + " to be saved for fast buffing on " + sTargetName + ".");
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
int GetHasDomainSpell(object oCaster, int nClass, int nLevel, int nSpell)
{
    int nIndex, nMaxIndex, nMSpell, nMmSpell, bDomain, nSubRadSpell, nSubSpell;
    string sSubRadSpell;
    if(StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
    {
        nMaxIndex = GetMemorizedSpellCountByLevel(oCaster, nClass, nLevel);
        while(nIndex < nMaxIndex)
        {
            nMSpell = GetMemorizedSpellId(oCaster, nClass, nLevel, nIndex);
            if(nSpell == nMSpell)
            {
                if(GetMemorizedSpellIsDomainSpell(oCaster, nClass, nLevel, nIndex)) return nLevel;
            }
            nIndex ++;
        }
    }
    return 0;
}
