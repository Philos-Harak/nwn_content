/*////////////////////////////////////////////////
 Script: NW_S0_FreeMove
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Brd 4, Clr 4, Drd 4, Luck 4, Rgr 4
Components: V, S, M, DF
Casting Time:   1 standard action
Range:  Personal or touch
Target: You or creature touched
Duration:   10 min./level
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

This spell enables you or a creature you touch to move and attack normally for
the duration of the spell, even under the influence of magic that usually impedes
movement, such as paralysis, solid fog, slow, and web. The subject automatically
succeeds on any grapple check made to resist a grapple attempt, as well as on
grapple checks or Escape Artist checks made to escape a grapple or a pin.

The spell also allows the subject to move and attack normally while underwater,
even with slashing weapons such as axes and swords or with bludgeoning weapons
such as flails, hammers, and maces, provided that the weapon is wielded in the
hand rather than hurled. The freedom of movement spell does not, however, allow
water breathing.

Material Component: A leather thong, bound around the arm or a similar appendage.
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
    Spell.sEnhancingComp = "octel_dust";
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if (Spell.sEnhancingComp == "TRUE") Spell.fDuration *= 1.5;
    // Create visual effects.
    effect eVisual = EffectVisualEffect (VFX_DUR_FREEDOM_OF_MOVEMENT);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effects.
    effect eParalysis = EffectImmunity (IMMUNITY_TYPE_PARALYSIS);
    effect eEntangle = EffectImmunity (IMMUNITY_TYPE_ENTANGLE);
    effect eSlow = EffectImmunity (IMMUNITY_TYPE_SLOW);
    effect eMove = EffectImmunity (IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
    //Link effects
    effect eLink = EffectLinkEffects(eParalysis, eEntangle);
    eLink = EffectLinkEffects(eLink, eSlow);
    eLink = EffectLinkEffects(eLink, eVisual);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = EffectLinkEffects(eLink, eMove);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        //Apply Linked Effect
        ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

