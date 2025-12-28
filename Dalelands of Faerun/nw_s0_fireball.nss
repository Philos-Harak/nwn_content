/*////////////////////////////////////////////////
 Script Name: NW_S0_Fireball
 Programmer: Noel Borstad
////////////////////////////////////////////////
Evocation [Fire]
Level:  Sor/Wiz 3
Components: V, S, M
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   20-ft.-radius spread
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes

A fireball spell is an explosion of flame that detonates with a low roar and
deals 1d6 points of fire damage per caster level (maximum 10d6) to every creature
within the area.

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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 10;
    Spell.iImpact = VFX_IMP_FLAME_M;
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
    effect eCenter = EffectVisualEffect (VFX_FNF_FIREBALL);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

