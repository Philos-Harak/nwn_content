/*//////////////////////////////////////////////////////////////////////////////
 Undead Servant for a Blackguard
 x0_s2_blkdead
////////////////////////////////////////////////////////////////////////////////
 The level of the Blackguard determines the type of undead that is summoned.
 Level 3rd - 6th Ghast
 Level 7th + Doom Knight
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    object oCaster = OBJECT_SELF;
    // Get the BlackGuard's level.
    int nCasterLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCaster);
    string sResRef;
    object oCreature;
    location lLocation = GetSpellTargetLocation();
    effect eImpact, eTurnResistance;
    if(nCasterLevel < 7) { sResRef = "NW_S_GHAST"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    else { sResRef = "NW_S_DOOMKGHT"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_EVIL_10), lLocation);
    // Create the undead.
    oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature);
    AddHenchman(oCaster, oCreature);
    // Must mark them as a summons.
    SetLocalInt (oCreature, "0_Summon_ID", GetLastSpell());
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac5");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_ch_ac7");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_ac9");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "nw_ch_acani9");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
    NWNX_Object_SetDialogResref(oCreature, "co_henchmen");
}
