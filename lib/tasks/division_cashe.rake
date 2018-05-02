namespace :division_cashe do
  desc "Update party statistick"
  task whip: :environment do
    Division.all.find_each do |d|
      Vote.joins(:mp).where(division_id: d.id).to_a.group_by{|m| m.mp.faction}.each do |f|
        division = d.id
        faction = f[0]
        hash = {
            not_voted: f[1].count{|v| v.vote == "not_voted"},
            absent: f[1].count{|v| v.vote == "absent"},
            against: f[1].count{|v| v.vote == "against"},
            aye: f[1].count{|v| v.vote == "aye"},
            abstain: f[1].count{|v| v.vote == "abstain"}
        }
        whip_guess = hash.sort_by{|k,v| v}.last.first.to_s
        whip = Whip.find_or_initialize_by(division_id: division, party: faction)
        whip.aye_votes = hash[:aye]
        whip.no_votes = hash[:not_voted]
        whip.absent = hash[:absent]
        whip.against = hash[:against]
        whip.abstain = hash[:abstain]
        whip.whip_guess = whip_guess
        whip.save
      end
    end
  end

  desc "Update division statistic"
  task info: :environment do
    Division.all.find_each do |d|
      division = d.id
      v =  Vote.joins(:mp).where(division_id: d.id).map {|v| v}
      hash = {
          not_voted: v.count{|v| v.vote == "not_voted"},
          absent: v.count{|v| v.vote == "absent"},
          against: v.count{|v| v.vote == "against"},
          aye: v.count{|v| v.vote == "aye"},
          abstain: v.count{|v| v.vote == "abstain"}
      }
      possible_turnout = hash.sum{|k,v| v}
      turnout = possible_turnout - hash[:absent]
      rebellions = []
      v.group_by{|m| m.mp.faction}.each do |f|
        whip_guess = Whip.find_by(party: f[0], division_id: division).whip_guess
        rebellions << f[1].count{|v| v.vote != whip_guess and v.vote != "absent"}
      end
      division_info = DivisionInfo.find_or_initialize_by(division_id: division)
      division_info.aye_votes = hash[:aye]
      division_info.no_votes = hash[:not_voted]
      division_info.absent = hash[:absent]
      division_info.against = hash[:against]
      division_info.abstain = hash[:abstain]
      division_info.possible_turnout = possible_turnout
      division_info.turnout = turnout
      division_info.rebellions = rebellions.sum
      division_info.save
    end
  end
  desc "Cache party voted aye 50%+1"
  task party_voted: :environment do
    p "Start aye_votes"
    Whip.all.find_each do |w|
      p w.division_id
      size = (w.aye_votes + w.no_votes + w.absent + w.against + w.abstain)/2+1
      if w.aye_votes >= size
        VoteFaction.find_or_create_by(faction: w.party, division_id: w.division_id, aye: true)
      end
    end
    p "End aye_votes"
    p "Start Party Frends"
    Division.all.to_a.group_by{|d| d.date.strftime("%Y-%m")}.each do |d|
      date = d[0]
      p date
      vote_id =  d[1].map{|v| v.id }
      p  vote_id
      Mp.pluck(:faction).uniq do |m1|
        p m1
        sql = %Q{
       SELECT
        votes2.faction, count(*)
       FROM
        public.vote_factions AS votes1
       LEFT JOIN
        public.vote_factions AS votes2 ON votes1.division_id = votes2.division_id AND votes1.aye = votes2.aye AND votes1.faction != votes2.faction
       WHERE
        votes1.faction = \'#{m1}\' AND votes1.division_id IN (#{vote_id.join(',')}) AND votes2.faction is not null
       GROUP BY
        votes2.faction
        }
        ActiveRecord::Base.connection.execute(sql).each do |q|
          p q
          friends = PartyFriend.find_or_initialize_by(party:  m1, friend_party: q["faction"], date_party_friend:  Date.strptime(date, '%Y-%m') )
          friends.count = q["count"]
          friends.save
          p friends
        end
      end
    end
    p "End party friends"
  end
end
