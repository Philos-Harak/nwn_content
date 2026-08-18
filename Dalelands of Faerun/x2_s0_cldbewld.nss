/*////////////////////////////////////////////////
 Script: X2_S0_CldBewld
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 2, Bard 2
Innate Level: 2
School: Evocation
Descriptor(s): Gas
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Huge
Duration: 1 Round / Level
Additional Counter Spells:
Save: Fortitude
Spell Resistance: Yes

The caster blows forth a cloud of noxious air. Enemies in the area of effect
are stunned and blinded for 1d6 rounds.
/*//////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, 39/*VFX_PER_FOGBEWILDERMENT*/))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Fog of bewilderment spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (39/*VFX_PER_FOGBEWILDERMENT*/);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (VFX_IMP_DUST_EXPLOSION);
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create the AOE object at the selected location
        ApplyEffectAtLocation (Spell.iDuration, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

