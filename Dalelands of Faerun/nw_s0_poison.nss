/*////////////////////////////////////////////////
 Script Name: NW_S0_Poison
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Innate Level: 3
School: Necromancy
Descriptor(s): Poison
Component(s): Verbal, Somatic, Divine Focus
Range: Touch
Area of Effect / Target: Single
Duration: Instant
Additional Counter Spells: Neutralize Poison
Save: Fortitude Negates
Spell Resistance: Yes

If the caster succeeds at a melee touch attack, the target must make a Fortitude
save or suffer the effects of large scorpion venom (1d6 Strength damage on primary
and secondary hits).
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_PERMANENT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_POISON;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect ePoison = EffectPoison(37 /* Poison Spell */);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        //Make a touch attack to afflict target
        if (TouchAttackMelee (Spell.oAreaTarget, GetSpellCastItem () == OBJECT_INVALID) > 0)
        {
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Apply the poison effect and VFX impact
                ApplyEffectToObject(Spell.iDurationType, ePoison, Spell.oAreaTarget);
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

