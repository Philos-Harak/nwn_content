/*/////////////////////////////////////////////////////////////////////////////////// 
 Aura of defense: On Enter
 Created By: Philos
/////////////////////////////////////////////////////////////////////////////////////
    Creatures entering the zone :
    Give +1 ac at Paladin 6th+ or +2 ac if Paladins is 13th+ if in this PC's party.
/*/////////////////////////////////////////////////////////////////////////////////// 
void main()
{
    object oTarget = GetEnteringObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are in the party.
    if(GetFactionEqual (oCaster, oTarget))
    {
        // Get bonus to AC.
        int nBonus = 1;
        if(GetHasFeat (1494 /* Improved Aura of Defense */, oCaster)) nBonus = 2;
        effect eAC = EffectACIncrease (nBonus, AC_DODGE_BONUS, AC_VS_DAMAGE_TYPE_ALL);
        effect eVisual = EffectVisualEffect (VFX_IMP_AC_BONUS);
        // Tag the effect.
        eAC = TagEffect (eAC, "AURA_OF_DEFENSE" + GetName (oCaster));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eAC, oTarget);
    }
}
