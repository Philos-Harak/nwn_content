/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_portal_use
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse event of a quest portal placeable.
 This is useable by Players and NPC's.
 Makes a Spellcraft check to see if it can be destroyed safely.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_effects"
#include "0i_quest"

void main()
{
    int iCheck, iBonus, iDC;
    string sState, sQuestID;
    object oUser, oArea, oPaper;
    float fDelay;
    effect eEffect;
    // Get the user of the Poral.
    oUser = GetLastUsedBy ();
    // Get DC of the Portal based on area level.
    oArea = GetArea (OBJECT_SELF);
    // DC 15 + area level. 1st level is a 17, must have skill points to make the check.
    iDC = 15 + GetLocalInt (oArea, "0_Area_Level");
    // No bonus at the moment.
    iBonus = 0;
    // Send message that you are trying to close the portal.
    SendMessages ("You attempt to close the portal!", COLOR_YELLOW, oUser);
    // Make a Spellcraft check to safely destroy the portal.
    iCheck = GetSkillCheck (oUser, SKILL_SPELLCRAFT, FALSE, iBonus, iDC, TRUE, FALSE);
    // If you make your check then the portal is removed with no ill effects.
    if (iCheck >= 0)
    {
        // Make a closing portal effect.
        fDelay = ClosePortalEffect (OBJECT_SELF, oUser);
        // Remove the portal.
        DestroyObject (OBJECT_SELF, fDelay);
        // Check for quest start area location.
        sQuestID = GetQuestIDByPlaceable(OBJECT_SELF, oUser);
        if(sQuestID != "")
        {
            // Set State 1 to TRUE (Object Destroyed).
            SetQuestState(oUser, sQuestID, 1, 1);
            // Give feedback!
            QuestUpdate(oUser, sQuestID, GetName (OBJECT_SELF) + " has been destroyed!", TRUE);
        }
    }
}
