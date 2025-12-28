/*////////////////////////////////////////////////
 Script: nw_s0_acidfog
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Creation) [Acid]
Level:  Sor/Wiz 6, Water 7
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Fog spreads in 20-ft. radius, 20 ft. high
Duration:   1 round/level
Saving Throw:   None
Spell Resistance:   No
Acid fog creates a billowing mass of misty vapors similar to that produced by a
solid fog spell. In addition to slowing creatures down and obscuring sight, this
spell’s vapors are highly acidic. Each round on your turn, starting when you
cast the spell, the fog deals 2d6 points of acid damage to each creature and
object within it.

Arcane Material Component
A pinch of dried, powdered peas combined with powdered animal hoof.
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_FOGACID))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Acid fog spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_FOGACID);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (257);
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

