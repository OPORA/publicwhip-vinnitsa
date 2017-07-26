class SumisneHolosuvanniaController < ApplicationController
  def init
     if params[:month].nil? or params[:month].blank?
       params[:month] = "full"
     end
    if params[:party].nil? or params[:party].blank?
      params[:party] = "Блок Петра Порошенка"
    end
     @party = VoteFaction.pluck(:faction).uniq
     @month = VoteFaction.order(date: :desc).pluck(:date).uniq
  end
  def api
    party = VoteFaction.pluck(:faction).uniq
    if params[:month] == "full"
       @vote = VoteFaction.order(vote_aye: :desc).map{|v| {faction: v.faction, date: v.date.strftime('%Y-%m'), vote_aye: v.vote_aye}}
    else
       @vote = VoteFaction.where(date: Date.strptime(params[:month], '%Y-%m')).order(vote_aye: :desc).map{|v| {faction: v.faction, date: v.date.strftime('%Y-%m'), vote_aye: v.vote_aye}}
    end
    vote_party = @vote.map{|p| p[:faction]}
    party_not_voted = party.find_all{|v| vote_party.include?(v) == false }
    unless party_not_voted.blank?
    @vote =  @vote + party_not_voted.map{|p| {faction: p, date: @vote.last[:date], vote_aye: 0} }
    end
    render :json => @vote
  end
end
