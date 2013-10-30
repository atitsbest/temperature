class Measurement < ActiveRecord::Base
  validates_presence_of :sensor, :value, :created_at

  # Als CSV String.
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |measure|
        csv << measure.attributes.values_at(*column_names)
      end
    end
  end
end
