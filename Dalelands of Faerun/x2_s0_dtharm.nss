/*////////////////////////////////////////////////
 Script: X2_S0_DthArm
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 2
Innate Level: 2
School: Necromancy
Component(s): Verbal, Somatic, Material
Range: Personal
Area of Effect / Target: Caster
Duration: 1 round / level
Additional Counter Spells:
Save: Will negates
Spell Resistance: Yes

A magical aura surrounds the caster -- injuring creatures that touch it.
Any creature striking the caster takes 1d4 points of damage +1 point
per 2 caster levels (maximum +5).
Boosted: If the caster has the boosting component (onyx dust worth 50gp) then any
creature striking the caster takes 2d4 points of damage +1 point per level of
the caster (maximum +20).

Material Component: A paste made of exotic herbs and ground bones.
Enhancing Component: Onyx dust worth 50 gp, which is added to the paste.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sEnhancingComp = "0_onyx_dust";
    Spell.iCompAmount = 2; // 50 gp worth of onyx dust.
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 2;
    Spell.iMaxDuration = 5;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 2;
    Spell.iMaxModifier = 5;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    int iDamageBonus = DAMAGE_BONUS_1d4;
    // Do they have the Enhancing component?
    if (Spell.sEnhancingComp == "TRUE")
    {
        iDamageBonus = DAMAGE_BONUS_2d4;
        Spell.iModifier = 1;
        Spell.iModPerLvl = 1;
        Spell.iMaxModifier = 20;
    }
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    effect eShield = EffectDamageShield (Spell.iResult, iDamageBonus, Spell.iDamageType);
    // Create visual effects.
    effect eDur = EffectVisualEffect (463);
    //Link effects
    effect eLink = EffectLinkEffects (eShield, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply effects to target.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

