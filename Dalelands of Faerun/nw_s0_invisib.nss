/*///////////////////////////////////////////////
 Script: NW_S0_Invisib.nss
 Programmer: Preston Watamaniuk
///////////////////////////////////////////////
Illusion (Glamer)
Level:  Brd 2, Sor/Wiz 2, Trickery 2
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Personal or touch
Target: You or a creature or object weighing no more than 100 lb./level
Duration:   1 min./level (D)
Saving Throw:   Will negates (harmless) or Will negates (harmless, object)
Spell Resistance:   Yes (harmless) or Yes (harmless, object)

The creature or object touched becomes invisible, vanishing from sight, even
from darkvision. If the recipient is a creature carrying gear, that vanishes, too.
If you cast the spell on someone else, neither you nor your allies can see the
subject, unless you can normally see invisible things or you employ magic to do so.

Material Component: An eyelash encased in a bit of gum arabic.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_GLAMER;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.sEnhancingComp = "chrysophrase_dust";
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
    if (Spell.sEnhancingComp == "TRUE") Spell.fDuration *= 1.5;
    // Create visual effect.
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Create effect.
    effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    // Link effects.
    effect eLink = EffectLinkEffects(eInvis, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        //Apply effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

