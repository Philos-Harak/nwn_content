/*////////////////////////////////////////////////////////////////
 Script: x2_s1_petrgaze
 Programmer: Georg Zoeller
//////////////////////////////////////////////////////////////////
 Gaze attack for shifter forms
  Petrification gaze  for polymorph type basilisk and medusa
/*////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_shifter"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_SUPERNATURAL;
    Spell.iAreaShape = SHAPE_SPELLCONE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveDC = 15;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Enforce artifical use limit on that ability
    if (ShifterDecrementGWildShapeSpellUsesLeft () < 1)
    {
        // * You can not concentrate on using this ability effectively *
        FloatingTextStrRefOnCreature (83576, Spell.oCaster);
        return;
    }
    // Make sure we are not blind
    if (GetHasEffect (EFFECT_TYPE_BLINDNESS, Spell.oCaster))
    {
        FloatingTextStrRefOnCreature(84530, Spell.oCaster ,FALSE);
        return;
    }
    // Calculate Save DC
    Spell.iSaveDC = ShifterGetSaveDC (Spell.oCaster, SHIFTER_DC_EASY_MEDIUM);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            DelayCommand (Spell.fDelay, ApplyPetrificationEffect (Spell));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
     }
    CleanUpSpell (Spell);
}

