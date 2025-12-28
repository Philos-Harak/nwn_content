/*////////////////////////////////////////////////
 Script: 0s_dom_orc
 Created By: Philos
////////////////////////////////////////////////
 Dominate an orc.
 The orc warlord may dominate an orc who gets a will save with a DC equal to the
 Orc Warlord's intimidate ranks + Str modifier.
 Permanent against NPC's and 1 round / Level for PC's.
 The orc warlord may use this ability once per day at 1st level,
 +1 use per day at levels 4, 7 and 10.
 With the feat Dom orc Radius this affects all orcs in a 10' radius.

/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the effect in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_EXTRAORDINARY;
    // Do they have the Dominate Orc 10' Radius feat.
    if (GetHasFeat (FEAT_DOMINATE_ORC_RADIUS))
    {
        Spell.iAreaShape = SHAPE_SPHERE;
        Spell.fAreaSize = 10.0f;
    }
    else Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_FEAR;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get save DC since this is not a spell.
    Spell.iSaveDC = GetSkillRank (SKILL_INTIMIDATE, Spell.oCaster, TRUE) + GetAbilityModifier (ABILITY_STRENGTH, Spell.oCaster);
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oCreature;
    effect eImpact = EffectVisualEffect (VFX_IMP_DOMINATE_S);
    effect eDomination = EffectCutsceneDominated();
    effect eDuration = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eLink = EffectLinkEffects (eDuration, eDomination);
    eLink = ExtraordinaryEffect (eLink);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult && (GetHasFeat (FEAT_RACIAL_TYPE_ORC, Spell.oAreaTarget) ||
            GetTag (Spell.oAreaTarget) == "orc") &&
            !GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_DOMINATE, Spell.oCaster))
        {
            // Set NPC duration to permanent, leave PC duration as per declaration.
            if (!GetIsPC (Spell.oAreaTarget))
            {
                Spell.iDurationType = DURATION_TYPE_PERMANENT;
                Spell.fDuration = 0.0f;
            }
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
