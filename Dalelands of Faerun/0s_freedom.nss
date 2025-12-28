/*////////////////////////////////////////////////
 Script: 0s_freedom
 Programmer: Philos
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 9
Innate Level: 9
School: Abjuration
Component(s): Verbal, Somatic
Range: None
Area of Effect / Target: Creature
Duration: Permanent
Additional Counter Spells: Imprisonment
Save: Will negates
Spell Resistance: Yes

Cast this spell on a creature to free it from spells and effects that restrict
movement, including binding, entangle, grappling, imprisonment, maze, paralysis,
petrification, pinning, sleep, slow, stunning, temporal stasis, and web.

You may also cast this spell on the ground to pull a creature that has been
imprisoned or is in a maze spell. They will be pulled to the location of the
caster. If nothing is imprisoned or in a maze spell then nothing happens.
/*///////////////////////////////////////////////
#include "0i_creature"
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iImpact = VFX_IMP_GOOD_HELP;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Define variables.
    int iEffectType;
    effect eEffect;
    // Create visual effects
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Check for target.
    if (GetIsObjectValid (Spell.oTarget))
    {
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        while(GetIsObjectValid(Spell.oAreaTarget))
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply vfx impact and paralyzation effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            // Clear all effects that stop/slow movement.
            eEffect = GetFirstEffect (Spell.oAreaTarget);
            while (GetIsEffectValid (eEffect))
            {
                iEffectType = GetEffectType (eEffect);
                if (iEffectType == EFFECT_TYPE_ENTANGLE) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_MOVEMENT_SPEED_DECREASE) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_PARALYZE) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_PETRIFY) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_SLOW) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_STUNNED) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_SLEEP) RemoveEffect (Spell.oAreaTarget, eEffect);
                eEffect = GetNextEffect (Spell.oAreaTarget);
            }
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    else
    {
        // Check for a creature imprisoned.
        object oWaypoint = GetObjectByTag ("WP_Imprisonment");
        eEffect = EffectVisualEffect (VFX_FNF_SUMMON_MONSTER_3);
        object oCreature = GetFirstObjectInShape (SHAPE_SPHERE, 10.0f, GetLocation (oWaypoint), TRUE);
        // No one imprisoned, but maybe there is a NPC imprisoned?
        if (!GetIsObjectValid (oCreature) || GetIsDead (oCreature))
        {
            if (d100() <= 15)
            {
                // Create the NPC.
                int iLevel = GetCharacterLevels (Spell.oCaster);
                string sArray = "--------" + IntToString (iLevel) + "--2-1--3-";
                sArray = CreateNPCArray (sArray);
                oCreature = CreateNPC (GetLocation (oWaypoint), sArray);
                int iPackage = StringToInt (GetStringArray (sArray, 6, "-"));
                DelayCommand (1.0f, GiveMagicalEquipment (oCreature, iLevel, iPackage));
                // Equip Items.
                DelayCommand (1.5f, EquipItems  (oCreature, TRUE, TRUE));
            }
        }
        // Now summon them to the caster.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eEffect, Spell.lTarget);
        if (GetIsObjectValid (oCreature) && !GetIsDead (oCreature)) DelayCommand (2.0f, AssignCommand (oCreature, JumpToLocation (Spell.lTarget)));
    }
    CleanUpSpell (Spell);
}
