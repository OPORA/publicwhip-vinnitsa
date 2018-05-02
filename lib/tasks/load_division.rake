namespace :load_division do
  desc "Load votes"
  task :votes, [:from_date, :to_date] => :environment do |t, args|
    load_votes = JSON.load(open('http://vinnitsavoted.oporaua.org/votes_events'))
    save_votes = Division.pluck(:date).uniq.to_a.map{|d| d.strftime('%Y-%m-%d')}
    date_votes = load_votes - save_votes
    date_votes.each do |date|
      divisions = JSON.load(open("http://vinnitsavoted.oporaua.org/votes_events/#{date}"))
      divisions.each do |d|
        division = Division.find_or_create_by(
            date: DateTime.parse(d[0]["date_vote"]).strftime("%F"),
            number: d[0]["number"],
            name: d[0]["name"],
            clock_time: DateTime.parse(d[0]["date_vote"]).strftime("%T"),
            result: d[0]["option"]
        )
        division.votes.destroy_all
        d[1]["votes"].each do |v|
          division.votes.create(deputy_id: v["voter_id"], vote: v["result"] )
        end
      end
    end
  end
end
