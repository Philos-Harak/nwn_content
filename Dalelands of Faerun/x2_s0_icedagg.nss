/*////////////////////////////////////////////////
 Script: X2_S0_IceDagg
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Sorcerer / Wizard 1
Innate Level: 1
School: Evocation
Descriptor(s): Cold
Component(s): Verbal, Somatic, Material
Range: Short
Area of Effect / Target: One creature
Duration: Instantaneous
Save: Reflex 1/2
Spell Resistance: Yes

You create a piece of ice that flies toward the target and deals 1d4 points of
cold damage per level (maximum of 5d4).

Material Component: A few drops of water made from melted ice.
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
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iDescriptor = DESC_COLD;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_COLD;
    Spell.iSaveHalf = TRUE;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_COLD;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 5;
    Spell.iImpact = VFX_IMP_FROST_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDmg;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the modifier for the effect.
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            //Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            // Apply effects to the currently selected target.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

