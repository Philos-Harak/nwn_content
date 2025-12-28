/*////////////////////////////////////////////////
 Script: X0_S0_Bombard
 Programmer: Brent
////////////////////////////////////////////////
Bombardment

Conjuration (Creation)
Level: Druid 8,
Components: V, S, AF,
Casting Time: 1 standard action
Range: Long (400 ft. + 40 ft./level)
Area: 15-ft.-radius burst
Duration: Instantaneous
Saving Throw: Reflex half; see text
Spell Resistance: Yes

You cause a rain of rocks to fall from the sky, knocking your opponents down.
Each creature in the area that fails a Reflex saving throw takes 1d8 points of
damage per caster level (maximum 20d8) and is knocked to the ground.
A successful save halves the damage and avoids being knocked down.

Focus: A quartz crystal embedded in rock.
/*//////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 40.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 5;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_BLUDGEONING;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 20;
    Spell.iImpact = VFX_IMP_FLAME_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    effect eDmg;
    // Create effects.
    effect eKnockdown = EffectKnockdown ();
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_METEOR_SWARM);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Link effects.
    effect eLink = EffectLinkEffects (eKnockdown, eDuration);
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
        // Save failed so knock them down, unless immune!
        if (!Spell.iSaveResult && !GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_KNOCKDOWN))
        {
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
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


