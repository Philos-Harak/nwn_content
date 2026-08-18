/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ac_0_quest_paper
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Activate item script for quest papers.
 Used to check the quest papers difficulty.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_creature"

void main()
{
    object oPC = OBJECT_SELF;
    object oPaper = GetLocalObject(oPC, "0_item");
    object oArea = GetArea(oPC);
    if(GetIsAreaInterior(oArea))
    {
        SendMessages("You cannot use treasure maps while inside! The map only helps with overland traveling.", COLOR_RED, oPC);
        return;
    }
    // Get the location of the area that holds the treasure.
    string sAreaArray = GetLocalString (oPaper, "0_Q_AREA");
    string sLocation = GetStringArray(sAreaArray, 1, "-");
    sLocation = GetStringLeft(sLocation, 7);
    int nTreasureMapX = StringToInt(GetStringLeft(sLocation, 3));
    int nTreasureMapY = StringToInt(GetStringRight(sLocation, 3));
    // Get current location x,y coordinates.
    string sAreaTag = GetTag(oArea);
    int nAreaX = StringToInt(GetStringLeft(sAreaTag, 3));
    int nAreaY = StringToInt(GetStringRight(sAreaTag, 3));
    // Get distance from x and y.
    int nX = nTreasureMapX - nAreaX;
    int nY = nTreasureMapY - nAreaY;
    int nDistance = abs(nX) + abs(nY);
    string sName;
    // If the distance is 0 then they are here.
    if(nDistance == 0) sName = "Here";
    else
    {
        // Check the information point to see if a direction is blocked.
        object oInfoPoint = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        // Select the direction the creatures went.
        // Decide if they followed the x or the y axis.
        // This follows the X axis.
        if(abs(nX) > abs(nY))
        {
            // They went East if possible.
            if(nX > 0)
            {
                // See if we can go East.
                if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                else
                {
                    if(nY > 0)
                    {
                        // See if we can go North.
                        if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                        else
                        {
                            // See if we can go South.
                            if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                            else sName = "Blocked";
                        }
                    }
                    else
                    {
                        // See if we can go South.
                        if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                        else
                        {
                            // See if we can go North.
                            if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                            else sName = "Blocked";
                        }
                    }
                }
            }
            // They went West if possible.
            else
            {
                // See if we can go West.
                if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                else
                {
                    if(nY > 0)
                    {
                        // See if we can go North.
                        if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                        else
                        {
                            // See if we can go South.
                            if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                            else sName = "Blocked";
                        }
                    }
                    else
                    {
                        // See if we can go South.
                        if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                        else
                        {
                            // See if we can go North.
                            if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                            else sName = "Blocked";
                        }
                    }
                }
            }
        }
        // The followed the Y axis.
        else
        {
            // They went North if possible.
            if(nY < 0)
            {
                // See if we can go North.
                if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                else
                {
                    if(nX > 0)
                    {
                        // See if we can go East.
                        if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                        else
                        {
                            // See if we can go West.
                            if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                            else sName = "Blocked";
                        }
                    }
                    else
                    {
                        // See if we can go West.
                        if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                        else
                        {
                            // See if we can go East.
                            if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                            else sName = "Blocked";
                        }
                    }
                }
            }
            // They went South if possible.
            else
            {
                // See if we can go South.
                if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                else
                {
                    if(nX > 0)
                    {
                        // See if we can go East.
                        if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                        else
                        {
                            // See if we can go West.
                            if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                            else sName = "Blocked";
                        }
                    }
                    else
                    {
                        // See if we can go West.
                        if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                        else
                        {
                          // See if we can go East.
                          if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                          else sName = "Blocked";
                        }
                    }
                }
            }
        }
    }
    string sAreaName = GetStringArray(sAreaArray, 0, "-");
    if(sName != "")
    {
        if(sName == "Blocked")
        {
            SendMessages("There is no place for you to leave this area and get to " + sAreaName + ".", COLOR_RED, oPC);
        }
        else if(sName == "Here")
        {
            SendMessages("The map indicates that you are very close to " + sAreaName + ".", COLOR_GREEN, oPC);
        }
        else SendMessages("Looking at the map you need to head " + sName + ".", COLOR_GREEN, oPC);
    }
    else SendMessages("You must have the map upside down! There is an error when looking at " + sAreaName + ".", COLOR_RED, oPC);
}
