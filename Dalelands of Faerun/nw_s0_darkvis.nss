/*////////////////////////////////////////////////
 Script: NW_S0_DarkVis
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 2, Cleric 2, Druid 1, Ranger 1, Wizard 2
Innate Level: 2
School: Transmutation
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Single
Duration: 1 Hour / Level
Save: Harmless
Spell Resistance: No

The target creature's ability to see in complete darkness is improved beyond
that of Darkvision. When this spell is applied even the effects of magical
darkness are pierced.

Material Component Either a pinch of dried carrot or an agate.
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
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
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
    effect eVis = EffectVisualEffect (VFX_DUR_ULTRAVISION);
    effect eVis2 = EffectVisualEffect (VFX_DUR_MAGICAL_SIGHT);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eUltra = EffectUltravision();
    effect eLink = EffectLinkEffects (eVis, eDur);
    eLink = EffectLinkEffects (eLink, eVis2);
    eLink = EffectLinkEffects (eLink, eUltra);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event to fire.
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt(Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
