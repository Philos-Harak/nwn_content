/*////////////////////////////////////////////////
 Script: 0s_chaos_blast
 Programmer: Philos
////////////////////////////////////////////////
Enchantment (Charm) [Mind-Affecting]
Level: Innate 15
Components: S
Casting Time: 1 standard action
Range:  Medium
Effect: 20' Chaos blast
Duration: Instantaneous
Saving Throw: Will
Spell Resistance: Yes

You may make a 20' radius blast requiring all non-chaotic creatures to save
versus will at 10 + 1/2 sorcer's level + Charisma modifier. If failed the
creature is confused for 1 round per level of the sorcerer.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
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
    int iHit;
    effect eConfusion = EffectConfused ();
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    eConfusion = SetEffectCasterLevel(eConfusion, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        if (GetAlignmentLawChaos (Spell.oAreaTarget) != ALIGNMENT_CHAOTIC)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Apply Effect and VFX
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eConfusion, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}




