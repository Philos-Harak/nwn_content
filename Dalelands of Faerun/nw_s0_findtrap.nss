/*////////////////////////////////////////////////
 Script Name: NW_S0_FindTrap
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 3, Cleric 2, Wizard / Sorcerer 3
Innate Level: 2
School: Divination
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Colossal
Duration: Instant
Save: Harmless
Spell Resistance: No

All traps within the area of effect become known to the caster of this spell.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 100.0f;
    Spell.iObjectFilter = OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effect.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Set the center of the sphere at the caster.
    Spell.lTarget = GetLocation (Spell.oCaster);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        if (GetIsTrapped (Spell.oAreaTarget))
        {
            // Set the trap detected by caster.
            SetTrapDetectedBy (Spell.oAreaTarget, Spell.oCaster);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

