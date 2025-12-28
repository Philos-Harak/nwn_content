/*////////////////////////////////////////////////
 Script: NW_S0_DomMon
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Sor/Wiz 9
Components: V, S
Casting Time:   1 round
Range:  Close (25 ft. + 5 ft./2 levels)
Target: One creature
Duration:   1 hour / level
Saving Throw:   Will negates
Spell Resistance:   Yes

 Will save or the target is dominated for 1 hour per caster level.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iImpact = VFX_IMP_DOMINATE_S;
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
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Create effect.
    effect eDominate = EffectDominated ();
    // Link effects
    effect eLoopLink, eDominateLoop;
    effect eLink = EffectLinkEffects (eMind, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            eLoopLink = EffectLinkEffects(eLink, eDominateLoop);
            //Apply impact and linked effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLoopLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
