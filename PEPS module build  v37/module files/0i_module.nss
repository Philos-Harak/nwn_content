/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_module
////////////////////////////////////////////////////////////////////////////////
 Include script for handling event scripts for injecting the systems into a
 module for either single player or a server.
*///////////////////////////////////////////////////////////////////////////////
#include "x2_inc_switches"
#include "0i_associates"
#include "0i_menus"
#include "0i_menus_dm"
#include "0i_player_target"
#include "0i_gui_events"
// Add to nw_c2_default9 OnSpawn event script of monsters and
int ai_OnMonsterSpawn(object oCreature);
// Add to nw_ch_ac9 OnSpawn event script of henchman.
void ai_OnAssociateSpawn(object oCreature);
// Run all of the game setup scripts and build for PC.
// If oPC is passed as Invalid then it will get the firt PC in the game.
void ai_CheckPCStart(object oPC = OBJECT_INVALID);
// Run all of the games setup scripts and build for DM.
void ai_CheckDMStart(object oDM);
// Checks to see if we should change the monster via Json.
int ai_ChangeMonster(object oCreature, object oModule);
// Checks to see if we should change the associate via Json.
object ai_ChangeAssociate(object oCreature, object oModule);
// Sets the events for oCreature that is a Monster while playing Infinite Dungeons.
void ai_SetIDMonsterEventScripts(object oCreature);
// Sets the events for oCreature that is a monster in while using the PRC and
// playing Infinite Dungeons.
void ai_SetPRCIDMonsterEventScripts(object oCreature);
// Sets the events for oCreature that is an associate while using the PRC.
void ai_SetPRCAssociateEventScripts(object oCreature);
// Reverts single player monster event scripts back to their default.
void ai_ChangeEventScriptsForMonster(object oCreature);
// Reverts single player associates event scripts back to their default.
void ai_ChangeEventScriptsForAssociate(object oCreature);
// If using PRC this will replace some spells with PRC variants.
json ai_ReplaceSpellsWithPRCVariants(object oCreature, json jCreature);

//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
int ai_OnMonsterSpawn(object oCreature)
{
    if(GetLocalInt(oCreature, AI_ONSPAWN_EVENT)) return FALSE;
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    object oModule = GetModule();
    int nInfiniteDungeons;
    int nPRC = GetLocalInt(oModule, AI_USING_PRC);
    // If you are running a server this will not affect the module.
    if(!ai_GetIsServer())
    {
        ai_CheckPCStart();
        string sModuleName = GetModuleName();
        if(sModuleName == "Neverwinter Nights - Infinite Dungeons" ||
           sModuleName == "Infinite Dungeons [PRC8]")
        {
            nInfiniteDungeons = TRUE;
            if(nPRC) ai_SetPRCIDMonsterEventScripts(oCreature);
            else ai_SetIDMonsterEventScripts(oCreature);
            // Fix to get plot givers, finishers from getting killed a lot.
            if(GetLocalString(oCreature, "sConversation") == "id1_plotgiver " ||
               GetLocalString(oCreature, "sConversation") == "id1_plotdest")
            {
                ChangeToStandardFaction(oCreature, STANDARD_FACTION_MERCHANT);
                SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 50, oCreature);
            }
        }
    }
    // PRC and Infinite dungeons has issues with Ondeath script so we just leave it alone.
    if(!nPRC && !nInfiniteDungeons)
    {
        // We change this script so we can setup permanent summons on/off.
        string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
        SetLocalString(oCreature, "AI_ON_DEATH", sScript);
        SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
    }
    if(GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL))
    {
        string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        if (sCombatAI == "") SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_incorporeal");
    }
    ai_SetListeningPatterns(oCreature);
    ai_SetCreatureAIScript(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAura(oCreature);
    SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, AI_MONSTER_HEAL_IN_COMBAT_CHANCE);
    SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, AI_MONSTER_HEAL_OUT_COMBAT_CHANCE);
    int nMonsterHpIncrease = GetLocalInt(oModule, AI_INCREASE_MONSTERS_HP);
    if(nMonsterHpIncrease)
    {
        int nHp = GetMaxHitPoints(oCreature);
        nHp = (nHp * nMonsterHpIncrease) / 100;
        effect eHp = EffectTemporaryHitpoints(nHp);
        eHp = SupernaturalEffect(eHp);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHp, oCreature);
    }
    // Check if the monster should change how they search for targets.
    if(d100() <= GetLocalInt(GetModule(), AI_RULE_AI_DIFFICULTY))
    {
        SetLocalInt(oCreature, AI_RULE_AI_DIFFICULTY, TRUE);
    }
    // Do json changes after we have setup the creature.
    if(ai_ChangeMonster(oCreature, oModule)) return TRUE;
    return FALSE;
}
void ai_OnAssociateSpawn(object oCreature)
{
    if(GetLocalInt(oCreature, AI_ONSPAWN_EVENT)) return;
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    int bPRC = GetLocalInt(GetModule(), AI_USING_PRC);
    // If you are running a server this will not affect the module.
    if(!ai_GetIsServer())
    {
        if(bPRC) ai_SetPRCAssociateEventScripts(oCreature);
    }
    // PRC has issues with Ondeath script so we just leave it alone.
    if(!bPRC)
    {
        // We change this script so we can setup permanent summons on/off.
        // If you don't use this you may remove the next three lines.
        string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
        // If our script is set in the OnDeath event then don't save as secondary.
        if(sScript != "0e_ch_7_ondeath")
        {
            SetLocalString(oCreature, "AI_ON_DEATH", sScript);
            SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
        }
        else if(GetLocalString(oCreature, "AI_ON_DEATH") == "0e_ch_7_ondeath")
        {
            // If we have somehow saved our death script then change to default.
            SetLocalString(oCreature, "AI_ON_DEATH", "nw_ch_ac7");
        }
    }
    // Initialize Associate modes for basic use.
    ai_SetListeningPatterns(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAssociateAIScript(oCreature, FALSE);
    ai_SetAura(oCreature);
    if(GetLocalInt(GetModule(), AI_RULE_PARTY_SCALE)) ai_CheckXPPartyScale(oCreature);
    // Bioware summoned shadows are not incorporeal, also set the ai code.
    if (GetTag(OBJECT_SELF) == "NW_S_SHADOW")
    {
        SetLocalInt(OBJECT_SELF, "X2_L_IS_INCORPOREAL", TRUE);
        SetLocalString(OBJECT_SELF, AI_DEFAULT_SCRIPT, "ai_shadow");
    }
}
void ai_CheckPCStart(object oPC = OBJECT_INVALID)
{
    if(oPC == OBJECT_INVALID) oPC = GetFirstPC();
    // There should always be a PC widget. If it doesn't exist then we assume
    // that the module is being loaded or started.
    if(!NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI))
    {
        object oModule = GetModule();
        // Do PRC check and save variable to the module.
        if(ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) != "")
            SetLocalInt(oModule, AI_USING_PRC, TRUE);
        ai_SetAIRules();
        ai_CheckAssociateData(oPC, oPC, "pc");
        ai_StartupPlugins(oPC);
        ai_SetupPlayerTarget();
        ai_SetupModuleGUIEvents();
        ai_CreateWidgetNUI(oPC, oPC);
        ai_SetNormalAppearance(oPC);
    }
}
void ai_CheckDMStart(object oDM)
{
    if(!NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI))
    {
        object oModule = GetModule();
        // Do PRC check and save variable to the module.
        if(ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) != "")
            SetLocalInt(oModule, AI_USING_PRC, TRUE);
        ai_SetAIRules();
        ai_CheckDMData(oDM);
        ai_StartupPlugins(oDM);
        ai_SetupPlayerTarget();
        ai_SetupModuleGUIEvents();
        ai_CreateDMWidgetNUI(oDM);
    }
}
void ai_CopyMonster(object oCreature, object oModule)
{
    // After setting the monster lets see if we should copy it.
    float fMonsterIncrease = GetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS);
    if(GetIsEncounterCreature(oCreature) && fMonsterIncrease > 0.0)
    {
        int nMonsterIncrease;
        float fMonsterCounter = GetLocalFloat(oModule, "AI_MONSTER_COUNTER");
        fMonsterCounter += fMonsterIncrease;
        nMonsterIncrease = FloatToInt(fMonsterCounter);
        if(nMonsterIncrease > 0)
        {
           fMonsterCounter = fMonsterCounter - IntToFloat(nMonsterIncrease);
        }
        SetLocalFloat(oModule, "AI_MONSTER_COUNTER", fMonsterCounter);
        while(nMonsterIncrease > 0)
        {
            CopyObject(oCreature, GetLocation(oCreature), OBJECT_INVALID, "", TRUE);
            nMonsterIncrease = nMonsterIncrease - 1;
        }
    }
}
void ai_CreateMonster(json jCreature, location lLocation, object oModule)
{
    //WriteTimestampedLogEntry("0i_module, 181, " + JsonDump(jCreature, 1));
    object oCreature = JsonToObject(jCreature, lLocation, OBJECT_INVALID, TRUE);
    if(AI_DEBUG) ai_Debug("0i_module", "210", "Creating: " + GetName(oCreature));
    // Lets set the new version as spawned so we skip the initial setup again.
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    /*if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY))
    {
        SetIsDestroyable(FALSE, FALSE, TRUE, oCreature);
        SetLootable(oCreature, TRUE);
    } */
    if(AI_DEBUG) ai_Debug("0i_module", "187", GetName(oCreature));
    ai_CopyMonster(oCreature, oModule);
    // This is a hak to allow wild shaped creatures to be able to attack!
    if(GetHasFeat(FEAT_WILD_SHAPE, oCreature))
    {
        AssignCommand(oCreature, ActionUseFeat(FEAT_WILD_SHAPE, oCreature, SUBFEAT_WILD_SHAPE_BADGER));
        DelayCommand(4.0, ai_RemoveASpecificEffect(oCreature, EFFECT_TYPE_POLYMORPH));
    }
    return;
}
json ai_SetCompanionSummoning(object oCreature, json jCreature)
{
    if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature, TRUE))
    {
        json jFamiliar = JsonObjectGet(jCreature, "FamiliarName");
        jFamiliar = JsonObjectSet(jFamiliar, "value", JsonString("Summoned Familiar"));
        jCreature = JsonObjectSet(jCreature, "FamiliarName", jFamiliar);
        jFamiliar = JsonObjectGet(jCreature, "FamiliarType");
        jFamiliar = JsonObjectSet(jFamiliar, "value", JsonInt(10)); //JsonInt(Random(11)));
        return JsonObjectSet(jCreature, "FamiliarType", jFamiliar);
    }
    if(GetHasFeat(FEAT_ANIMAL_COMPANION , oCreature, TRUE))
    {
        json jCompanion = JsonObjectGet(jCreature, "CompanionName");
        jCompanion = JsonObjectSet(jCompanion, "value", JsonString("Summoned Companion"));
        jCreature = JsonObjectSet(jCreature, "CompanionName", jCompanion);
        jCompanion = JsonObjectGet(jCreature, "CompanionType");
        jCompanion = JsonObjectSet(jCompanion, "value", JsonInt(Random(9)));
        return JsonObjectSet(jCreature, "CompanionType", jCompanion);
    }
    return jCreature;
}
int ai_ChangeMonster(object oCreature, object oModule)
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature);
    // Lets not mess up the cutscenes with silly RULES.
    if(GetCutsceneMode(oPC)) return FALSE;
    float fDistance = GetDistanceBetween(oCreature, oPC);
    // Looks bad to see creatures wink in and out plus could cause module errors.
    if(fDistance != 0.0 && fDistance < 20.0) return FALSE;
    if(IsInConversation(oCreature)) return FALSE;
    json jCreature = ObjectToJson(oCreature, TRUE);
    // We now use plugins to mod our monsters.
    json jMonsterMods = GetLocalJson(oModule, AI_MONSTER_MOD_JSON);
    if(JsonGetType(jMonsterMods) != JSON_TYPE_NULL)
    {
        SetLocalJson(oModule, AI_MONSTER_JSON, jCreature);
        SetLocalObject(oModule, AI_MONSTER_OBJECT, oCreature);
        int nIndex;
        string sMonsterMod = JsonGetString(JsonArrayGet(jMonsterMods, nIndex));
        while(sMonsterMod != "")
        {
            ExecuteScript(sMonsterMod, oPC);
            sMonsterMod = JsonGetString(JsonArrayGet(jMonsterMods, ++nIndex));
        }
        jCreature = GetLocalJson(oModule, AI_MONSTER_JSON);
    }
    int nSummon = GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS) &&
                 (GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature, TRUE) ||
                  GetHasFeat(FEAT_ANIMAL_COMPANION, oCreature, TRUE));
    int nPercDist = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE) != 11 &&
                    GetReputation(oCreature, oPC) < 11;
    //WriteTimestampedLogEntry(GetName(oCreature) + ": fDistance: " + FloatToString(fDistance, 0, 2) + " nSummon: " + IntToString(nSummon) +
    //      " nPercDist: " + IntToString(nPercDist) + " Reputation: " + IntToString(GetReputation(oCreature, oPC)));
    if(nSummon || nPercDist)
    {
        location lLocation = GetLocation(oCreature);
        if(nPercDist)
        {
            json jPerception = JsonObjectGet(jCreature, "PerceptionRange");
            jPerception = JsonObjectSet(jPerception, "value", JsonInt(GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE)));
            jCreature = JsonObjectSet(jCreature, "PerceptionRange", jPerception);
        }
        if(nSummon) jCreature = ai_SetCompanionSummoning(oCreature, jCreature);
        SetLocalInt(oModule, AI_MONSTER_CHANGED, TRUE);
    }
    // Did any of the Monster mods get used? These are done in independent mod scripts.
    if(GetLocalInt(oModule, AI_MONSTER_CHANGED))
    {
        SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
        location lLocation = GetLocation(oCreature);
        if(AI_DEBUG) ai_Debug("0i_module", "299", "Destroying: " + GetName(oCreature));
        DestroyObject(oCreature);
        AssignCommand(oModule, DelayCommand(1.0, ai_CreateMonster(jCreature, lLocation, oModule)));
        DeleteLocalInt(oModule, AI_MONSTER_CHANGED);
        return TRUE;
    }
    else ai_CopyMonster(oCreature, oModule);
    DeleteLocalJson(oModule, AI_MONSTER_JSON);
    DeleteLocalObject(oModule, AI_MONSTER_OBJECT);
    // This is a hak to allow wild shaped creatures to be able to attack!
    if(GetHasFeat(FEAT_WILD_SHAPE))
    {
        AssignCommand(oCreature, ActionUseFeat(FEAT_WILD_SHAPE, oCreature, SUBFEAT_WILD_SHAPE_BADGER));
        DelayCommand(4.0, ai_RemoveASpecificEffect(oCreature, EFFECT_TYPE_POLYMORPH));
    }
    return FALSE;
}
// Special event scripts for Infinite Dungeons!
void ai_SetIDMonsterEventScripts(object oCreature)
{
    if(GetIsPC(oCreature)) return;
    //if(AI_DEBUG) ai_Debug("0i_module", "433", "Changing " + GetName(oCreature) + "'s Infinte Dungeons event scripts.");
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else if(sScript == "nw_c2_default1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_id_events");
    else if(sScript == "nw_c2_default2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_id_events");
    else if(sScript == "nw_c2_default3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_id_events");
    else if(sScript == "nw_c2_default4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_id_events");
    else if(sScript == "nw_c2_default5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_id_events");
    else if(sScript == "nw_c2_default6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // We don't set OnDeath for Infinite Dungeons!
    //********** On Death **********
    //sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    //SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_id_events");
    //********** On Disturbed **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_id_events");
    else if(sScript == "nw_c2_default8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "x2_def_rested") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_id_events");
    else if(sScript == "nw_c2_defaulta") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_id_events");
    else if(sScript == "nw_c2_defaultb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_id_events");
    else if(sScript == "nw_c2_defaulte") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
// Special event scripts for Infinite Dungeons with PRC!
void ai_SetPRCIDMonsterEventScripts(object oCreature)
{
    if(GetIsPC(oCreature)) return;
    //if(AI_DEBUG) ai_Debug("0i_module", "433", "Changing " + GetName(oCreature) + "'s Infinte Dungeons event scripts for PRC.");
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_id_events");
    else if(sScript == "nw_c2_default1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_id_events");
    else if(sScript == "nw_c2_default2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_id_events");
    else if(sScript == "nw_c2_default3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_id_events");
    else if(sScript == "nw_c2_default4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_id_events");
    else if(sScript == "nw_c2_default5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_id_events");
    else if(sScript == "nw_c2_default6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // We don't set OnDeath for PRC or Infinite dungeons.
    //********** On Death **********
    //sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    //SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_prc_id_events");
    //********** On Disturbed **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_id_events");
    else if(sScript == "nw_c2_default8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "x2_def_rested") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_id_events");
    else if(sScript == "nw_c2_defaulta") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_id_events");
    else if(sScript == "nw_c2_defaultb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_id_events");
    else if(sScript == "nw_c2_defaulte") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_id_events");
    else if(sScript == "") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_id_events");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
// Special event scripts for PRC associates!
void ai_SetPRCAssociateEventScripts(object oCreature)
{
    if(GetIsPC(oCreature)) return;
    //if(AI_DEBUG) ai_Debug("0i_module", "433", "Changing " + GetName(oCreature) + "'s Infinte Dungeons event scripts for PRC.");
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_ch_events");
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_ch_events");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_ch_events");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_ch_events");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_ch_events");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_ch_events");
    //********** On Disturbed **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ac8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_ch_events");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_ch_events");
    else if(sScript == "nw_ch_aca") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_ch_events");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_ch_events");
    else if(sScript == "nw_ch_acb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_ch_events");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_ch_events");
    else if(sScript == "nw_ch_ace") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_ch_events");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    if(!GetCommandable(oCreature)) SetCommandable(TRUE, oCreature);
}
void ai_ChangeEventScriptsForMonster(object oCreature)
{
    if(GetIsPC(oCreature)) return;
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "0e_c2_1_hb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_c2_default1");
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    if(sScript == "0e_c2_2_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_c2_default2");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    if(sScript == "0e_c2_3_endround") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_c2_default3");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    if(sScript == "0e_c2_4_convers") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_c2_default4");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    if(sScript == "0e_c2_5_phyatked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_c2_default5");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    if(sScript == "0e_c2_6_damaged") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_c2_default6");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_c2_deafult7");
    //********** On Disturbed **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    if(sScript == "0e_c2_8_disturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_c2_default8");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_c2_defaulta");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    if(sScript == "0e_c2_b_castat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_c2_defaultb");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    if(sScript == "0e_c2_e_blocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_c2_defaulte");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "nw_c2_defaulte");
}
void ai_ChangeEventScriptsForAssociate(object oCreature)
{
    if(GetIsPC(oCreature)) return;
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac6");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_ch_ac7");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_aca");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "nw_ch_acd");
}
