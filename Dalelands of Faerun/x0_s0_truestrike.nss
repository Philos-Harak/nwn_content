/*///////////////////////////////////////////////
 Script: x0_s0_truestrike.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Divination
Level:  Sor/Wiz 1
Components: V, F
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   See text
You gain temporary, intuitive insight into the immediate future during your next
attack. Your next single attack roll (if it is made before the end of the next
round) gains a +20 insight bonus.

Focus: A small wooden replica of an archery target.
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 3;
    Spell.iModifier = 20;
    Spell.iImpact = VFX_IMP_HEAD_ODD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAttack, eLink;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Create effect and link.
        eAttack = EffectAttackIncrease (Spell.iResult);
        eLink = EffectLinkEffects(eAttack, eDur);
        //Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

