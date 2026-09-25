/*//////////////////////////////////////////////////////////////////////////////
 Script: m1q1faribmodend
////////////////////////////////////////////////////////////////////////////////
    OnConversation Action script that moves the player to the chapter end.
    Removed it from stripping all personal items so we can keep all of our
    henchman.
*///////////////////////////////////////////////////////////////////////////////
//#include "nw_i0_henchman"
//#include "M1_PLOT"
void RestoreEveryone()
{
    object oTarget = GetFirstPC();
    while(GetIsObjectValid(oTarget))
    {
        effect eBad = GetFirstEffect(oTarget);
        //Search for negative effects
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_AC_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_ATTACK_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SKILL_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS ||
                GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
                GetEffectType(eBad) == EFFECT_TYPE_CURSE ||
                GetEffectType(eBad) == EFFECT_TYPE_DISEASE ||
                GetEffectType(eBad) == EFFECT_TYPE_POISON ||
                GetEffectType(eBad) == EFFECT_TYPE_PARALYZE ||
                GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL)
            {
                //Remove effect if it is negative.
                RemoveEffect(oTarget, eBad);
            }
            eBad = GetNextEffect(oTarget);
        }
        int nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
        if(nHeal > 0)
        {
            effect eHeal = EffectHeal(nHeal);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
        }
        oTarget = GetNextPC();
    }
}
void main()
{
    RestoreEveryone();
    //StripAllPersonalItemsFromEveryone();
    // * have to delay this so that there is time to strip all the items
    DelayCommand(0.5,StartNewModule("Chapter1E"));
}
