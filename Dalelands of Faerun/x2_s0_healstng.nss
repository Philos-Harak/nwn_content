/*////////////////////////////////////////////////
 Script Name: X2_S0_HealStng
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Druid 3
Innate Level: 3
School: Necromancy
Descriptor(s): Negative
Component(s): Verbal, Somatic, Material
Range: Touch
Area of Effect / Target: Creature touched
Duration: Instantaneous
Save: Fortitude negates
Spell Resistance: Yes

You inflict 1d6 points of damage,  +1 per caster level  to the living creature
touched and gain an equal amount of hit points. You may not gain more Hit Points
than your maximum with the Healing Sting.

Material Component: Five dried wasp bodies.
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
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_NEGATIVE;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iRacialType, iMaxHp;
    effect eHeal, eDmg;
    // Create visual effects.
    effect eImpactHeal = EffectVisualEffect (VFX_IMP_HEALING_M);
    // Create damage effects.
    effect eImpactDmg = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make sure we don't use this on undead or constructs.
        iRacialType = GetRacialType (Spell.oAreaTarget);
        if(iRacialType != RACIAL_TYPE_UNDEAD &&
           iRacialType != RACIAL_TYPE_CONSTRUCT &&
           !GetHasSpellEffect (SPELL_NEGATIVE_ENERGY_PROTECTION, Spell.oAreaTarget))
        {
            // Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Fire cast spell at event for the caster.
            SignalEvent (Spell.oCaster, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Get the result for the effect, sets Spell.iResult.
                Spell = GetModifier (Spell);
                // Do not take more hitpoints than the creature has, counting bleeding hp.
                iMaxHp = GetCurrentHitPoints (Spell.oAreaTarget) + 10;
                if(iMaxHp < Spell.iResult) Spell.iResult = iMaxHp;
                eHeal = EffectHeal (Spell.iResult);
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                //Apply effects.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpactDmg, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpactHeal, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
