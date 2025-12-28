/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_psionics
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for all psionic based scripts.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
void MindBlast (object oTarget, int nShape, float fSize, string sStunDie = "", string sDmgDie = "", int nDC = 0)
{
    int nStunDuration, nDamage;
    float fDelay;
    effect eDmg;
    if (nDC == 0) nDC = 10 + (GetHitDice (OBJECT_SELF) / 2) + GetAbilityModifier (ABILITY_CHARISMA);
    location lLocation = GetLocation (oTarget);
    effect eImpact = EffectVisualEffect (VFX_IMP_SONIC);
    effect eStun = EffectStunned ();
    oTarget = GetFirstObjectInShape (nShape, fSize, lLocation, TRUE);
    while (oTarget != OBJECT_INVALID)
    {
        if (!GetIsImmune (oTarget, IMMUNITY_TYPE_MIND_SPELLS))
        {
            SignalEvent(oTarget, EventSpellCastAt (OBJECT_SELF, GetSpellId()));
            if (WillSave (oTarget, nDC) < 1)
            {
                fDelay = GetDistanceBetween (OBJECT_SELF, oTarget) / 20;
                DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget));
                if (sStunDie != "")
                {
                    nStunDuration = RollDiceString (sStunDie);
                    DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eStun, oTarget, RoundsToSeconds (nStunDuration)));
                }
                if (sDmgDie != "")
                {
                    nDamage = RollDiceString (sDmgDie);
                    DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectDamage (nDamage, DAMAGE_TYPE_SONIC), oTarget));
                }
            }
        }
        oTarget = GetNextObjectInShape (nShape, fSize, lLocation, TRUE);
    }
}
