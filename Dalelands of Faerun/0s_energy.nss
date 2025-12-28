/*///////////////////////////////////////////////
 Script: 0s_energy
 Programmer: Preston Watamaniuk
/////////////////////////////////////////////////
Used for all energy endure, resist, protect, and buffer spells.
Level: Varies.
School: Abjuration
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Single
Duration: Varies
Save: Harmless
Spell Resistance: No

The target creature gains damage resistance 10/- against all elemental forms of
damage. The spell ends after absorbing 20 points of damage from any single elemental type.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // Get which spell this is.
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    // Setup each individual spells structs.
    int iAmount, iLimit;
    Spell.iSpellID = GetSpellId ();
    // Endure Elements Lvl:1 - Resists 5 damage absorb 20 points of damage.
    if (Spell.iSpellID == SPELL_ENDURE_ELEMENTS)
    {
        iAmount = 5;
        iLimit = 20;
    }
    // Resist Elements Lvl:2 - Resists 10 damage absorb 30 points of damage.
    else if (Spell.iSpellID == SPELL_RESIST_ELEMENTS)
    {
        Spell.iDivineFocus = TRUE;
        Spell.iDurPerLvl = 1;
        iAmount = 10;
        iLimit = 30;
        Spell.sEnhancingComp = "0_adam_shaving";
        Spell.iCompAmount = 50;
    }
    // Protection from Elements Lvl:3 - Resists 20 damage absorb 40 points of damage.
    else if (Spell.iSpellID == SPELL_PROTECTION_FROM_ELEMENTS)
    {
        Spell.iDivineFocus = TRUE;
        iAmount = 20;
        iLimit = 40;
        Spell.sEnhancingComp = "0_adam_shaving";
        Spell.iCompAmount = 100;
    }
    // Energy Buffer Lvl:5 - Resists 40 damage absorb 60 points of damage.
    else if (Spell.iSpellID == SPELL_ENERGY_BUFFER)
    {
        iAmount = 40;
        iLimit = 60;
        Spell.sEnhancingComp = "0_adam_shaving";
        Spell.iCompAmount = 150;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if (Spell.sEnhancingComp == "TRUE")
    {
        // Resist Elements Lvl:2 - (Enhanced) Resists 10 damage absorb 40 points of damage.
        if (Spell.iSpellID == SPELL_RESIST_ELEMENTS) iLimit = 40;
        // Protection from Elements Lvl:3 - (Enhanced) Resists 20 damage absorb 60 points of damage.
        else if (Spell.iSpellID == SPELL_PROTECTION_FROM_ELEMENTS) iLimit = 60;
        // Energy Buffer Lvl:5 - (Enhanced) Resists 40 damage absorb 80 points of damage.
        else if (Spell.iSpellID == SPELL_ENERGY_BUFFER) iLimit = 80;
    }
    effect eCold = EffectDamageResistance (DAMAGE_TYPE_COLD, iAmount, iLimit);
    effect eFire = EffectDamageResistance (DAMAGE_TYPE_FIRE, iAmount, iLimit);
    effect eAcid = EffectDamageResistance (DAMAGE_TYPE_ACID, iAmount, iLimit);
    effect eSonic = EffectDamageResistance (DAMAGE_TYPE_SONIC, iAmount, iLimit);
    effect eElec = EffectDamageResistance (DAMAGE_TYPE_ELECTRICAL, iAmount, iLimit);
    effect eImpact = EffectVisualEffect (VFX_IMP_ELEMENTAL_PROTECTION);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects (eCold, eFire);
    eLink = EffectLinkEffects (eLink, eAcid);
    eLink = EffectLinkEffects (eLink, eSonic);
    eLink = EffectLinkEffects (eLink, eElec);
    eLink = EffectLinkEffects (eLink, eDur);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Link Effects
        RemoveEffectsFromSpell (Spell.oAreaTarget, Spell.iSpellID);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
