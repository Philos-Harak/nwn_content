/*////////////////////////////////////////////////
 Script: x0_s0_udetfoe
 Pogrammer: Brent
////////////////////////////////////////////////
Caster Level(s): Cleric 9
Innate Level: 9
School: Abjuration
Component(s): Verbal, Somatic, Divine Focus
Range: Long
Area of Effect / Target: Medium
Duration: 1 round / level
Save: None
Spell Resistance: No

All allies in the area of effect will receive the following bonuses: immunity to
negative damage, immunity to level/energy drain, immunity to ability score
decreases, immunity to poisons, immunity to diseases and a +4 deflection bonus
to AC as well as saves.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 1;
    Spell.iImpact = VFX_IMP_HOLY_AID;
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
    effect eAC = EffectACIncrease (4, AC_DEFLECTION_BONUS);
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, 4);
    effect eNegativeDmg = EffectDamageImmunityIncrease (DAMAGE_TYPE_NEGATIVE, 100);
    effect eNegativeLevel = EffectImmunity (IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbDecrease = EffectImmunity (IMMUNITY_TYPE_ABILITY_DECREASE);
    effect ePoison = EffectImmunity (IMMUNITY_TYPE_POISON);
    effect eDisease = EffectImmunity (IMMUNITY_TYPE_DISEASE);
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    effect eCaster = EffectVisualEffect (VFX_IMP_HEAD_HOLY);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Link effects
    effect eLink = EffectLinkEffects(eNegativeDmg, eNegativeLevel);
    eLink = EffectLinkEffects(eLink, eAbDecrease);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, ePoison);
    eLink = EffectLinkEffects(eLink, eDisease);
    eLink = EffectLinkEffects(eLink, eDuration);
    // Apply vfx at spells center and over caster.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eCaster, Spell.oCaster);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply the effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
