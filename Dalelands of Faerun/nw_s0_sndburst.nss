/*////////////////////////////////////////////////
 Script: NW_S0_SndBurst
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Level:  Brd 2, Clr 2
Components: V, S, F/DF
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Area:   10-ft.-radius spread
Duration:   Instantaneous
Saving Throw:   Fortitude partial
Spell Resistance:   Yes

You blast an area with a tremendous cacophony. Every creature in the area takes
1d8 points of sonic damage and must succeed on a Fortitude save to avoid being
stunned for 1 round.

Creatures that cannot hear are not stunned but are still damaged.

Arcane Focus: A musical instrument.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_SONIC;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_SONIC;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_SONIC;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iImpact = VFX_IMP_SONIC;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eStun = EffectStunned ();
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eFNF = EffectVisualEffect (VFX_FNF_SOUND_BURST);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eStun, eMind);
    eLink = EffectLinkEffects(eLink, eDur);
    effect eDmg;
    //Apply the FNF to the spell location
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event to fire.
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        // Failed the save so do stun effect.
        if (!Spell.iSaveResult)
        {
            // Apply stun effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        }
        // Failed the save or Made the save (i.e. did not resist 1,2,3).
        // Do damage.
        if (Spell.iResult > 0)
        {
            //Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply the VFX impact and damage effect
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

