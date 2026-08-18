/*////////////////////////////////////////////////
 Script: x0_s0_entrshield.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Abjuration
Level:  Clr 1, Luck 1
Components: V, S
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 min./level (D)

A magical field appears around you, glowing with a chaotic blast of multicolored
hues. This field deflects incoming arrows, rays, and other ranged attacks.
Each ranged attack directed at you for which the attacker must make an attack
roll has a 20% miss chance (similar to the effects of concealment). Other attacks
that simply work at a distance are not affected.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 20;
    Spell.iImpact = VFX_IMP_AC_BONUS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Limit the modification.
    if (Spell.iResult > 100) Spell.iResult = 100;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Set the four unique armor bonuses
    effect eShield =  EffectConcealment (Spell.iResult, MISS_CHANCE_TYPE_VS_RANGED);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
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
        //Apply the armor bonuses and the VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

