/*////////////////////////////////////////////////
 Script Name: NW_S0_VampTch
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3
Innate Level: 3
School: Necromancy
Descriptor(s): Negative
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Single
Duration: Instant
Additional Counter Spells: Negative Energy Protection
Save: None
Spell Resistance: Yes

The target creature takes 1d6 points of damage for every 2 caster levels (maximum 10d6).
This damage is then applied to the caster's hit points as a temporary bonus.
You can't gain more temporary hit points than what is required to kill the target
(target's current hit points + 10).
The temporary hitpoints last for 1 hour.

Enchanting:
Weapons and gloves gain vampiric regeneration.
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
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 2;
    Spell.iMaxModNumOfDice = 10;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iRacialType, iMaxHp;
    effect eHeal, eDmg, eLink;
    // Create effects.
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eImpactHeal = EffectVisualEffect (VFX_IMP_HEALING_M);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
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
            //Make a touch attack to afflict target
            if (TouchAttackMelee (Spell.oAreaTarget, GetSpellCastItem () == OBJECT_INVALID) > 0)
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
                    // Create effects.
                    eHeal = EffectTemporaryHitpoints (Spell.iResult);
                    eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
                    // Link effects.
                    effect eLink = EffectLinkEffects (eHeal, eDur);
                    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
                    // Apply effects.
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpactHeal, Spell.oCaster));
                    DelayCommand (Spell.fDelay, AssignCommand (Spell.oCaster, RemoveTempHitPoints ()));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, Spell.oCaster, Spell.fDuration));
                 }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
