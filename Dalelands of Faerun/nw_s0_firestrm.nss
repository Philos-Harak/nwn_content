/*////////////////////////////////////////////////
 Script: NW_S0_FireStm
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Fire]
Level:  Clr 8, Drd 7, Fire 7
Components: V, S
Casting Time:   1 round
Range:  Medium (100 ft. + 10 ft./level)
Area:   Two 10-ft. cubes per level (S)
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes

When a fire storm spell is cast, the whole area is shot through with sheets of
roaring flame. Any other creature within the area takes 1d6 points of fire
damage per caster level (maximum 20d6).
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_CUBE;
    // 10' cube per 2 levels of caster see below
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 20;
    Spell.iImpact = VFX_IMP_FLAME_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    float fDelay;
    // Create variables.
    effect eDmg;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_FIRESTORM);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Get the area of effect: 10' cubes per 2 levels.
    Spell.fAreaSize = Spell.fAreaSize * IntToFloat (Spell.iCasterLevel / 2);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            // Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
            // Gives the effect the damage is random in the area instead of from the point.
            fDelay = GetRandomDelay (1.5, 2.5);
            // Apply effect.
            DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            // Apply impact effect.
            DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
