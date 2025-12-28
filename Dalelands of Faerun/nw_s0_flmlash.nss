/*////////////////////////////////////////////////
 Script: NW_S0_FlmLash
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Druid 2
Innate Level: 2
School: Evocation
Descriptor(s): Fire
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Single
Duration: Instant
Additional Counter Spells:
Save: Reflex 1/2
Spell Resistance: Yes

The Druid is able to flay an enemy with flaming brands that do 2d6 points of
fire damage, + 1d6 per 3 caster levels above level 3.

Enchanting:
Weapons and gloves gain fire damage.
Armors gains fire damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs fire.
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
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 3;
    Spell.iImpact = VFX_IMP_FLAME_S;
    Spell.iBeam = VFX_BEAM_FIRE_LASH;
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
    effect eRay, eDmg;
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Set damage effect, sets Spell.iResult
        Spell = GetModifier (Spell);
        // We need to add an additional 1d6 per spell effect.
        Spell.iResult = Spell.iResult + d6(1);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply the VFX impact and damage effect
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
