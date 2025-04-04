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
// Add to nw_c2_default9 OnSpawn event script of monsters and
void ai_OnMonsterSpawn(object oCreature);
// Add to nw_ch_ac9 OnSpawn event script of henchman.
void ai_OnAssociateSpawn(object oCreature);
// Run all of the players starting scripts.
// If oPC is passed as Invalid then it will get the firt PC in the game.
void ai_CheckPCStart(object oPC = OBJECT_INVALID, int bForce = FALSE);
// Checks to see if we should change the monster via Json.
object ai_ChangeMonster(object oCreature, object oModule);
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
    // DOES NOT WORK IN VERSION 36!
    if(!AI_SERVER)
    {
        ai_CheckPCStart();
        string sModuleName = GetModuleName();
        if(sModuleName == "Neverwinter Nights - Infinite Dungeons" ||
           sModuleName == "Infinite Dungeons [PRC8]")
        {
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
    // Do changes before we adjust anything on the creature via Json!
    //oCreature = ai_ChangeMonster(oCreature, oModule);
    // We change this script so we can setup permanent summons on/off.
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
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
void ai_OnAssociateSpawn(object oCreature)
{
    if(GetLocalInt(oCreature, AI_ONSPAWN_EVENT)) return;
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    // If you are running a server this will not affect the module.
    if(!AI_SERVER)
    {
        if(ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) != "")
        {
            ai_SetPRCAssociateEventScripts(oCreature);
        }
    }
    // We change this script so we can setup permanent summons on/off.
    // If you don't use this you may remove the next three lines.
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
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
        ai_CreateWidgetNUI(oPC, oPC);
        ai_SetNormalAppearance(oPC);
    }
}
object ai_CreateMonster(json jCreature, location lLocation, object oModule)
{
    //WriteTimestampedLogEntry("0i_module, 106, " + JsonDump(jCreature, 1));
    object oCreature = JsonToObject(jCreature, lLocation, OBJECT_INVALID, TRUE);
    if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY))
    {
        AssignCommand(oCreature, SetIsDestroyable(FALSE, FALSE, TRUE));
        SetLootable(oCreature, TRUE);
    }
    return oCreature;
}
void ai_SetCompanionSummoning(object oCreature, json jCreature)
{
    if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature, TRUE))
    {
        json jFamiliar = JsonObjectGet(jCreature, "FamiliarName");
        JsonObjectSetInplace(jFamiliar, "value", JsonString("Summoned Familiar"));
        JsonObjectSetInplace(jCreature, "FamiliarName", jFamiliar);
        jFamiliar = JsonObjectGet(jCreature, "FamiliarType");
        JsonObjectSetInplace(jFamiliar, "value", JsonInt(Random(11)));
        JsonObjectSetInplace(jCreature, "FamiliarType", jFamiliar);
    }
    if(GetHasFeat(FEAT_ANIMAL_COMPANION , oCreature, TRUE))
    {
        json jCompanion = JsonObjectGet(jCreature, "CompanionName");
        JsonObjectSetInplace(jCompanion, "value", JsonString("Summoned Companion"));
        JsonObjectSetInplace(jCreature, "CompanionName", jCompanion);
        jCompanion = JsonObjectGet(jCreature, "CompanionType");
        JsonObjectSetInplace(jCompanion, "value", JsonInt(Random(9)));
        JsonObjectSetInplace(jCreature, "CompanionType", jCompanion);
    }
}
object ai_ChangeMonster(object oCreature, object oModule)
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature);
    // Lets not mess up the cutscenes with silly RULES.
    if(GetCutsceneMode(oPC)) return oCreature;
    float fDistance = GetDistanceBetween(oCreature, oPC);
    // Looks bad to see creatures wink in and out plus could cause module errors.
    //if(fDistance != 0.0 && fDistance < AI_RANGE_PERCEPTION) return oCreature;
    if(IsInConversation(oCreature)) return oCreature;
    int nSummon = GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS);
    int nPercDist = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE);
    //WriteTimestampedLogEntry("nStay: " + IntToString(nStay) + " nSummon: " + IntToString(nSummon) +
    //      " nPercDist: " + IntToString(nPercDist));
    if(nSummon || nPercDist != 11)
    {
        location lLocation = GetLocation(oCreature);
        json jCreature = ObjectToJson(oCreature, TRUE);
        if(nPercDist != 11)
        {
            json jPerception = JsonObjectGet(jCreature, "PerceptionRange");
            JsonObjectSetInplace(jPerception, "value", JsonInt(nPercDist));
            JsonObjectSetInplace(jCreature, "PerceptionRange", jPerception);
        }
        if(nSummon) ai_SetCompanionSummoning(oCreature, jCreature);
        SetIsDestroyable(TRUE, FALSE, FALSE);
        DestroyObject(oCreature);
        return ai_CreateMonster(jCreature, lLocation, oModule);
    }
    return oCreature;
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
    // This is always set incase they have permanent summons turned on.
    //********** On Death **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_id_events");
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
    // This is always set incase they have permanent summons turned on.
    //********** On Death **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_prc_id_events");
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
    //if(AI_DEBUG) ai_Debug("0i_module", "433", "Changing " + GetName(oCreature) + "'s Infinte Dungeons event scripts for PRC.");
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_ch_events");
    else return;
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_ch_events");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_ch_events");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_ch_events");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_ch_events");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_ch_events");
    //********** On Disturbed **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_ch_events");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_ch_events");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_ch_events");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "default") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_ch_events");
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




