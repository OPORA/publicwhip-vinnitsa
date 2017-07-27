class DivisionInfo < ApplicationRecord
  belongs_to :division

  def self.to_csv
    CSV.generate do |csv|
      csv << self.column_names
      all.each do |mp|
        csv << mp.attributes.values_at(*column_names)
      end
    end
  end

  def attendance_division
    turnout.to_f / possible_turnout if possible_turnout > 0
  end
  def rebellions_fraction
    rebellions.to_f / turnout if turnout > 0
  end

end
