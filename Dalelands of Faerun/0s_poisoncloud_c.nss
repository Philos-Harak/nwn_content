/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_poisoncloud_c
 Programmer: Kevin Curtis
////////////////////////////////////////////////////////////////////////////////
 Heartbeat script.
 A poisonous cloud that poisons anyone who fails a fortitude save reducing
 a random ability score by area 1 to area level / 4.
 DC: Area Level + 10.

/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    int nLevel = GetLocalInt (GetArea (OBJECT_SELF), "0_Area_Level");
    effect eImpact = EffectVisualEffect (VFX_IMP_POISON_L);
    effect eIcon = EffectIcon (EFFECT_ICON_POISON);
    effect eABDecrease = EffectAbilityDecrease (d6() -1, Random (nLevel / 4) + 1);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects (eABDecrease, eDuration);
    eLink = EffectLinkEffects (eLink, eIcon);
    // Get the first object in the area of effect.
    object oTarget = GetFirstInPersistentObject();
    while(oTarget != OBJECT_INVALID)
    {
        int nPoison = GetLocalInt(oTarget, "0_WET_CAVERN_POISON");
        if(nPoison)
        {
            SetLocalInt(oTarget, "0_WET_CAVERN_POISON", nPoison - 1);
        }
        else
        {
            SetLocalInt(oTarget, "0_WET_CAVERN_POISON", d3() + 1);
            if (!FortitudeSave (oTarget, nLevel + 10, SAVING_THROW_TYPE_POISON, GetAreaOfEffectCreator ()))
            {
                float fDelay = GetRandomDelay (0.75, 1.75);
                DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget));
                DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oTarget, HoursToSeconds (24)));
            }
        }
        // Get next object in the area of effect.
        oTarget = GetNextInPersistentObject();
    }
}
