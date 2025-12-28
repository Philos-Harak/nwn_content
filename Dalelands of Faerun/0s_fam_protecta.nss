/*////////////////////////////////////////////////
 Family of Protection: On Enter
 Created By: Philos
////////////////////////////////////////////////
    Creatures entering the zone :
    Give +4 dodge ac if an ally.
    Greater gives +4 dodge and saves.
/*///////////////////////////////////////////////
#include "0i_master"
#include "0i_database"

void main()
{
    object oTarget = GetEnteringObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are an ally.
    if (!GetIsEnemy (oTarget, oCaster))
    {
        // Get bonus to AC.
        int nACBonus = 4;
        effect eAC = EffectACIncrease (nACBonus, AC_DODGE_BONUS, AC_VS_DAMAGE_TYPE_ALL);
        effect eVis = EffectVisualEffect (VFX_IMP_AC_BONUS);
        int bHasDomain;
        // Check if we have the correct Deity. We assume NPC's always have the correct Deity.
        if (GetIsCharacter (oCaster))
        {
            int nDeity = GetObjectDatabaseInt (oCaster, CHARACTER_TABLE, "deity");
            bHasDomain = StringToInt (Get2DAString ("deities", "Luck_Domain", nDeity));
        }
        else bHasDomain = TRUE;
        if (bHasDomain)
        {
            effect eSaves = EffectSavingThrowIncrease (SAVING_THROW_ALL, 4);
            eAC = EffectLinkEffects (eSaves, eAC);
        }
        // Tag the effect.
        eAC = TagEffect (eAC, "FAMILY_PROT" + GetName (oCaster));
        // Apply VFX until the area effect is gone or they leave it.
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oTarget);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eAC, oTarget);
    }
}
