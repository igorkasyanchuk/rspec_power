class Account
  def self.endpoint
    ENV["API_URL"]
  end

  def self.current_date
    Date.today
  end

  def self.current_time
    Time.now
  end
end
