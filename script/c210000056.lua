-- Rainbow Realm Blank Canvas
local s,id,o=GetID()
-- c210000056
function s.initial_effect(c)
	--[[
	[Activation]
	Activate only if you control no monsters.
	You cannot Summon/Set monsters until the end of the next turn after this card is activated.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0))
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- If you control no cards, you can activate this card from your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.e2con)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	You can only use 1 of the following effects of “Rainbow Realm Blank Canvas” per turn, and only once that turn.
	• When this card is activated: Reveal 1 “Area” Continuous Trap in your Deck;
	until the End Phase, this card’s name becomes that card’s, and replace this effect with that card’s original effects.
	• You can send this face-up card on the field to the GY; send 1 card your opponent controls to the GY.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,(id+0))
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCost(s.e3cst)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.e1fil(c)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and not c:IsPublic()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_DECK,0,nil)

	if chk==0 then
		return g:GetCount()>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	
	local sg=g:Select(tp,1,1,nil)
	local code=g:GetFirst():GetOriginalCodeRule()
	e:SetLabel(code)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local e1a1=Effect.CreateEffect(c)
	e1a1:SetType(EFFECT_TYPE_FIELD)
	e1a1:SetCode(EFFECT_CANNOT_SUMMON)
	e1a1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a1:SetTargetRange(1,0)
	e1a1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1a1,tp)

	local e1a2=Effect.CreateEffect(c)
	e1a2:SetType(EFFECT_TYPE_FIELD)
	e1a2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e1a2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a2:SetTargetRange(1,0)
	e1a2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1a2,tp)

	local e1a3=Effect.CreateEffect(c)
	e1a3:SetType(EFFECT_TYPE_FIELD)
	e1a3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1a3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a3:SetTargetRange(1,0)
	e1a3:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1a3,tp)

	local e1a4=Effect.CreateEffect(c)
	e1a4:SetType(EFFECT_TYPE_FIELD)
	e1a4:SetCode(EFFECT_CANNOT_MSET)
	e1a4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a4:SetTargetRange(1,0)
	e1a4:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1a4,tp)

	local code=e:GetLabel()

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1b:SetCode(EFFECT_CHANGE_CODE)
	e1b:SetValue(code)
	c:RegisterEffect(e1b)

	c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
end
function s.e2con(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
function s.e3fil(c)
	return c:IsAbleToGrave()
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFaceup()
		and c:IsAbleToGraveAsCost()
		and c:IsStatus(STATUS_EFFECT_ENABLED)
	end
	
	Duel.SendtoGrave(c,REASON_COST)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroup(s.e3fil,tp,0,LOCATION_ONFIELD,nil):GetCount()>0
	end
end
function s.e3evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end