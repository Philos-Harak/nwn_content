/*////////////////////////////////////////////////
 Script: NW_S0_CrpDoom
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Summoning)
Level:  Drd 7
Components: V, S
Casting Time:   1 round
Range:  Close (25 ft. + 5 ft./2 levels)/ 100 ft.; see text
Effect: One swarm of centipedes per two levels
Duration:1 round/level
Saving Throw:   None
Spell Resistance:   No

The caster summons a mass of biting and stinging insects which causes 1d6 points
of damage. For every subsequent round that a creature remains within the area of
effect, the damage inflicted is increased by an increment of 1d6 (ie. 1d6 for the
first round, 2d6 for the second, 4d6 for the third, 7d6 for the fourth, and so on).
The spell deals damage until its duration expires or it deals 1,000 points of damage.
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_CREEPING_DOOM))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Creeping doom spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_CREEPING_DOOM);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}
