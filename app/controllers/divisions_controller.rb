class DivisionsController < ApplicationController
  def index
    @divisions = division()
    respond_to do |format|
      format.html
      format.js
    end
  end
  def page
    @divisions_page = division()

    respond_to do |format|
      format.js
    end
  end
  def division
    if params[:per].nil?
      params[:per] = 5
    end
    divisions = Division.includes(:division_info)
    unless params[:divisions].blank?
      divisions = divisions.find_by_search_query(params[:divisions])
      if params[:sort].blank?
        params[:sort] = "attendance"
      end
    end
    @divisions =
        case params[:sort]
          when "attendance"
            if params[:filter_min].nil?
              params[:filter_min] = 30
            end
            if params[:filter_max].nil?
              params[:filter_max] = 90
            end
            divi = divisions.to_a.find_all{|m| m.division_info.attendance_division.to_f >= params[:filter_min].to_f/100 and m.division_info.attendance_division.to_f <= params[:filter_max].to_f/100 }.sort_by{ |m| [-(m.division_info.attendance_division || -1), m.date, m.number ]}
            Kaminari.paginate_array(divi).page(params[:page]).per(params[:per])
          when "rebellions"
            if params[:filter_min].nil?
              params[:filter_min] = 20
            end
            if params[:filter_max].nil?
              params[:filter_max] = 90
            end
            divi =divisions.to_a.find_all{|m| m.division_info.rebellions_fraction.to_f >= params[:filter_min].to_f/100 and m.division_info.rebellions_fraction.to_f <= params[:filter_max].to_f/100 }.sort_by{ |m| [-(m.division_info.rebellions_fraction || -1), m.date, m.number ]}
            Kaminari.paginate_array(divi).page(params[:page]).per(params[:per])
          else
            if (params[:min_date].nil? or params[:min_date].blank? or params[:max_date].nil? or params[:max_date].blank?) and (params[:last].nil? or params[:last].blank?)
              params[:last] = "3"
            end
            if params[:last] == "3"
              params[:min_date] = (Date.today() - 3.month).strftime('%d.%m.%Y')
              params[:max_date] = Date.today().strftime('%d.%m.%Y')
            elsif params[:last] == "1"
              min_date = Date.strptime((Division.order(date: :asc).pluck(:date).last.strftime('%m.%Y')), '%m.%Y')
              params[:min_date] = min_date.strftime('%d.%m.%Y')
              params[:max_date] = (min_date + 1.month - 1.day).strftime('%d.%m.%Y')
            end
            divisions.where("date >= ? AND date <= ?", Date.strptime(params[:min_date], '%d.%m.%Y'), Date.strptime(params[:max_date], '%d.%m.%Y')).order(date: :desc, number: :desc).page(params[:page]).per(params[:per])
        end
  end
  def show
    @divisions = Division.includes(:division_info).where(date: params[:date], number: params[:id])
    @whips = Whip.where(division_id: @divisions.first.id).order(:party)
    vote = Vote.includes(:mp, :division).where(division_id: @divisions.first.id).order('mps.faction')
    @voted = vote.to_a.map{|v| {name: v.mp.full_name, url: v.mp.url_name,  vote: v.vote, party: v.mp.faction } }.group_by{|f| f[:party]}
    respond_to do |format|
      format.html
      format.csv { send_data vote.to_div_csv , :filename =>  vote.first.division.name + '.csv' }
    end
  end
end
