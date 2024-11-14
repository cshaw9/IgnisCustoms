-- Banishite Dragon Rider
local s,id,o=GetID()
-- c210000065
function s.initial_effect(c)
	-- All Illusion monsters on the field gain 100 ATK/DEF for each card in the banishments, except “Banishite Dragon Rider”.
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1a:SetTarget(s.e1fil1)
	e1a:SetValue(s.e1val)
	c:RegisterEffect(e1a)

	local e1b=e1a:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned: You can add 1 “Banishite King” from your Deck to your hand.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,(id+0))
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2a:SetTarget(s.e2tgt)
	e2a:SetOperation(s.e2evt)
	c:RegisterEffect(e2a)

	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--[[
	[HOPT]
	If this card is banished:
	You can Special Summon 1 “Banishite Dragon” from your hand or Deck in Attack Position, ignoring its Summoning conditions.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,(id+1))
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1fil1(c)
	return s:IsRace(RACE_ILLUSION)
end
function s.e1fil2(c)
	return not c:IsCode(id)
end
function s.e1val()
	return Duel.GetMatchingGroup(s.e1fil2,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil):GetCount()*100
end
function s.e2fil(c)
	return c:IsCode(210000066)
	and c:IsAbleToHand()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e3fil(c,e,tp)
	return c:IsCode(210000064)
	and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)

	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_ATTACK)
	end
end