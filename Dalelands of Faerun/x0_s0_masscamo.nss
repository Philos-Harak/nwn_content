/*////////////////////////////////////////////////
 Script Name:x0_s0_masscamo.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Caster Level(s): Druid 4, Ranger 4
Innate Level: 4
School: Transmutation
Descriptor(s):
Component(s): Verbal, Somatic
Range: Long
Area of Effect / Target: Colossal
Duration: 10 turns / level
Save: None
Spell Resistance: No

All allies in the area of effect gain a +10 bonus to their hide skill.
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
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 10;
    Spell.iImpact = VFX_IMP_IMPROVE_ABILITY_SCORE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect ePoint = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    effect eImpact = EffectVisualEffect (VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effect.
    effect eHide = EffectSkillIncrease(SKILL_HIDE, Spell.iResult);
    // link effects.
    effect eLink = EffectLinkEffects (eHide, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply spells point visual effect.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePoint, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        // Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
