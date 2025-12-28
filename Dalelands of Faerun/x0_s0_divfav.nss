/*////////////////////////////////////////////////
 Script: x0_s0_divfav.nss
 Programmer: Created By: Brent Knowles
////////////////////////////////////////////////
Evocation
Level:  Clr 1, Pal 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 minute

Calling upon the strength and wisdom of a deity, you gain a +1 bonus on
attack and weapon damage rolls for every three caster levels you have
(at least +1, maximum +3). The bonus doesn’t apply to spell damage.

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
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 3;
    Spell.iMaxModifier = 3;
    Spell.iImpact = VFX_IMP_HEAD_HOLY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // Adjust modifier over 5 (Only used if spell gets bonus effects.
    if (Spell.iResult > 5) Spell.iResult = Spell.iResult + 10;
    // Caps at +20 (i.e. 30 for adjusted bonus DAMAGE_BONUS_20 = 30.
    if (Spell.iResult > 30) Spell.iResult = 30;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    // * determine the damage bonus to apply
    effect eAttack = EffectAttackIncrease(Spell.iResult);
    effect eDamage = EffectDamageIncrease(Spell.iResult, DAMAGE_TYPE_MAGICAL);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eDur);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

