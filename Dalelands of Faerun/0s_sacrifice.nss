/*////////////////////////////////////////////////
 Script: 0s_sacrifice
 Programmer: Philos
////////////////////////////////////////////////
You make the ultimate sacrifice giving your life
to heal and remove all effects from your comrades.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    int iAllyHealed = FALSE;
    // Remove all bad effects and heal all party members.
    effect eVisual = EffectVisualEffect (VFX_FNF_MASS_HEAL);
    effect eHeal = EffectHeal (1000);
    // Cycle through all Allied PC's.
    object oAlly = GetFirstFactionMember (OBJECT_SELF);
    while (GetIsObjectValid (oAlly))
    {
        if (oAlly != OBJECT_SELF)
        {
            iAllyHealed = TRUE;
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oAlly);
            RemoveCreatureEffects (oAlly, 1);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eHeal, oAlly);
        }
        //Get the next ally.
        oAlly = GetNextFactionMember (OBJECT_SELF);
    }
    if (iAllyHealed)
    {
        // We have an ally that was healed so now we die!
        effect eDeath = EffectDeath ();
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDeath, OBJECT_SELF);
    }
}




