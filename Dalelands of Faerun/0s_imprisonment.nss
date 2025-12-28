/*////////////////////////////////////////////////
 Script: 0s_imprisonment
 Programmer: Philos
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 9
Innate Level: 9
School: Abjuration
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature
Duration: Permanent
Additional Counter Spells: Freedom
Save: Will negates
Spell Resistance: Yes

When you cast imprisonment and touch a creature, it is entombed in a state of
suspended animation in a small room far beneath the surface of the earth. The
subject remains there unless a freedom spell is cast at the locale where the
imprisonment took place.
/*///////////////////////////////////////////////
#include "0i_creature"
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 2;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iImpact = VFX_IMP_PULSE_HOLY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Define variables.
    float fZ, fDelay;
    object oWaypoint;
    // Create effects.
    effect eParalyze = EffectParalyze ();
    // Create visual effects
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eVisual = EffectVisualEffect (VFX_IMP_UNSUMMON);
    // Link effects.
    effect eLink = EffectLinkEffects (eParalyze, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
             GiveXPForKill (Spell.oAreaTarget);
             // Apply vfx impact and paralyzation effect.
             DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
             DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
             // Now do imprisonment effect.
             DelayCommand (Spell.fDelay + 2.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, Spell.oAreaTarget));
             // Do magical lower into the ground.
             fDelay = Spell.fDelay + 2.0f;
             fZ = 0.0f;
             while (fZ > -5.0f)
             {
                 fZ -= 0.25f;
                 DelayCommand (fDelay, MoveObject (Spell.oAreaTarget, 0.0f, 0.0f, fZ));
                 fDelay += 0.2f;
             }
             oWaypoint = GetObjectByTag ("WP_Imprisonment");
             DelayCommand (fDelay + 1.0f, AssignCommand (Spell.oAreaTarget, JumpToObject (oWaypoint)));
             if (!GetIsPC (Spell.oAreaTarget)) DestroyObject (Spell.oAreaTarget, fDelay + 2.0f);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


