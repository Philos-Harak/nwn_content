/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_beholder
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for beholders.
 OBJECT_SELF is the beholder running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
const string sBeholderRays = "BEHOLDER_RAYS";
const int BEHOLDER_CHARM_PERSON_RAY        = 0x00000001;
const int BEHOLDER_CHARM_MONSTER_RAY       = 0x00000002;
const int BEHOLDER_SLEEP_RAY               = 0x00000004;
const int BEHOLDER_FLESH_STONE_RAY         = 0x00000008;
const int BEHOLDER_DISINTEGRATE_RAY        = 0x00000010;
const int BEHOLDER_FEAR_RAY                = 0x00000020;
const int BEHOLDER_SLOW_RAY                = 0x00000040;
const int BEHOLDER_INFLICT_MODERATE_WOUNDS = 0x00000080;
const int BEHOLDER_FINGER_OF_DEATH         = 0x00000100;
const int BEHOLDER_TELEKINESIS             = 0x00000200;
const int BEHOLDER_ALL_RAYS                = 0x000003ff;
struct stBeholder
{
    int nNumOfEyesUsed;
    int nTotalNumOfEyesUsed;
    int nEyes;
};
#include "0i_actions"
//#include "0i_creature"
// Gets the highest class position so we can get the best class of the target.
int GetHighestLevelClass (object oTarget)
{
    int nLevel1 = GetLevelByPosition (1, oTarget);
    int nLevel2 = GetLevelByPosition (2, oTarget);
    int nLevel3 = GetLevelByPosition (3, oTarget);
    if (nLevel1 > nLevel2)
    {
        if (nLevel1 > nLevel3) return 1;
        else return 3;
    }
    else if (nLevel2 > nLevel3) return 2;
    else return 3;
    return 1;
}
// Breaks down the targets class into either warrior or caster.
int GetClassType (int nPosition, object oTarget)
{
    int nClass = GetClassByPosition (nPosition, oTarget);
    if (nClass == CLASS_TYPE_BARBARIAN     || nClass == CLASS_TYPE_FIGHTER ||
        nClass == 45/*CLASS_TYPE_PALADIN*/ || nClass == 43/*CLASS_TYPE_SWASHBUCKLER*/ ||
        nClass == 46/*CLASS_TYPE_RANGER*/  || nClass == CLASS_TYPE_ANIMAL ||
        nClass == CLASS_TYPE_GIANT         || nClass == CLASS_TYPE_HUMANOID ||
        nClass == CLASS_TYPE_VERMIN        || nClass == 29/*oozes*/ ||
        nClass == CLASS_TYPE_MAGICAL_BEAST || nClass == CLASS_TYPE_BEAST ||
        nClass == CLASS_TYPE_BLACKGUARD)
    {
        return CLASS_TYPE_FIGHTER;
    }
    return CLASS_TYPE_WIZARD;
}
int EyeIsReady (int nRay, int nEyes)
{
    //Debug ("ai_beholder", "62", "Eye is ready: Ray: " + IntToString (nRay) +
    //       " nEyes: " + IntToString (nEyes) + " & " + IntToString (nEyes & nRay));
    return (nEyes & nRay);
}
int SetEyeUsed (int nEyes, int nRay)
{
    return nEyes & ~nRay;
}
// Uses the beholders ray: Touch attack with hit or miss mechanics.
int UseBeholderRay (int nSpell, int nRay, int nEyes, object oTarget, string sSpell)
{
    nEyes = SetEyeUsed (nEyes, nRay);
    float fDelay = IntToFloat (d4());
    //Debug ("ai_beholder", "75", GetName (OBJECT_SELF) + " shoots " +
    //       Get2DAString ("spells", "Label", nSpell) + " at " + GetName (oTarget));
    SendMessageToPC(oTarget, ai_AddColorToText(GetName (OBJECT_SELF), AI_COLOR_LIGHT_MAGENTA) +
    ai_AddColorToText(" uses ray of " + sSpell + " on " + GetName (oTarget) + "!", AI_COLOR_DARK_ORANGE));
    if (TouchAttackRanged (oTarget, TRUE) > 0)
    {
         ActionCastSpellAtObject(nSpell, oTarget, 255, TRUE, 0, 0, TRUE);
    }
    else
    {
        location lMiss = GetLocation (oTarget);
        vector vMiss = GetPositionFromLocation (lMiss);
        // If we are too close and change target it might make us turn!
        if (GetDistanceBetween (OBJECT_SELF, oTarget) > 6.0f)
        {

            vMiss.x += IntToFloat (Random (3)) - 1.5;
            vMiss.y += IntToFloat (Random (3)) - 1.5;
            vMiss.z += IntToFloat (Random (2));
            lMiss = Location (GetArea (oTarget), vMiss, 0.0f);
        }
        // Set a variable on the beholder if we miss!
        SetLocalInt (OBJECT_SELF, "0_MISSED", TRUE);
        ActionCastSpellAtLocation (nSpell, lMiss, 255, TRUE, 0, TRUE);
    }
    return nEyes;
}
// Beholder decides which eyes to use against a warrior target.
struct stBeholder DoBeholderRaysvsWarrior(object oTarget, struct stBeholder stBeholder, int nRound)
{
    // Reduce the roll as we use eyes. This should speed up selection.
    int nRoll = d100() - (stBeholder.nTotalNumOfEyesUsed * 10);
    //Debug ("ai_beholder", "107", GetName (OBJECT_SELF) + " shoots rays at " + GetName (oTarget) +
    //       ". nEyes: " + IntToString (stBeholder.nEyes));
    if(nRoll < 7 && EyeIsReady (BEHOLDER_TELEKINESIS, stBeholder.nEyes) &&
        !GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN))
    {
        stBeholder.nEyes = UseBeholderRay (787, BEHOLDER_TELEKINESIS, stBeholder.nEyes, oTarget, "telekinesis");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 14 && EyeIsReady (BEHOLDER_FINGER_OF_DEATH, stBeholder.nEyes) &&
        !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH))
    {
        stBeholder.nEyes = UseBeholderRay (786, BEHOLDER_FINGER_OF_DEATH, stBeholder.nEyes, oTarget, "death");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 21 && EyeIsReady (BEHOLDER_DISINTEGRATE_RAY, stBeholder.nEyes) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_DEATH))
    {
        stBeholder.nEyes = UseBeholderRay (780, BEHOLDER_DISINTEGRATE_RAY, stBeholder.nEyes, oTarget, "disitegrate");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 28 && EyeIsReady (BEHOLDER_FLESH_STONE_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_PETRIFY, oTarget))
    {
        stBeholder.nEyes = UseBeholderRay (779, BEHOLDER_FLESH_STONE_RAY, stBeholder.nEyes, oTarget, "flesh to stone");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 42 && nRound < 3)
    {
        if(EyeIsReady (BEHOLDER_CHARM_PERSON_RAY, stBeholder.nEyes) &&
            AmIAHumanoid(oTarget) &&
            !GetHasEffect (EFFECT_TYPE_CHARMED, oTarget) &&
            !GetIsImmune (oTarget, IMMUNITY_TYPE_CHARM))
        {
            stBeholder.nEyes = UseBeholderRay (776, BEHOLDER_CHARM_PERSON_RAY, stBeholder.nEyes, oTarget, "charm person");
            nRoll = 101; stBeholder.nNumOfEyesUsed ++;
        }
        else if(EyeIsReady (BEHOLDER_CHARM_MONSTER_RAY, stBeholder.nEyes) &&
             !GetHasEffect (EFFECT_TYPE_CHARMED, oTarget) &&
             !GetIsImmune (oTarget, IMMUNITY_TYPE_CHARM))
        {
            stBeholder.nEyes = UseBeholderRay (777, BEHOLDER_CHARM_MONSTER_RAY, stBeholder.nEyes, oTarget, "charm monster");
            nRoll = 101; stBeholder.nNumOfEyesUsed ++;
        }
    }
    if(nRoll < 56 && EyeIsReady (BEHOLDER_SLEEP_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_SLEEP, oTarget) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_SLEEP))
    {
        stBeholder.nEyes = UseBeholderRay (778, BEHOLDER_SLEEP_RAY, stBeholder.nEyes, oTarget, "sleep");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 70 && EyeIsReady (BEHOLDER_FEAR_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_FRIGHTENED, oTarget) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_FEAR))
    {
        stBeholder.nEyes = UseBeholderRay (783, BEHOLDER_FEAR_RAY, stBeholder.nEyes, oTarget, "fear");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 84 && EyeIsReady (BEHOLDER_SLOW_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_SLOW, oTarget) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_SLOW))
    {
        stBeholder.nEyes = UseBeholderRay (784, BEHOLDER_SLOW_RAY, stBeholder.nEyes, oTarget, "slow");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if(nRoll < 101 && EyeIsReady (BEHOLDER_INFLICT_MODERATE_WOUNDS, stBeholder.nEyes))
    {
        stBeholder.nEyes = UseBeholderRay (785, BEHOLDER_INFLICT_MODERATE_WOUNDS, stBeholder.nEyes, oTarget, "wounding");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    //Debug ("ai_beholder", "177", "Number of eyes used: " + IntToString (stBeholder.nNumOfEyesUsed));
    return stBeholder;
}
// Beholder decides which eyes to use against a caster target.
struct stBeholder DoBeholderRaysvsCaster (object oTarget, struct stBeholder stBeholder, int nRound)
{
    // Reduce the roll as we use eyes. This should speed up selection.
    int nRoll = d100() - (stBeholder.nTotalNumOfEyesUsed * 10);
    //Debug ("ai_beholder", "185", GetName (OBJECT_SELF) + " shoots rays at " + GetName (oTarget) +
    //       ". nEyes: " + IntToString (stBeholder.nEyes));
    if (nRoll < 7 && nRound < 3)
    {
        if (EyeIsReady (BEHOLDER_CHARM_PERSON_RAY, stBeholder.nEyes) &&
            AmIAHumanoid(oTarget) &&
            !GetHasEffect (EFFECT_TYPE_CHARMED, oTarget) &&
            !GetIsImmune (oTarget, IMMUNITY_TYPE_CHARM))
        {
            stBeholder.nEyes = UseBeholderRay (776, BEHOLDER_CHARM_PERSON_RAY, stBeholder.nEyes, oTarget, "charm person");
            nRoll = 101; stBeholder.nNumOfEyesUsed ++;
        }
        else if (EyeIsReady (BEHOLDER_CHARM_MONSTER_RAY, stBeholder.nEyes) &&
             !GetHasEffect (EFFECT_TYPE_CHARMED, oTarget) &&
             !GetIsImmune (oTarget, IMMUNITY_TYPE_CHARM))
        {
            stBeholder.nEyes = UseBeholderRay (777, BEHOLDER_CHARM_MONSTER_RAY, stBeholder.nEyes, oTarget, "charm monster");
            nRoll = 101; stBeholder.nNumOfEyesUsed ++;
        }
    }
    if (nRoll < 14 && EyeIsReady (BEHOLDER_SLEEP_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_SLEEP, oTarget) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_SLEEP))
    {
        stBeholder.nEyes = UseBeholderRay (778, BEHOLDER_SLEEP_RAY, stBeholder.nEyes, oTarget, "sleep");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 21 && EyeIsReady (BEHOLDER_FEAR_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_FRIGHTENED, oTarget) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_FEAR))
    {
        stBeholder.nEyes = UseBeholderRay (783, BEHOLDER_FEAR_RAY, stBeholder.nEyes, oTarget, "fear");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 28 && EyeIsReady (BEHOLDER_SLOW_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_SLOW, oTarget) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_SLOW))
    {
        stBeholder.nEyes = UseBeholderRay (784, BEHOLDER_SLOW_RAY, stBeholder.nEyes, oTarget, "slow");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 42 && EyeIsReady (BEHOLDER_TELEKINESIS, stBeholder.nEyes) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_KNOCKDOWN))
    {
        stBeholder.nEyes = UseBeholderRay (787, BEHOLDER_TELEKINESIS, stBeholder.nEyes, oTarget, "telekinesis");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 56 && EyeIsReady (BEHOLDER_FINGER_OF_DEATH, stBeholder.nEyes) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_DEATH))
    {
        stBeholder.nEyes = UseBeholderRay (786, BEHOLDER_FINGER_OF_DEATH, stBeholder.nEyes, oTarget, "death");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 70 && EyeIsReady (BEHOLDER_DISINTEGRATE_RAY, stBeholder.nEyes) &&
        !GetIsImmune (oTarget, IMMUNITY_TYPE_DEATH))
    {
        stBeholder.nEyes = UseBeholderRay (780, BEHOLDER_DISINTEGRATE_RAY, stBeholder.nEyes, oTarget, "disintegrate");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 84 && EyeIsReady (BEHOLDER_FLESH_STONE_RAY, stBeholder.nEyes) &&
        !GetHasEffect (EFFECT_TYPE_PETRIFY, oTarget))
    {
        stBeholder.nEyes = UseBeholderRay (779, BEHOLDER_FLESH_STONE_RAY, stBeholder.nEyes, oTarget, "flesh to stone");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    if (nRoll < 101 && EyeIsReady (BEHOLDER_INFLICT_MODERATE_WOUNDS, stBeholder.nEyes))
    {
        stBeholder.nEyes = UseBeholderRay (785, BEHOLDER_INFLICT_MODERATE_WOUNDS, stBeholder.nEyes, oTarget, "wounding");
        nRoll = 101; stBeholder.nNumOfEyesUsed ++;
    }
    //Debug ("ai_beholder", "255", "Number of eyes used: " + IntToString (stBeholder.nNumOfEyesUsed));
    return stBeholder;
}
void main()
{
    // Get the number of enemies that we are in melee combat with.
    int nMelee = ai_GetNumOfEnemiesInRange(OBJECT_SELF);
    object oNearestEnemy = GetLocalObject (OBJECT_SELF, AI_ENEMY_NEAREST);
    //Debug ("ai_beholder", "263", "*************** " + GetName (OBJECT_SELF) + " ***************");
    //Debug ("ai_beholder", "264", "oNearest Enemy: " + GetName (oNearestEnemy) +
    //       " Distance to Nearest Enemy: " + FloatToString (GetDistanceToObject (oNearestEnemy), 0, 2) +
    //       " Melee: " + IntToString (nMelee));
    //Debug ("ai_beholder", "267", "************* CHOOSING BEHOLDER ACTIONS ***********");
    // Get, increase the round, and then set.
    int nRound = GetLocalInt (OBJECT_SELF, "COMBAT_ROUNDS") + 1;
    SetLocalInt (OBJECT_SELF, "COMBAT_ROUNDS", nRound);
    //Debug ("ai_beholder", "271", " nRound: " + IntToString (nRound));
    //**************************************************************************
    //* 1) Use eye stalks and anti-magic cone.
    //**************************************************************************
    // Check all 4 directions for targets using 3 rays per direction maximum.
    // If we use a ray remove that ray from the options.
    // We will also try to prioritize rays bases on warrior or a caster.
    // It will also stop all magic on any creatures in front of it for 1 round!
    // We assume it shuts its eyes while firing, but then opens for maximum effect!
    int nPosition, nClass;
    struct stBeholder stBeholder;
    // Setup that we can use each eye.
    stBeholder.nEyes = BEHOLDER_ALL_RAYS;
    //**************************************************************************
    //* 1a) Check ahead of the beholder.
    //**************************************************************************
    //Debug ("ai_beholder", "287", "Rays: " + IntToString (stBeholder.nEyes) +
    //       " Get targets ahead of " + GetName (OBJECT_SELF));
    int nSanityCheck, bUseLargeEye;
    location lPoint = GetAheadLocation (OBJECT_SELF);
    effect eEffect;
    object oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
    if(oTarget != OBJECT_INVALID)
    {
        while(oTarget != OBJECT_INVALID)
        {
            // Lets see if we should use our eye stalks in front of us or use our
            // large anti-magic eye instead!
            // Anti-magic eye only blocks casting so only use on casters.
            if(GetIsEnemy(oTarget))
            {
                nPosition = GetHighestLevelClass(oTarget);
                nClass = GetClassType(nPosition, oTarget);
                // They are a magic user type usually we use anti-magic and melee attack.
                if(nClass == CLASS_TYPE_WIZARD)
                {
                    bUseLargeEye = TRUE;
                    break;
                }
            }
            oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
        }
        if(bUseLargeEye)
        {
            oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
            while(oTarget != OBJECT_INVALID)
            {
                // Set all targets in front of it with anti-magic!
                if(!GetLocalInt (oTarget, "0_Anti_Magic"))
                {
                    if(ai_GetIsCharacter(oTarget))
                    {
                        SendMessageToPC(oTarget, ai_AddColorToText(GetName (OBJECT_SELF), AI_COLOR_LIGHT_MAGENTA) +
                        ai_AddColorToText(" gaze places " + GetName (oTarget) + " under an anti-magic effect!", AI_COLOR_DARK_ORANGE));
                    }
                    SetLocalInt(oTarget, "0_Anti_Magic", TRUE);
                    DelayCommand(6.0f, DeleteLocalInt (oTarget, "0_Anti_Magic"));
                }
                oTarget = GetNextObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
            }
        }
        // Use our eye stalks in front of us instead.
        else
        {
            oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
            while(stBeholder.nNumOfEyesUsed < 3)
            {
                if(GetIsEnemy(oTarget))
                {
                    nPosition = GetHighestLevelClass(oTarget);
                    nClass = GetClassType(nPosition, oTarget);
                    // Shoot rays against a warrior!
                    if(nClass == CLASS_TYPE_FIGHTER)
                    {
                        stBeholder = DoBeholderRaysvsWarrior (oTarget, stBeholder, nRound);
                    }
                    // Shoot rays against a caster and uses its Antimagic!
                    else stBeholder = DoBeholderRaysvsCaster (oTarget, stBeholder, nRound);
                }
                oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
                if(oTarget == OBJECT_INVALID)
                {
                    oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
                    if(++nSanityCheck > 5 || oTarget == OBJECT_INVALID) break;
                }
            }
        }
    }
    //**************************************************************************
    //* 1b) Check right of the beholder.
    //**************************************************************************
    //Debug ("ai_beholder", "330", "Rays: " + IntToString (stBeholder.nEyes) +
    //       " Get targets right of " + GetName (OBJECT_SELF));
    stBeholder.nTotalNumOfEyesUsed += stBeholder.nNumOfEyesUsed;
    stBeholder.nNumOfEyesUsed = 0;
    lPoint = GetFlankingRightLocation (OBJECT_SELF);
    oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
    if (oTarget != OBJECT_INVALID)
    {
        while (stBeholder.nNumOfEyesUsed < 3)
        {
            if (GetIsEnemy (oTarget))
            {
                nPosition = GetHighestLevelClass (oTarget);
                nClass = GetClassType (nPosition, oTarget);
                // Shoot rays against a warrior!
                if (nClass == CLASS_TYPE_FIGHTER)
                {
                    stBeholder = DoBeholderRaysvsWarrior (oTarget, stBeholder, nRound);
                }
                // Shoot rays against a caster!
                else stBeholder = DoBeholderRaysvsCaster (oTarget, stBeholder, nRound);
            }
            oTarget = GetNextObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
            if (oTarget == OBJECT_INVALID)
            {
                oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
                if (++nSanityCheck > 8 || oTarget == OBJECT_INVALID) break;
            }
        }
    }
    //**************************************************************************
    //* 1c) Check left of the beholder.
    //**************************************************************************
    //Debug ("ai_beholder", "363", "Rays: " + IntToString (stBeholder.nEyes) +
    //       " Get targets left of " + GetName (OBJECT_SELF));
    stBeholder.nTotalNumOfEyesUsed += stBeholder.nNumOfEyesUsed;
    stBeholder.nNumOfEyesUsed = 0;
    lPoint = GetFlankingLeftLocation (OBJECT_SELF);
    oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
    if (oTarget != OBJECT_INVALID)
    {
        while (stBeholder.nNumOfEyesUsed < 3)
        {
            if (GetIsEnemy (oTarget))
            {
                nPosition = GetHighestLevelClass (oTarget);
                nClass = GetClassType (nPosition, oTarget);
                // Shoot rays against a warrior!
                if (nClass == CLASS_TYPE_FIGHTER)
                {
                    stBeholder = DoBeholderRaysvsWarrior (oTarget, stBeholder, nRound);
                }
                // Shoot rays against a caster!
                else stBeholder = DoBeholderRaysvsCaster (oTarget, stBeholder, nRound);
            }
            oTarget = GetNextObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
            if (oTarget == OBJECT_INVALID)
            {
                oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
                if (++nSanityCheck > 11 || oTarget == OBJECT_INVALID) break;
            }
        }
    }
    //**************************************************************************
    //* 1d) Check behind of the beholder.
    //**************************************************************************
    //Debug ("ai_beholder", "396", "Rays: " + IntToString (stBeholder.nEyes) +
    //       " Get targets behind of " + GetName (OBJECT_SELF));
    stBeholder.nTotalNumOfEyesUsed += stBeholder.nNumOfEyesUsed;
    stBeholder.nNumOfEyesUsed = 0;
    lPoint = GetBehindLocation (OBJECT_SELF);
    oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
    if (oTarget != OBJECT_INVALID)
    {
        while (stBeholder.nNumOfEyesUsed < 3)
        {
            if (GetIsEnemy (oTarget))
            {
                nPosition = GetHighestLevelClass (oTarget);
                nClass = GetClassType (nPosition, oTarget);
                // Shoot rays against a warrior!
                if (nClass == CLASS_TYPE_FIGHTER)
                {
                    stBeholder = DoBeholderRaysvsWarrior (oTarget, stBeholder, nRound);
                }
                // Shoot rays against a caster!
                else stBeholder = DoBeholderRaysvsCaster (oTarget, stBeholder, nRound);
            }
            oTarget = GetNextObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
            if (oTarget == OBJECT_INVALID)
            {
                oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 40.0f, lPoint, TRUE);
                if (++nSanityCheck > 13 || oTarget == OBJECT_INVALID
                // Or if the beholder has used all of the eyes.
                || stBeholder.nEyes == 0) break;
            }
        }
    }
    //**************************************************************************
    //* 1) Check for moral. Use special fleeing so they can still use eye stalks!
    //**************************************************************************
    int nHpPercent = GetPercentageHPLoss(OBJECT_SELF);
    //Debug ("ai_beholder", "432", "nHpPercent: " + IntToString (nHpPercent));
    if (nHpPercent < 50)
    {
        int nDifficulty = 15;
        // Are we below 1/4 hp? Increase Difficulty by 10.
        if (nHpPercent <= 25) nDifficulty += 5;
        int nFlee = GetLocalInt (OBJECT_SELF, "0_FLEEING");
        if (!WillSave (OBJECT_SELF, nDifficulty, SAVING_THROW_TYPE_FEAR, oNearestEnemy) ||
            nFlee > 0)
        {
            SetLocalInt (OBJECT_SELF, "0_FLEEING", 1);
            //Debug ("ai_beholder", "443", "Checkmovement: nMelee: " + IntToString (nMelee) +
            //       " NearestEnemy: " + GetName (oNearestEnemy));
            //******************************************************************
            //* Stay out of combat!
            //******************************************************************
            // Lets make sure we are staying out of combat.
            // Stay 15 meters away from our closest enemy.
            // Lets not be annoying! If we try 2 times then give up and defend yourself.
            //Debug ("ai_beholder", "451", "oNearestEnemy: " + GetName (oNearestEnemy) + " Distance: " +
            //       FloatToString (GetDistanceToObject (oNearestEnemy), 0, 2));
            if (oNearestEnemy != OBJECT_INVALID && GetDistanceToObject (oNearestEnemy) < 15.0f)
            {
                if (nFlee < 4)
                {
                    SetLocalInt (OBJECT_SELF, "0_FLEEING", ++nFlee);
                    //Debug ("ai_beholder", "458", GetName (OBJECT_SELF) + " They are too close, we are fleeing (" +
                    //      IntToString (nFlee) + ")!");
                    ClearAllActions (TRUE);
                    ActionMoveAwayFromObject (oNearestEnemy, TRUE, 20.0);
                } else DeleteLocalInt (OBJECT_SELF, "0_FLEEING");
            }
            return;
        }
    }
    //**************************************************************************
    //* PHYSICAL ATTACKS.
    //**************************************************************************
    //Debug ("ai_beholder", "470", "Lets use an attack!");
    // ************************** Melee feat attacks *************************
    if (ai_TrySneakAttack(OBJECT_SELF, nMelee)) return;
    oTarget = ai_GetNearestTargetForMeleeCombat(OBJECT_SELF, nMelee);
    if (oTarget != OBJECT_INVALID)
    {
        if (ai_TryMeleeTalents(OBJECT_SELF, oTarget)) return;
        //Debug ("ai_beholder", "477", "Do melee attack against " + GetName (oTarget) + "!");
        SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
        ActionAttack (oTarget);
    }
}
