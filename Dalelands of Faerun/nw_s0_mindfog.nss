/*////////////////////////////////////////////////
 Script Name:NW_S0_MindFog.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Brd 5, Sor/Wiz 5
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Fog spreads in 20-ft. radius, 20 ft. high
Duration: 2 rounds + 1 / 2 levels; see text
Saving Throw:   Will negates
Spell Resistance:   Yes
Mind fog produces a bank of thin mist that weakens the mental resistance of
those caught in it. Creatures in the mind fog take a -10 competence penalty on
Wisdom checks and Will saves. (A creature that successfully saves against the
fog is not affected and need not make further saves even if it remains in the
fog.) Affected creatures take the penalty as long as they remain in the fog
and for 2d6 rounds thereafter.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 2;
    Spell.iDurationDie = 1;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 2;
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_FOGMIND))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Mind fog spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_FOGMIND);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (262);
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

