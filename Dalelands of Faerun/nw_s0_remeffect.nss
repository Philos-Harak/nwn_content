/*////////////////////////////////////////////////
 Script Name: NW_SO_RemEffect
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
 Runs the spells;
        Remove Disease
        Remove Curse
        Remove Blindness / Deafness
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_REMOVE_CONDITION;
    // Set each spells specific variables.
    int iEffect1, iEffect2, iSpellID = GetSpellId ();
    if(iSpellID == SPELL_REMOVE_BLINDNESS_AND_DEAFNESS)
    {
        Spell.iSubSchool = SUBSCHOOL_HEALING;
        Spell.iAreaShape = SHAPE_SPHERE;
        Spell.fAreaSize = 10.0f;
        Spell.iLineOfSight = TRUE;
        Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
        Spell.iTargetType = TARGET_TYPE_ALL;
        iEffect1 = EFFECT_TYPE_BLINDNESS;
        iEffect2 = EFFECT_TYPE_DEAF;
    }
    else if(iSpellID == SPELL_REMOVE_CURSE)
    {
        Spell.iAreaShape = SHAPE_RANGE_TARGET;
        iEffect1 = EFFECT_TYPE_CURSE;
    }
    else if(iSpellID == SPELL_REMOVE_DISEASE || iSpellID == SPELLABILITY_REMOVE_DISEASE)
    {
        Spell.iSubSchool = SUBSCHOOL_HEALING;
        Spell.iAreaShape = SHAPE_RANGE_TARGET;
        iEffect1 = EFFECT_TYPE_DISEASE;
        iEffect2 = EFFECT_TYPE_ABILITY_DECREASE;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Remove effects
        DelayCommand (Spell.fDelay, RemoveASpecificEffect (Spell.oAreaTarget, iEffect1));
        if (iEffect2 != 0) DelayCommand (Spell.fDelay, RemoveASpecificEffect (Spell.oAreaTarget, iEffect2));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


