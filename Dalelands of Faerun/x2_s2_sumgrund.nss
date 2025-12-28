/*//////////////////////////////////////////////////////////////////////////////
 Summon Greater Undead
 X2_S2_SumGrUnd
 Created By: Andrew Nobbs updated by Philos
////////////////////////////////////////////////////////////////////////////////
 The level of the Pale Master determines the type of undead that is summoned.
     2003-10-03 - GZ: Added Epic Progression
     The level of the Pale Master determines the
     type of undead that is summoned.

     Level 9 <= Mummy Warrior
     Level 10 <= Spectre
     Level 12 <= Vampire Rogue
     Level 14 <= Bodak
     Level 16 <= Ghoul King
     Level 18 <= Vampire Mage
     Level 20 <= Skeleton Blackguard
     Level 22 <= Lich
     Level 24 <= Lich Lord
     Level 26 <= Alhoon
     Level 28 <= Elder Alhoon
     Level 30 <= Lesser Demi Lich
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_specialevents"
#include "0i_spells"
void main()
{
    object oCaster = OBJECT_SELF;
    // Get the Pale Master's highest level arcane class to add those levels.
    int nClass = GetHighestArcaneCasterClass(OBJECT_SELF, CLASS_TYPE_PALE_MASTER);
    int nCasterLevel = GetCasterLevelByClass(oCaster, nClass);
    nCasterLevel += GetLevelByClass(CLASS_TYPE_PALE_MASTER, OBJECT_SELF);
    string sResRef;
    object oCreature;
    location lLocation = GetSpellTargetLocation();
    effect eImpact, eTurnResistance;
    //Summon the appropriate creature based on the summoner level
    if(nCasterLevel >= 30) { sResRef = "X2_S_LICH_30"; eImpact = EffectVisualEffect(496); }
    else if(nCasterLevel >= 28) { sResRef = "x2_s_lich_26"; eImpact = EffectVisualEffect(496); }
    else if(nCasterLevel >= 26) { sResRef = "X2_S_LICH_24"; eImpact = EffectVisualEffect(496); }
    else if(nCasterLevel >= 24) { sResRef = "X2_S_LICH_22"; eImpact = EffectVisualEffect(496); }
    else if(nCasterLevel >= 22) { sResRef = "X2_S_LICH_20"; eImpact = EffectVisualEffect(496); }
    else if(nCasterLevel >= 20) { sResRef = "x2_s_bguard_18"; eImpact = EffectVisualEffect(VFX_IMP_HARM); }
    else if(nCasterLevel >= 18) { sResRef = "x2_s_vamp_18"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    else if(nCasterLevel >= 16) { sResRef = "X2_S_GHOUL_16"; eImpact = EffectVisualEffect(VFX_IMP_HARM); }
    else if(nCasterLevel >= 14) { sResRef = "X2_S_BODAK_14"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    else if(nCasterLevel >= 12) { sResRef = "X2_S_SPECTRE_10"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    else if(nCasterLevel >= 10) { sResRef = "X2_S_MUMMY_9"; eImpact = EffectVisualEffect(VFX_IMP_HARM); }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_EVIL_10), lLocation);
    // Create the undead.
    oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature);
    // Increase the Turning Resistance.
    int nTurnResistance = GetTurnResistanceHD(oCreature);
    if(nTurnResistance > 0)
    {
        RemoveASpecificEffect(oCreature, EFFECT_TYPE_TURN_RESISTANCE_INCREASE);
    }
    eTurnResistance = EffectTurnResistanceIncrease(nTurnResistance + 4);
    eTurnResistance = UnyieldingEffect(eTurnResistance);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eTurnResistance, oCreature);
    AddHenchman(oCaster, oCreature);
    // Must mark them as a summons.
    SetLocalInt (oCreature, "0_Summon_ID", 627);
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
    MyrkulSetCheck(oCaster, oCreature);
}
