/*////////////////////////////////////////////////
 Script Name: NW_S0_InvSph
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 3, Wizard / Sorcerer 3
Innate Level: 3
School: Illusion
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster, 15ft Radius
Duration: 1 Turn / Level
Additional Counter Spells: Invisibility Purge
Save: Harmless
Spell Resistance: No

The caster brings into being a zone of invisibility that travels with him for
the duration of the spell. All allies within the spell's area of effect are
rendered invisible, but not to each other. Those that leave the sphere are
visible once more.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_GLAMER;
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
    effect eAOE = EffectAreaOfEffect (AOE_PER_INVIS_SPHERE);
    eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
    // Create an instance of the AOE Object using the Apply Effect function
    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eAOE, Spell.oCaster, Spell.fDuration));
    CleanUpSpell (Spell);
}
