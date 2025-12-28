/*////////////////////////////////////////////////
 Grease: Heartbeat
 Created By: Preston Watamaniuk
////////////////////////////////////////////////
    Creatures entering the zone of grease must make
    a reflex save or fall down.  Those that make
    their save have their movement reduced by 1/2.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "X2_inc_switches"
void main()
{
    //Declare major variables
    object oTarget;
    effect eFall = EffectKnockdown();
    float fDelay;
    //Get first target in spell area
    oTarget = GetFirstInPersistentObject();
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) &&
          (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL) != TRUE) )
        {
            fDelay = GetRandomDelay(0.0, 2.0);
            if(!SavingThrowWithEffects (SAVING_THROW_REFLEX, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_NONE, GetAreaOfEffectCreator (), fDelay))
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFall, oTarget, 4.0));
            }
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject();
    }
}

