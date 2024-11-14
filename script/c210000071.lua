-- Banishite Lord
local s,id,o=GetID()
-- c210000071
function s.initial_effect(c)
	-- Any card sent to the GY is banished instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If you control “Banishite Lady”: You can Special Summon this card from your hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can add 1 “Banishite” Spell/Trap from your Deck to your hand.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCountLimit(1,(id+0))
	e3a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3a:SetTarget(s.e3tgt)
	e3a:SetOperation(s.e3evt)
	c:RegisterEffect(e3a)

	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
	--[[
	[HOPT]
	When a monster on the field activates its effect (Quick Effect):
	You can banish this card you control (until the End Phase); negate that effect.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,(id+1))
	e4:SetCondition(s.e4con)
	e4:SetCost(s.e4cst)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e1tgt(e,c)
	return Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.e2con(e,tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210000072),tp,LOCATION_MZONE,0,1,nil)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.e3fil(c)
	return c:IsSetCard(0xce3)
	and c:IsSpellTrap()
	and c:IsAbleToHand()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e4con(e,tp,eg,ep,ev,re)
	return re:IsMonsterEffect()
	and re:GetActivateLocation()==LOCATION_MZONE
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end

	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e4b=Effect.CreateEffect(c)
		e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4b:SetCode(EVENT_PHASE+PHASE_END)
		e4b:SetReset(RESET_PHASE+PHASE_END)
		e4b:SetCountLimit(1)
		e4b:SetLabelObject(c)
		e4b:SetOperation(s.e4bevt)
		Duel.RegisterEffect(e4b,tp)
	end
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.e4evt(e,tp,eg,ep,ev)
	Duel.NegateEffect(ev)
end
function s.e4bevt(e)
	Duel.ReturnToField(e:GetLabelObject())
end