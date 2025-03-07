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
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    // DOES NOT WORK IN VERSION 36!
    // Do changes before we adjust anything on the creature via Json!
    //oCreature = ai_ChangeMonster(oCreature, oModule);
    if(!AI_SERVER)
    {
        // Do PRC check and save variable to the module.
        if(ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) != "")
            SetLocalInt(oModule, AI_USING_PRC, TRUE);
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
                //ChangeFaction(oCreature, GetObjectByTag("id1_littletimmy"));
            }
        }
    }
    // We change this script so we can setup permanent summons on/off.
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
    if(bIncorporeal)
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
json ai_SetCompanionSummoning(object oCreature, json jCreature)
{
    if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature, TRUE))
    {
        jCreature = GffReplaceInt(jCreature, "FamiliarType", Random(11));
        jCreature = GffReplaceString(jCreature, "FamiliarName", "Summoned Familiar");
    }
    if(GetHasFeat(FEAT_ANIMAL_COMPANION , oCreature, TRUE))
    {
        jCreature = GffReplaceInt(jCreature, "CompanionType", Random(9));
        jCreature = GffReplaceString(jCreature, "CompanionName", "Summoned Companion");
    }
    return jCreature;
}
object ai_ChangeMonster(object oCreature, object oModule)
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature);
    // Lets not mess up the cutscenes with silly RULES.
    float fDistance = GetDistanceBetween(oCreature, oPC);
    if(GetCutsceneMode(oPC)) return oCreature;
    // Looks bad to see creatures wink in and out plus could cause module errors.
    if(fDistance != 0.0 && fDistance < AI_RANGE_PERCEPTION) return oCreature;
    if(IsInConversation(oCreature)) return oCreature;
    int nStay = GetLocalInt(oModule, AI_RULE_CORPSES_STAY);
    int nSummon = GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS);
    int nPercDist = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE);
    //WriteTimestampedLogEntry("nStay: " + IntToString(nStay) + " nSummon: " + IntToString(nSummon) +
    //      " nPercDist: " + IntToString(nPercDist));
    if(nStay || nSummon || nPercDist != 11)
    {
        location lLocation = GetLocation(oCreature);
        json jCreature = ObjectToJson(oCreature, TRUE);
        //WriteTimestampedLogEntry("0i_module, 144 " + GetName(oCreature) + " " + JsonDump(jCreature, 1));
        if(nPercDist != 11) jCreature = GffReplaceByte(jCreature, "PerceptionRange", nPercDist);
        if(nStay) jCreature = GffReplaceDword(jCreature, "DecayTime", 600000);
        if(nSummon) jCreature = ai_SetCompanionSummoning(oCreature, jCreature);
        AssignCommand(oCreature, SetIsDestroyable(FALSE, FALSE, TRUE));
        DestroyObject(oCreature);
        return ai_CreateMonster(jCreature, lLocation, oModule);
    }
    return oCreature;
}
void ai_OnAssociateSpawn(object oCreature)
{
    SetLocalInt(oCreature, AI_ONSPAWN_EVENT, TRUE);
    // We change this script so we can setup permanent summons on/off.
    // If you don't use this you may remove the next three lines.
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_ondeath");
    if(!AI_SERVER)
    {
        if(ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) != "")
        {
            ai_SetPRCAssociateEventScripts(oCreature);
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
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_c2_default1");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_c2_default2");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_c2_default3");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_c2_default4");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_c2_default5");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_c2_default6");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_c2_default8");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_c2_defaulta");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_c2_defaultb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_c2_defaulte");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
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




