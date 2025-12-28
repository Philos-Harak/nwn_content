/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: x2_s0_evilblight
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
Caster Level(s): Cleric / Favored Soul 5, Wizard / Sorcerer 6
Innate Level: 5
School: Transmutation
Component(s): Verbal
Range: Medium
Area of Effect / Target: Colossal
Duration: Permanent
Additional Counter Spells: Remove Curse
Save: Will Negates
Spell Resistance: Yes

All enemies within the are of effect have a curse placed upon them, lowering all of the target
creature's ability scores by 3.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_PERMANENT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iModifier = 3;
    Spell.iImpact = VFX_IMP_REDUCE_ABILITY_SCORE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCurse = EffectCurse (Spell.iResult, Spell.iResult, Spell.iResult, Spell.iResult, Spell.iResult, Spell.iResult);
    // Make sure that curse is of type supernatural not magical
    eCurse = SupernaturalEffect (eCurse);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Apply Effect and VFX
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eCurse, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
