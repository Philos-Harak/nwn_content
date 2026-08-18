/*////////////////////////////////////////////////
 Script: NW_S0_Heal.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Healing)
Level:  Clr 6, Drd 7, Healing 6
Components: V, S
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   Instantaneous
Saving Throw:   Will halves vs undead
Spell Resistance:   Yes

Heal enables you to channel positive energy into a creature to wipe away injury
and afflictions. It immediately ends any and all of the following adverse conditions
affecting the Target: ability damage, blinded, confused, dazed, deafened,
diseased, stunned,
and poisoned. It also cures 10 hit points of damage per level of the caster,
to a maximum of 150 points at 15th level.

Heal does not remove negative levels, restore permanently drained levels, or
restore permanently drained ability score points.

If used against an undead creature, heal instead acts like harm.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_HEALING;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_POSITIVE;
    Spell.iSaveHalf = TRUE;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 10;
    Spell.iModPerLvl = 1;
    Spell.iDamageType = DAMAGE_TYPE_POSITIVE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Do spell effects.
    int iHit, iEffectType;
    effect eHeal, eDmg, eImp, eEffect;
    // Get the amount of healing or damage.
    Spell = GetModifier (Spell);
    // Check for Healing domain power.
    if (GetHasFeat (FEAT_HEALING_DOMAIN_POWER)) Spell.iResult = Spell.iResult + (GetSpellLevel (Spell) * 2);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Check to see if they are undead.
        if (GetRacialType(Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD ||
            GetClassByPosition(1, Spell.oAreaTarget) == CLASS_TYPE_UNDEAD)
        {
            // If the spell is a touch attack.
            if (Spell.iAreaShape == SHAPE_TOUCH_TARGET) iHit = TouchAttackMelee (Spell.oAreaTarget);
            // else its a ranged touch attack.
            else iHit = TouchAttackRanged (Spell.oAreaTarget);
            if (iHit)
            {
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // If the target doesn't make a Resistance and Save check.
                Spell = ResistAndSave (Spell);
                if (Spell.iResult > 0)
                {
                    eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                    //Apply the VFX impact and effects
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
                    eImp = EffectVisualEffect (VFX_IMP_SUNSTRIKE);
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eImp, Spell.oAreaTarget));
                }
            }
        }
        else
        {
            // Cure adverse conditions.
            eEffect = GetFirstEffect (Spell.oAreaTarget);
            while (GetIsEffectValid (eEffect))
            {
                iEffectType = GetEffectType(eEffect);
                //Check if the current effect needs to be removed.
                if (iEffectType == EFFECT_TYPE_ABILITY_DECREASE ||
                    iEffectType == EFFECT_TYPE_BLINDNESS ||
                    iEffectType == EFFECT_TYPE_CONFUSED ||
                    iEffectType == EFFECT_TYPE_DAZED ||
                    iEffectType == EFFECT_TYPE_DEAF ||
                    iEffectType == EFFECT_TYPE_DISEASE ||
                    iEffectType == EFFECT_TYPE_STUNNED)
                {
                    //Remove the effect and apply VFX impact
                    RemoveEffect (Spell.oAreaTarget, eEffect);
                }
                //Get the next effect on the target
                eEffect = GetNextEffect (Spell.oAreaTarget);
            }
            int nNPCHp = GetLocalInt (Spell.oAreaTarget, "0_Hitpoints");
            int nAssociateType = GetLocalInt (Spell.oAreaTarget, "0_PCAssociate");
            if ((nAssociateType == ASSOCIATE_TYPE_HENCHMAN || nAssociateType == ASSOCIATE_TYPE_NPC) &&
                nNPCHp < 1 && nNPCHp > -10 && GetIsDead(Spell.oAreaTarget))
            {
                nNPCHp = nNPCHp + Spell.iResult;
                SetLocalInt (Spell.oAreaTarget, "0_Hitpoints", nNPCHp);
                SendMessages (GetName (Spell.oAreaTarget) + " : " + "Healed " + IntToString (Spell.iResult) + " hit points.", COLOR_YELLOW, Spell.oCaster, FALSE, FALSE);
                //Apply heal effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eHeal, Spell.oAreaTarget));
                eImp = EffectVisualEffect(VFX_IMP_HEALING_X);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImp, Spell.oAreaTarget));
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            }
            else
            {
                //Set the heal effect
                eHeal = EffectHeal (Spell.iResult);
                eHeal = SetEffectCasterLevel(eHeal, Spell.iCasterLevel);
                //Apply heal effect and VFX impact
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eHeal, Spell.oAreaTarget));
                eImp = EffectVisualEffect (VFX_IMP_HEALING_X);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImp, Spell.oAreaTarget));
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

