namespace :deputi_cashe do
  desc "Update mp cashe"
  task mp_month: :environment do

    Division.all.to_a.group_by{|d| d.date.strftime("%Y-%m")}.each do |d|
      date = d[0]
      vote_id =  d[1].map{|v| v.id }
      date_query = Date.strptime(date, "%Y-%m")
      mp = Mp.where("? >= start_date and end_date > ?", date_query, date_query)
      mp.each do |m|
        if mp.where(faction: m.faction).count >= 5
          rebellions_month = Division.joins(:whips, :votes).where('votes.deputy_id = ? and votes.division_id  in (?)', m.id, vote_id ).where('whips.party = ?', m.faction).where("votes.vote != 'absent'").where('votes.vote != whips.whip_guess').count
        else
          rebellions_month = nil
        end
        v_month =  Vote.where(deputy_id: m.id, division_id: vote_id ).map {|v| v}

        hash_month = {
            not_voted: v_month.count{|v| v.vote == "not_voted"},
            absent: v_month.count{|v| v.vote == "absent"},
            against: v_month.count{|v| v.vote == "against"},
            aye: v_month.count{|v| v.vote == "aye"},
            abstain: v_month.count{|v| v.vote == "abstain"}
        }
        p m.deputy_id
        p m.full_name
        p hash_month
        votes_possible_month = hash_month.sum{|k,v| v}
        votes_attended_month = votes_possible_month - hash_month[:absent]
        save_update_mp_ifo(m.id, Date.strptime(date, '%Y-%m'), rebellions_month, hash_month[:not_voted], hash_month[:absent], hash_month[:against],hash_month[:aye], hash_month[:abstain], votes_possible_month, votes_attended_month)
      end
    end
  end
  desc "Update mp cashe"
  task mp: :environment do
    @mp = Mp.all
      @mp.each do |m|
      if Mp.where(faction: m.faction, end_date: '9999-12-31').count >= 5
        rebellions = Division.joins(:whips, :votes).where('votes.deputy_id = ?', m.id ).where('whips.party = ?', m.faction).where("votes.vote != 'absent'").where('votes.vote != whips.whip_guess').count
      else
        rebellions = nil
      end
      v =  Vote.where(deputy_id: m.id).map {|v| v}
      hash = {
          not_voted: v.count{|v| v.vote == "not_voted"},
          absent: v.count{|v| v.vote == "absent"},
          against: v.count{|v| v.vote == "against"},
          aye: v.count{|v| v.vote == "aye"},
          abstain: v.count{|v| v.vote == "abstain"}
      }
      votes_possible = hash.sum{|k,v| v}
      votes_attended = votes_possible - hash[:absent]
      save_update_mp_ifo(m.id, '9999-12-31', rebellions, hash[:not_voted], hash[:absent], hash[:against],hash[:aye], hash[:abstain], votes_possible, votes_attended)
      end
  end
  desc "Update mp friend cashe"
  task friends_month: :environment do
    mps = Mp.distinct.pluck(:id)
    Division.all.to_a.group_by{|d| d.date.strftime("%Y-%m")}.each do |d|
      date = d[0]
      vote_id =  d[1].map{|v| v.id }
      mps.each do |m1|
        sql = %Q{

      SELECT
          mps2.id, count(*)
         FROM
          public.votes AS votes1
         LEFT JOIN
          public.votes AS votes2 ON votes1.division_id = votes2.division_id AND votes1.vote = votes2.vote AND votes1.deputy_id != votes2.deputy_id
         LEFT JOIN
          public.mps AS mps1 ON  votes1.deputy_id =  mps1.id
         LEFT JOIN
          public.mps AS mps2 ON  votes2.deputy_id =  mps2.id
         WHERE
           mps1.id = #{m1} AND votes1.division_id IN (#{vote_id.join(',')}) AND votes2.deputy_id is not null AND votes1.vote != 'absent'
         GROUP BY
          mps2.id
        }
        ActiveRecord::Base.connection.execute(sql).each do |q|
          p q
          friend = MpFriend.find_or_initialize_by(deputy_id:  m1, friend_deputy_id: q["id"], date_mp_friend:  Date.strptime(date, '%Y-%m') )
          friend.count = q["count"]
          friend.save
          p friend
        end
      end
    end
  end
  desc "Update mp friend cashe"
  task friends: :environment do
    mps = Mp.distinct.pluck(:id)
        mps.each do |m1|
         sql = %Q{
         SELECT
          mps2.id, count(*)
         FROM
          public.votes AS votes1
         LEFT JOIN
          public.votes AS votes2 ON votes1.division_id = votes2.division_id AND votes1.vote = votes2.vote AND votes1.deputy_id != votes2.deputy_id
         LEFT JOIN
          public.mps AS mps1 ON  votes1.deputy_id =  mps1.id
         LEFT JOIN
          public.mps AS mps2 ON  votes2.deputy_id =  mps2.id
         WHERE
           mps1.id = #{m1}  AND votes2.deputy_id is not null AND votes1.vote != 'absent'
         GROUP BY
          mps2.id
          }
          ActiveRecord::Base.connection.execute(sql).each do |q|
            p q
            friend = MpFriend.find_or_initialize_by(deputy_id:  m1, friend_deputy_id: q["id"], date_mp_friend: "9999-12-31")
            friend.count = q["count"]
            friend.save
            p friend
          end
    end


  end
  def save_update_mp_ifo(deputy_id, date, rebellions, not_voted, absent, against, aye, abstain, votes_possible, votes_attended)
    mp_info = MpInfo.find_or_initialize_by(deputy_id: deputy_id, date_mp_info: date)
    mp_info.rebellions = rebellions
    mp_info.not_voted = not_voted
    mp_info.absent = absent
    mp_info.against = against
    mp_info.aye_voted = aye
    mp_info.abstain = abstain
    mp_info.votes_possible = votes_possible
    mp_info.votes_attended = votes_attended
    mp_info.save
    p mp_info
  end
end
