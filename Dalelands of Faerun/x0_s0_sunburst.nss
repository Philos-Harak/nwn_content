/*////////////////////////////////////////////////
 Script: X0_S0_Sunburst
 Script: Brent
////////////////////////////////////////////////
Evocation [Light]
Level:  Drd 8, Sor/Wiz 8, Sun 8
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   80-ft.-radius burst
Duration:   Instantaneous
Saving Throw:   Reflex partial; see text
Spell Resistance:   Yes

Sunburst causes a globe of searing radiance to explode a point you select. All
creatures in the globe are blinded and take 6d6 points of damage. Reflex save
negates the blindness and reduces the damage by half.

Undead and oozes caught within the globe take 1d6 points of damage per caster
level (maximum 25d6), or half damage if a Reflex save is successful. In addition,
the burst results in the destruction of any undead creature specifically harmed
by bright light if it fail its save.

Material Component: A piece of sunstone and a naked flame.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_LIGHT;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 80.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSaveType = SAVING_THROW_TYPE_DIVINE;
    Spell.iDamageType = DAMAGE_TYPE_DIVINE;
    Spell.iImpact = VFX_IMP_DIVINE_STRIKE_FIRE;
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
    // Create effects.
    effect eBlind = EffectBlindness ();
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDeathImpact = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eCaster = EffectVisualEffect (VFX_IMP_HEAD_HOLY);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Link effects
    effect eLink = EffectLinkEffects (eBlind, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply visual effect at the center of the effect area and on the caster.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCaster, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        //This vfx is applied to the target object not the location as above.
        // This vfx represents the flame that erupts on the target not on the ground.
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
        // Make resistance check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            iRacialType = GetRacialType (Spell.oAreaTarget);
            //Check if the target is an undead or an ooze.
            if (iRacialType == RACIAL_TYPE_UNDEAD || iRacialType == RACIAL_TYPE_OOZE)
            {
                // Damage 1d6 / level (max 25)
                Spell.iModNumOfDice = 1;
                Spell.iModifierDie = 6;
                Spell.iModDicePerLvl = 1;
                Spell.iMaxModNumOfDice = 25;
                Spell.iModifier = 0;
            }
            else
            {
                // Damage 6d6
                Spell.iModNumOfDice = 6;
                Spell.iModifierDie = 6;
                Spell.iModDicePerLvl = 0;
                Spell.iMaxModNumOfDice = 0;
                Spell.iModifier = 0;
            }
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            if (!SavingThrowWithEffects (SAVING_THROW_REFLEX, Spell.oAreaTarget, Spell.iSaveDC, Spell.iSaveType, Spell.oCaster))
            {
                // They failed the save so destroy any undead harmed by bright light.
                sTag = GetTag (Spell.oAreaTarget);
                if (sTag == "vampire")
                {
                    // Death by damage.
                    Spell.iResult = GetMaxHitPoints (Spell.oAreaTarget) + 10;
                }
                else
                {
                    // Failed save so blind them.
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                    // Auto fail so we get the correct damage.
                    Spell.iResult = GetReflexAdjustedDamage (Spell.iResult, Spell.oAreaTarget, 100, Spell.iSaveType);
                }
            }
            // Adjust damage for evasion thus why the save is automatically made.
            else Spell.iResult = GetReflexAdjustedDamage (Spell.iResult, Spell.oAreaTarget, 0, Spell.iSaveType);
            if (Spell.iResult > 0)
            {
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                //Apply the VFX impact and damage effect
                if (sTag == "vampire") DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeathImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));

            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
