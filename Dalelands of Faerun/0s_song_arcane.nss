/*/////////////////////////////////////////////////////
 0s_song_arcane
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
    int iWill, iFeat1, iSpellDmg, iCasterLevel, iSpellDC;
    int iSpellDur, iFeat2, iFeat3;
    float fSpellWiden;
    object oSkin;
    itemproperty ipFeat;
    effect eWill, eVisual, eDuration, eLink, eCenter, eImpact, eBardLink;
    if (iPerform >= 100 && Spell.iCasterLevel >= 30)
    {
        iSpellDur = 10;        iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 5;
        iCasterLevel = 3;      iSpellDC = 4;                    iWill = 7;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 95 && Spell.iCasterLevel >= 29)
    {
        iSpellDur = 10;        iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 5;
        iCasterLevel = 3;      iSpellDC = 2;                    iWill = 7;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 90 && Spell.iCasterLevel >= 28)
    {
        iSpellDur = 10;        iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 5;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 7;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 85 && Spell.iCasterLevel >= 27)
    {
        iSpellDur = 8;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 5;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 6;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 80 && Spell.iCasterLevel >= 26)
    {
        iSpellDur = 8;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 4;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 6;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 75 && Spell.iCasterLevel >= 25)
    {
        iSpellDur = 6;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 4;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 5;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 70 && Spell.iCasterLevel >= 24)
    {
        iSpellDur = 6;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 3;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 5;
        fSpellWiden = 3.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 65 && Spell.iCasterLevel >= 23)
    {
        iSpellDur = 6;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 3;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 4;
        fSpellWiden = 2.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 60 && Spell.iCasterLevel >= 22)
    {
        iSpellDur = 6;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 2;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 4;
        fSpellWiden = 2.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 55 && Spell.iCasterLevel >= 21)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 2;
        iCasterLevel = 2;      iSpellDC = 2;                    iWill = 3;
        fSpellWiden = 2.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 45 && Spell.iCasterLevel >= 19)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 2;
        iCasterLevel = 2;      iSpellDC = 1;                    iWill = 3;
        fSpellWiden = 2.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 35 && Spell.iCasterLevel >= 17)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 2;
        iCasterLevel = 1;      iSpellDC = 1;                    iWill = 3;
        fSpellWiden = 2.0f;    iFeat2 = 15; iFeat3 = 80;
    }
    else if (iPerform >= 30 && Spell.iCasterLevel >= 16)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 2;
        iCasterLevel = 1;      iSpellDC = 1;                    iWill = 2;
        fSpellWiden = 2.0f;    iFeat2 = 15; iFeat3 = -1;
    }
    else if (iPerform >= 24 && Spell.iCasterLevel >= 15)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 2;
        iCasterLevel = 1;      iSpellDC = 1;                    iWill = 2;
        fSpellWiden = 0.0f;    iFeat2 = 15; iFeat3 = -1;
    }
    else if (iPerform >= 21 && Spell.iCasterLevel >= 13)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 1;
        iCasterLevel = 1;      iSpellDC = 1;                    iWill = 2;
        fSpellWiden = 0.0f;    iFeat2 = 15; iFeat3 = -1;
    }
    else if (iPerform >= 18 && Spell.iCasterLevel >= 11)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 1;
        iCasterLevel = 1;      iSpellDC = 1;                    iWill = 1;
        fSpellWiden = 0.0f;    iFeat2 = -1;                     iFeat3 = -1;
    }
    else if (iPerform >= 15 && Spell.iCasterLevel >= 8)
    {
        iSpellDur = 4;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 1;
        iCasterLevel = 1;      iSpellDC = 0;                    iWill = 1;
        fSpellWiden = 0.0f;    iFeat2 = -1;                     iFeat3 = -1;
    }
    else if (iPerform >= 12 && Spell.iCasterLevel >= 6)
    {
        iSpellDur = 2;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 1;
        iCasterLevel = 1;      iSpellDC = 0;                    iWill = 1;
        fSpellWiden = 0.0f;    iFeat2 = -1;                     iFeat3 = -1;
    }
    else if (iPerform >= 9 && Spell.iCasterLevel >= 3)
    {
        iSpellDur = 2;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 1;
        iCasterLevel = 0;      iSpellDC = 0;                    iWill = 1;
        fSpellWiden = 0.0f;    iFeat2 = -1;                     iFeat3 = -1;
    }
    else if (iPerform >= 6 && Spell.iCasterLevel >= 2)
    {
        iSpellDur = 2;         iFeat1 = IP_CONST_FEAT_COMBAT_CASTING;    iSpellDmg = 0;
        iCasterLevel = 0;      iSpellDC = 0;                    iWill = 1;
        fSpellWiden = 0.0f;    iFeat2 = -1;                     iFeat3 = -1;
    }
    else if (iPerform >= 3 && Spell.iCasterLevel >= 1)
    {
        iSpellDur = 2;         iFeat1 = -1;                     iSpellDmg = 0;
        iCasterLevel = 0;      iSpellDC = 0;                    iWill = 0;
        fSpellWiden = 0.0f;    iFeat2 = -1;                     iFeat3 = -1;
    }
    // Create effects.
    eLink = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    if (iWill > 0)
    {
        eWill = EffectSavingThrowIncrease (SAVING_THROW_WILL, iWill);
        eLink = EffectLinkEffects (eWill, eLink);
    }
    eImpact = EffectVisualEffect (Spell.iImpact);
    // Setup an expire script passing data in a string array.
    // : Caster Level : Spell DC : Spell Dmg : Spell Widen : Spell Duration : Combat Casting :
    // Used to anchor the spell to the creature so we can test for it.
    eDuration = EffectSpellImmunity (SPELL_HORSE_MOUNT);
    eDuration = RemoveEffectIcon (eDuration);
    // Setup armor bonus i.e. Spell.iResult.
    // Setup an expire script to remove spells non-effects effects.
    string sData = ":" + IntToString (iCasterLevel) + ":" + IntToString (iSpellDC) +
                   ":" + IntToString (iSpellDmg) + ":" + FloatToString (fSpellWiden) +
                   ":" + IntToString (iSpellDur) + ":";
    effect eScript = EffectRunScript ("", "0s_song_arcane_r", "", 0.0, sData);
    // Link the effects
    eDuration = EffectLinkEffects (eDuration, eScript);
    // Apply visual effect at the center of the effect area & make the bard sing.
    eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_30);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, GetLocation (Spell.oCaster));
    eVisual = EffectVisualEffect (VFX_DUR_BARD_SONG);
    eBardLink = EffectLinkEffects (eLink, eVisual);
    // Tag effects.
    eBardLink = TagEffect (eBardLink, "Bard_Song");
    eLink = TagEffect (eLink, "Bard_Song");
    eDuration = TagEffect (eDuration, "Bard_Song");
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        if (!GetHasEffect (EFFECT_TYPE_DEAF, Spell.oAreaTarget))
        {
            RemoveBardSongEffects (Spell.oAreaTarget);
            // Fire spell cast at event for target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // SetVariables for special spell effects.
            if (iCasterLevel > 0)
            {
                iCasterLevel += GetLocalInt (Spell.oAreaTarget, "0_SpellCasterLvlMod");
                SetLocalInt (Spell.oAreaTarget, "0_SpellCasterLvlMod", iCasterLevel);
            }
            if (iSpellDC > 0)
            {
                iSpellDC += GetLocalInt (Spell.oAreaTarget, "0_Spell_DC_Mod");
                SetLocalInt (Spell.oAreaTarget, "0_Spell_DC_Mod", iSpellDC);
            }
            if (iSpellDmg > 0)
            {
                iSpellDmg += GetLocalInt (Spell.oAreaTarget, "0_SpellDmgMod");
                SetLocalInt (Spell.oAreaTarget, "0_SpellDmgMod", iSpellDmg);
            }
            if (fSpellWiden > 0.0f)
            {
                fSpellWiden += GetLocalFloat (Spell.oAreaTarget, "0_SpellWidthMod");
                SetLocalFloat (Spell.oAreaTarget, "0_SpellWidthMod", fSpellWiden);
            }
            if (iSpellDur > 0)
            {
                iSpellDur += GetLocalInt (Spell.oAreaTarget, "0_SpellDurationMod");
                SetLocalInt (Spell.oAreaTarget, "0_SpellDurationMod", iSpellDur);
            }
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
            if (iFeat3 > -1)
            {
                ipFeat = ItemPropertyBonusFeat (iFeat3);
                ipFeat = TagItemProperty (ipFeat, "Bard_Song");
                AddItemProperty (DURATION_TYPE_TEMPORARY, ipFeat, oSkin, Spell.fDuration);
            }
            // Apply the effect.
            if (Spell.oAreaTarget == Spell.oCaster) ApplyEffectToObject (Spell.iDurationType, eBardLink, Spell.oAreaTarget, Spell.fDuration);
            else ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
            // Apply VFX impact
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            ApplyEffectToObject (Spell.iDurationType, eDuration, Spell.oAreaTarget, Spell.fDuration);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    DecrementRemainingFeatUses (Spell.oCaster, FEAT_BARD_SONGS);
    CleanUpSpell (Spell);
}
