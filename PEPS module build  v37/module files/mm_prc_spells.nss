#include "0i_menus"
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
json ai_CheckToReplaceSpell(json jSpellList, int nClass, int nLevel, int nSlot)
{
    //if(d100() > 49) return jSpellList;
    string sSpellTableColumn = Get2DAString("classes", "SpellTableColumn", nClass);
    int nRoll = d10() + 1 + nLevel * 10;
    int nSpell = StringToInt(Get2DAString("prc_add_spells", sSpellTableColumn, nRoll));
    if(nSpell > 0)
    {
        //WriteTimestampedLogEntry("mm_prc_spells, 13 nSpell: " + IntToString(nSpell) +
        //                      " nLevel: " + IntToString(nLevel) + " nSlot: " + IntToString(nSlot));
        json jSpellArray = JsonArrayGet(jSpellList, nSlot);
        json jSpell = JsonObjectGet(jSpellArray, "Spell");
        jSpell = JsonObjectSet(jSpell, "value", JsonInt(nSpell));
        jSpellArray = JsonObjectSet(jSpellArray, "Spell", jSpell);
        return JsonArraySet(jSpellList, nSlot, jSpellArray);
    }
    return jSpellList;
}
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    int bChanged, bCreatureChanged, nPosition, nClass, nLevel, nSlot, nMaxSlots;
    json jClass, jMemorizedList, jKnownList;
    object oModule = GetModule();
    json jCreature = GetLocalJson(oModule, AI_MONSTER_JSON);
    object oCreature = GetLocalObject(oModule, AI_MONSTER_OBJECT);
    json jClassList = GffGetList(jCreature, "ClassList");
    while(nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        nClass = GetClassByPosition(nPosition, oCreature);
        if(Get2DAString("classes", "SpellCaster", nClass) == "1")
        {
            //WriteTimestampedLogEntry("mm_prc_spells, 39 " + GetName(oCreature) + JsonDump(jClassList, 4));
            jClass = JsonArrayGet(jClassList, nPosition - 1);
            if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
            {
                nLevel = 1;
                while(nLevel < 9)
                {
                    jMemorizedList = GffGetList(jClass, "MemorizedList" + IntToString(nLevel));
                    if(JsonGetType(jMemorizedList) != JSON_TYPE_NULL)
                    {
                        nSlot = 0;
                        nMaxSlots = GetMemorizedSpellCountByLevel(oCreature, nClass, nLevel);
                        while(nSlot < nMaxSlots)
                        {
                            jMemorizedList = ai_CheckToReplaceSpell(jMemorizedList, nClass, nLevel, nSlot);
                            nSlot++;
                        }
                        //WriteTimestampedLogEntry("nClass: " + IntToString(nClass) + " nLevel: " + IntToString(nLevel) +
                        //                         " nSlot: " + IntToString(nSlot) + " jMemorizedList " + JsonDump(jMemorizedList, 4));
                        jClass = GffReplaceList(jClass, "MemorizedList" + IntToString(nLevel), jMemorizedList);
                        bChanged = TRUE;
                    }
                    nLevel++;
                }
            }
            else
            {
                nLevel = 1;
                while(nLevel < 9)
                {
                    jKnownList = GffGetList(jClass, "KnownList" + IntToString(nLevel));
                    if(JsonGetType(jMemorizedList) != JSON_TYPE_NULL)
                    {
                        nSlot = 0;
                        nMaxSlots = GetKnownSpellCount(oCreature, nClass, nLevel);
                        while(nSlot < nMaxSlots)
                        {
                            jKnownList = ai_CheckToReplaceSpell(jKnownList, nClass, nLevel, nSlot);
                            nSlot++;
                        }
                        jClass = GffReplaceList(jClass, "KnownList" + IntToString(nLevel), jKnownList);
                        bChanged = TRUE;
                    }
                    nLevel++;
                }
            }
            if(bChanged)
            {
                //WriteTimestampedLogEntry("0i_module, 87 " + GetName(oCreature) + " jClass: " + JsonDump(jClass, 4));
                jClassList = JsonArraySet(jClassList, nPosition - 1, jClass);
                //if(AI_DEBUG) ai_Debug("0i_module, 89 " + GetName(oCreature) + " jClassList: " + JsonDump(jClassList, 4));
                jCreature = GffReplaceList(jCreature, "ClassList", jClassList);
                bCreatureChanged = TRUE;
                bChanged = FALSE;
            }
        }
        nPosition++;
    }
    if(bCreatureChanged)
    {
        //WriteTimestampedLogEntry("mm_prc_spells, 99 " + GetName(oCreature) + " jClassList: " + JsonDump(jClassList, 4));
        SetLocalJson(oModule, AI_MONSTER_JSON, jCreature);
        SetLocalInt(oModule, AI_MONSTER_CHANGED, TRUE);
    }
}
int PRCSpellsSetup(object oPC)
{
    // Check to make sure prc_add_spells.2da is loaded.
    if(ResManGetAliasFor("prc_add_spells", RESTYPE_2DA) == "")
    {
        SendMessageToPC(oPC, "prc_add_spells.2da is not loaded! Make sure it is in the override or development folder.");
        return FALSE;
    }
    // Check to make sure PRC is loaded.
    if(!GetLocalInt(GetModule(), AI_USING_PRC))
    {
        SendMessageToPC(oPC, "PRC is not being used. PRC must be active for this mod to work.");
        return FALSE;
    }
    return TRUE;
}
void SetMonsterModJson(object oPC)
{
    object oModule = GetModule();
    json jMonsterMods = GetLocalJson(oModule, AI_MONSTER_MOD_JSON);
    if(JsonGetType(jMonsterMods) == JSON_TYPE_NULL) jMonsterMods = JsonArray();
    int nIndex;
    string sMonsterMod = JsonGetString(JsonArrayGet(jMonsterMods, nIndex));
    while(sMonsterMod != "")
    {
        if(sMonsterMod == "mm_prc_spells") return;
        sMonsterMod = JsonGetString(JsonArrayGet(jMonsterMods, ++nIndex));
    }
    jMonsterMods = JsonArrayInsert(jMonsterMods, JsonString("mm_prc_spells"));
    SetLocalJson(oModule, AI_MONSTER_MOD_JSON, jMonsterMods);
    ai_SendMessages("mm_prc_spells loaded! Monsters will be using PRC spells.", AI_COLOR_YELLOW, oPC);
}
int StartingUp(object oPC)
{
    if(!PRCSpellsSetup(oPC))
    {
        SendMessageToPC(oPC, "mm_prc_spells monster mod has failed to load due to an error.");
        // Return -1 in AI_PLUGIN_SET to tell PEPS that we failed to load.
        SetLocalInt(oPC, AI_PLUGIN_SET, -1);
        return TRUE;
    }
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("mm_prc_spells"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(3));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Monsters will use PRC spells!"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString(""));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        SetMonsterModJson(oPC);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    SetMonsterModJson(oPC);
    return TRUE;
}

