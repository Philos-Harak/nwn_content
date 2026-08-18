/*////////////////////////////////////////////////
 Script: X2_S0_Stnehold
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Druid 6
Innate Level: 6
School: Conjuration
Descriptor(s): Paralyse
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Huge
Duration: 1 Round / Level
Save: Will negates
Spell Resistance: Yes

Creates a cloud that paralyzes any creatures inside of it, encasing them in
stone for 1d6 rounds.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, 42/*VFX_PER_STONEHOLD*/))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Stone hold spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (42/*VFX_PER_STONEHOLD*/);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_NATURE);
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

