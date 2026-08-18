/*////////////////////////////////////////////////
 Script: NW_S0_HorrWilt
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy
Level:  Sor/Wiz 8, Water 8
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Targets:    Living creatures, no two of which can be more than 60 ft. apart
Duration:   Instantaneous
Saving Throw:   Fortitude half
Spell Resistance:   Yes

This spell evaporates moisture from the body of each subject living creature,
dealing 1d6 points of damage per caster level (maximum 20d6). This spell is
especially devastating to water elementals and plant creatures, which instead
take 1d8 points of damage per caster level (maximum 20d8).

Arcane Material Component: A bit of sponge.
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 60.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 20;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    int iRacialType;
    string sTag;
    effect eDmg;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_HORRID_WILTING);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        iRacialType = GetRacialType (Spell.oAreaTarget);
        if (iRacialType != RACIAL_TYPE_CONSTRUCT && iRacialType != RACIAL_TYPE_UNDEAD)
        {
            // Check for plants and water elementals as they take 1d8 dmg per level!
            sTag = GetTag (Spell.oAreaTarget);
            if (sTag == "water_elemental" || sTag == "plant") Spell.iModifierDie = 8;
            else Spell.iModifierDie = 6;
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (Spell.iResult > 0)
            {
                // Set the damage effect
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                // Apply effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                // Apply impact effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
