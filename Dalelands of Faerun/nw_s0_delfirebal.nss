/*////////////////////////////////////////////////
 Script: NW_S0_DelFirebal
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Fire]
Level:  Sor/Wiz 7
Components: V, S, M
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   20-ft.-radius spread
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes

The caster creates a small, magical zone that can detect the passage of enemy
creatures for up to 5 rounds. When the field is activated, it explodes, doing
1d6 points of fire damage per caster level to all within the area of effect,
to a maximum of 20d6.

Material Component: A tiny ball of bat guano and sulfur.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 5;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    effect eAOE = EffectAreaOfEffect (AOE_PER_DELAY_BLAST_FIREBALL);
    // Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
    CleanUpSpell (Spell);
}

