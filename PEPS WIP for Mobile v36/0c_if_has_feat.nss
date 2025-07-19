/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_feat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if they have a specific feat.
 Param:
 sTarget - either "OBJECT_SELF", or "PCSpeaker", blanks defaults to "PCSpeaker"
 nFeat - the feat number from Feats.2da
 bNot - if 1 TRUE then this returns true for the target not having the feat.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_main"
int StartingConditional()
{
    string sTarget = GetScriptParam("sTarget");
    int nFeat = StringToInt(GetScriptParam("nFeat"));
    int bNot = StringToInt(GetScriptParam("bNot"));
    object oCreature;
    if(sTarget == "OBJECT_SELF") oCreature = OBJECT_SELF;
    else if(sTarget == "" || sTarget == "PCSpeaker") oCreature = GetPCSpeaker();
    if(bNot) return !GetHasFeat(nFeat, oCreature);
    return (GetHasFeat(nFeat ,oCreature) || ai_GetIsDungeonMaster(oCreature));
}
