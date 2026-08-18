/*//////////////////////////////////////////////////////////////////////////////
 Script Name: NW_S0_SummShad02
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////////////////////////////////////
 Death domain power.
 Summon a shadow for the caster.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_SUMMONING;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Get caster level.
    int nLevel = //GetLevelByClass (CLASS_TYPE_CLERIC, Spell.oCaster)
               Spell.iCasterLevel
               + GetLevelByClass (CLASS_TYPE_PALE_MASTER, Spell.oCaster);
    // Check for correct Deity.
    string sDeity = GetDeity (Spell.oCaster);
    if (sDeity == "Jergal" || sDeity == "Kelemvor" || sDeity == "Velsharoon") nLevel ++;
    string sLevel;
    if (nLevel < 10) sLevel = "0";
    sLevel = sLevel + IntToString (nLevel);
    // Get the summon effect based on level.
    int nVisual;
    if (Spell.iCasterLevel > 10) nVisual = VFX_FNF_SUMMON_EPIC_UNDEAD;
    else nVisual = VFX_FNF_SUMMON_UNDEAD;
    //Set the summoned shadow to the appropriate template based on the caster level
    effect eSummon = EffectSummonCreature ("0s_shadow_" + sLevel, nVisual);
    eSummon = SetEffectCasterLevel(eSummon, Spell.iCasterLevel);
    //Apply VFX impact and summon effect
    AdjustCurrentSummonedCreatures (Spell.oCaster, Spell.iSpellID);
    ApplyEffectAtLocation (Spell.iDurationType, eSummon, Spell.lTarget, Spell.fDuration);
    // MarkSummonedCreatures also runs CheckForSummonsBuffs to apply any buffs the caster has to the summons.
    DelayCommand(0.1, MarkSummonedCreatures (Spell.oCaster, Spell.iSpellID, TRUE));
    CleanUpSpell (Spell);
}

