/*////////////////////////////////////////////////
 Script: [X0_S0_Flare.nss]
 Programmer: Brent
////////////////////////////////////////////////
Evocation [Light]
Level:  Brd 0, Drd 0, Sor/Wiz 0
Components: V
Casting Time: 1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Effect: Burst of light
Duration: 10 rounds
Saving Throw: Fortitude negates
Spell Resistance:   Yes

This cantrip creates a burst of light. If you cause the light to burst directly
in front of a single creature, that creature is dazzled for 1 minute unless it
makes a successful Fortitude save. Sightless creatures, as well as creatures
already dazzled, are not affected by flare.
Dazzled creatures get a -1 to hit and -1 to search and spot checks.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_LIGHT;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 10;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_FLAME_S;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAttack, eSpot, eSearch, eLink;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    // Create effects and link.
    eAttack = EffectAttackDecrease(Spell.iResult);
    eSpot = EffectSkillDecrease(SKILL_SPOT, Spell.iResult);
    eSearch = EffectSkillDecrease(SKILL_SEARCH, Spell.iResult);
    eLink = EffectLinkEffects(eAttack, eSpot);
    eLink = EffectLinkEffects(eSearch, eLink);
    eLink = EffectLinkEffects(eDuration, eLink);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Get the modifier for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Apply the vfx impact effect.
        DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        // Make resistance and save check.
        Spell = ResistAndSave(Spell);
        if(!Spell.iSaveResult)
        {
            //Apply the effect
            DelayCommand(Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}


