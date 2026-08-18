/*////////////////////////////////////////////////
 Script Name: NW_S0_CharmMon
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Charm) [Mind-Affecting]
Level:  Brd 3, Sor/Wiz 4
Components: V, S
Casting Time: 1 standard action
Range:  Short
Target: One humanoid creature
Duration:   1 day
Saving Throw:   Will negates
Spell Resistance:   Yes

This charm makes a humanoid creature regard you as its trusted friend and ally
(treat the target�s attitude as friendly). If the creature is currently being
threatened or attacked by you or your allies, however, it receives a +5 bonus
on its saving throw.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CHARM;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_CHARM;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCharm = EffectCharmed ();
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    //Link persistant effects
    effect eLink = EffectLinkEffects (eMind, eDur);
    eLink = EffectLinkEffects (eLink, eCharm);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Apply impact and linked effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
