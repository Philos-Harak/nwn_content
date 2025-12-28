/*////////////////////////////////////////////////
 Script Name:NW_S0_SlayLive.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Death]
Level:  Clr 5, Death 5
Components: V, S
Casting Time:   1 standard action
Range:  Touch
Target: Living creature touched
Duration:   Instantaneous
Saving Throw:   Fortitude partial
Spell Resistance:   Yes
You can slay any one living creature. You must succeed on a melee touch attack
to touch the subject, and it can avoid death with a successful Fortitude save.
If it succeeds, it instead takes 3d6 points of damage +1 point per caster level.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DEATH;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 3;
    Spell.iModifierDie = 6;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    effect eDmg;
    // Create visual effects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make a touch attack to afflict target
        if (TouchAttackMelee (Spell.oAreaTarget, GetSpellCastItem () == OBJECT_INVALID) > 0)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Apply the death effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectDeath(), Spell.oAreaTarget));
            }
            else if (Spell.iSaveResult == 0 || Spell.iSaveResult == 4)
            {
                // Get the result for the effect, sets Spell.iResult.
                Spell = GetModifier (Spell);
                //Apply damage effect and VFX impact
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
