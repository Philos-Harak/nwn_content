/*//////////////////////////////////////////////////////////////////////////////
 0s_web_darknessb
////////////////////////////////////////////////////////////////////////////////
    On Exit script for:
 Creates a mass of sticky webs that cling to and entangle targets who fail a
 Reflex Save. Those caught can make a new save every round.  Movement in the
 web is 1/5 normal. The higher the creatures Strength the faster they move
 within the web.
*///////////////////////////////////////////////////////////////////////////////
#include "x2_inc_spellhook"

void main()
{
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject();
    //Search through the valid effects on the target.
    effect eAOE = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eAOE))
    {
        //If the effect was created by the Web then remove it
        if (GetEffectCreator(eAOE) == GetAreaOfEffectCreator())
        {
            if(GetEffectSpellId(eAOE) == SPELL_WEB)
            {
                RemoveEffect(oTarget, eAOE);
            }
        }
        eAOE = GetNextEffect(oTarget);
    }
}

