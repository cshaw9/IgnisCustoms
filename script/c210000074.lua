-- Banishite Priest
local s,id,o=GetID()
-- c210000074
function s.initial_effect(c)
	--[[
	[HOPT]
	When your opponent activates a Spell/Trap Card, or monster effect (Quick Effect):
	You can banish this card from your hand; negate that effect, and if you do, banish that card.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,(id+0))
	e1:SetCondition(s.e1con)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1con(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	
	return rp==(1-tp)
	and Duel.IsChainNegatable(ev)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.e1evt(e,tp,eg,ep,ev,re)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 then
			local c=e:GetHandler()
			--[[
			[HOPT]
			During your next Standby Phase after this card was banished by this effect:
			You can pay 500 LP;
			add both this card and the card banished by this effect from the banishment(s) to their owner’s hand(s).
			]]--
			local g=Group.CreateGroup()
			g:AddCard(c)
			g:AddCard(eg:GetFirst())
			g:KeepAlive()

			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
			
			local e2=Effect.CreateEffect(c)
			e2:SetCategory(CATEGORY_TOHAND)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e2:SetRange(LOCATION_REMOVED)
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e5:SetHintTiming(0,TIMING_STANDBY_PHASE)
			e2:SetCondition(s.e2con)
			e2:SetCost(s.e2cst)
			e2:SetTarget(s.e2tgt)
			e2:SetOperation(s.e2evt)
			e2:SetLabelObject(g)
			e2:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,1)
			c:RegisterEffect(e2)
		end
	end
end
function s.e2con(e,tp)
	local c=e:GetHandler()

	return c:GetTurnID()~=Duel.GetTurnCount()
	and tp==Duel.GetTurnPlayer()
	and c:GetFlagEffect(id)>0
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,500)
	end

	Duel.PayLPCost(tp,500)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()

	if chk==0 then
		return g:GetCount()==g:Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetCount()
	end
	
	local c=e:GetHandler()

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	
	c:ResetFlagEffect(id)
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
	end
end