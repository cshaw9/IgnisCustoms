-- Rainbow Realm Mirroring
local s,id,o=GetID()
-- c210000053
function s.initial_effect(c)
	--[[
	[HOPT]
	Reveal any number of “Area” Continuous Traps in your hand;
	draw cards equal to the number of revealed cards + 1,
	and if you do, place the revealed cards on the bottom of the Deck in any order.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0)+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and not c:IsPublic()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_HAND,0,nil)

	if chk==0 then
		return g:GetCount()>0
		and Duel.IsPlayerCanDraw(tp,2)
	end

	local max=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if max>(g:GetCount()+1) then
		max=g:GetCount()+1
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	
	local sel=g:Select(tp,1,max-1,nil)
	sel:KeepAlive()
	e:SetLabelObject(sel)

	Duel.ConfirmCards(1-tp,sel)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,sel:GetCount()+1)
end
function s.e1evt(e,tp)
	local tg=e:GetLabelObject()

	if tg and Duel.Draw(tp,tg:GetCount()+1,REASON_EFFECT)>0 then
		local rt=Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if rt==0 then return end
		Duel.SortDeckbottom(tp,tp,rt)
	end
end