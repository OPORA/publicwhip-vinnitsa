class Vote < ApplicationRecord
  belongs_to :division
  belongs_to :mp, primary_key: :id, foreign_key: :deputy_id
  def self.find_mp(id)
    find_by(deputy_id: id ).vote
  end
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |d|
        csv << d.attributes.values_at(*column_names)
      end
    end
  end

  def self.to_div_csv
    CSV.generate do |csv|
      attrib_first = %w{date number name clock_time result}
      csv << attrib_first + %w{full_name vote}
      all.each do |d|
        csv <<  [ d.division.date, d.division.number, d.division.name, d.division.clock_time, d.division.result, d.mp.full_name, d.vote ]
      end
    end
  end
end
