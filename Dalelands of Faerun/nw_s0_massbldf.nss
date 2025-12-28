/*////////////////////////////////////////////////
 Script: NW_S0_BlindDead
 Porgrammer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 8
Innate Level: 8
School: Illusion
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Medium
Duration: 1 Round / Level
Additional Counter Spells: Remove Blindness / Deafness
Save: Fortitude Negates
Spell Resistance: Yes

All enemies within a 10-ft radius are struck blind and deaf.
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
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iImpact = VFX_IMP_BLIND_DEAF_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects.
    effect eBlind =  EffectBlindness();
    effect eDeaf = EffectDeaf();
    // Create visual efffects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eCenter = EffectVisualEffect (VFX_FNF_BLINDDEAF);
    // Link effects.
    effect eLink = EffectLinkEffects (eBlind, eDeaf);
    eLink = EffectLinkEffects (eLink, eDuration);
    // Apply vfx at spell target location.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Apply visual and effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
