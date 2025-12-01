/*//////////////////////////////////////////////////////////////////////////////
 Script: hf_hen_combat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Darkness over Daggerford - henchman developement script.
  OnCombatRoundEnd event script;
  Fires at the end of each combat round (6 seconds).
*///////////////////////////////////////////////////////////////////////////////
#include "x0_inc_henai"
// remove all uses of a feat for today
// ... after a certain level some feats can't be removed because
// ... they become permanent? Druid Wild Shape?
int HenchmanRemoveFeat(object oHenchman, int nFeat);

void main()
{
    // do nothing if henchman is passive
    if (GetLocalInt(OBJECT_SELF, "HF_HENCHMAN_PASSIVE"))
    {
        return;
    }
    // we don't want our druid to turn into a badger
    HenchmanRemoveFeat(OBJECT_SELF, FEAT_WILD_SHAPE);
    ExecuteScript("nw_ch_ac3");
    // signal end of combat round
    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
    }
}
int HenchmanRemoveFeat(object oHenchman, int nFeat)
{
    int n = 0;
    while (GetHasFeat(nFeat, oHenchman))
    {
        if (++n >= 10)
            return(FALSE);
        DecrementRemainingFeatUses(oHenchman, nFeat);
    }
    return(TRUE);
}


