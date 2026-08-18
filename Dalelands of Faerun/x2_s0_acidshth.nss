/*////////////////////////////////////////////////
 Script Name:X2_S0_AcidShth
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 5
Innate Level: 5
School: Conjuration
Descriptor(s): Acid
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Round / level
Save: No
Spell Resistance: No

This spell creates an acid shield around your person. Any creature striking you
with its body does normal damage, but at the same time the attacker takes 1d6
points +2 points per caster level of acid damage.

Material Component: A handful of fire ants (alive or dead).
Focus: A glass sculpture of a humanoid.

Enchanting:
Weapons and gloves gain acid damage.
Armors gains acid damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs acid.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_ACID;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iDamageType = DAMAGE_TYPE_ACID;
    Spell.iModifier = 2;
    Spell.iModPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eVisual = EffectVisualEffect (448);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Create effect.
    effect eShield = EffectDamageShield(Spell.iResult, DAMAGE_BONUS_1d6, Spell.iDamageType);
    //Link effects
    effect eLink = EffectLinkEffects (eShield, eDuration);
    eLink = EffectLinkEffects (eLink, eVisual);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

