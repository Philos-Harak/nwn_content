/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oi_walk_wp_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the players clicks to move.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_henchmen"
#include "0i_npc"
#include "0i_area"
#include "nwnx_events"
void MoveToClickLocation (object oAssociate, location lClicked, int bRun)
{
    //if (!GetAssociateMode (MODE_IN_COMBAT, oAssociate))
    if (!IsInCombatRound (oAssociate))
    {
        AssignCommand (oAssociate, ClearAllActions ());
        AssignCommand (oAssociate, ActionMoveToLocation (lClicked, bRun));
    }
}

void MovePCToClickLocation (object oPC, location lClicked, int bRun)
{
    AssignCommand (oPC, ClearAllActions ());
    AssignCommand (oPC, ActionMoveToLocation (lClicked, bRun));
}

void main()
{
    object oPC = OBJECT_SELF;
    object oArea = StringToObject (NWNX_Events_GetEventData ("AREA"));
    // Since we have clicked on a new location lets remove the old one.
    DeleteMoveVariables (oPC);
    float fX = StringToFloat (NWNX_Events_GetEventData ("POS_X"));
    float fY = StringToFloat (NWNX_Events_GetEventData ("POS_Y"));
    float fZ = StringToFloat (NWNX_Events_GetEventData ("POS_Z"));
    int bRun = StringToInt (NWNX_Events_GetEventData ("RUN_TO_POINT"));
    vector vVector = Vector (fX, fY, fZ);
    location lClicked = Location (oArea, vVector, GetFacing (oPC));
    //Debug ("0e_oi_walk_wp_b", "40", "oArea: " + GetName (oArea) + " Area Tag: " + GetTag (oArea) +
    //       " fX: " + FloatToString (fX, 0, 2) + " fY: " + FloatToString (fY, 0, 2));
    // Check to see if we are transitioning to a new area.
    // Note if a map tile gets to close to the edge then it will allow transitioning!
    // We stop this in areas that don't use it by setting the variable: 0_NoEdgeTransition
    if (!GetLocalInt (oArea, "0_NoEdgeTransition") &&
       (fX < 2.1f || fX > 117.9f ||
        fY < 2.1f || fY > 117.9f))
    {
        // Set the variables for where we are going.
        SetLocalFloat (oPC, "Move_X", fX);
        SetLocalFloat (oPC, "Move_Y", fY);
        SetLocalFloat (oPC, "Move_Z", fZ);
        SetLocalObject (oPC, "Move_Area", oArea);
        SetLocalLocation (oPC, "Move_Loc", lClicked);
        // Check distance as we don't want to transition until they are close.
        float fDistance = GetDistanceBetweenLocations (GetLocation (oPC), lClicked);
        //Debug ("0e_oi_walk_wp_b", "55", "fDistance: " + FloatToString (fDistance, 0, 2));
        if (fDistance > 2.0f)
        {
            // Check to see if we are already looking to move.
            int nCount = GetLocalInt (oPC, "Move_Count");
            // If the original count was 0 then we need to start a
            // wait for transition function for this PC Clear if the counter is 30+.
            if (nCount > 29)
            {
                DeleteLocalInt(oPC, "Move_Count");
                nCount = 0;
            }
            if (nCount == 0)
            {
                //Debug ("0e_oi_walk_wp_b", "66", "Running WaitToTransition (oClicker)!");
                SetLocalInt(oPC, "Move_Count", 1);
                WaitToTransition(oPC);
            }
            // If it is counting then we need to clear the count since we have
            // clicked a new location. The old wait for transition will still run.
            else SetLocalInt (oPC, "Move_Count", 0);
        }
        else Transition (oPC);
        return;
    }
    // We have clicked to a non-transition location, so lets stop any WaitToTransition functions.
    else DeleteLocalInt (oPC, "Move_Count");
    /*/ Cycle through all the associate types we might have.
    int nNth, nAssociateType = 1;
    object oAssociate;
    while(nAssociateType < 7)
    {
        nNth = 1;
        oAssociate = GetAssociate(nAssociateType, oPC, nNth);
        while(oAssociate != OBJECT_INVALID)
        {
            // If we are not busy, disabled, in combat, or StandingGround.
            if(!GetIsBusy (oAssociate) &&
               !Disabled (oAssociate) &&
               !GetLocalInt(oAssociate, "AI_ENEMY_NUM") &&
               !(GetLocalInt(oAssociate, "ASSOCIATE_MODES") & 0x00008000))
            {
                // Follow master if we are not scouting ahead.
                if (!(GetLocalInt(oAssociate, "ASSOCIATE_MODES") & 0x00002000))
                {
                    float fFollowDistance = GetLocalFloat(oAssociate, "AI_FOLLOW_RANGE");
                    if(GetDistanceBetweenLocations (lClicked, GetLocation(oAssociate)) > fFollowDistance)
                    {
                        // Using a delay command of .33 x fFollowDistance gives a
                        // delay of .66 seconds, 1.32 seconds and 1.98 seconds.
                        //Debug ("0e_oi_walk_wp_b", "119", GetName (OBJECT_SELF) + " is moving to mouse click!");
                        DelayCommand (fFollowDistance * 0.33f, MoveToClickLocation(oAssociate, lClicked, bRun));
                        // Lets get all NPC associates following from here as well.
                        int nAssociateType;
                        object oCreature;
                        for(nAssociateType = 2; nAssociateType < 6; nAssociateType++)
                        {
                            oCreature = GetAssociate(nAssociateType, oAssociate);
                            if(oCreature != OBJECT_INVALID) ActionMoveToObject(oCreature, bRun, fFollowDistance);
                        }
                    }
                }
            }
            oAssociate = GetAssociate(nAssociateType, oPC, ++nNth);
        }
        nAssociateType++;
    } */
    // Cycle through all PC followers to have them follow.
    int nCount = 1;
    object oFollower = GetLocalObject (oPC, "0_Follower_" + IntToString (nCount));
    while (GetIsObjectValid (oFollower) && nCount <= 10)
    {
        if (!GetIsDungeonMaster (oFollower)) DelayCommand (1.32f, MovePCToClickLocation (oFollower, lClicked, bRun));
        nCount ++;
        oFollower = GetLocalObject (oPC, "0_Follower_" + IntToString (nCount));
    }
}

