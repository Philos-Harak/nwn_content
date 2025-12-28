/*//////////////////////////////////////////////////////////////////////////////
 Aura of Horrific Appearance On Enter
 nw_s1_HorrApprA.nss
////////////////////////////////////////////////////////////////////////////////
    Entering the aura requires a fortitude save (DC 10 + 1/2 ghost hitdice).
    Failure is 1d4 permanent Strength, Dexterity, and Constitution drain.
    A creature can only be affected by this ability once.
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_spells"
void main()
{
    object oTarget = GetEnteringObject ();
    object oSource =  GetAreaOfEffectCreator ();
    string sSourceName = StripColorCodes (GetName (oSource));
    int nDC = GetHitDice (oSource) / 2 + 10 + GetAbilityModifier (ABILITY_CHARISMA, oSource);
    // Is the target a valid creature
    if (GetIsEnemy (oTarget, oSource) && GetLocalString (oTarget, "0_AURA_HORRIFIC_APPEARANCE") != sSourceName)
    {
        SetLocalString (oTarget, "0_AURA_HORRIFIC_APPEARANCE", sSourceName);
        SignalEvent (oTarget, EventSpellCastAt (oSource, AOE_MOB_HORRIFICAPPEARANCE));
        effect eImpact = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
        effect eVisual = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);
        effect eAbility = EffectAbilityDecrease (ABILITY_STRENGTH, d4());
        eAbility = EffectLinkEffects (EffectAbilityDecrease (ABILITY_DEXTERITY, d4()), eAbility);
        eAbility = EffectLinkEffects (EffectAbilityDecrease (ABILITY_CONSTITUTION, d4()), eAbility);
        eAbility = SupernaturalEffect (eAbility);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
        if (!FortitudeSave (oTarget, nDC, SAVING_THROW_TYPE_NONE, oSource))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eAbility, oTarget);
        }
    }
}

