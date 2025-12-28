/*////////////////////////////////////////////////
 Script: NW_S0_IncCloud
////////////////////////////////////////////////
Conjuration (Creation) [Fire]
Level:  Fire 8, Sor/Wiz 8
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Cloud spreads in 20-ft. radius, 20 ft. high
Duration:   1 round/level
Saving Throw:   Reflex half; see text
Spell Resistance:   No

An incendiary cloud spell creates a cloud of roiling smoke shot through with
white-hot embers. The white-hot embers within the cloud deal 4d6 points of fire
damage to everything within the cloud each round. All targets can make Reflex
saves each round to take half damage.
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
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_FOGFIRE))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Incendiary cloud spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_FOGFIRE);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (260); /*VFX_FNF_GAS_EXPLOSION_FIRE*/
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}
