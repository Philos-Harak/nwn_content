/*////////////////////////////////////////////////
 Script: nw_s0_masheal
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Healing)
Level:  Clr 8, Drd 9
Components: V, S
Casting Time:   1 standard action
Range:  Touch
Target: Creatures in a 30' area.
Duration:   Instantaneous
Saving Throw:   Will halves vs undead
Spell Resistance:   Yes

Heal enables you to channel positive energy into a creature to wipe away injury
and afflictions. It immediately ends any and all of the following adverse conditions
affecting the Target: ability damage, blinded, confused, dazed, deafened,
diseased, stunned,
and poisoned. It also cures 10 hit points of damage per level of the caster,
to a maximum of 250 points at 25th level.

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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
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
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Do spell effects.
    int iHit, iEffectType, bHasDomain = FALSE;
    effect eHeal, eDmg, eImp, eEffect;
    // Check to see if they have a set deity in the database.
    if (GetIsCharacter (Spell.oCaster))
    {
        int nDeity = GetObjectDatabaseInt (Spell.oCaster, CHARACTER_TABLE, "deity");
        bHasDomain = StringToInt (Get2DAString ("deities", "Healing_Domain", nDeity));
    }
    // We assume all NPC's have the correct god for special domain powers.
    else bHasDomain = TRUE;
    if (GetHasFeat (FEAT_HEALING_DOMAIN_POWER) && bHasDomain) Spell.iResult = Spell.iResult + ((GetSpellLevel (Spell) + 1) * 2);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (Spell.oAreaTarget != OBJECT_INVALID)
    {
        // Check to see if they are living.
        if (GetRacialType (Spell.oAreaTarget) != RACIAL_TYPE_UNDEAD)
        {
            //Set the heal effect
            eHeal = EffectHeal (Spell.iResult);
            eHeal = SetEffectCasterLevel(eHeal, Spell.iCasterLevel);
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

            //Apply heal effect and VFX impact
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eHeal, Spell.oAreaTarget));
            eImp = EffectVisualEffect (VFX_IMP_HEALING_X);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImp, Spell.oAreaTarget));
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        }
        // Now do undead effect.
        else
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // If the target doesn't make a Resistance and Save check.
            Spell = ResistAndSave (Spell);
            if (Spell.iResult > 0)
            {
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                //Apply the VFX impact and effects
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
                eImp = EffectVisualEffect (VFX_IMP_SUNSTRIKE);
                DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eImp, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

