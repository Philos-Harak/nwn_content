/*////////////////////////////////////////////////
 Script: NW_S0_HoldPers
 Programmer: Keith Soleski
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Brd 2, Clr 2, Sor/Wiz 3
Components: V, S,AF/DF
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target: One humanoid creature
Duration:   1 round/level (D); see text
Saving Throw:   Will negates; see text
Spell Resistance:   Yes

The subject becomes paralyzed and freezes in place. It is aware and breathes
normally but cannot take any actions, even speech.

Arcane Focus: A small, straight piece of iron.
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
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
    // Declare variables.
    int iRacialType;
    // Create visual effects.
    effect eVis = EffectVisualEffect(82);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eDur3 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    // Create effects.
    effect eParal = EffectParalyze();
    // Link effects.
    effect eLink = EffectLinkEffects(eDur2, eDur);
    eLink = EffectLinkEffects(eLink, eParal);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eDur3);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        //Make sure the target is a humanoid
        iRacialType = GetRacialType (Spell.oAreaTarget);
        if (GetIsPlayableRacialType (Spell.oAreaTarget) ||
            iRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID ||
            iRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS ||
            iRacialType == RACIAL_TYPE_HUMANOID_ORC ||
            iRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN)
        {
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Apply paralyze effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
