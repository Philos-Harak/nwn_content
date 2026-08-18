/*/::///////////////////////////////////////////////////////////////////////////
//:: Terrifying Rage Script
//:: x2_s2_terrage_a.nss
//:: Copyright (c) 2003 Bioware Corp.
//::////////////////////////////////////////////////////////////////////////////
While the barbarian is raging, any enemy that comes close to him must make a
Will save vs Fear opposed by the barbarian's Intimidate check. Opponents under
the barbarians Hit Dice that fail the save will become panicked (-6 penalty to
attacks, saves, skill checks and becomes paralyzed for 1d6 rounds). Opponents
with up to twice the barbarian's Hit Dice that fail the save will become shaken
(-2 penalty to attacks, saves, skill checks). Creatures with more then 2x the
barbarian's Hit Dice are not affected by the rage.
////////////////////////////////////////////////////////////////////////////////
// Created By: Georg Zoeller
// Created On: 2003-07-10
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
void main()
{
    object oTarget = GetEnteringObject();
    object oBarbarian = GetAreaOfEffectCreator();
    effect eVisual = EffectVisualEffect(VFX_IMP_FEAR_S);
    int nHitDice = GetHitDice(oBarbarian);
    int nDC = GetSkillRank(SKILL_INTIMIDATE, oBarbarian);
    int nDuration = d6(4);
    if(GetIsEnemy(oTarget, oBarbarian))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(oBarbarian, GetSpellId()));
        if(!WillSave(oTarget, nDC, SAVING_THROW_TYPE_FEAR))
        {
            if(GetHitDice(oTarget) < nHitDice)
            {
                //Apply the VFX impact and effects
                FloatingTextStringOnCreature("* panicked with fear! *", oTarget, FALSE);
                Panicked(oTarget, RoundsToSeconds(nDuration), nHitDice);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
                PlayVoiceChat(VOICE_CHAT_HELP,oTarget);
            }
            // Up to twice the barbs HD shaken
            else if(GetHitDice(oTarget) < nHitDice * 2)
            {
                FloatingTextStringOnCreature("* shaken with fear! *", oTarget, FALSE);
                Shaken(oTarget, RoundsToSeconds(nDuration), nHitDice);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
            }
            // else immune
        }
    }
}
