/*////////////////////////////////////////////////
 Script Name: NW_S0_ClairAdVo
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Divination (Scrying)
Level:  Brd 3, Knowledge 3, Sor/Wiz 3
Components: V, S, F/DF
Casting Time:   10 minutes
Range:  Long (400 ft. + 40 ft./level)
Effect:     Magical sensor
Duration: 1 min./level (D)
Saving Throw:   None
Spell Resistance:   No
Grants the target creature a bonus of +10 to spot and listen checks.

Arcane Focus
A small horn (for hearing) or a glass eye (for seeing).
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_SCRYING;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 10;
    Spell.iImpact = VFX_IMP_FLAME_S;
    Spell.iBeam = VFX_BEAM_FIRE;
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
    effect eSpot = EffectSkillIncrease (SKILL_SPOT, Spell.iResult);
    effect eListen = EffectSkillIncrease (SKILL_LISTEN, Spell.iResult);
    effect eVis = EffectVisualEffect (VFX_DUR_MAGICAL_SIGHT);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link the effects.
    effect eLink = EffectLinkEffects(eSpot, eListen);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply linked and VFX effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDuration, eLink, Spell.oAreaTarget, Spell.fDuration));
        // Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

