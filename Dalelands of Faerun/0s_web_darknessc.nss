/*//////////////////////////////////////////////////////////////////////////////
 0s_web_darknessc
////////////////////////////////////////////////////////////////////////////////
 Heartbeat script for:
 Creates a mass of sticky webs that cling to and entangle targets who fail a
 Reflex Save. Those caught can make a new save every round.  Movement in the
 web is 1/5 normal. The higher the creatures Strength the faster they move
 within the web.
*///////////////////////////////////////////////////////////////////////////////
#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{

    //Declare major variables
    int nBonusDmg;
    effect eWeb = EffectEntangle();
    effect eVis = EffectVisualEffect(VFX_DUR_WEB);
    object oCaster = GetAreaOfEffectCreator ();
    if (oCaster != OBJECT_INVALID) nBonusDmg = GetCasterLevel (oCaster);
    else nBonusDmg = 5;
    effect eDmg = EffectDamage (d6 () + nBonusDmg);
    object oTarget;
    //Spell resistance check
    oTarget = GetFirstInPersistentObject();
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) &&(GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) != TRUE) )
        {
            if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, GetAreaOfEffectCreator()))
            {
            // *************
            // * Patch Fix
            // * Brent
            // * Moved the two spell cast events down after the reaction check check
                //Fire cast spell at event for the target
                SignalEvent(oTarget, EventSpellCastAt(GetAreaOfEffectCreator(), SPELL_WEB));
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_WEB));

                if(!MyResistSpell(GetAreaOfEffectCreator(), oTarget))
                {
                    //Make a Fortitude Save to avoid the effects of the entangle.
                    if(!/*Reflex Save*/ MySavingThrow(SAVING_THROW_REFLEX, oTarget, GetSpellSaveDC()))
                    {
                        //Entangle effect and Web VFX impact
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eWeb, oTarget, RoundsToSeconds(1));
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget, RoundsToSeconds(1));
                    }
                }
            }
        }
        oTarget = GetNextInPersistentObject();
    }
}
