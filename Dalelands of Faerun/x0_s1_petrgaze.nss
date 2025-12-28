/*////////////////////////////////////////////////////
 Script: X0_S1_PETRGAZE
 Programmer: Naomi Novik
/////////////////////////////////////////////////////
 Petrification gaze monster ability.
 Fortitude save (DC 15) or be turned to stone permanently.
 Used by Basilisk, Medusa.
/*////////////////////////////////////////////////////
#include "0i_spells"

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
