module ApplicationHelper
  def body_class
      controller.controller_path
  end
  def last_sessions_rada
    Division.order(date: :asc).pluck(:date).last.strftime('%d.%m.%Y')
  end
  def last_update_rada
    Division.order(updated_at: :asc).pluck(:updated_at).last.strftime('%d.%m.%Y / %H:%M')
  end
end
