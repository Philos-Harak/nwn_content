/*////////////////////////////////////////////////
 Aura of defense: On Enter
 Created By: Philos
////////////////////////////////////////////////
    Creatures entering the zone :
    Give +2 ac if in this PC's party.
/*///////////////////////////////////////////////

void main()
{
    object oTarget = GetEnteringObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are in the party.
    if (GetFactionEqual (oCaster, oTarget))
    {
        // Get bonus to AC.
        int iBonus;
        if (GetHasFeat (1494 /* Improved Aura of Defense */, oCaster)) iBonus = 2;
        else iBonus = 1;
        effect eAC = EffectACIncrease (iBonus, AC_DODGE_BONUS, AC_VS_DAMAGE_TYPE_ALL);
        effect eVis = EffectVisualEffect (VFX_IMP_AC_BONUS);
        // Tag the effect.
        eAC = TagEffect (eAC, "AURA_OF_DEFENSE" + GetName (oCaster));
        // Apply VFX until the area effect is gone or they leave it.
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oTarget);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eAC, oTarget);
    }
}
