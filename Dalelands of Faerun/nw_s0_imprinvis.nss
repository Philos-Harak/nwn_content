/*/////////////////////////////////////////////////
 Script: NW_S0_ImprInvis
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Illusion (Glamer)
Level:  Brd 4, Sor/Wiz 4
Components: V, S
Target: You or creature touched
Duration:   1 minute/level (D)
Saving Throw:   Will negates (harmless)

Target creature can attack and cast spells while invisible
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_GLAMER;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effect
    effect eImpact = EffectVisualEffect(VFX_IMP_HEAD_MIND);
    effect eVisual = EffectVisualEffect(VFX_DUR_INVISIBILITY);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Create effect
    effect eInvisible = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eCover = EffectConcealment(50);
    // Link effects
    effect eLink = EffectLinkEffects(eDuration, eCover);
    eLink = EffectLinkEffects(eLink, eVisual);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eInvisible, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


