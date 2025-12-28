/*////////////////////////////////////////////////
 Script Name: X2_S0_ScntSphere
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3
Innate Level: 3
School: Evocation
Descriptor(s): Electricity
Component(s): Verbal, Somatic, Material
Range: Medium
Area of Effect / Target: Huge
Duration: Instantaneous
Additional Counter Spells:
Save: Reflex 1/2
Spell Resistance: Yes

The caster unleashes a crackling electric projectile that explodes upon all
within the area of effect for 1d6 points of electric damage per caster level,
to a maximum of 10d6.

Material Component
A small crystal prism.

Enchanting:
Weapons and gloves gain electricity damage.
Armors gains electricity damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs electricity.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_ELECTRICITY;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 10;
    Spell.iImpact = VFX_IMP_LIGHTNING_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDmg;
    // Create visual effect
    effect eCenter = EffectVisualEffect (459);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            // Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            // Apply effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            // Apply impact effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

