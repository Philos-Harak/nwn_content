/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_module
////////////////////////////////////////////////////////////////////////////////
 Include script for handling event scripts for injecting the systems into a
 module for either single player or a server.
*///////////////////////////////////////////////////////////////////////////////
#include "x2_inc_switches"
#include "0i_associates"
#include "0i_menus"
#include "0i_player_target"
#include "0i_gui_events"
// Add to nw_c2_default9 OnSpawn event script of monsters and
void ai_OnMonsterSpawn(object oCreature);
// Add to nw_ch_ac9 OnSpawn event script of henchman.
void ai_OnAssociateSpawn(object oCreature);
// Run all of the players starting scripts.
// If oPC is passed as Invalid then it will get the firt PC in the game.
void ai_CheckPCStart(object oPC = OBJECT_INVALID, int bForce = FALSE);
// Checks to see if we should copy the monster.
void ai_CopyMonster(object oCreature, object oModule);
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

//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
void ai_OnMonsterSpawn(object oCreature)
{
    if(GetLocalInt(oCreature, AI_ONSPAWN_EVENT)) return;
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    object oModule = GetModule();
    int nInfiniteDungeons;
    // If you are running a server this will not affect the module.
    if(!AI_SERVER)
    {
        ai_CheckPCStart();
        string sModuleName = GetModuleName();
        if(sModuleName == "Neverwinter Nights - Infinite Dungeons" ||
           sModuleName == "Infinite Dungeons [PRC8]")
        {
            nInfiniteDungeons = TRUE;
            if(GetLocalInt(oModule, AI_USING_PRC))
            {
                ai_SetPRCIDMonsterEventScripts(oCreature);
            }
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
    if(!GetLocalInt(oModule, AI_USING_PRC) && !nInfiniteDungeons)
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
    // Version 36 does not work with this code! ai_ChangeMonster(oCreature, oModule);
    ai_CopyMonster(oCreature, oModule);
}
void ai_OnAssociateSpawn(object oCreature)
{
    if(GetLocalInt(oCreature, AI_ONSPAWN_EVENT)) return;
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    int bPRC = GetLocalInt(GetModule(), AI_USING_PRC);
    // If you are running a server this will not affect the module.
    if(!AI_SERVER)
    {
        if(bPRC) ai_SetPRCAssociateEventScripts(oCreature);
    }
    // PRC has issues with Ondeath script so we just leave it alone.
    if(!bPRC)
    {
        // We change this script so we can setup permanent summons on/off.
        // If you don't use this you may remove the next three lines.
        string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
        SetLocalString(oCreature, "AI_ON_DEATH", sScript);
        SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
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
void ai_CheckPCStart(object oPC = OBJECT_INVALID, int bForce = FALSE)
{
    if(oPC == OBJECT_INVALID) oPC = GetFirstPC();
    // There should always be a PC widget. If it doesn't exist then we assume
    // that the module is being loaded or started.
    if(bForce || !NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI))
    {
        object oModule = GetModule();
        // Do PRC check and save variable to the module.
        if(ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) != "")
            SetLocalInt(oModule, AI_USING_PRC, TRUE);
        ai_SetAIRules();
        ai_CheckAssociateData(oPC, oPC, "pc");
        ai_StartupPlugins(oPC);
        ai_SetupPlayerTarget(oPC);
        ai_SetupModuleGUIEvents(oPC);
        ai_CreateWidgetNUI(oPC, oPC);
        ai_SetNormalAppearance(oPC);
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
    //WriteTimestampedLogEntry("0i_module, 106, " + JsonDump(jCreature, 1));
    object oCreature = JsonToObject(jCreature, lLocation, OBJECT_INVALID, TRUE);
    /*if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY))
    {
        AssignCommand(oCreature, SetIsDestroyable(FALSE, FALSE, TRUE));
        SetLootable(oCreature, TRUE);
    } */
    ai_CopyMonster(oCreature, oModule);
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
        jFamiliar = JsonObjectSet(jFamiliar, "value", JsonInt(Random(11)));
        jCreature = JsonObjectSet(jCreature, "FamiliarType", jFamiliar);
    }
    if(GetHasFeat(FEAT_ANIMAL_COMPANION , oCreature, TRUE))
    {
        json jCompanion = JsonObjectGet(jCreature, "CompanionName");
        jCompanion = JsonObjectSet(jCompanion, "value", JsonString("Summoned Companion"));
        jCreature = JsonObjectSet(jCreature, "CompanionName", jCompanion);
        jCompanion = JsonObjectGet(jCreature, "CompanionType");
        jCompanion = JsonObjectSet(jCompanion, "value", JsonInt(Random(9)));
        jCreature = JsonObjectSet(jCreature, "CompanionType", jCompanion);
    }
    return jCreature;
}
void ai_ChangeMonster(object oCreature, object oModule)
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature);
    float fDistance = GetDistanceBetween(oCreature, oPC);
    // Looks bad to see creatures wink in and out plus could cause module errors.
    // Lets not mess up the cutscenes with silly RULES.
    if(!GetCutsceneMode(oPC) && fDistance > AI_RANGE_LONG &&
       !IsInConversation(oCreature))
    {
        int nSummon = GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS) &&
                     (GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature, TRUE)) ||
                      GetHasFeat(FEAT_ANIMAL_COMPANION, oCreature, TRUE);
        int nPercDist = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE) != 11 &&
                        GetReputation(oCreature, oPC) < 11;
        //WriteTimestampedLogEntry(GetName(oCreature) + ": fDistance: " + FloatToString(fDistance, 0, 2) + " nSummon: " + IntToString(nSummon) +
        //      " nPercDist: " + IntToString(nPercDist) + " Reputation: " + IntToString(GetReputation(oCreature, oPC)));
        if(nSummon || nPercDist)
        {
            location lLocation = GetLocation(oCreature);
            json jCreature = ObjectToJson(oCreature, TRUE);
            if(nPercDist)
            {
                //jCreature = GffReplaceByte(jCreature, "PerceptionRange", GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE));
                WriteTimestampedLogEntry("0i_module, 233, jCreature: " + JsonDump(jCreature, 1));
                //json jPerception = JsonObjectGet(jCreature, "PerceptionRange");
                //jPerception = JsonObjectSet(jPerception, "value", JsonInt(GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE)));
                //jCreature = JsonObjectSet(jCreature, "PerceptionRange", jPerception);
            }
            //if(nSummon) ai_SetCompanionSummoning(oCreature, jCreature);
            //AssignCommand(oCreature, SetIsDestroyable(TRUE, FALSE, FALSE));
            //DestroyObject(oCreature, 0.1);
            //AssignCommand(oModule, DelayCommand(1.0, ai_CreateMonster(jCreature, lLocation, oModule)));
        }
    }
    else ai_CopyMonster(oCreature, oModule);
}
// Special event scripts for Infinite Dungeons!
void ai_SetIDMonsterEventScripts(object oCreature)
{
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
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac6");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_aca");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}




