-- Rainbow Realm of Doom
local s,id,o=GetID()
-- c210000046
function s.initial_effect(c)
	-- When this card and 5 “Area” Continuous Trap Cards with different names are face-up on your field, you win the Duel.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(LOCATION_FZONE)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.e0evt)
	c:RegisterEffect(e0)
	-- [Activation]
	-- Activate this card by sending all monsters you control to the GY (min. 0).
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.e1cst)
	c:RegisterEffect(e1)
	-- While this card is face-up on the field, you cannot Summon/Set monsters.
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_SUMMON)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,0)
	c:RegisterEffect(e2a)

	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2b:SetTargetRange(1,0)
	c:RegisterEffect(e2b)

	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_FIELD)
	e2c:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2c:SetRange(LOCATION_FZONE)
	e2c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2c:SetTargetRange(1,0)
	c:RegisterEffect(e2c)

	local e2d=Effect.CreateEffect(c)
	e2d:SetType(EFFECT_TYPE_FIELD)
	e2d:SetCode(EFFECT_CANNOT_MSET)
	e2d:SetRange(LOCATION_FZONE)
	e2d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2d:SetTargetRange(1,0)
	c:RegisterEffect(e2d)
	-- If this face-up card in the Field Zone is destroyed or banished: Send all Spell/Traps on the field to the GY.
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3a:SetCode(EVENT_DESTROYED)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCondition(s.e3con)
	e3a:SetTarget(s.e3tgt)
	e3a:SetOperation(s.e3evt)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3b:SetCode(EVENT_REMOVE)
	e3b:SetProperty(EFFECT_FLAG_DELAY)
	e3b:SetCondition(s.e3con)
	e3b:SetTarget(s.e3tgt)
	e3b:SetOperation(s.e3evt)
	c:RegisterEffect(e3b)
	--[[
	[SOPT]
	Once per turn, during your End Phase: You can Set 1 "Area" Continuous Trap Card from your hand, Deck, or GY.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e0fil(c)
	return c:IsFaceup()
	and c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
end
function s.e0evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e0fil,tp,LOCATION_ONFIELD,0,nil)
	if g:GetClassCount(Card.GetCode)>=5 then
		Duel.Win(tp,WIN_REASON_DESTINY_BOARD)
	end
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.e3con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_FZONE)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_SZONE+LOCATION_FZONE,LOCATION_SZONE+LOCATION_FZONE)
	
	if chk==0 then
		return g:GetCount()>0
	end

	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function s.e3evt(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_SZONE+LOCATION_FZONE,LOCATION_SZONE+LOCATION_FZONE)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.e4fil(c)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and not c:IsForbidden()
end
function s.e4con(e,tp)
	return tp==Duel.GetTurnPlayer()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>=1
	end
end
function s.e4evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
	end
end