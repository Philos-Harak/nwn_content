/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_tool_str_cmbt
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Spell script that starts combat in a 50 x 50 meter area of the DM.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
/*#include "0i_area"
#include "0i_creature"

void main()
{
    // Get Permanent faction and change to it.
    int nPermanent_Faction, nCurrent_Faction, nCounter = 1;
    location lTarget = GetLocation (OBJECT_SELF);
    object oNeutralFaction = GetObjectByTag ("neutral_faction");
    object oCreature = GetFirstObjectInShape (SHAPE_SPHERE, 50.0f, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while (oCreature != OBJECT_INVALID)
    {
        // See if they have a set faction.
        if (!GetIsPC (oCreature) &&
            !GetIsDead (oCreature) &&
            GetLocalInt (oCreature, PC_ASSOCIATE_TYPE) == 0 &&
            !GetIsDMPossessed (oCreature))
        {
            nPermanent_Faction = GetLocalInt (oCreature, "0_PermanentFaction");
            nCurrent_Faction = GetLocalInt (oCreature, "0_CurrentFaction");
            if (nPermanent_Faction == STANDARD_FACTION_HOSTILE && nCurrent_Faction != STANDARD_FACTION_HOSTILE)
            {
                AssignCommand (oCreature, SpeakString (AddColorToText ("Turns hostile!", COLOR_RED)));
                ChangeToStandardFaction (oCreature, STANDARD_FACTION_HOSTILE);
                SetLocalInt (oCreature, "0_CurrentFaction", STANDARD_FACTION_HOSTILE);
            }
            else if (nPermanent_Faction == STANDARD_FACTION_COMMONER && nCurrent_Faction != STANDARD_FACTION_COMMONER)
            {
                ChangeToStandardFaction (oCreature, STANDARD_FACTION_COMMONER);
                SetLocalInt (oCreature, "0_CurrentFaction", STANDARD_FACTION_COMMONER);
            }
            else if (nPermanent_Faction == STANDARD_FACTION_MERCHANT  && nCurrent_Faction != STANDARD_FACTION_MERCHANT)
            {
                ChangeToStandardFaction (oCreature, STANDARD_FACTION_MERCHANT);
                SetLocalInt (oCreature, "0_CurrentFaction", STANDARD_FACTION_MERCHANT);
            }
            else if (nPermanent_Faction == STANDARD_FACTION_DEFENDER && nCurrent_Faction != STANDARD_FACTION_DEFENDER)
            {
                ChangeToStandardFaction (oCreature, STANDARD_FACTION_DEFENDER);
                SetLocalInt (oCreature, "0_CurrentFaction", STANDARD_FACTION_DEFENDER);
            }
            else if (nPermanent_Faction == 4/*FACTION_NEUTRAL*/// && nCurrent_Faction != 4/*FACTION_NEUTRAL*/)
         /*  {
                ChangeFaction (oCreature, oNeutralFaction);
                SetLocalInt (oCreature, "0_CurrentFaction", 4);
            }
            // Make all creatures perceptions fire.
            AssignCommand (oCreature, DoMonsterCombatRound ());
        }
        nCounter ++;
        oCreature = GetNextObjectInShape (SHAPE_SPHERE, 50.0f, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
}

