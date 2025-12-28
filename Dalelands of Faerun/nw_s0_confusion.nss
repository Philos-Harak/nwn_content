/*////////////////////////////////////////////////
 Script Name: NW_S0_Confusion
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Brd 3, Sor/Wiz 4, Trickery 4
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Medum
Targets:    All creatures in a 15-ft. radius burst
Duration:   1 round/level
Saving Throw:   Will negates
Spell Resistance:   Yes
This spell causes the targets to become confused, making them unable to
independently determine what they will do.

Arcane Material Component
A set of three nut shells.
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 15.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iImpact = VFX_IMP_CONFUSION_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    effect eConfuse = EffectConfused();
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_20);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    // Link effects.
    effect eLink = EffectLinkEffects (eMind, eConfuse);
    eLink = EffectLinkEffects(eLink, eDur);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_MIND_SPELLS))
            {
                // Apply effects.
                DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

