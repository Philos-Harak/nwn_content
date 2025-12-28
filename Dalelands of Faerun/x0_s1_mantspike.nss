//::///////////////////////////////////////////////////
//:: X0_S1_MANTSPIKE
//:: Handles the damage effects of the manticore spikes.
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/15/2002
//::///////////////////////////////////////////////////
#include "0i_battle"
void main ()
{
    int nAttacks = 6;
    float fDistance, fDelay;
    effect eMissile = EffectVisualEffect (359);
    effect eImpact = EffectVisualEffect (VFX_COM_BLOOD_SPARK_SMALL);
    object oTarget = GetSpellTargetObject ();
    location lTarget = GetLocation (oTarget);
    while (nAttacks > 0)
    {
        object oTarget = GetFirstObjectInShape (SHAPE_SPHERE, 9.0f, lTarget, TRUE);
        while (oTarget != OBJECT_INVALID && nAttacks > 0)
        {
            // Calculate appropriate distances from target.
            fDistance = GetDistanceBetween (OBJECT_SELF, oTarget);
            fDelay = fDistance / (3.0 * log(fDistance) + 2.0);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, oTarget);
            DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact, oTarget));
            // Do real attack!
            DelayCommand (fDelay, DoSpecificRangedAttack (OBJECT_SELF, oTarget, 6, DAMAGE_TYPE_PIERCING, "1d8+2", FALSE));
            nAttacks --;
            oTarget = GetNextObjectInShape (SHAPE_SPHERE, 9.0f, lTarget, TRUE);
        }
    }
}
