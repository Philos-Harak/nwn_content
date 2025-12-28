/*////////////////////////////////////////////////
 Script: NW_S0_CircGoodB
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
    Remove protection effects to exiting allies.
/*///////////////////////////////////////////////
#include "NW_I0_SPELLS"
void main()
{
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject ();
    object oCaster = GetAreaOfEffectCreator ();
    effect eAOE;
    if (GetHasSpellEffect (SPELL_MAGIC_CIRCLE_AGAINST_GOOD, oTarget))
    {
        //Search through the valid effects on the target.
        eAOE = GetFirstEffect (oTarget);
        while (GetIsEffectValid (eAOE))
        {
            if (GetEffectCreator (eAOE) == oCaster)
            {
                //If the effect was created by the AOE then remove it
                if(GetEffectSpellId (eAOE) == SPELL_MAGIC_CIRCLE_AGAINST_GOOD)
                {
                    RemoveEffect (oTarget, eAOE);
                }
            }
            //Get next effect on the target
            eAOE = GetNextEffect (oTarget);
        }
    }
}
