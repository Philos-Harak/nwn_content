/*////////////////////////////////////////////////
 Script Name: NW_S0_ConeCold
 Programmer: Noel Borstad
////////////////////////////////////////////////
Cone of Cold
Evocation [Cold]
Level:  Sor/Wiz 5, Water 6
Components: V, S, M/DF
Casting Time:   1 standard action
Range:30 ft.
Area:   Cone-shaped burst
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes
Cone of cold creates an area of extreme cold, originating at your hand and
extending outward in a cone. It drains heat, dealing 1d6 points of cold damage
per caster level (maximum 15d6).

Arcane Material Component
A very small crystal or glass cone.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_COLD;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPELLCONE;
    Spell.fAreaSize = 36.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_COLD;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_COLD;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 15;
    Spell.iImpact = VFX_IMP_FROST_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    effect eDmg;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
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

