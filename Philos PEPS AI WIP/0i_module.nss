/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_module
////////////////////////////////////////////////////////////////////////////////
 Include script for handling event scripts for injecting the systems into a
 module for either single player or a server.
*///////////////////////////////////////////////////////////////////////////////
#include "nw_inc_gff"
#include "0i_associates"
// Checks to see if we should change the monster via Json.
object ai_ChangeMonster(object oCreature, object oModule);
// Checks to see if we should change the associate via Json.
object ai_ChangeAssociate(object oCreature, object oModule);
// Sets the events for oCreature that use event scripts for monsters in most modules.
void ai_SetMonsterEventScripts(object oCreature);
// Sets the events for oCreature that use event scripts for monsters in Infinite Dungeons.
void ai_SetIDMonsterEventScripts(object oCreature);
// Sets the events for oCreature that use event scripts for associates.
void ai_SetAssociateEventScripts(object oCreature);
// Reverts a single players monsters, NPC's and associate event scripts back to their default.
void ai_FixEventScripts(object oCreature);
// Special event scripts for Infinite Dungeons!
void ai_SetIDMonsterEventScripts(object oCreature);
// Special event scripts for PRC modules.
void ai_SetPRCAssociateEventScripts(object oCreature);
//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
// These scripts are one line inserts for the creature event they go at the end.
// example ai_OnDeath goes at the end of the OnDeath event (nw_c2_default7).

// Add to nw_c2_default9 OnSpawn event script of monsters and
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal);
// Add to nw_ch_ac9 OnSpawn event script of henchman.
void ai_OnAssociateSpawn(object oCreature);

//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal)
{
    object oModule = GetModule();
    // Do changes before we adjust anything on the creature via Json!
    oCreature = ai_ChangeMonster(oCreature, oModule);
    string sModuleName = GetModuleName();
    //string sModuleTag = GetTag(oModule);
    //if(AI_DEBUG) ai_Debug("0i_module", "44", "ModuleTag: " + sModuleTag);
    if(sModuleName == "Neverwinter Nights - Infinite Dungeons")
    {
        ai_SetIDMonsterEventScripts(oCreature);
    }
    else ai_SetMonsterEventScripts(oCreature);
    if(bIncorporeal)
    {
        string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        if (sCombatAI == "") SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_incorporeal");
    }
    ai_SetListeningPatterns(oCreature);
    ai_SetCreatureAIScript(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAura(oCreature);
    ai_SetNormalAppearance(oCreature);
    SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, 70);
    SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    int nMonsterHpIncrease = GetLocalInt(oModule, AI_INCREASE_MONSTERS_HP);
    if(nMonsterHpIncrease)
    {
        int nHp = GetMaxHitPoints(oCreature);
        nHp = (nHp * nMonsterHpIncrease) / 100;
        effect eHp = EffectTemporaryHitpoints(nHp);
        eHp = SupernaturalEffect(eHp);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHp, oCreature);
    }
    // After setting the monster lets see if we should copy it.
    int nMonsterIncrease = GetLocalInt(oModule, AI_INCREASE_ENC_MONSTERS);
    if(nMonsterIncrease && GetIsEncounterCreature(oCreature))
    {
        object oNewCreature;
        while(nMonsterIncrease > 0)
        {
            CopyObject(oCreature, GetLocation(oCreature), OBJECT_INVALID, "", TRUE);
            nMonsterIncrease --;
        }
    }
    // If we have already seen an enemy then we need to begin combat!
    object oEnemy = GetNearestEnemy(oCreature);
    if(AI_DEBUG) ai_Debug("0i_single_player", "62", GetName(oCreature) + " nearest enemy: " + GetName(oEnemy) +
                 " Distance: " + FloatToString(GetDistanceBetween(oCreature, oEnemy), 0, 2) +
                 " Talents set? " + IntToString(GetLocalInt(oCreature, AI_TALENTS_SET)));
    if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_PERCEPTION)
    {
        ai_SetupMonsterBuffTargets(oCreature);
        // To save steps and time we set the talenst while we buff!
        ai_SetCreatureTalents(oCreature, TRUE);
        ai_ClearBuffTargets(oCreature, "AI_ALLY_TARGET_");
        ai_Debug("0i_single_player", "65", GetName(oCreature) + " is starting combat!");
        ai_DoMonsterCombatRound(oCreature);
    }
}
object ai_CreateMonster(json jCreature, location lLocation, object oModule)
{
    //if(AI_DEBUG) ai_Debug("0i_module", "129", JsonDump(jCreature, 1));
    object oCreature = JsonToObject(jCreature, lLocation, OBJECT_INVALID, TRUE);
    if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY))
    {
        SetIsDestroyable(FALSE, FALSE, TRUE, oCreature);
        SetLootable(oCreature, TRUE);
    }
    return oCreature;
}
json ai_SetCompanionSummoning(object oCreature, json jCreature)
{
    if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature, TRUE))
    {
        jCreature = GffReplaceInt(jCreature, "FamiliarType", Random(11));
    }
    if(GetHasFeat(FEAT_ANIMAL_COMPANION , oCreature, TRUE))
    {
        jCreature = GffReplaceInt(jCreature, "CompanionType", Random(9));
    }
    return jCreature;
}
object ai_ChangeMonster(object oCreature, object oModule)
{
    if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY) || GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS))
    {
        location lLocation = GetLocation(oCreature);
        json jCreature = ObjectToJson(oCreature, TRUE);
        //ai_Debug("0i_single_player", "116", GetName(oCreature) + " " + JsonDump(jCreature, 1));
        if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY)) jCreature = GffReplaceDword(jCreature, "DecayTime", 600000);
        if(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS)) jCreature = ai_SetCompanionSummoning(oCreature, jCreature);
        DestroyObject(oCreature);
        return ai_CreateMonster(jCreature, lLocation, oModule);
    }
    return oCreature;
}
void ai_OnAssociateSpawn(object oCreature)
{
    // Change the associate via Json.
    //oCreature = ai_ChangeAssociate(oCreature, GetModule());
    // Initialize Associate modes for basic use.
    SetLocalFloat(oCreature, AI_FOLLOW_RANGE, 3.0);
    SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, 50);
    SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    SetLocalFloat(oCreature, AI_LOOT_CHECK_RANGE, 20.0);
    SetLocalFloat(oCreature, AI_LOCK_CHECK_RANGE, 20.0);
    SetLocalFloat(oCreature, AI_TRAP_CHECK_RANGE, 20.0);
    ai_SetMagicMode(oCreature, AI_MAGIC_NORMAL_MAGIC_USE);
    ai_SetListeningPatterns(oCreature);
    // Do PRC check.
    if(ResManGetAliasFor("prc_ai_fam_heart", RESTYPE_NCS) != "")
    {
        ai_SetPRCAssociateEventScripts(oCreature);
    }
    else ai_SetAssociateEventScripts(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAssociateAIScript(oCreature, FALSE);
    ai_SetAura(oCreature);
    ai_SetNormalAppearance(oCreature);
    // Bioware summoned shadows are not incorporeal, also set the ai code.
    if (GetTag(OBJECT_SELF) == "NW_S_SHADOW")
    {
        SetLocalInt(OBJECT_SELF, "X2_L_IS_INCORPOREAL", TRUE);
        SetLocalString(OBJECT_SELF, AI_DEFAULT_SCRIPT, "ai_shadow");
    }
}
object ai_CreateAssociate(json jCreature, location lLocation, object oModule)
{
    WriteTimestampedLogEntry("0i_module [168] " + JsonDump(jCreature, 1));
    if(AI_DEBUG) ai_Debug("0i_Module", "168", JsonDump(jCreature, 1));
    object oCreature = JsonToObject(jCreature, lLocation, OBJECT_INVALID, TRUE);
    return oCreature;
}
object ai_ChangeAssociate(object oCreature, object oModule)
{
    json jCreature = ObjectToJson(oCreature, TRUE);
    WriteTimestampedLogEntry("0i_module [176] " + GetName(oCreature) + " " + JsonDump(jCreature, 1));
    //if(GetLocalFloat(oModule, AI_RULE_ASSOC_PERC_DISTANCE))
    //{
        location lLocation = GetLocation(oCreature);
        //json jCreature = ObjectToJson(oCreature, TRUE);
        jCreature = GffReplaceByte(jCreature, "PerceptionRange", 12);
        //if(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS)) jCreature = ai_SetCompanionSummoning(oCreature, jCreature);
        DestroyObject(oCreature);
        return ai_CreateAssociate(jCreature, lLocation, oModule);
    //}
    //return oCreature;
}
void ai_SetMonsterEventScripts(object oCreature)
{
    //if(AI_DEBUG) ai_Debug("0i_module", "194", "Changing " + GetName(oCreature) + "'s monster event scripts.");
    //********** On Heartbeat **********
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "nw_c2_default1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(sScript != "") WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Perception **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "nw_c2_default2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "m1q5e01zombie2" || sScript == "m1q5dcultist_2") {/*Let the base script run*/}
    else if(sScript == "m0q0_mystmage_2") {/*Let the base script run*/}
    else if(sScript == "m1q0cboss2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript != "") WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On End Combat Round **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "nw_c2_default3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if (sScript == "m1_combanter_3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_m1_3_endround");
    else if (sScript == "m1q0dboss") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q0dboss");
    else if (sScript == "m1q0dendboss3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q0dboss");
    else if (sScript == "m1q2devour3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q2devour3");
    else if(sScript != "") WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Dialogue **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "nw_c2_default4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "m1q2daelp_4") {/*Let the base script run*/}
    else if(sScript == "m1q3adryad4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_4_m1q3adryad4");
    else if(sScript == "m1q1apyre_4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_4_m1q1apyre_4");
    else if(sScript != "") WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Melee Attacked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "nw_c2_default5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(sScript == "m1q02devour5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_5_m1q2devour5");
    else if(sScript != "") WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Damaged **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "nw_c2_default6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript != "") WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Death **********
    // This is always set incase they have permanent summons switched on/off.
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    //********** On Disturbed **********
    if(sScript == "nw_c2_default8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(sScript != "") WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //********** On Rested **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    // We just save the monsters rest event script incase we need to revert it for a user.
    //if(sScript == "" || sScript == "nw_c2_defaulta") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_c2_a_rested);
    //else if(sScript != "") WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Spell Cast At **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "nw_c2_defaultb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(sScript != "") WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //********** On Blocked **********
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "nw_c2_defaulte") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(sScript != "") WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetAssociateEventScripts(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_module", "276", "Changing " + GetName(oCreature) + "'s associate event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "nw_ch_ac1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else if(sScript == "x0_ch_hen_heart") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "nw_ch_ac2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else if(sScript == "x0_ch_hen_percep") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "nw_ch_ac3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else if(sScript == "x0_ch_hen_combat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "nw_ch_ac4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else if(sScript == "x0_ch_hen_conv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else if(sScript == "x0_ch_hen_attack") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "nw_ch_ac6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    // Added due to summon monsters having the incorrect script attached to the on damage event.
    else if(sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript == "x0_ch_hen_damage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // This is always set incase they have permanent summons turned on.
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "nw_ch_ac8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else if(sScript == "x0_ch_hen_distrb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "nw_ch_aca") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else if(sScript == "x0_ch_hen_rest") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "nw_ch_acb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else if(sScript == "x0_ch_hen_spell") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "nw_ch_ace") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else if(sScript == "x0_ch_hen_block") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_FixEventScriptsForMonster(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_module", "338", "Reverting " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetLocalString(oCreature, "AI_ON_HEARTBEAT");
    if(sScript == "") sScript = "nw_c2_default1";
    ai_Debug("0i_main", "404", "Reverting ON_HEARTBEAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_NOTICE");
    if(sScript == "") sScript = "nw_c2_default2";
    ai_Debug("0i_main", "404", "Reverting ON_NOTICE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_END_COMBATROUND");
    if(sScript == "") sScript = "nw_c2_default3";
    ai_Debug("0i_main", "404", "Reverting ON_END_COMBATROUND: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DIALOGUE");
    if(sScript == "") sScript = "nw_c2_default4";
    ai_Debug("0i_main", "404", "Reverting ON_DIALOGUE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_MELEE_ATTACKED");
    if(sScript == "") sScript = "nw_c2_default5";
    ai_Debug("0i_main", "404", "Reverting ON_MELEE_ATTACKED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DAMAGED");
    if(sScript == "") sScript = "nw_c2_default6";
    ai_Debug("0i_main", "404", "Reverting ON_DAMAGED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetLocalString(oCreature, "AI_ON_DISTURBED");
    if(sScript == "") sScript = "nw_c2_default8";
    ai_Debug("0i_main", "404", "Reverting ON_DISTURBED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetLocalString(oCreature, "AI_ON_RESTED");
    if(sScript == "") sScript = "nw_c2_defaulta";
    ai_Debug("0i_main", "404", "Reverting ON_RESTED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_SPELLCASTAT");
    if(sScript == "") sScript = "nw_c2_defaultb";
    ai_Debug("0i_main", "404", "Reverting ON_SPELLCASTAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR");
    if(sScript == "") sScript = "nw_c2_defaulte";
    ai_Debug("0i_main", "404", "Reverting ON_BLOCKED_BY_DOOR: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_FixEventScriptsForAssociate(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_module", "385", "Reverting " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetLocalString(oCreature, "AI_ON_HEARTBEAT");
    if(sScript == "") sScript = "nw_ch_ac1";
    ai_Debug("0i_main", "404", "Reverting ON_HEARTBEAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_NOTICE");
    if(sScript == "") sScript = "nw_ch_ac2";
    ai_Debug("0i_main", "404", "Reverting ON_NOTICE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_END_COMBATROUND");
    if(sScript == "") sScript = "nw_ch_ac3";
    ai_Debug("0i_main", "404", "Reverting ON_END_COMBATROUND: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DIALOGUE");
    if(sScript == "") sScript = "nw_ch_ac4";
    ai_Debug("0i_main", "404", "Reverting ON_DIALOGUE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_MELEE_ATTACKED");
    if(sScript == "") sScript = "nw_ch_ac5";
    ai_Debug("0i_main", "404", "Reverting ON_MELEE_ATTACKED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DAMAGED");
    if(sScript == "") sScript = "nw_ch_ac6";
    ai_Debug("0i_main", "404", "Reverting ON_DAMAGED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetLocalString(oCreature, "AI_ON_DISTURBED");
    if(sScript == "") sScript = "nw_ch_ac8";
    ai_Debug("0i_main", "404", "Reverting ON_DISTURBED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetLocalString(oCreature, "AI_ON_RESTED");
    if(sScript == "") sScript = "nw_ch_aca";
    ai_Debug("0i_main", "404", "Reverting ON_RESTED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_SPELLCASTAT");
    if(sScript == "") sScript = "nw_ch_acb";
    ai_Debug("0i_main", "404", "Reverting ON_SPELLCASTAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR");
    if(sScript == "") sScript = "nw_ch_ace";
    ai_Debug("0i_main", "404", "Reverting ON_BLOCKED_BY_DOOR: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
// Special event scripts for Infinite Dungeons!
void ai_SetIDMonsterEventScripts(object oCreature)
{
    //if(AI_DEBUG) ai_Debug("0i_module", "433", "Changing " + GetName(oCreature) + "'s Infinte Dungeons event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // This is always set incase they have permanent summons turned on.
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "x2_def_rested") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetPRCAssociateEventScripts(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_module", "483", "Changing " + GetName(oCreature) + "'s PRC event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "prc_ai_fam_heart") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_heart") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "prc_ai_fam_percp") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_percp") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "prc_ai_fam_combt") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_combt") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "prc_ai_fam_conv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_conv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_DIALOGUE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "prc_ai_fam_attck") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_attck") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "prc_ai_fam_damag") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_damag") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_DAMAGED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // We do not use the ondeath script when using the PRC, too many issues.
    //sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    //SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    //if(sScript == "prc_ai_fam_death") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_prc_fam_event");
    //else if(sScript == "prc_ai_sum_death") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_prc_sum_event");
    //else WriteTimestampedLogEntry("ON_DEATH SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "prc_ai_fam_distb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_distb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_DISTURBED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "prc_ai_fam_rest") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_rest") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "prc_ai_fam_spell") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_fam_event");
    else if(sScript == "prc_ai_sum_spell") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "prc_ai_fam_block") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_fam_event");
    else if(sScript == "prc_ai_fam_block") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_prc_sum_event");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
}

