module DossiersHelper
  def school_years_in_range(start_date, end_date)
    start_year = start_date.month >= 9 ? start_date.year : start_date.year - 1
    end_year   = end_date.month >= 9 ? end_date.year : end_date.year - 1

    (start_year..end_year).map { |y| "#{y}/#{y + 1}" }
  end
end
