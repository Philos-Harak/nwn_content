/*////////////////////////////////////////////////
 Script: nw_s0_grease
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Brd 1, Sor/Wiz 1
Components: V, S, M
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Target or Area: 10-ft. square
Duration:   1 round/level (D)
Saving Throw:   See text
Spell Resistance:   No

A grease spell covers a solid surface with a layer of slippery grease. Any
creature in the area when the spell is cast must make a successful Reflex save
or fall. This save is repeated on your turn each round that the creature remains
within the area. A creature can walk within or through the area of grease at
half normal speed.

Material Component: A bit of pork rind or butter.
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
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_GREASE))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Grease spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        effect eAOE = EffectAreaOfEffect (AOE_PER_GREASE);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        effect eCenter = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_GREASE);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

