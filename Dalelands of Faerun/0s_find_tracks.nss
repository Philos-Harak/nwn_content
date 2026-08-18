/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_find_tracks
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Used to find tracks of creatures in the current area.
    If the user has the track feat they can also
    get the direction of creatures in quests they have.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
#include "nwnx_area"
void main()
{
    string sName, sName1 = "", sName2 = "", sName3 = "", sName4 = "", sName5 = "";
    int nCheck, bMakeCheck, iDC, bFoundTracks = FALSE, iCounter;
    // Get the user of the skill.
    object oPC = OBJECT_SELF;
    object oUser = oPC;
    // Is the henchman looking for tracks?
    if(!GetIsCharacter(oPC)) 
    {
        oPC = GetPlayerMaster(oPC);
        SendMessages(GetName(oUser) + " is looking for tracks.", COLOR_GREEN, oPC);
    }
    object oArea = GetArea(oUser);
    // Check to make sure we are not in a civilized area.
    if(GetLocalInt(oArea, "0_No_Difficulty"))
    {
        SendMessages("The ground has been disturbed too much to find any good tracks!", COLOR_RED, oPC, FALSE, FALSE);
        return;
    }
    // First check to see if they have already checked in this area.
    if(GetLocalString(oUser, "0_FindTracks") == GetTag(oArea))
    {
        SendMessages("This area has already been checked for tracks!", COLOR_RED, oPC, FALSE, FALSE);
        return;
    }
    // Set that they are checking for tracks so they cannot spam the ability.
    SetLocalString(oUser, "0_FindTracks", GetTag (oArea));
    // Remove it after 1 minute so they can use it again.
    DelayCommand(60.0f, DeleteLocalInt (oUser, "0_FindTracks"));
    location lLocation = GetLocation(oUser);
    ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW);
    // ******* Do find tracks in the area ********
    // Cycle through all creatures in the area.
    iCounter = 1;
    object oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oUser, iCounter, CREATURE_TYPE_IS_ALIVE, TRUE);
    while (GetIsObjectValid (oCreature) && iCounter < 20)
    {
        // Don't track familiars, companions, or summons.
        if (GetAssociateType (oCreature) == ASSOCIATE_TYPE_NONE)
        {
            // Check to see if we have already seen this creature.
            sName = GetName (oCreature);
            if(sName1 == "") {sName1 = sName; bMakeCheck = TRUE;}
            else if(sName == sName1) bMakeCheck = FALSE;
            else if(sName2 == "") {sName2 = sName; bMakeCheck = TRUE;}
            else if(sName == sName2) bMakeCheck = FALSE;
            else if(sName3 == "") {sName3 = sName; bMakeCheck = TRUE;}
            else if(sName == sName3) bMakeCheck = FALSE;
            else if(sName4 == "") {sName4 = sName; bMakeCheck = TRUE;}
            else if(sName == sName4) bMakeCheck = FALSE;
            else if(sName5 == "") {sName5 = sName; bMakeCheck = TRUE;}
            else if(sName == sName5) {bMakeCheck = FALSE; iCounter = 21;}
            // Check for Trackless Step when in nature.
            if(GetIsAreaNatural(oArea) == AREA_NATURAL)
            {
                // If they have trackless step then they cannot be tracked!
                if(GetHasFeat(FEAT_TRACKLESS_STEP, oCreature)) bMakeCheck = FALSE;
            }
            if(GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL)) bMakeCheck = FALSE;
            if(bMakeCheck)
            {
                // Get the DC for the tracks.
                iDC = TrackingDC(oArea, oUser, oCreature, lLocation);
                // Make a Survival check against the DC of the tracks, Survival use to be Craft_Armor!
                if(GetSkillCheck(oUser, SKILL_CRAFT_ARMOR, FALSE, 0, iDC, 0, FALSE) >= 0)
                {
                    // We found the tracks now reveal the name of the creature.
                    SendMessages("There are " + sName + " tracks in this area.", COLOR_GREEN, oPC, FALSE, FALSE);
                    bFoundTracks = TRUE;
                }
            }
        }
        iCounter++;
        oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oUser, iCounter, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    // ********* Do track feat************
    // Check to see if we need to look for quest tracks.
    // 1224 is the Track feat.
    if(oPC != oUser)
    {
        bFoundTracks = TrackQuests(oPC, oUser, bFoundTracks);
    }
    else if(GetHasFeat (1262 /* TRACK_FEAT */, oUser)) bFoundTracks = TrackQuests(oPC, OBJECT_INVALID, bFoundTracks);
    if(!bFoundTracks) SendMessages("Tracks could not be found in this area!", COLOR_RED, oPC, FALSE, FALSE);
}

