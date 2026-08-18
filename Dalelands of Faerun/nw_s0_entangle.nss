/*////////////////////////////////////////////////
 Script: nw_s0_entangle
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:  Drd 1, Plant 1, Rgr 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   Plants in a 40-ft.-radius spread
Duration:   1 min./level (D)
Saving Throw:   Reflex partial; see text
Spell Resistance: No

Grasses, weeds, bushes, and even trees wrap, twist, and entwine about creatures
in the area or those that enter the area, holding them fast and causing them to
become entangled. A creature that succeeds on a Reflex save is not entangled but can still
move at only half speed through the area. Each round on your turn, the plants
once again attempt to entangle all creatures that have avoided or escaped entanglement.
/*////////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_ENTANGLE))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Entangle spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create area of effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_ENTANGLE);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

