/*////////////////////////////////////////////////
 Script Name:NW_S0_Haste
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Caster Level(s): Bard 3, Wizard / Sorcerer 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Material
Range: Short
Area of Effect / Target: Single
Duration: 1 Round / Level
Additional Counter Spells: Slow
Save: Harmless
Spell Resistance: No

The target of this spell gains, +1 bonus to dodge AC, Reflex save and attack,
1 extra action per round (allowing an additional attack only) and
has their movement increased by 50%.

Material Component
A shaving of licorice root.

Enchanting:
Boots gain the haste property.
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_IMP_HASTE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iCounter;
    // Create effect.
    effect eHaste = EffectHaste ();
    effect eAttack = EffectAttackIncrease (1);
    effect eReflex = EffectSavingThrowIncrease (SAVING_THROW_REFLEX, 1);
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_30);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Link effects.
    effect eLink = EffectLinkEffects (eHaste, eDuration);
    eLink = EffectLinkEffects (eLink, eAttack);
    eLink = EffectLinkEffects (eLink, eReflex);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget) && iCounter < Spell.iCasterLevel)
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Remove other spells that effect haste and speed.
        if (GetHasSpellEffect (SPELL_EXPEDITIOUS_RETREAT, Spell.oAreaTarget))
        {
            RemoveSpellEffects (SPELL_EXPEDITIOUS_RETREAT, Spell.oCaster, Spell.oAreaTarget);
        }
        if (GetHasSpellEffect (647/*Epic_Blinding_Speed*/, Spell.oAreaTarget))
        {
            RemoveSpellEffects (647/*Epic_Blinding_Speed*/, Spell.oCaster, Spell.oAreaTarget);
        }
        if (GetHasSpellEffect (SPELL_HASTE, Spell.oAreaTarget))
        {
            RemoveSpellEffects (SPELL_HASTE, Spell.oCaster, Spell.oAreaTarget);
        }
        // Apply effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        iCounter ++;
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}



