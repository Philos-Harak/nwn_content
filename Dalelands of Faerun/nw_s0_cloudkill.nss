/*////////////////////////////////////////////////
 Script Name: NW_S0_CloudKill.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Sor/Wiz 5
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Cloud spreads in 20-ft. radius, 20 ft. high
Duration:   1 min./level
Saving Throw:   Fortitude partial; see text
Spell Resistance:   No
This spell generates a bank of fog, similar to a fog cloud, except that its
vapors are yellowish green and poisonous. These vapors automatically kill any
living creature with 3 or fewer HD (no save). A living creature with 4 to 6 HD
is slain unless it succeeds on a Fortitude save (in which case it takes 1d4
points of Constitution damage on your turn each round while in the cloud).

A living creature with 6 or more HD takes 1d4 points of Constitution damage on
your turn each round while in the cloud (a successful Fortitude save halves
this damage). Holding one’s breath doesn’t help, but creatures immune to poison
are unaffected by the spell.
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
    Spell.iDurationType = DURATION_TYPE_MINUTES;
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_FOGKILL))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Cloud kill spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_FOGKILL);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (258);
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}
