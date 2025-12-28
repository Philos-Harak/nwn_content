/*/////////////////////////////////////////////////////
 0s_song_rogue
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
    int iReflex, iSkill, iFeat1, iFeat2;
    object oSkin;
    itemproperty ipFeat;
    effect eReflex, eSkill, eVisual, eDuration, eLink, eCenter, eImpact, eBardLink;
    if (iPerform >= 100 && Spell.iCasterLevel >= 30)
    {
        iSkill = 21;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_5D6;
        iReflex = 8;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 95 && Spell.iCasterLevel >= 29)
    {
        iSkill = 20;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_5D6;
        iReflex = 8;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 90 && Spell.iCasterLevel >= 28)
    {
        iSkill = 19;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_5D6;
        iReflex = 8;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 85 && Spell.iCasterLevel >= 27)
    {
        iSkill = 18;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_5D6;
        iReflex = 7;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 80 && Spell.iCasterLevel >= 26)
    {
        iSkill = 17;           iFeat1 = 122/*IP_CONST_FEAT_SNEAK_ATTACK_4D6*/;
        iReflex = 7;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 75 && Spell.iCasterLevel >= 25)
    {
        iSkill = 16;           iFeat1 = 122/*IP_CONST_FEAT_SNEAK_ATTACK_4D6*/;
        iReflex = 6;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 70 && Spell.iCasterLevel >= 24)
    {
        iSkill = 15;           iFeat1 = 122/*IP_CONST_FEAT_SNEAK_ATTACK_4D6*/;
        iReflex = 6;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 65 && Spell.iCasterLevel >= 23)
    {
        iSkill = 14;           iFeat1 = 122/*IP_CONST_FEAT_SNEAK_ATTACK_4D6*/;
        iReflex = 5;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 60 && Spell.iCasterLevel >= 22)
    {
        iSkill = 13;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_3D6;
        iReflex = 5;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 55 && Spell.iCasterLevel >= 21)
    {
        iSkill = 12;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_3D6;
        iReflex = 4;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 45 && Spell.iCasterLevel >= 19)
    {
        iSkill = 11;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_3D6;
        iReflex = 4;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 35 && Spell.iCasterLevel >= 17)
    {
        iSkill = 10;           iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
        iReflex = 4;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 30 && Spell.iCasterLevel >= 16)
    {
        iSkill = 9;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
        iReflex = 3;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 24 && Spell.iCasterLevel >= 15)
    {
        iSkill = 8;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
        iReflex = 3;           iFeat2 = 121/*Evasion*/;
    }
    else if (iPerform >= 21 && Spell.iCasterLevel >= 13)
    {
        iSkill = 7;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
        iReflex = 3;           iFeat2 = -1;
    }
    else if (iPerform >= 18 && Spell.iCasterLevel >= 11)
    {
        iSkill = 6;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
        iReflex = 2;           iFeat2 = -1;
    }
    else if (iPerform >= 15 && Spell.iCasterLevel >= 8)
    {
        iSkill = 5;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_1D6;
        iReflex = 2;           iFeat2 = -1;
    }
    else if (iPerform >= 12 && Spell.iCasterLevel >= 6)
    {
        iSkill = 4;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_1D6;
        iReflex = 2;           iFeat2 = -1;
    }
    else if (iPerform >= 9 && Spell.iCasterLevel >= 3)
    {
        iSkill = 3;            iFeat1 = IP_CONST_FEAT_SNEAK_ATTACK_1D6;
        iReflex = 1;           iFeat2 = -1;
    }
    else if (iPerform >= 6 && Spell.iCasterLevel >= 2)
    {
        iSkill = 2;            iFeat1 = -1;
        iReflex = 1;           iFeat2 = -1;
    }
    else if (iPerform >= 3 && Spell.iCasterLevel >= 1)
    {
        iSkill = 1;            iFeat1 = -1;
        iReflex = 0;           iFeat2 = -1;
    }
    // Create effects.
    if (iSkill > 0)
    {
        eSkill = EffectSkillIncrease (SKILL_ALL_SKILLS, iSkill);
        eLink = EffectLinkEffects (eLink, eSkill);
    }
    if (iReflex > 0)
    {
        eReflex = EffectSavingThrowIncrease (SAVING_THROW_REFLEX, iReflex);
        eLink = EffectLinkEffects (eLink, eReflex);
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
            if (iFeat1 > -1)
            {
                oSkin = GetItemInSlot (INVENTORY_SLOT_CARMOUR, Spell.oAreaTarget);
                ipFeat = ItemPropertyBonusFeat (iFeat1);
                ipFeat = TagItemProperty (ipFeat, "Bard_Song");
                AddItemProperty (DURATION_TYPE_TEMPORARY, ipFeat, oSkin, Spell.fDuration);
            }
            if (iFeat2 > -1)
            {
                ipFeat = ItemPropertyBonusFeat (iFeat2);
                ipFeat = TagItemProperty (ipFeat, "Bard_Song");
                AddItemProperty (DURATION_TYPE_TEMPORARY, ipFeat, oSkin, Spell.fDuration);
            }
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
