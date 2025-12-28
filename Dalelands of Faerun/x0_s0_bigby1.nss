/*////////////////////////////////////////////////
 Script Name:x0_s0_bigby1
 Programmer: Brent
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 5
Innate Level: 5
School: Evocation
Component(s): Verbal, Somatic, Focus
Range: Long
Area of Effect / Target: Single
Duration: 1 round / level
Save: None
Spell Resistance: Yes

A giant hand appears over the target, making it difficult for him to attack.
They receives a -10 penalty to all attack rolls for the duration of the spell.

Focus: A soft glove.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects.
    effect eAttackDecrease = EffectAttackDecrease (10);
    // Create visual effects.
    effect eVisual = EffectVisualEffect (VFX_DUR_BIGBYS_INTERPOSING_HAND);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eVisual , Spell.oAreaTarget, Spell.fDuration));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eAttackDecrease , Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

