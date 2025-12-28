/*////////////////////////////////////////////////
 Script: NW_S0_Destruc
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Death]
Level:  Clr 7, Death 7
Components: V, S, F
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Target: One creature
Duration:   Instantaneous
Saving Throw:   Fortitude partial
Spell Resistance:   Yes

This spell instantly slays the subject and removes the soul immediately.
If the target’s Fortitude saving throw succeeds, it instead takes 10d6 points
of damage. The only way to restore life to a character who has failed to save
against this spell is to use true resurrection.

Focus
A special holy (or unholy) symbol of silver marked with verses of anathema (cost 500 gp).
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
    Spell.sDivineComponent = "0_symbol_verses";
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 10;
    Spell.iModifierDie = 6;
    Spell.iImpact = 234; /*VFX_IMP_DESTRUCTION*/
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eImpact2 = EffectVisualEffect (VFX_IMP_NEGATIVE_ENERGY);
    effect eDmg, eDeath = EffectDeath ();
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Create an instance of the AOE Object using the Apply Effect function
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDeath, Spell.oAreaTarget));
            // Ressurect spells look for this variable and if set will require specific spell
            // based upon the value: 1 Raise Dead, 2 Ressurection, 3 True Ressurection.
            SetLocalInt (Spell.oAreaTarget, "0_Raise", 3);
        }
        // Do damage if they save!
        else if (Spell.iSaveResult == 4)
        {
            // Target shouldn't take damage if they are immune to death magic.
            if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_DEATH))
            {
                // Get the result for the effect, sets Spell.iResult.
                Spell = GetModifier (Spell);
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                //Apply damage effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact2, Spell.oAreaTarget));                }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
