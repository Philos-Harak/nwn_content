/*////////////////////////////////////////////////
 Script: nw_s0_rmvfear
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Brd 1, Clr 1
Components: V, S
Casting Time:   1 standard action
Range:  Short
Targets: Targets within 30ft.
Duration: 10 minutes; see text
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)
You instill courage in the subject, granting it a +4 morale bonus against fear
effects for 10 minutes. If the subject is under the influence of a fear effect
when receiving the spell, that effect is suppressed for the duration of the spell.

Remove fear counters and dispels cause fear.
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
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iModifier = 4;
    Spell.iImpact = VFX_IMP_REMOVE_CONDITION;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eFear, eSave, eLink;
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect ePointImpact = EffectVisualEffect (VFX_FNF_LOS_HOLY_10);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, ePointImpact, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any fear effects from target.
        eFear = GetFirstEffect (Spell.oAreaTarget);
        //Get the first effect on the current target
        while(GetIsEffectValid(eFear))
        {
            if (GetEffectType(eFear) == EFFECT_TYPE_FRIGHTENED)
            {
                //Remove any fear effects and apply the VFX impact
                RemoveEffect (Spell.oAreaTarget, eFear);
            }
            //Get the next effect on the target
            eFear = GetNextEffect(Spell.oAreaTarget);
        }
        // Get the modifier for the effect.
        Spell = GetModifier (Spell);
        // Set the save bonus and link with effects.
        eSave = EffectSavingThrowIncrease (SAVING_THROW_WILL, Spell.iResult, SAVING_THROW_TYPE_FEAR);
        eLink = EffectLinkEffects (eDur, eSave);
        eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
        // Apply the linked effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        // Apply the impact effect.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

