/*/////////////////////////////////////////////////////
 Script: 0e_removesummons
 Programmer: Philos
///////////////////////////////////////////////////////
 This removes the bonuses from the spell Mage armor and Greater Mage armor.
 OBJECT_SELF is the target of the effect.
/*/////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    object oCreature = OBJECT_SELF;
    SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
    effect eVisual = EffectVisualEffect(VFX_IMP_UNSUMMON);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisual, GetLocation(oCreature));
    DestroyObject(oCreature);
}
