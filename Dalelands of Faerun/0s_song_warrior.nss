/*/////////////////////////////////////////////////////
 0s_song_warrior
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
    int iAttack, iDmg, iAC, iHP, iFeat1, iFeat2;
    object oSkin;
    itemproperty ipFeat;
    effect eAttack, eDmg, eAC, eHP, eVisual, eDuration, eLink, eCenter, eImpact, eBardLink;
    if (iPerform >= 100 && Spell.iCasterLevel >= 30)
    {
        iAttack = 9;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 9;              iAC = 7;                         iHP = 50;
    }
    else if (iPerform >= 95 && Spell.iCasterLevel >= 29)
    {
        iAttack = 8;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 8;              iAC = 7;                         iHP = 45;
    }
    else if (iPerform >= 90 && Spell.iCasterLevel >= 28)
    {
        iAttack = 8;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 8;              iAC = 6;                         iHP = 45;
    }
    else if (iPerform >= 85 && Spell.iCasterLevel >= 27)
    {
        iAttack = 8;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 8;              iAC = 6;                         iHP = 30;
    }
    else if (iPerform >= 80 && Spell.iCasterLevel >= 26)
    {
        iAttack = 7;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 7;              iAC = 6;                         iHP = 30;
    }
    else if (iPerform >= 75 && Spell.iCasterLevel >= 25)
    {
        iAttack = 7;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 7;              iAC = 5;                         iHP = 30;
    }
    else if (iPerform >= 70 && Spell.iCasterLevel >= 24)
    {
        iAttack = 6;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 6;              iAC = 5;                         iHP = 30;
    }
    else if (iPerform >= 65 && Spell.iCasterLevel >= 23)
    {
        iAttack = 6;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 6;              iAC = 4;                         iHP = 30;
    }
    else if (iPerform >= 60 && Spell.iCasterLevel >= 22)
    {
        iAttack = 5;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 5;              iAC = 4;                         iHP = 30;
    }
    else if (iPerform >= 55 && Spell.iCasterLevel >= 21)
    {
        iAttack = 5;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 5;              iAC = 4;                         iHP = 15;
    }
    else if (iPerform >= 45 && Spell.iCasterLevel >= 19)
    {
        iAttack = 5;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 5;              iAC = 3;                         iHP = 15;
    }
    else if (iPerform >= 35 && Spell.iCasterLevel >= 17)
    {
        iAttack = 4;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 4;              iAC = 3;                         iHP = 15;
    }
    else if (iPerform >= 30 && Spell.iCasterLevel >= 16)
    {
        iAttack = 4;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 4;              iAC = 2;                         iHP = 15;
    }
    else if (iPerform >= 24 && Spell.iCasterLevel >= 15)
    {
        iAttack = 3;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = 120;
        iDmg = 3;              iAC = 2;                         iHP = 15;
    }
    else if (iPerform >= 21 && Spell.iCasterLevel >= 13)
    {
        iAttack = 3;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = -1;
        iDmg = 3;              iAC = 2;                         iHP = 6;
    }
    else if (iPerform >= 18 && Spell.iCasterLevel >= 11)
    {
        iAttack = 2;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = -1;
        iDmg = 2;              iAC = 2;                         iHP = 6;
    }
    else if (iPerform >= 15 && Spell.iCasterLevel >= 8)
    {
        iAttack = 2;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = -1;
        iDmg = 2;              iAC = 1;                         iHP = 6;
    }
    else if (iPerform >= 12 && Spell.iCasterLevel >= 6)
    {
        iAttack = 1;           iFeat1 = IP_CONST_FEAT_CLEAVE;   iFeat2 = -1;
        iDmg = 1;              iAC = 1;                         iHP = 6;
    }
    else if (iPerform >= 9 && Spell.iCasterLevel >= 3)
    {
        iAttack = 1;           iFeat1 = -1;                     iFeat2 = -1;
        iDmg = 1;              iAC = 1;                         iHP = 0;
    }
    else if (iPerform >= 6 && Spell.iCasterLevel >= 2)
    {
        iAttack = 1;           iFeat1 = -1;                     iFeat2 = -1;
        iDmg = 1;              iAC = 0;                         iHP = 0;
    }
    else if (iPerform >= 3 && Spell.iCasterLevel >= 1)
    {
        iAttack = 1;           iFeat1 = -1;                     iFeat2 = -1;
        iDmg = 0;              iAC = 0;                         iHP = 0;
    }
    // Create effects.
    if (iAttack > 0)
    {
        eAttack = EffectAttackIncrease (iAttack);
        eLink = EffectLinkEffects (eLink, eAttack);
    }
    if (iDmg > 0)
    {
        eDmg = EffectDamageIncrease (iDmg);
        eLink = EffectLinkEffects (eLink, eDmg);
    }
    if (iAC > 0)
    {
        eAC = EffectACIncrease (iAC);
        eLink = EffectLinkEffects (eLink, eAC);
    }
    if (iHP > 0)
    {
        eHP = EffectTemporaryHitpoints (iHP);
        eLink = EffectLinkEffects (eLink, eHP);
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
    while(GetIsObjectValid(Spell.oAreaTarget))
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
    DecrementRemainingFeatUses(Spell.oCaster, FEAT_BARD_SONGS);
    CleanUpSpell(Spell);
}
