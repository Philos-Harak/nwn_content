/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_position
 Programmer: Naomi Novik
//////////////////////////////////////////////////////////////////////////////////////////////////////
Include file for functions that can be used to determine locations and positions.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// This actually moves the target to the given new location,
// and makes them face the correct way once they get there.
void MoveToNewLocation (location lNewLocation, object oTarget=OBJECT_SELF);

// This returns the change in X coordinate that should be made to
// cause an object to be fDistance away at fAngle.
float GetChangeInX (float fDistance, float fAngle);

// This returns the change in Y coordinate that should be made to
// cause an object to be fDistance away at fAngle.
float GetChangeInY (float fDistance, float fAngle);

// This returns a new vector representing a position that is fDistance
// meters away at fAngle from the original position.
// If a negative coordinate is generated, the absolute value will
// be used instead.
vector GetChangedPosition (vector vOriginal, float fDistance, float fAngle);

// This returns the angle between two locations
float GetAngleBetweenLocations (location lOne, location lTwo);

//******************** DIRECTION FUNCTIONS *************************
// These functions return a direction based on fDirection put in.
//******************************************************************

// This returns the opposite direction.
float GetOppositeDirection(float fDirection);

// This returns the direction directly to the right. (IE, what
// you would use to make an object turn to the right.)
float GetRightDirection(float fDirection);

// This returns a direction that's a half-turn to the right
float GetHalfRightDirection(float fDirection);

// This returns a direction one and a half turns to the right
float GetFarRightDirection(float fDirection);

// This returns a direction a specified angle to the right
float GetCustomRightDirection(float fDirection, float fAngle);

// This returns the direction directly to the left. (IE, what
// you would use to make an object turn to the left.)
float GetLeftDirection(float fDirection);

// This returns a direction that's a half-turn to the left
float GetHalfLeftDirection(float fDirection);

// This returns a direction one and a half turns to the left
float GetFarLeftDirection(float fDirection);

// This returns a direction a specified angle to the left
float GetCustomLeftDirection(float fDirection, float fAngle);

//****************** LOCATION FUNCTIONS **********************
// These functions return new locations suitable for placing
// created objects in relation to a target, for example.
//************************************************************

// Turns the target object to face the specified object
void TurnToFaceObject (object oObjectToFace, object oTarget=OBJECT_SELF);

// This returns the location flanking the target to the right fDistance away.
location GetFlankingRightLocation (object oTarget, float fDistance = 3.0f);

// Returns the location flanking the target to the left fDistance away.
location GetFlankingLeftLocation (object oTarget, float fDistance = 3.0f);

// Returns a location directly opposite the target and facing the target
location GetOppositeLocation (object oTarget, float fDistance = 3.0f);

// Returns location directly ahead of the target and facing
// same direction as the target
location GetAheadLocation (object oTarget, float fDistance = 3.0f);

// Returns location directly behind the target and facing same
// direction as the target (useful for backstabbing attacks)
location GetBehindLocation (object oTarget, float fDistance = 3.0f);

// Returns location to the forward right flank of the target
// and facing the same way as the target
// (useful for guarding)
location GetForwardFlankingRightLocation (object oTarget, float fDistance = 3.0f);

// Returns location to the forward left flank of the target
// and facing the same way as the target
// (useful for guarding)
location GetForwardFlankingLeftLocation (object oTarget, float fDistance = 3.0f);

// Returns location to the forward right and facing the target.
// (useful for one of two people facing off against the target)
location GetAheadRightLocation (object oTarget, float fDistance = 3.0f);

// Returns location to the forward left and facing the target.
// (useful for one of two people facing off against the target)
location GetAheadLeftLocation (object oTarget, float fDistance = 3.0f);

// Returns location just a step to the left
location GetStepLeftLocation (object oTarget, float fDistance = 1.0f);

// Returns location just a step to the right
location GetStepRightLocation (object oTarget, float fDistance = 1.0f);

// Get a random location in a given area based on a given object,
// the specified distance away.
// If no object is given, will use a random object in the area.
// If that is not available, will use the roughly-center point
// of the area.
// If distance is set to 0.0, a random distance will be used.
location GetRandomLocation(object oArea, object oSource=OBJECT_INVALID, float fDist=0.0);

// This actually moves the target to the given new location,
// and makes them face the correct way once they get there.
void MoveToNewLocation (location lNewLocation, object oTarget = OBJECT_SELF)
{
    AssignCommand (oTarget, ActionMoveToLocation (lNewLocation));
    AssignCommand (oTarget, ActionDoCommand (SetFacing (GetFacingFromLocation (lNewLocation))));
}

// This returns the change in X coordinate that should be made to
// cause an object to be fDistance away at fAngle.
float GetChangeInX(float fDistance, float fAngle)
{
    return fDistance * cos (fAngle);
}

// This returns the change in Y coordinate that should be made to
// cause an object to be fDistance away at fAngle.
float GetChangeInY(float fDistance, float fAngle)
{
    return fDistance * sin (fAngle);
}

// This returns a new vector representing a position that is fDistance
// meters away in the direction fAngle from the original position.
// If a negative coordinate is generated, the absolute value will
// be used instead.
vector GetChangedPosition (vector vOriginal, float fDistance, float fAngle)
{
    vector vChanged;
    vChanged.z = vOriginal.z;
    vChanged.x = vOriginal.x + GetChangeInX(fDistance, fAngle);
    if (vChanged.x < 0.0)
        vChanged.x = - vChanged.x;
    vChanged.y = vOriginal.y + GetChangeInY(fDistance, fAngle);
    if (vChanged.y < 0.0)
        vChanged.y = - vChanged.y;

    return vChanged;
}

// This returns the angle between two locations
float GetAngleBetweenLocations (location lOne, location lTwo)
{
    vector vPos1 = GetPositionFromLocation(lOne);
    vector vPos2 = GetPositionFromLocation(lTwo);
    float fDist = GetDistanceBetweenLocations(lOne, lTwo);

    float fChangeX = IntToFloat(abs(FloatToInt(vPos1.x - vPos2.x)));

    float fAngle = acos(fChangeX / fDist);
    return fAngle;
}


// This returns a direction normalized to the range 0.0 - 360.0
float GetNormalizedDirection (float fDirection)
{
    while (fDirection >= 360.0)
    {
        fDirection -= 360.0;
    }
    return fDirection;
}

// This returns the opposite direction (ie, this is the direction you
// would use to set something facing exactly opposite the way of
// something else that's facing in direction fDirection).
float GetOppositeDirection(float fDirection)
{
    return GetNormalizedDirection (fDirection + 180.0);
}


// This returns the direction directly to the right. (IE, what
// you would use to make an object turn to the right.)
float GetRightDirection(float fDirection)
{
    return GetNormalizedDirection (fDirection - 90.0);
}

// This returns a direction that's a half-turn to the right
float GetHalfRightDirection (float fDirection)
{
    return GetNormalizedDirection (fDirection - 45.0);
}

// This returns a direction one and a half turns to the right
float GetFarRightDirection (float fDirection)
{
    return GetNormalizedDirection (fDirection - 135.0);
}

// This returns a direction a specified angle to the right
float GetCustomRightDirection (float fDirection, float fAngle)
{
    return GetNormalizedDirection (fDirection - fAngle);
}

// This returns the direction directly to the left. (IE, what
// you would use to make an object turn to the left.)
float GetLeftDirection (float fDirection)
{
    return GetNormalizedDirection (fDirection + 90.0);
}

// This returns a direction that's a half-turn to the left
float GetHalfLeftDirection (float fDirection)
{
    return GetNormalizedDirection (fDirection + 45.0);
}

// This returns a direction one and a half turns to the left
float GetFarLeftDirection (float fDirection)
{
    return GetNormalizedDirection (fDirection + 135.0);
}

// This returns a direction a specified angle to the left
float GetCustomLeftDirection (float fDirection, float fAngle)
{
    return GetNormalizedDirection (fDirection + fAngle);
}

// Turns the object to face the specified object
void TurnToFaceObject (object oObjectToFace, object oTarget=OBJECT_SELF)
{
    AssignCommand(oTarget, SetFacingPoint (GetPosition (oObjectToFace)));
}

// Private function -- we use this to get the new location
location GenerateNewLocation (object oTarget, float fDistance, float fAngle, float fOrientation)
{
    object oArea = GetArea (oTarget);
    vector vNewPos = GetChangedPosition (GetPosition (oTarget), fDistance, fAngle);
    return Location (oArea, vNewPos, fOrientation);
}

// Private function -- we use this to get the new location from a source location.
location GenerateNewLocationFromLocation (location lTarget, float fDistance, float fAngle, float fOrientation)
{
    object oArea = GetAreaFromLocation (lTarget);
    vector vNewPos = GetChangedPosition (GetPositionFromLocation (lTarget), fDistance, fAngle);
    return Location (oArea, vNewPos, fOrientation);
}

// This returns the location flanking the target to the right fDistance away.
location GetFlankingRightLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngleToRightFlank = GetFarRightDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngleToRightFlank, fDir);
}


// Returns the location flanking the target to the left fDistance away.
location GetFlankingLeftLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngleToLeftFlank = GetFarLeftDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngleToLeftFlank, fDir);
}


// Returns a location directly ahead of the target and facing the target fDistance away.
location GetOppositeLocation(object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngleOpposite = GetOppositeDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fDir, fAngleOpposite);
}

// Returns location directly ahead of the target and facing same direction as the target fDistance away.
location GetAheadLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    return GenerateNewLocation (oTarget, fDistance, fDir, fDir);
}

// Returns location directly behind the target and facing same
// direction as the target fDistance away (useful for backstabbing attacks)
location GetBehindLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngleOpposite = GetOppositeDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngleOpposite, fDir);
}

// Returns location to the forward right flank of the target
// and facing the same way as the target fDistance away. (useful for guarding)
location GetForwardFlankingRightLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngle = GetHalfRightDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngle, fDir);
}

// Returns location to the forward left flank of the target
// and facing the same way as the target fDistance away (useful for guarding)
location GetForwardFlankingLeftLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngle = GetHalfLeftDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngle, fDir);
}

// Returns location to the forward right and facing the target.
// (useful for one of two people facing off against the target)
location GetAheadRightLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngle = GetHalfRightDirection (fDir);
    float fFaceAngle = GetOppositeDirection (fAngle);
    return GenerateNewLocation (oTarget, fDistance, fAngle, fFaceAngle);
}

// Returns location to the forward left and facing the target.
// (useful for one of two people facing off against the target)
location GetAheadLeftLocation (object oTarget, float fDistance = 3.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngle = GetHalfLeftDirection (fDir);
    float fFaceAngle = GetOppositeDirection (fAngle);
    return GenerateNewLocation (oTarget, fDistance, fAngle, fFaceAngle);
}

// Returns location just a step to the left
location GetStepLeftLocation (object oTarget, float fDistance = 1.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngle = GetLeftDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngle, fDir);
}

// Returns location just a step to the right
location GetStepRightLocation (object oTarget, float fDistance = 1.0f)
{
    float fDir = GetFacing (oTarget);
    float fAngle = GetRightDirection (fDir);
    return GenerateNewLocation (oTarget, fDistance, fAngle, fDir);
}

// Get the (roughly) center point of an area.
// This works by going through all the objects in an area and
// getting their positions, so it is resource-intensive.
location GetCenterPointOfArea (object oArea)
{
    float fXMax = 0.0;
    float fXMin = 10000.0;
    float fYMax = 0.0;
    float fYMin = 10000.0;
    object oTmp = OBJECT_INVALID;
    vector vTmp;
    oTmp = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTmp))
    {
        vTmp = GetPositionFromLocation(GetLocation(oTmp));
        if (vTmp.x > fXMax) fXMax = vTmp.x;
        if (vTmp.x < fXMin) fXMin = vTmp.x;
        if (vTmp.y > fYMax) fYMax = vTmp.y;
        if (vTmp.y < fYMin) fYMin = vTmp.y;
        oTmp = GetNextObjectInArea(oArea);
    }
    // We now have the max and min positions of all objects in an area.
    vTmp = Vector( (fXMax + fXMin)/2.0, (fYMax + fYMin)/2.0, 0.0);
    return Location(oArea, vTmp, 0.0);
}

// Get a random location in a given area based on a given object,
// the specified distance away.
// If no object is given, will use a random object in the area.
// If that is not available, will use the roughly-center point
// of the area.
// If distance is set to 0.0, a random distance will be used.
location GetRandomLocation (object oArea, object oSource=OBJECT_INVALID, float fDist=0.0)
{
    location lStart;
    if (!GetIsObjectValid (oSource)) lStart = GetCenterPointOfArea (oArea);
    else lStart = GetLocation(oSource);
    float fAngle; float fOrient;
    if (fDist == 0.0)
    {
        int nRoll = Random(3);
        switch (nRoll)
        {
            case 0:
                fDist = 3.0f; break;
            case 1:
                fDist = 10.0f; break;
            case 2:
                fDist = 20.0f; break;
        }
    }
    fAngle = IntToFloat (Random (140) + 40);
    fOrient = IntToFloat (Random (360));
    return GenerateNewLocationFromLocation (lStart, fDist, fAngle, fOrient);
}
