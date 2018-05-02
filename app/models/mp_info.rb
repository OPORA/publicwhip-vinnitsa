class MpInfo < ApplicationRecord
  belongs_to :mp, primary_key: :id, foreign_key: :deputy_id
  def rebellions_fraction
    unless rebellions.nil?
      rebellions.to_f / votes_attended if votes_attended > 0
    else
     return nil
    end
  end
  def attendance_fraction
    votes_attended.to_f / votes_possible if votes_possible > 0
  end
  def self.mp_to_csv
    CSV.generate do |csv|
      attrib_first = %w{faction}
      attrib = %w{rebellions not_voted	absent	against	aye_voted	abstain	votes_possible	votes_attended date_mp_info}
      csv << attrib_first + %w{full_name}  + attrib
      all.each do |mp|
        csv << [mp.mp.faction] + [mp.mp.full_name] + mp.attributes.values_at(*attrib)
      end
    end
  end
end
