--Machina, The Great Polygod Machine
local s,id,o=GetID()
-- c210000042
function s.initial_effect(c)
	-- 3 Level 4 “Polygod” monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),4,3)
	c:EnableReviveLimit()
	-- Gains DEF equal to the number of materials attached to this card x 1000.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	--[[
	[SOPT]
	Once per turn, if your opponent has no cards in their banishment (Quick Effect):
	You can detach 1 material from this card; skip your opponent’s next Main Phase 1.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_DRAW_PHASE)
	e2:SetCondition(s.e2con)
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	During your Main Phase, if your opponent has cards in their banishment, while this card is in face-up Defense Position:
	You can change this card to Attack Position, and if you do, shuffle all cards in your opponent’s banishment into the Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1val(e,c)
	return c:GetOverlayCount()*1000
end
function s.e2con(e,tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	return g:GetCount()<=0
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_M1)
	end
end
function s.e2evt(e,tp)
	local e2b=Effect.CreateEffect(e:GetHandler())
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_SKIP_M1)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2b:SetTargetRange(0,1)

	if Duel.GetTurnPlayer()==1-tp then
		e2b:SetLabel(Duel.GetTurnCount())
		e2b:SetCondition(s.e2bcon)
		e2b:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e2b:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end

	Duel.RegisterEffect(e2b,tp)
end
function s.e2bcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.e3con(e,tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	
	return e:GetHandler():IsDefensePos()
	and g:GetCount()>0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_REMOVED)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	if c:IsDefensePos() then
		local req=true

		local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
		if repl:GetCount()>0 then
			if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
				Duel.ChangePosition(c,POS_FACEUP_ATTACK)
			end
		else
			req=Duel.ChangePosition(c,POS_FACEUP_ATTACK)>0
		end

		if req then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
			if g:GetCount()>=1 then
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end