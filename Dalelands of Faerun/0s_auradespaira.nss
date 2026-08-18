/*////////////////////////////////////////////////
 Aura of despair: On Enter
 Created By: Philos
////////////////////////////////////////////////
    Creatures entering the zone :
    Enemies get -2 penalty on all Saving Throws.
/*///////////////////////////////////////////////

void main()
{
    object oTarget = GetEnteringObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are an enemy.
    if(GetIsEnemy(oTarget, oCaster) && !GetIsDead(oTarget))
    {
        effect eDispair = EffectSavingThrowDecrease(SAVING_THROW_ALL, 2);
        effect eVisual = EffectVisualEffect (VFX_IMP_HEAD_EVIL);
        // Tag the effect.
        eDispair = TagEffect (eDispair, "AURA_OF_DESPAIR" + GetName (oCaster));
        // Apply VFX until the area effect is gone or they leave it.
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oTarget);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDispair, oTarget);
    }
}
