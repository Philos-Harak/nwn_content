/*////////////////////////////////////////////////
 Script: x0_s0_shield.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Abjuration [Force]
Level:  Sor/Wiz 1
Components: V, S
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 min./level (D)
Shield creates an invisible, tower shield-sized mobile disk of force that hovers
in front of you. It negates magic missile attacks directed at you. The disk also
provides a +4 shield bonus to AC. The shield has no armor check penalty or
arcane spell failure chance. Unlike with a normal tower shield, you can’t use
the shield spell for cover.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FORCE;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 4;
    Spell.iImpact = VFX_IMP_AC_BONUS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eArmor, eLink;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eSpell = EffectSpellImmunity (SPELL_MAGIC_MISSILE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
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
        // Create effects and link.
        eArmor = EffectACIncrease(Spell.iResult, AC_DEFLECTION_BONUS);
        eLink = EffectLinkEffects(eArmor, eDur);
        eLink = EffectLinkEffects(eLink, eSpell);
        //Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}



