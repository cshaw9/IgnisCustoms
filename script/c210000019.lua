--Apus, The Polygod Paradise
local s,id,o=GetID()
-- c210000019
function s.initial_effect(c)
	--[[
	Cannot be Normal Summoned/Set.
	Must be Special Summoned (from your hand or banishment) by having 8 or more “Polygod” cards with different names in your banishment, except “Apus, The Polygod Paradise”, and cannot be Special Summoned by other ways.
	]]--
	c:EnableReviveLimit()
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1b)
	-- If this card would be sent to the GY, banish it instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.e2con)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

	if not s.global_check then
		s.global_check=true

		local e2b=Effect.GlobalEffect()
		e2b:SetType(EFFECT_TYPE_FIELD)
		e2b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e2b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e2b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e2b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e2b,0)
	end
	-- While “Polyworld” is face-up on the field, this card is unaffected by other cards’ effects.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.e3con)
	e3:SetValue(s.e3fil)
	c:RegisterEffect(e3)
	--[[
	[SOPT]
	Once per turn: You can shuffle all other cards on the field and in the banishments into the Deck.
	This card cannot attack during the turn you activate this effect.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.e4con)
	e4:SetCost(s.e4cst)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	When your opponent activates a card or effect (Quick Effect): You can banish 1 card from your opponent’s hand, field, or GY.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,(id+0))
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
function s.e1fil(c)
	return c:IsSetCard(0xce1)
	and not c:IsCode(id)
end
function s.e1con(e,c)
	if c==nil then return true end
	local tp=c:GetControler()

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return false end

	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>7
end
function s.e2con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e3con(e)
	return Duel.IsEnvironment(210000020)
end
function s.e3fil(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.e4fil(c)
	return not c:IsCode(id)
end
function s.e4con(e)
	return Duel.IsExistingMatchingCard(s.e4fil,0,LOCATION_ONFIELD+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_REMOVED,1,e:GetHandler())
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return c:GetAttackAnnouncedCount()==0
	end
	
	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_SINGLE)
	e4b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e4b:SetCode(EFFECT_CANNOT_ATTACK)
	e4b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e4b)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	end

	local tg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
function s.e4evt(e,tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_REMOVED,e:GetHandler())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.e5con(e,tp,eg,ep)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and ep==(1-tp)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)

	if chk==0 then
		return g:GetCount()>0
	end

	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.e5evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE):Select(tp,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end