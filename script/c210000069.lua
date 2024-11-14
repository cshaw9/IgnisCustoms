-- Banishite Knight
local s,id,o=GetID()
-- c210000069
function s.initial_effect(c)
	-- If this card would be sent to the GY, banish it instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(0xff,0xff)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	--e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--[[
	if not s.global_check then
		s.global_check=true

		local e1b=Effect.GlobalEffect()
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e1b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e1b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e1b,0)
	end
	]]--
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can Special Summon 1 “Banishite” monster from your hand.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
	You can Special Summon 1 “Banishite King” from your Deck or banishment.
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
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e1tgt(e,c)
	return Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.e2fil(c,e,tp)
	return c:IsSetCard(0xce3)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND,0,1,1,nil,e,tp)

	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e3fil(c,e,tp)
	return c:IsCode(210000066)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)

	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end