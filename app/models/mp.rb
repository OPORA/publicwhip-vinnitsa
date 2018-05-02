class Mp < ApplicationRecord
  has_many :votes
  has_many :divisions, through: :votes
  has_many :mp_friends, primary_key: :id, foreign_key: :deputy_id
  has_one :mp_info, primary_key: :id, foreign_key: :deputy_id
  has_many :mp_infos, primary_key: :id, foreign_key: :deputy_id

  def url_name
    self.last_name + "_" + self.first_name + "_" + self.middle_name
  end
  def full_name
    self.last_name + " " + self.first_name + " " + self.middle_name
  end
  def short_name
    self.first_name + " " + self.last_name
  end
  def self.find_by_search_query(query)
    where("UPPER(CONCAT (Last_name, ' ', first_name, ' ', middle_name)) like :query or UPPER(faction) like :query ", query: "%#{query.gsub(/(\s|\.)/,'%').upcase}%" )
  end
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |mp|
        csv << mp.attributes.values_at(*column_names)
      end
    end
  end
end
