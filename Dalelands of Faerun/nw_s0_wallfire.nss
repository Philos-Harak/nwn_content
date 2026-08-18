/*////////////////////////////////////////////////
Script Name: NW_S0_WallFire.nss
Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Fire]
Level:  Drd 5, Fire 4, Sor/Wiz 4
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Flame up to 30 ft. long
Duration: 1 round / level
Saving Throw:   None
Spell Resistance:   Yes

An immobile fire springs into existence. The wall deals 4d6 points of fire
damage to any creature passing through it.

Arcane Material Component
A small piece of phosphorus.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
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
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_WALLFIRE))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Wall of fire spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_WALLFIRE);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}
