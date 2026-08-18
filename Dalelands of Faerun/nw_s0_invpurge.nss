/*////////////////////////////////////////////////
 Script Name: NW_S0_InvPurge
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation
Level:  Clr 3
Components: V, S
Range:  Personal
Target: You
Duration:   1 turn / level (D)

This spell removes the invisibility from all invisible creatures and items.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    effect eAOE = EffectAreaOfEffect (35);
    eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
    // Create visual effects.
    effect eDur1 = EffectVisualEffect (VFX_DUR_MAGICAL_SIGHT);
    effect eDur2 = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eDur1, eDur2);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectToObject (Spell.iDurationType, eAOE, OBJECT_SELF, Spell.fDuration);
    ApplyEffectToObject (Spell.iDurationType, eLink, OBJECT_SELF, Spell.fDuration);
    CleanUpSpell (Spell);
}
