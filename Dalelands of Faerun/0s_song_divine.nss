/*/////////////////////////////////////////////////////
 0s_song_divine
 Created By: Philos
///////////////////////////////////////////////////////
 This spells applies bonuses to all of the bard's allies within 30ft
 for a set duration of 10 rounds.
/*/////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"

void main()
{
    // ***********************************************************
    // *************** Set Song Structure ***********************
    // ***********************************************************
    // Setup the song in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_EXTRAORDINARY;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 10;
    if (GetHasFeat (870/*FEAT_EPIC_LASTING_INSPIRATION*/)) Spell.iDuration *= 10;
    if (GetHasFeat (424/*LINGERING_SONG*/)) Spell.iDuration += 5;
    Spell.iImpact = VFX_IMP_HEAD_SONIC;
    // Must set the class here since this is not a spell.
    Spell.iClass = CLASS_TYPE_BARD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check if we have any song uses left.
    if (!GetHasFeat(FEAT_BARD_SONGS, Spell.oCaster))
    {
         FloatingTextStrRefOnCreature (85587, Spell.oCaster);
         return;
    }
    // Cannot use song when silenced.
    if (GetHasEffect (EFFECT_TYPE_SILENCE, Spell.oCaster))
    {
        FloatingTextStrRefOnCreature (85764, Spell.oCaster);
        return;
    }
    int iPerform = GetSkillRank (SKILL_PERFORM, Spell.oCaster);
    int iSave, iRegenerate, iPoison, iDisease;
    object oSkin;
    effect eSave, eRegen, eVisual, eDuration, eLink, eCenter, eImpact, eBardLink;
    if (iPerform >= 100 && Spell.iCasterLevel >= 30)
    {
        iRegenerate = 11;               iPoison = 1;
        iSave = 8;                     iDisease = 1;
    }
    else if (iPerform >= 95 && Spell.iCasterLevel >= 29)
    {
        iRegenerate = 10;               iPoison = 1;
        iSave = 8;                     iDisease = 1;
    }
    else if (iPerform >= 90 && Spell.iCasterLevel >= 28)
    {
        iRegenerate = 9;               iPoison = 1;
        iSave = 8;                     iDisease = 1;
    }
    else if (iPerform >= 85 && Spell.iCasterLevel >= 27)
    {
        iRegenerate = 9;               iPoison = 1;
        iSave = 7;                     iDisease = 1;
    }
    else if (iPerform >= 80 && Spell.iCasterLevel >= 26)
    {
        iRegenerate = 8;               iPoison = 1;
        iSave = 7;                     iDisease = 1;
    }
    else if (iPerform >= 75 && Spell.iCasterLevel >= 25)
    {
        iRegenerate = 7;               iPoison = 1;
        iSave = 7;                     iDisease = 1;
    }
    else if (iPerform >= 70 && Spell.iCasterLevel >= 24)
    {
        iRegenerate = 7;               iPoison = 1;
        iSave = 6;                     iDisease = 1;
    }
    else if (iPerform >= 65 && Spell.iCasterLevel >= 23)
    {
        iRegenerate = 6;               iPoison = 1;
        iSave = 6;                     iDisease = 1;
    }
    else if (iPerform >= 60 && Spell.iCasterLevel >= 22)
    {
        iRegenerate = 5;               iPoison = 1;
        iSave = 6;                     iDisease = 1;
    }
    else if (iPerform >= 55 && Spell.iCasterLevel >= 21)
    {
        iRegenerate = 5;               iPoison = 1;
        iSave = 5;                     iDisease = 1;
    }
    else if (iPerform >= 45 && Spell.iCasterLevel >= 19)
    {
        iRegenerate = 4;               iPoison = 1;
        iSave = 5;                     iDisease = 1;
    }
    else if (iPerform >= 35 && Spell.iCasterLevel >= 17)
    {
        iRegenerate = 4;               iPoison = 1;
        iSave = 5;                     iDisease = 0;
    }
    else if (iPerform >= 30 && Spell.iCasterLevel >= 16)
    {
        iRegenerate = 4;               iPoison = 1;
        iSave = 4;                     iDisease = 0;
    }
    else if (iPerform >= 24 && Spell.iCasterLevel >= 15)
    {
        iRegenerate = 3;               iPoison = 1;
        iSave = 4;                     iDisease = 0;
    }
    else if (iPerform >= 21 && Spell.iCasterLevel >= 13)
    {
        iRegenerate = 3;               iPoison = 0;
        iSave = 4;                     iDisease = 0;
    }
    else if (iPerform >= 18 && Spell.iCasterLevel >= 11)
    {
        iRegenerate = 3;               iPoison = 0;
        iSave = 3;                     iDisease = 0;
    }
    else if (iPerform >= 15 && Spell.iCasterLevel >= 8)
    {
        iRegenerate = 2;               iPoison = 0;
        iSave = 3;                     iDisease = 0;
    }
    else if (iPerform >= 12 && Spell.iCasterLevel >= 6)
    {
        iRegenerate = 2;               iPoison = 0;
        iSave = 2;                     iDisease = 0;
    }
    else if (iPerform >= 9 && Spell.iCasterLevel >= 3)
    {
        iRegenerate = 1;               iPoison = 0;
        iSave = 2;                     iDisease = 0;
    }
    else if (iPerform >= 6 && Spell.iCasterLevel >= 2)
    {
        iRegenerate = 1;               iPoison = 0;
        iSave = 1;                     iDisease = 0;
    }
    else if (iPerform >= 3 && Spell.iCasterLevel >= 1)
    {
        iRegenerate = 1;               iPoison = 0;
        iSave = 0;                     iDisease = 0;
    }
    // Create effects.
    if (iRegenerate > 0)
    {
        eRegen = EffectRegenerate (iRegenerate, 6.0f);
        eLink = EffectLinkEffects (eLink, eRegen);
    }
    if (iSave > 0)
    {
        eSave = EffectSavingThrowIncrease (SAVING_THROW_FORT, iSave);
        eLink = EffectLinkEffects (eLink, eSave);
        eSave = EffectSavingThrowIncrease (SAVING_THROW_WILL, iSave);
        eLink = EffectLinkEffects (eLink, eSave);
    }
    eImpact = EffectVisualEffect (Spell.iImpact);
    eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    eLink = EffectLinkEffects (eLink, eDuration);
    // Apply visual effect at the center of the effect area & make the bard sing.
    eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_30);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, GetLocation (Spell.oCaster));
    eVisual = EffectVisualEffect (VFX_DUR_BARD_SONG);
    eBardLink = EffectLinkEffects (eLink, eVisual);
    eBardLink = TagEffect (eBardLink, "Bard_Song");
    eLink = TagEffect (eLink, "Bard_Song");
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        if (!GetHasEffect (EFFECT_TYPE_DEAF, Spell.oAreaTarget))
        {
            RemoveBardSongEffects (Spell.oAreaTarget);
            // Fire spell cast at event for target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply the effect.
            if (Spell.oAreaTarget == Spell.oCaster) ApplyEffectToObject (Spell.iDurationType, eBardLink, Spell.oAreaTarget, Spell.fDuration);
            else ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
            // Apply VFX impact
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    DecrementRemainingFeatUses (Spell.oCaster, FEAT_BARD_SONGS);
    CleanUpSpell (Spell);
}
