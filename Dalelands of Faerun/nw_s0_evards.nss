/*////////////////////////////////////////////////
 Script Name:NW_S0_Evards.nss
 Prorammer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Sor/Wiz 4
Components: V, S, M
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Area:   20-ft.-radius spread
Duration:   1 round/level (D)
Saving Throw:   None
Spell Resistance:   No
A field of thick, 10 feet long rubbery tentacles rises from the ground.
Each is capable of grappling a target doing 1d6+4 points bludgeoning damage.
If successful, the target must then make a Fortitude saving throw or become
paralyzed by the grappling tentacle. The tentacles are randomly spread out over
the area of effect allowing no more than half of the tentacles to reach a single
target in any given round. The inability of the tentacles to target small
creatures makes all small creatures completely immune to the spells effects.

Material Component
A piece of tentacle from a giant octopus or a giant squid.
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_EVARDS_BLACK_TENTACLES))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Evards black tentacles spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_EVARDS_BLACK_TENTACLES);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

