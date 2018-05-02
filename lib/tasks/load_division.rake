namespace :load_division do
  desc "Load votes"
  task :votes, [:from_date, :to_date] => :environment do |t, args|
    load_votes = JSON.load(open('http://vinnitsavoted.oporaua.org/votes_events'))
    save_votes = Division.pluck(:date).uniq.to_a.map{|d| d.strftime('%Y-%m-%d')}
    date_votes = load_votes - save_votes
    date_votes.each do |date|
      encoded_url = URI.encode(date)
      uri = URI.parse(encoded_url)
      divisions = JSON.load(open("http://vinnitsavoted.oporaua.org/votes_events/#{uri}"))
      divisions.each do |d|
            if DateTime.parse(d[0]["date_vote"]).strftime("%F") == "1899-12-30"
              date_vote = "2016-12-30"
            else
              date_vote =  DateTime.parse(d[0]["date_vote"]).strftime("%F")
            end
            mps =  Mp.where("? >= start_date and end_date >= ?", date_vote, date_vote).to_a.uniq(&:deputy_id)
        division = Division.find_or_create_by(
            date: date_vote,
            number: d[0]["number"],
            name: d[0]["name"],
            clock_time: DateTime.parse(d[0]["date_vote"]).strftime("%T"),
            result: d[0]["option"]
        )
        division.votes.destroy_all
        d[1]["votes"].each do |v|
          next if v["voter_id"] == 1004
          p v["voter_id"]
          mp = mps.find{|m| m["deputy_id"] == v["voter_id"] }.id
          division.votes.create(deputy_id: mp, vote: v["result"] )
        end
      end
    end
  end
end
