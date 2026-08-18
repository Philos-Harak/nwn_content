/*////////////////////////////////////////////////
 Script Name: 0s_hellfire
 Programmer: Philos
////////////////////////////////////////////////
Evocation [Fire]
Level:  Innate 15
Components: V, S
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   20-ft.-radius spread
Duration: 1 round / level of caster
Saving Throw: Reflex half and special
Spell Resistance:   Yes
A Hellfire spell is an explosion of flame that detonates with a low roar and
deals 1d6 points of fire damage per caster level to every creature within the
area. On a failed save any good creatures are shaken for 1 round per level of the caster.
You point your finger and determine the range (distance and height) at which the
fireball is to burst. A glowing, pea-sized bead streaks from the pointing digit
and, unless it impacts upon a material body or solid barrier prior to attaining
the prescribed range, blossoms into the fireball at that point. (An early impact
results in an early detonation.)
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
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    //Spell.iMaxModNumOfDice = 10;
    Spell.iImpact = VFX_IMP_FLAME_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDmg;
    // Create visual effects.
    effect eCenter = EffectVisualEffect(VFX_FNF_FIREBALL);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eFear = EffectVisualEffect(VFX_IMP_FEAR_S);
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
        // Failed the save.
        if(!Spell.iSaveResult)
        {
            //Apply the VFX impact and effect
            DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eFear, Spell.oAreaTarget));
            DelayCommand(Spell.fDelay, Shaken(Spell.oAreaTarget, Spell.fDuration, Spell.iCasterLevel));
        }
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

