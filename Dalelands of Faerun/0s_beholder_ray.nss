/*//////////////////////////////////////////////////////////////////////////////
 Script: 0s_beholder_ray
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
Supernatural power
Level: Sorcerer 13th
Range:  150ft ray.
Effect: One ray of choosen type
Duration: Instantaneous
Saving Throw: Fortitude or Will
Spell Resistance: Yes

The beholder may shoot any of 10 different types of rays.
Charm Person, Charm Monster, Sleep, Flesh to Stone, Disintegrate, Fear, Slow,
Inflict Moderate Wounds, Finger of Death, Telekinesis (Move and Knockdown).
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // Check to see if we missed!
    if (GetLocalInt (OBJECT_SELF, "0_MISSED"))
    {
        DeleteLocalInt (OBJECT_SELF, "0_MISSED");
        return;
    }
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iClass = CLASS_TYPE_SORCERER;
    Spell.iCasterLevel = 13;
    Spell.iSubType = SUBTYPE_SUPERNATURAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iSpellResistance = TRUE;
    // Set which spell this is structure variables.
    Spell.iSpellID = GetSpellId ();
    // Charm Person Ray
    if (Spell.iSpellID == 776)
    {
        Spell.iDescriptor = DESC_MIND;
        Spell.iDurationType = DURATION_TYPE_ROUNDS;
        Spell.iDuration = 3;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
        Spell.iImpact = VFX_IMP_CHARM;
    }
    // Charm Monster Ray
    else if (Spell.iSpellID == 777)
    {
        Spell.iDescriptor = DESC_MIND;
        Spell.iDurationType = DURATION_TYPE_ROUNDS;
        Spell.iDuration = 5;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
        Spell.iImpact = VFX_IMP_CHARM;
    }
    // Sleep Ray
    else if (Spell.iSpellID == 778)
    {
        Spell.iDescriptor = DESC_MIND;
        Spell.iDurationType = DURATION_TYPE_ROUNDS;
        Spell.iDuration = 3;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    }
    // Flesh to Stone Ray
    else if (Spell.iSpellID == 779)
    {
        Spell.iDurationType = DURATION_TYPE_INSTANT;
        Spell.iSave = SAVING_THROW_FORT;
    }
    // Disintegrate Ray
    else if (Spell.iSpellID == 780)
    {
        Spell.iDurationType = DURATION_TYPE_INSTANT;
        Spell.iSave = SAVING_THROW_FORT;
        Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    }
    // Fear Ray
    else if (Spell.iSpellID == 783)
    {
        Spell.iDurationType = DURATION_TYPE_ROUNDS;
        Spell.iDuration = 3;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
        Spell.iImpact = VFX_IMP_FEAR_S;
    }
    // Slow ray
    else if (Spell.iSpellID == 784)
    {
        Spell.iDurationType = DURATION_TYPE_ROUNDS;
        Spell.iDuration = 1;
        Spell.iDurPerLvl = 1;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iImpact = VFX_IMP_SLOW;
    }
    // Inflict Moderate Wounds
    else if (Spell.iSpellID == 785)
    {
        Spell.iDurationType = DURATION_TYPE_INSTANT;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_NEGATIVE;
        Spell.iSaveHalf = TRUE;
        Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
        Spell.iModNumOfDice = 2;
        Spell.iModifierDie = 8;
        Spell.iModifier = 10;
    }
    // Finger of Death
    else if (Spell.iSpellID == 786)
    {
        Spell.iDurationType = DURATION_TYPE_INSTANT;
        Spell.iSave = SAVING_THROW_FORT;
        Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
        Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
        Spell.iModNumOfDice = 3;
        Spell.iModifierDie = 6;
        Spell.iModifier = 1;
        Spell.iModPerLvl = 1;
        Spell.iImpact = VFX_IMP_DEATH_L;
    }
    // Telekinesis
    else if (Spell.iSpellID == 787)
    {
        Spell.iDurationType = DURATION_TYPE_ROUNDS;
        Spell.iDuration = 3;
        Spell.iSave = SAVING_THROW_WILL;
        Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    //Fire cast spell at event for the specified target
    SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
    if (Spell.iSpellID == 776 || // Charm person ray
        Spell.iSpellID == 777) // Charm monster ray
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the duration for the effect.
            Spell = GetDuration (Spell);
            effect eCharm = EffectCharmed ();
            effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
            effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
            effect eLink = EffectLinkEffects (eMind, eDuration);
            eLink = EffectLinkEffects (eLink, eCharm);
            //Apply the VFX impact and damage effect
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
        }
    }
    else if (Spell.iSpellID == 778) // Sleep ray
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the duration for the effect.
            Spell = GetDuration (Spell);
            effect eSleep =  EffectSleep ();
            effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
            effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
            effect eLink = EffectLinkEffects (eSleep, eMind);
            eLink = EffectLinkEffects(eLink, eDur);
            effect eVis = EffectVisualEffect (VFX_IMP_SLEEP);
            effect eLink2 = EffectLinkEffects(eLink, eVis);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (Spell.iDurationType, eLink2, Spell.oAreaTarget, Spell.fDuration);
        }
    }
    else if (Spell.iSpellID == 779) // Flesh to Stone Ray
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            ApplyPetrificationEffect (Spell);
        }
    }
    else if (Spell.iSpellID == 780) // Disintegrate Ray
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            effect eDeath = EffectDeath ();
            //Create an instance of the AOE Object using the Apply Effect function
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget);
        }
    }
    else if (Spell.iSpellID == 783) // Fear Ray
    {
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the duration for the effect.
            Spell = GetDuration (Spell);
            effect eFear = EffectFrightened ();
            effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_FEAR);
            effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
            effect eLink = EffectLinkEffects (eFear, eMind);
            eLink = EffectLinkEffects (eLink, eDur);
            //Apply the linked effects and the VFX impact
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
        }
    }
    else if (Spell.iSpellID == 784) // Slow ray
    {
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the duration for the effect.
            Spell = GetDuration (Spell);
            effect eSlow = EffectSlow();
            effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
            effect eLink = EffectLinkEffects (eSlow, eDur);
            // Apply effect.
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
        }
    }
    else if (Spell.iSpellID == 785) // Inflict Moderate Wounds
    {
        // Get the amount of healing or damage.
        Spell = GetModifier (Spell);
        // If the target doesn't make a Resistance and Save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply the VFX impact and effects
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
        }
    }
    else if (Spell.iSpellID == 786) // Finger of Death
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            effect eDeath = EffectDeath ();
            //Create an instance of the AOE Object using the Apply Effect function
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget);
        }
        // Do damage if they save!
        else if (Spell.iSaveResult == 4)
        {
            // Target shouldn't take damage if they are immune to death magic.
            if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_DEATH))
            {
                // Get the result for the effect, sets Spell.iResult.
                Spell = GetModifier (Spell);
                effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                effect eImpact2 = EffectVisualEffect (VFX_IMP_NEGATIVE_ENERGY);
                //Apply damage effect and VFX impact
                ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
                ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact2, Spell.oAreaTarget);
            }
        }
    }
    else if (Spell.iSpellID == 787) // Telekinesis
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the duration for the effect.
            Spell = GetDuration (Spell);
            effect eKnockdown = EffectKnockdown ();
            effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
            effect eLink = EffectLinkEffects (eKnockdown, eDur);
            ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
        }
    }
    CleanUpSpell (Spell);
}




