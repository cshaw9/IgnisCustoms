-- Banishite Lady
local s,id,o=GetID()
-- c210000072
function s.initial_effect(c)
	-- Cannot be destroyed by battle.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[
	While there is another “Banishite” monster on the field,
	your opponent cannot target this card with card effects.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.e2con)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- Any card sent from your field to the GY is banished instead.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.e3tgt)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can add 1 “Banishite” monster from your Deck to your hand, except “Banishite Lady”.
	]]--
	local e4a=Effect.CreateEffect(c)
	e4a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4a:SetCode(EVENT_SUMMON_SUCCESS)
	e4a:SetRange(LOCATION_MZONE)
	e4a:SetCountLimit(1,{id,0})
	e4a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4a:SetTarget(s.e4tgt)
	e4a:SetOperation(s.e4evt)
	c:RegisterEffect(e4a)

	local e4b=e4a:Clone()
	e4b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4b)
	--[[
	During your Draw Phase, instead of conducting your normal draw:
	You can add 1 card from your banishment to your hand.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PREDRAW)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
function s.e2con(e)
	local c=e:GetHandler()
	local tp=g:GetHandlerPlayer()

	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xce3),tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.e3tgt(e,c)
	return Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.e4fil(c)
	return c:IsSetCard(0xce3)
	and c:IsMonster()
	and not c:IsCode(id)
	and c:IsAbleToHand()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e4evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e5con(e,tp)
	return tp==Duel.GetTurnPlayer()
	and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
	and Duel.GetDrawCount(tp)>0
end
function s.e5fil(c)
	return c:IsAbleToHand()
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e5fil,tp,LOCATION_REMOVED,0,1,nil)
	end

	local c=e:GetHandler()
	local dt=Duel.GetDrawCount(tp)

	if dt~=0 then
		local e5b=Effect.CreateEffect(c)
		e5b:SetType(EFFECT_TYPE_FIELD)
		e5b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5b:SetCode(EFFECT_DRAW_COUNT)
		e5b:SetTargetRange(1,0)
		e5b:SetReset(RESET_PHASE+PHASE_DRAW)
		e5b:SetValue(0)
		Duel.RegisterEffect(e5b,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.e5evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.e5fil,tp,LOCATION_REMOVED,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end