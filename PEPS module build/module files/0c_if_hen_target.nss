/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_assoc_mode
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see the ally targets have been set for
 this number target.
  nTarget (INT) : 0 = ALL, 1 PC, 2 Caster, 3-6 = oPC's Henchman, 7 = PC's Familiar
                 8 = PC's Animal Companion, 9 = PC's Summon.
 Param:
 nTarget - The target to check and see if they are set.
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    string sTarget = GetScriptParam("nTarget");
    return GetIsObjectValid(GetLocalObject(OBJECT_SELF, "AI_ALLY_TARGET_" + sTarget));
}
