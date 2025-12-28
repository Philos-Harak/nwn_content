/*////////////////////////////////////////////////
 Script: X2_S0_HoriBoom
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 1
Innate Level: 1
School: Evocation
Descriptor(s): Sonic
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: One creature
Duration: Instantaneous
Additional Counter Spells:
Save: Will partial
Spell Resistance: Yes

You blast the target with loud and high-pitched sounds.
The target takes 1d4 points of sonic damage per two caster levels (maximum 5d4)
and must make a Will save or be deafened for 1d4 rounds.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_SONIC;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 4;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_SONIC;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_SONIC;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 2;
    Spell.iMaxModNumOfDice = 5;
    Spell.iImpact = VFX_IMP_SONIC;
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
    effect eDeaf = EffectDeaf ();
    effect eDmg;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Apply vfx impact.
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
        // Get the modifier for the effect.
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        // Check for resistance only 1,2,3.
        if (Spell.iSaveResult != 1 || Spell.iSaveResult != 2 || Spell.iSaveResult != 3)
        {
            //Set damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply damage effect
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
            // Check for saving throw now.
            if (!Spell.iSaveResult)
            {
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eDeaf, Spell.oAreaTarget, Spell.fDuration));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
