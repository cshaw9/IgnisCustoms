-- Banishite Queen
local s,id,o=GetID()
-- c210000067
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control “Banishite King”: You can Special Summon this card from your hand or banishment.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	e1:SetCountLimit(1,(id+0))
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	During your Draw Phase, while this card is banished, instead of conducting your normal draw: You can draw 2 cards.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	c:RegisterEffect(e2)
end
function s.e1con(e,tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210000066),tp,LOCATION_MZONE,0,1,nil)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e1evt(e,tp)
	Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.e2con(e,tp)
	return tp==Duel.GetTurnPlayer()
	and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
	and Duel.GetDrawCount(tp)>0
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
	end

	local c=e:GetHandler()
	local dt=Duel.GetDrawCount(tp)

	if dt~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(2)
		Duel.RegisterEffect(e1,tp)
	end
end