/*////////////////////////////////////////////////
 Script: NW_S0_FireShld
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Fire or Cold]
Level:  Fire 5, Sor/Wiz 4, Sun 4
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 round/level (D)

This spell wreathes you in flame and causes damage to each creature that attacks
you in melee. The flames also protect you from fire-based attacks.

Any creature striking you with its body or a handheld weapon deals normal damage,
but at the same time the attacker takes 1d6 points of damage +1 point per
caster level (maximum +15). This damage is fire damage.
If the attacker has spell resistance, it applies to this effect.
Caster gains 50% cold immunity.

Arcane Material Component: A bit of phosphorus for the shield.


/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 15;
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
    //Declare major variables
    effect eVisual = EffectVisualEffect (VFX_DUR_ELEMENTAL_SHIELD);
    effect eShield = EffectDamageShield (Spell.iResult, DAMAGE_BONUS_1d6, Spell.iDamageType);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eCold = EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 50);
    effect eLight = EffectVisualEffect (VFX_DUR_LIGHT_WHITE_10);
    //Link effects
    effect eLink = EffectLinkEffects(eShield, eCold);
    eLink = EffectLinkEffects (eLink, eDuration);
    eLink = EffectLinkEffects (eLink, eVisual);
    eLink = EffectLinkEffects (eLink, eLight);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

