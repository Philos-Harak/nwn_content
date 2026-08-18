/*////////////////////////////////////////////////
 Script: x0_s0_exretreat.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Transmutation
Level:  Brd 1, Sor/Wiz 1
Components: V, S
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 min./level (D)
This spell increases your base land speed.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sEnhancingComp = "octel_dust";
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if (Spell.sEnhancingComp == "TRUE") Spell.fDuration *= 1.5;
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eFast = EffectMovementSpeedIncrease (50);
    effect eLink = EffectLinkEffects (eFast, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        // does nothing if target already has haste
        if (GetHasSpellEffect (SPELL_HASTE, Spell.oAreaTarget)) return ;
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
