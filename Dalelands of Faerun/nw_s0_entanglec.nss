/*////////////////////////////////////////////////
  Script: nw_s0_entanglec
  Programmer: Preston Watamaniuk
////////////////////////////////////////////////
    Upon entering the AOE the target must make
    a reflex save or be entangled by vegitation
/*///////////////////////////////////////////////
#include "0i_spells"
#include "X2_inc_switches"

void main()
{
    //Declare major variables
    effect eHold = EffectEntangle();
    effect eEntangle = EffectVisualEffect(VFX_DUR_ENTANGLE);
    //Link Entangle and Hold effects
    effect eLink = EffectLinkEffects(eHold, eEntangle);
    object oCreator = GetAreaOfEffectCreator();
    int bValid;
    object oTarget = GetFirstInPersistentObject();
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat (FEAT_WOODLAND_STRIDE, oTarget) &&
          (!GetCreatureFlag (OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL)))
        {
            //Fire cast spell at event for the specified target
            SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, SPELL_ENTANGLE));
            // Are they already entangled.
            if(!GetHasSpellEffect(SPELL_ENTANGLE, oTarget))
            {
                //Make reflex save
                if(!SavingThrowWithEffects (SAVING_THROW_REFLEX, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_NONE, oCreator))
                {
                    //Apply linked effects
                    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2));
                }
            }
        }
        //Get next target in the AOE
        oTarget = GetNextInPersistentObject();
    }
}
