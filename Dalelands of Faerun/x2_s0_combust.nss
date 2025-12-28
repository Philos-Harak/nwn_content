/*////////////////////////////////////////////////
 Script: X2_S0_Combust
 Programmer: Georg Zoeller
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 2
Innate Level: 2
School: Evocation
Descriptor(s): Fire
Component(s): Verbal, Somatic, Material
Range: Touch
Area of Effect / Target: One creature
Duration: Instantaneous
Save: Reflex partial
Spell Resistance: Yes

This spell makes a creature burst into flames. The initial eruption of flame
causes 2d6 fire damage +1 point per caster level (maximum +10) with no
saving throw. Further, the creature must make a Reflex save or catch fire
taking a further 1d6 points of damage. This will continue until the
Reflex save is made.

Material Component: A drop of oil and a piece of flint.

   There is an undocumented artificial limit of
   10 + casterlevel rounds on this spell to prevent
   it from running indefinitly when used against
   fire resistant creatures with bad saving throws
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_toollib"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 2;
    Spell.iModifierDie = 6;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 10;
    Spell.iImpact = VFX_IMP_FLAME_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDmg; //  = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
    effect eDur = EffectVisualEffect (498);
    // We need to get the Save DC for the burning effect.
    Spell = GetSaveDC (Spell);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the modifier for the effect.
        Spell = GetModifier (Spell);
        // Make resistance check.
        Spell = ResistAndSave (Spell);
        // Check for resistance only 1,2,3.
        if (Spell.iSaveResult != 1 || Spell.iSaveResult != 2 || Spell.iSaveResult != 3)
        {
            //Set damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply damage effect
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
            // Check to see if they are already burning. Only one burn effect per creature.
            if (GetLocalInt (Spell.oAreaTarget, "0_BURNING") == 0)
            {
                // Apply vfx impact.
                DelayCommand (Spell.fDelay, TLVFXPillar (VFX_IMP_FLAME_M, GetLocation(Spell.oAreaTarget), 5, 0.1f, 0.0f, 2.0f));
                // Apply duration effect, is also used to track spells duration.
                DelayCommand (Spell.fDelay ,ApplyEffectToObject(Spell.iDurationType, eDur, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand (6.0f, Burning (Spell, 1, 6, 0, TRUE));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}







