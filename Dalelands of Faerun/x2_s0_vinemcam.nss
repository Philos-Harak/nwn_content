/*////////////////////////////////////////////////
 Script Name:X2_S0_VineMCam
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
  Area of effect spell that places concealment
  bonus of +4 on all friendly creatures.
/*///////////////////////////////////////////////
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
    if (AOESpellOverlaps (Spell.lTarget, 40/*VFX_PER_CAMOUFLAGE*/))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Vine - Camouflage spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create area of effect.
        effect eAOE = EffectAreaOfEffect (40/*VFX_PER_CAMOUFLAGE*/);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}
