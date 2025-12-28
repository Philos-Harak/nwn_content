//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: ac_0_thief_tools
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Activate item script for Thieves' Tools.
 Used to unlock doors and disable traps with magical tools.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 3/29/15
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_checks"
#include "0i_creature"

void main()
{
    int nBonus, nDC, nCheck, nTake20 = TRUE;
    string sResRef, sName;
    object oTarget = GetLocalObject (OBJECT_SELF, "0_target");
    object oItem = GetLocalObject (OBJECT_SELF, "0_item");
    int nLevel = GetLocalInt (GetArea (OBJECT_SELF), "0_Area_Level");
    // Check the item for its bonus.
    sName = GetName (oTarget);
    sResRef = GetResRef(oItem);
    if (sResRef == "0_thief_tools_1") nBonus = 1;
    else if (sResRef == "0_thief_tools_2") nBonus = 2;
    else if (sResRef == "0_thief_tools_3") nBonus = 3;
    else if (sResRef == "0_thief_tools_4") nBonus = 4;
    else if (sResRef == "0_thief_tools_5") nBonus = 5;
    else if (sResRef == "0_thief_tools_6") nBonus = 6;
    else if (sResRef == "0_thief_tools_7") nBonus = 7;
    else if (sResRef == "0_thief_tools_8") nBonus = 8;
    else if (sResRef == "0_thief_tools_9") nBonus = 9;
    else if (sResRef == "0_thief_tools_10") nBonus = 10;
    // Check the target to see if it is trapped.
    if (GetTrapDetectedBy (oTarget, OBJECT_SELF))
    {
        // Since it is trapped then lets make a disable device check.
        // Get the DC of the trap.
        nDC = GetTrapDisarmDC (oTarget);
        // check to see if they are in combat. If so make a roll!
        if (GetIsInCombat (OBJECT_SELF)) nTake20 = FALSE;
        // Make skill check.
        nCheck = GetSkillCheck (OBJECT_SELF, SKILL_DISABLE_TRAP, FALSE, nBonus, nDC, 1, nTake20);
        if (nCheck >= 0)
        {
              // Send message to player.
              SendMessages  ("You disarm the trap!", COLOR_GREEN, OBJECT_SELF, FALSE, FALSE);
              // Disarm the trap as well as remove it as detectable.
              SetTrapDisabled (oTarget);
              SetTrapActive (oTarget, FALSE);
              SetTrapDetectedBy (oTarget, OBJECT_SELF, FALSE);
              SetTrapDetectable (oTarget, FALSE);
              int nTrapLevel = GetLocalInt (oTarget, "0_Trap_Level");
              if (nTrapLevel > nLevel) nLevel = nTrapLevel;
              // 0e_disarmtrap script gives xp.
              //GiveAreaXP (OBJECT_SELF, IntToFloat (nDC) + BASE_DISARM_TRAP_XP, IntToFloat (nLevel));
        }
        else SendMessages  ("You cannot disarm the trap!", COLOR_RED, OBJECT_SELF, FALSE, FALSE);
    }
    // Else check to see if its locked.
    else if (GetLocked (oTarget))
    {
        // First check to make sure the door does not require a key.
        if (GetLockKeyRequired (oTarget))
        {
            SendMessages  ("A key is required to unlock " + sName + "!", COLOR_RED, OBJECT_SELF, FALSE, FALSE);
        }
        // No key required so lets check.
        else
        {
            // Since it is locked then lets make an open lock check.
            // Get the DC of the lock.
            nDC = GetLockUnlockDC (oTarget);
            // check to see if they are in combat. If so make a roll!
            if (GetIsInCombat (OBJECT_SELF)) nTake20 = FALSE;
            // Make skill check.
            nCheck = GetSkillCheck (OBJECT_SELF, SKILL_OPEN_LOCK, FALSE, nBonus, nDC, 1, nTake20);
            if (nCheck >= 0)
            {
               // Send message to player.
               SendMessages  ("You unlock " + sName + "!", COLOR_GREEN, OBJECT_SELF, FALSE, FALSE);
               GiveAreaXP (OBJECT_SELF, IntToFloat (nDC) + BASE_UNLOCK_XP, IntToFloat (nLevel));
               // Unlock the object.
               SetLocked (oTarget, FALSE);
            }
            else SendMessages  ("You cannot unlock the " + sName + "!", COLOR_RED, OBJECT_SELF, FALSE, FALSE);
        }
    }
    else SendMessages  ("There is no trap or lock on " + sName, COLOR_GRAY, OBJECT_SELF, FALSE, FALSE);
}
