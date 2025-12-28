/*////////////////////////////////////////////////
 Script: nw_s0_HoldAnim
 Programmer: Keith Soleski
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level: Anm 2, Druid 2, Ranger 2
Components: V,
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target: One humanoid creature
Duration:   1 round/level (D); see text
Saving Throw:   Will negates; see text
Spell Resistance:   Yes

The subject becomes paralyzed and freezes in place. It is aware and breathes
normally but cannot take any actions, even speech.

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
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eParal = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eDur3 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    effect eLink = EffectLinkEffects(eDur2, eDur);
    eLink = EffectLinkEffects(eLink, eParal);
    eLink = EffectLinkEffects(eLink, eDur3);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        //Check racial type
        if (GetRacialType(Spell.oAreaTarget) == RACIAL_TYPE_ANIMAL)
        {
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Apply paralyze and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
