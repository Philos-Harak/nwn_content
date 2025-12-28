/*////////////////////////////////////////////////
 Script Name: NW_S0_TrueSee.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Divination
Level:  Clr 5, Drd 7, Knowledge 5, Sor/Wiz 6
Components: V, S, M
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 min./level
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

The target creature can see through Sanctuary and Invisibility effects, and
automatically spots hiding opponents.

Material Component
An ointment for the eyes that is made from mushroom powder, saffron, and fat.
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
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
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
    // Create visual effects.
    effect eVisual = EffectVisualEffect(VFX_DUR_MAGICAL_SIGHT);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Create effect.
    effect eSight = EffectTrueSeeing();
    // Link effects.
    effect eLink = EffectLinkEffects(eVisual, eSight);
    eLink = EffectLinkEffects(eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

