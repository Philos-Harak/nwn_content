/*////////////////////////////////////////////////
 Script: nw_s0_auraofdefense
 Programmer: Philos
////////////////////////////////////////////////
 All allies (in party) gain a +2 or +4 to AC
 while within the Aura.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    effect eAOE = EffectAreaOfEffect (49); /* VFX_AURA_OF_DEFENSE */
    // Create an instance of the AOE Object using the Apply Effect function
    eAOE = SupernaturalEffect (eAOE);
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eAOE, OBJECT_SELF);
}

