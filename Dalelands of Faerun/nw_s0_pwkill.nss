/*////////////////////////////////////////////////
 Script: NW_S0_PWKill
 Programmer: Noel Borstad
////////////////////////////////////////////////
Enchantment (Compulsion) [Death, Mind-Affecting]
Level:  Sor/Wiz 9, War 9
Components: V
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Target: One living creature with 100 hp or less
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   Yes

You utter a single word of power that instantly kills one creature of your
choice, whether the creature can hear the word or not. Any creature that
currently has 101 or more hit points is unaffected by power word kill.
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
    Spell.iDescriptor = DESC_DEATH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_DEATH;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDeath = EffectDeath ();
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Must have less than 100 hitpoints.
        if (GetCurrentHitPoints (Spell.oAreaTarget) <= 100)
        {
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Apply vfx Impact and Death effect
                DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
