/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_s0_auraofdespair
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 All enemies within 10' of the blackguard get a -2 penalty to all saving throws
 while within the Aura.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"

void main()
{
    effect eAOE = EffectAreaOfEffect(54); /* VFX_AURA_OF_DESPAIR */
    // Create an instance of the AOE Object using the Apply Effect function
    eAOE = SupernaturalEffect(eAOE);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eAOE, OBJECT_SELF);
}

