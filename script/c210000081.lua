-- Banishite Recycler
local s,id,o=GetID()
-- c210000081
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--[[
	[SOPT ; OPC]
	Once per turn: You can target 5 cards in either player’s banishment(s); shuffle them into the Deck/Extra Deck,
	then if a card was shuffled into a player’s Main Deck by this effect, that player banishes the top 3 cards of their Deck.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,0,LOCATION_REMOVED,LOCATION_REMOVED,5,nil)
	end

	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_REMOVED,LOCATION_REMOVED,5,5,nil)
end
function s.e2fil(c)
	return not c:IsType(TYPE_FUSION)
	and not c:IsType(TYPE_SYNCHRO)
	and not c:IsType(TYPE_XYZ)
	and not c:IsType(TYPE_LINK)
end
function s.e2evt(e,tp,eg,ep,ev)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()

		local p1=false
		local p2=false

		local sg=tg:Filter(s.e2fil,nil,tp)
		for tc in aux.Next(sg) do
			if tc:GetOwner()==tp then
				p1=true
			else
				p2=true
			end
			if p1 and p2 then break end
		end

		local g1=Duel.GetDecktopGroup(tp,3)
		local g2=Duel.GetDecktopGroup(1-tp,3)

		local fg=Group.CreateGroup()
		if p1 then
			fg=fg:Merge(g1)
		end
		if p2 then
			fg=fg:Merge(g2)
		end

		if fg:GetCount()>0 and fg:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEUP)>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(fg,POS_FACEUP,REASON_COST)
		end
	end
end