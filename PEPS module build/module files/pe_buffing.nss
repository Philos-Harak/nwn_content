/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_buffing
////////////////////////////////////////////////////////////////////////////////
 Used with pi_buffing to run the buffing plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"

const int BUFF_MAX_SPELLS = 50;
const string FB_NO_MONSTER_CHECK = "FB_NO_MONSTER_CHECK";

// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetBuffDatabaseString(object oPlayer, string sDataField, string sData, string sTag);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetBuffDatabaseString(object oPlayer, string sDataField, string sTag);
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void SetBuffDatabaseJson(object oPlayer, string sDataField, json jData, string sTag);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json GetBuffDatabaseJson(object oPlayer, string sDataField, string sTag);
// Casts all buff spells saved to the widget button.
void CastSavedBuffSpells(object oPC);
// Will check and make sure the spell is memorized and/or ready.
// Returns TRUE if memorized and ready, FALSE if memorized but not ready,
// and -1 if not memorized for classes that memorize.
// nSpell is the spell to find.
// nClass that cast the spell.
// nLevel the level of the spell.
// nMetamagic is if it has metamagic on it.
// nDomain is if it is a domain spell.
int GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain);
// Creates the Buffing widget.
void PopupWidgetBuffGUIPanel(object oPC);
void main()
{
    object oPC = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();
    string sWndId  = NuiGetWindowId (oPC, nToken);
    //**************************************************************************
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(GetLocalInt (oPC, AI_NO_NUI_SAVE)) return;
        // Get the height, width, x, and y of the window.
        json jGeom = NuiGetBind(oPC, nToken, "window_geometry");
        // Save on the player using the sWndId.
        json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
        if(sWndId == "plbuffwin")
        {
            jMenuData = JsonArraySet(jMenuData, 1, JsonObjectGet(jGeom, "x"));
            jMenuData = JsonArraySet(jMenuData, 2, JsonObjectGet(jGeom, "y"));
        }
        else if(sWndId == "widgetbuffwin")
        {
            jMenuData = JsonArraySet(jMenuData, 5, JsonObjectGet(jGeom, "x"));
            jMenuData = JsonArraySet(jMenuData, 6, JsonObjectGet(jGeom, "y"));
        }
        SetBuffDatabaseJson(oPC, "spells", jMenuData, "menudata");
        return;
    }
    //**************************************************************************
    // Spell Buffing.
    if(sWndId == "plbuffwin")
    {
        if(sEvent == "click")
        {
            string sList;
            if(GetStringLeft(sElem, 10) == "btn_spell_")
            {
                json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
                sList = JsonGetString(JsonArrayGet(jMenuData, 0));
                json jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
                int nIndex = StringToInt(GetStringRight(sElem, GetStringLength(sElem) - 10));
                int nSpell = JsonGetInt(JsonArrayGet(JsonArrayGet(jSpells, nIndex), 0));
                string sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                jSpells = JsonArrayDel(jSpells, nIndex);
                SetBuffDatabaseJson(oPC, "spells", jSpells, sList);
                ai_SendMessages(sName + " has been removed from the list.", AI_COLOR_YELLOW, oPC);
                ExecuteScript("pi_buffing", oPC);
            }
            else if(sElem == "btn_save")
            {
                string sScript;
                object oCreature;
                if(JsonGetInt(NuiGetBind (oPC, nToken, "btn_save")))
                {
                    sScript = GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
                    SetLocalObject(oPC, "AI_BUFF_PC", oPC);
                    SetLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT", sScript);
                    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "pc_savebuffs");
                    // Setup your followers to allow spells to be saved on them as well.
                    int nAssociateType = 2;
                    object oAssociate = GetAssociate(nAssociateType, oPC);
                    while(nAssociateType < 5)
                    {
                        if(oAssociate != OBJECT_INVALID)
                        {
                            SetLocalString(oAssociate, "AI_BUFF_CAST_AT_SCRIPT", sScript);
                            SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "pc_savebuffs");
                        }
                        oAssociate = GetAssociate(++nAssociateType, oPC);
                    }
                    int nIndex = 1;
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    while(nIndex <= AI_MAX_HENCHMAN)
                    {
                        if(oAssociate != OBJECT_INVALID)
                        {
                            SetLocalString(oAssociate, "AI_BUFF_CAST_AT_SCRIPT", sScript);
                            SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "pc_savebuffs");
                        }
                        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
                    }
                    ai_SendMessages("Cast spells on yourself or an associate to save them to the widget.", AI_COLOR_YELLOW, oPC);
                }
                else
                {
                    DeleteLocalObject(oPC, "AI_BUFF_PC");
                    sScript = GetLocalString(oPC, "AI_BUFF_CAST_AT_SCRIPT");
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
                    NuiSetBind(oPC, nToken, "btn_save", JsonBool(FALSE));
                    ai_SendMessages("Saving spells to the list has been turned off.", AI_COLOR_YELLOW, oPC);
                }
            }
            else if(sElem == "btn_clear")
            {
                json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
                sList = JsonGetString(JsonArrayGet(jMenuData, 0));
                SetBuffDatabaseJson(oPC, "spells", JsonArray(), sList);
                ExecuteScript("pi_buffing", oPC);
            }
            else if(sElem == "btn_buff") CastSavedBuffSpells(oPC);
            // Runs all the List 1-4 buttons.
            if(GetStringLeft(sElem, 8) == "btn_list")
            {
                sList = "list" + GetStringRight(sElem, 1);
                json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
                jMenuData = JsonArraySet(jMenuData, 0, JsonString(sList));
                SetBuffDatabaseJson(oPC, "spells", jMenuData, "menudata");
                ExecuteScript("pi_buffing", oPC);
            }
        }
        else if(sEvent == "watch")
        {
            if(GetLocalInt (oPC, AI_NO_NUI_SAVE)) return;
            if(sElem == "buff_widget_check")
            {
                int bBuffWidget = JsonGetInt(NuiGetBind(oPC, nToken, "buff_widget_check"));
                json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
                jMenuData = JsonArraySet(jMenuData, 3, JsonBool(bBuffWidget));
                SetBuffDatabaseJson(oPC, "spells", jMenuData, "menudata");
                if(bBuffWidget) PopupWidgetBuffGUIPanel(oPC);
                else NuiDestroy(oPC, NuiFindWindow(oPC, "widgetbuffwin"));
            }
            else if(sElem == "lock_buff_widget_check")
            {
                int bBuffLockWidget = JsonGetInt(NuiGetBind(oPC, nToken, "lock_buff_widget_check"));
                json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
                if(bBuffLockWidget) jMenuData = JsonArraySet(jMenuData, 3, JsonBool(TRUE));
                jMenuData = JsonArraySet(jMenuData, 4, JsonBool(bBuffLockWidget));
                SetBuffDatabaseJson(oPC, "spells", jMenuData, "menudata");
                NuiSetBind(oPC, nToken, "buff_widget_check", JsonBool(TRUE));
                PopupWidgetBuffGUIPanel(oPC);
            }
            else if(sElem == "chbx_no_monster_check_check")
            {
                int bNoCheckMonsters = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                SetLocalInt(oPC, FB_NO_MONSTER_CHECK, bNoCheckMonsters);
            }
            else if(sElem == "txt_spell_delay")
            {
                string sDelay = JsonGetString(NuiGetBind(oPC, nToken, "txt_spell_delay"));
                float fDelay = StringToFloat(sDelay);
                if(fDelay < 0.1f) fDelay = 0.1f;
                if(fDelay > 6.0f) fDelay = 6.0f;
                sDelay = FloatToString(fDelay, 0, 1);
                SetBuffDatabaseString(oPC, "spells", sDelay, "Delay");
            }
        }
    }
    //**************************************************************************
    // Spell Buffing.
    else if(sWndId == "widgetbuffwin")
    {
        if(sEvent == "click")
        {
            string sList;
            if(sElem == "btn_one") sList = "list1";
            if(sElem == "btn_two") sList = "list2";
            if(sElem == "btn_three") sList = "list3";
            if(sElem == "btn_four") sList = "list4";
            json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
            jMenuData = JsonArraySet(jMenuData, 0, JsonString(sList));
            SetBuffDatabaseJson(oPC, "spells", jMenuData, "menudata");
            CastSavedBuffSpells(oPC);
        }
    }
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
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@tag", sTag);
    if(SqlStep(sql)) return SqlGetJson(sql, 0);
    else return JsonArray();
}
void CastBuffSpell(object oPC, object oCaster, object oTarget, int nSpell, int nClass, int nMetamagic, int nDomain, string sList, string sName, int bInstantSpell)
{
    string sCasterName = GetName(oCaster);
    string sTargetName = GetName(oTarget);
    ai_SendMessages(sCasterName + " is quick buffing " + sName + " on " + sTargetName, AI_COLOR_GREEN, oPC);
    AssignCommand(oCaster, ActionCastSpellAtObject(nSpell, oTarget, nMetamagic, FALSE, nDomain, 0, bInstantSpell, nClass));
}
void CastSavedBuffSpells(object oPC)
{
    // Lets make sure the save button is off!
    if(GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT) == "pc_savebuffs")
    {
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
        int nMainWindow = NuiFindWindow(oPC, "plbuffwin");
        if(nMainWindow) NuiSetBind(oPC, nMainWindow, "btn_save", JsonBool(FALSE));
        ai_SendMessages("Saving spells to the list has been turned off.", AI_COLOR_YELLOW, oPC);
    }
    float fDistance;
    if(!GetLocalInt(oPC, FB_NO_MONSTER_CHECK))
    {
        // Check for monsters! We cannot let them buff if they are close to the enemy!
        object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oPC);
        fDistance = GetDistanceBetween(oPC, oEnemy);
    }
    if(fDistance > 30.0f || fDistance == 0.0)
    {
        string sName;
        float fDelay;
        float fDelayIncrement = StringToFloat(GetBuffDatabaseString(oPC, "spells", "Delay"));;
        int bInstantSpell;
        if(fDelayIncrement < 3.0f) bInstantSpell = TRUE;
        int nSpell, nClass, nLevel, nMetamagic, nDomain, nSpellReady, nIndex = 0;
        json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
        string sList = JsonGetString(JsonArrayGet(jMenuData, 0));
        json jSpell, jSpells = GetBuffDatabaseJson(oPC, "spells", sList);
        while(nIndex <= BUFF_MAX_SPELLS)
        {
            jSpell = JsonArrayGet(jSpells, nIndex);
            if(JsonGetType(jSpell) != JSON_TYPE_NULL)
            {
                nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
                nLevel = JsonGetInt(JsonArrayGet(jSpell, 2));
                nMetamagic = JsonGetInt(JsonArrayGet(jSpell, 3));
                nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                location lLocation = GetLocation(oPC);
                // Saved the Caster's name so we can find them to cast the spell.
                string sCasterName = JsonGetString(JsonArrayGet(jSpell, 5));
                object oCaster;
                if(sCasterName == "" || sCasterName == ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPC)))) oCaster = oPC;
                else
                {
                    oCaster = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lLocation, TRUE);
                    while(oCaster != OBJECT_INVALID)
                    {
                        if(sCasterName == ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oCaster)))) break;
                        oCaster = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lLocation, TRUE);
                    }
                }
                if(oCaster == OBJECT_INVALID)
                {
                    DelayCommand(fDelay, ai_SendMessages("Cannot quick cast " + sName + " because the " + sCasterName + " is not here!", AI_COLOR_RED, oPC));
                }
                else
                {
                    // Saved the target's name so we can find them to cast the spell on.
                    string sTargetName = JsonGetString(JsonArrayGet(jSpell, 6));
                    object oTarget;
                    if(sTargetName == "" || sTargetName == ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oPC)))) oTarget = oPC;
                    else
                    {
                        oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lLocation, TRUE);
                        while(oTarget != OBJECT_INVALID)
                        {
                            if(sTargetName == ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oTarget)))) break;
                            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lLocation, TRUE);
                        }
                    }
                    if(oTarget == OBJECT_INVALID)
                    {
                        DelayCommand(fDelay, ai_SendMessages("Cannot quick cast " + sName + " because the " + sTargetName + " is not here!", AI_COLOR_RED, oPC));
                    }
                    else
                    {
                        if(nMetamagic > 0)
                        {
                            if(nMetamagic == METAMAGIC_EMPOWER) sName += " (Empowered)";
                            else if(nMetamagic == METAMAGIC_EXTEND) sName += " (Extended)";
                            else if(nMetamagic == METAMAGIC_MAXIMIZE) sName += " (Maximized)";
                            else if(nMetamagic == METAMAGIC_QUICKEN) sName += " (Quickened)";
                            else if(nMetamagic == METAMAGIC_SILENT) sName += " (Silent)";
                            else if(nMetamagic == METAMAGIC_STILL) sName += " (Still)";
                        }
                        nSpellReady = GetSpellReady(oCaster, nSpell, nClass, nLevel, nMetamagic, nDomain);
                        if(nSpellReady == TRUE)
                        {
                            DelayCommand(fDelay, CastBuffSpell(oPC, oCaster, oTarget, nSpell, nClass, nMetamagic, nDomain, sList, sName, bInstantSpell));
                        }
                        else if(nSpellReady == -1)
                        {
                            DelayCommand(fDelay, ai_SendMessages(sCasterName + " cannot quick cast " + sName + " because it is not ready to cast!", AI_COLOR_RED, oPC));
                        }
                        else if(nSpellReady == -2)
                        {
                            DelayCommand (fDelay, ai_SendMessages(sCasterName + " cannot quick cast " + sName + " because it is not memorized!", AI_COLOR_RED, oPC));
                        }
                        else if(nSpellReady == -3)
                        {
                            DelayCommand (fDelay, ai_SendMessages(sCasterName + " cannot quick cast " + sName + " because there are no spell slots of that level left!", AI_COLOR_RED, oPC));
                        }
                        else if(nSpellReady == -4)
                        {
                            DelayCommand (fDelay, ai_SendMessages(sCasterName + "cannot quick cast " + sName + " because that spell is not known.", AI_COLOR_RED, oPC));
                        }
                        fDelay += fDelayIncrement;
                    }
                }
            }
            else break;
            nIndex ++;
        }
        if(nIndex == 0 && !NuiFindWindow(oPC, "plbuffwin")) ExecuteScript("pi_buffing", oPC);
    }
    else ai_SendMessages("Enemies are too close for you to cast all your buff spells!", AI_COLOR_RED, oPC);
}
int GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain)
{
    int nIndex, nMaxIndex, nMSpell, nMmSpell, nDSpell, nSubRadSpell, nSubSpell;
    string sSubRadSpell;
    if(StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
    {
        int nSpellMemorized;
        nMaxIndex = GetMemorizedSpellCountByLevel(oCaster, nClass, nLevel);
        while(nIndex < nMaxIndex)
        {
            nMSpell = GetMemorizedSpellId(oCaster, nClass, nLevel, nIndex);
            if(nSpell == nMSpell)
            {
                nMmSpell = GetMemorizedSpellMetaMagic(oCaster, nClass, nLevel, nIndex);
                nDSpell = GetMemorizedSpellIsDomainSpell(oCaster, nClass, nLevel, nIndex);
                //SendMessageToPC(oCaster, "pe_buffing, 308, nSpell: " + IntToString(nSpell) +
                //         " nMSpell: " + IntToString(nMSpell) +
                //         " nMmSpell: " + IntToString(nMmSpell) +
                //         " nMetamagic: " + IntToString(nMetamagic) +
                //         " nDomain: " + IntToString(nDomain) +
                //         " nDSpell: " + IntToString(nDSpell));
                if(nMmSpell == nMetamagic)
                {
                    nSpellMemorized = TRUE;
                    if(GetMemorizedSpellReady(oCaster, nClass, nLevel, nIndex))
                    {
                        if((nDomain && nDSpell) || (!nDomain && !nDSpell)) return TRUE;
                    }
                }
            }
            for(nSubRadSpell = 1; nSubRadSpell < 5; nSubRadSpell++)
            {
                sSubRadSpell = "SubRadSpell" + IntToString(nSubRadSpell);
                if(nSpell == StringToInt(Get2DAString("spells", sSubRadSpell, nMSpell)))
                {
                    nMmSpell = GetMemorizedSpellMetaMagic(oCaster, nClass, nLevel, nIndex);
                    nDSpell = GetMemorizedSpellIsDomainSpell(oCaster, nClass, nLevel, nIndex);
                    //SendMessageToPC(oCaster, "pe_buffing, 433, nMmSpell: " + IntToString(nMmSpell) +
                    //         " nMetamagic: " + IntToString(nMetamagic) +
                    //         " nDomain: " + IntToString(nDomain) +
                    //         " nDSpell: " + IntToString(nDSpell));
                    if(nMmSpell == nMetamagic)
                    {
                        nSpellMemorized = TRUE;
                        if(GetMemorizedSpellReady(oCaster, nClass, nLevel, nIndex))
                        {
                            if((nDomain && nDSpell) || (!nDomain && !nDSpell)) return TRUE;
                        }
                    }
                }
            }
            nIndex ++;
        }
        if(nSpellMemorized) return -1;
        return -2;
    }
    else
    {
        int nSpellKnown;
        nMaxIndex = GetKnownSpellCount(oCaster, nClass, nLevel);
        while(nIndex < nMaxIndex)
        {
            nMSpell = GetKnownSpellId(oCaster, nClass, nLevel, nIndex);
            if(nSpell == nMSpell)
            {
                nSpellKnown = TRUE;
                if(GetSpellUsesLeft(oCaster, nClass, nSpell)) return TRUE;
            }
            for(nSubRadSpell = 1; nSubRadSpell < 5; nSubRadSpell++)
            {
                sSubRadSpell = "SubRadSpell" + IntToString(nSubRadSpell);
                if(nSpell == StringToInt(Get2DAString("spells", sSubRadSpell, nMSpell)))
                {
                    nSpellKnown = TRUE;
                    if(GetSpellUsesLeft(oCaster, nClass, nSpell)) return TRUE;
                }
            }
            nIndex ++;
        }
        if(nSpellKnown) return -3;
        return -4;
    }
    return -2;
}
void PopupWidgetBuffGUIPanel(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // Row 1 (buttons)**********************************************************
    json jRow = CreateButtonImage(JsonArray(), "ir_level1", "btn_one", 35.0f, 35.0f, 0.0);
    jRow = CreateButtonImage(jRow, "ir_level2", "btn_two", 35.0f, 35.0f, 0.0);
    jRow = CreateButtonImage(jRow, "ir_level3", "btn_three", 35.0f, 35.0f, 0.0);
    jRow = CreateButtonImage(jRow, "ir_level4", "btn_four", 35.0f, 35.0f, 0.0);
    // Add the row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    json jMenuData = GetBuffDatabaseJson(oPC, "spells", "menudata");
    int bAIBuffWidgetLock = JsonGetInt(JsonArrayGet(jMenuData, 4));
    // Get the window location to restore it from the database.
    float fX = JsonGetFloat(JsonArrayGet(jMenuData, 5));
    float fY = JsonGetFloat(JsonArrayGet(jMenuData, 6));
    if(fX == 0.0f && fY == 0.0f)
    {
        fX = 10.0f;
        fY = 10.0f;
    }
    float fGUI_Scale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    if(bAIBuffWidgetLock)
    {
        fX += 4.0f;
        // GUI scales are a mess, I just figured them out per scale to keep the widget from moving.
        if(fGUI_Scale == 1.0) fY += 37.0;
        else if(fGUI_Scale == 1.1) fY += 38.0;
        else if(fGUI_Scale == 1.2) fY += 40.0;
        else if(fGUI_Scale == 1.3) fY += 42.0;
        else if(fGUI_Scale == 1.4) fY += 43.0;
        else if(fGUI_Scale == 1.5) fY += 45.0;
        else if(fGUI_Scale == 1.6) fY += 47.0;
        else if(fGUI_Scale == 1.7) fY += 48.0;
        else if(fGUI_Scale == 1.8) fY += 50.0;
        else if(fGUI_Scale == 1.9) fY += 52.0;
        else if(fGUI_Scale == 2.0) fY += 54.0;
    }
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken;
    if(bAIBuffWidgetLock) nToken = SetWindow (oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 160.0, 62.0, FALSE, FALSE, FALSE, TRUE, FALSE, "pe_buffing");
    else nToken = SetWindow (oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 160.0, 95.0, FALSE, FALSE, FALSE, TRUE, TRUE, "pe_buffing");
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    //NuiSetBind (oPC, nToken, "btn_one", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_one_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_two", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_two_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_three", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_three_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_four", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_four_event", JsonBool (TRUE));
}

